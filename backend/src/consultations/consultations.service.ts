import { Injectable } from '@nestjs/common';
import type { Consultation, ConsultationStatus, NotificationType, Prisma } from '@prisma/client';
import { badRequest, conflict, forbidden, notFound } from '../common/errors/api-exceptions';
import { LawyersService } from '../lawyers/lawyers.service';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { CreateAvailabilitySlotDto } from './dto/create-availability-slot.dto';
import type { CreateConsultationDto } from './dto/create-consultation.dto';
import type { CreateReviewDto } from './dto/create-review.dto';
import type { RescheduleConsultationDto } from './dto/reschedule-consultation.dto';

/** Forward transitions this service will actually perform (see the
 * `ConsultationStatus` doc comment in schema.prisma for why live-session
 * states aren't here — Part 5's concern). */
const ALLOWED_TRANSITIONS: Record<ConsultationStatus, ConsultationStatus[]> = {
  pendingApproval: ['confirmed', 'declined', 'cancelled'],
  confirmed: ['completed', 'cancelled', 'missed', 'failed'],
  completed: [],
  cancelled: [],
  declined: [],
  missed: [],
  failed: [],
};

@Injectable()
export class ConsultationsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
    private readonly lawyers: LawyersService,
  ) {}

  // ---------------------------------------------------------------------------
  // Availability
  // ---------------------------------------------------------------------------

  async getAvailability(lawyerProfileId: string) {
    const exists = await this.prisma.lawyerProfile.findUnique({
      where: { id: lawyerProfileId },
      select: { id: true },
    });
    if (!exists) throw notFound('Lawyer not found.');

    return this.prisma.availabilitySlot.findMany({
      where: { lawyerProfileId },
      // `consultation` (the reverse 1:1) is included so callers can link a
      // booked slot back to the consultation it belongs to — mirrors the
      // frontend `AvailabilitySlot.consultationId` field.
      include: { consultation: { select: { id: true } } },
      orderBy: { startAt: 'asc' },
    });
  }

  async addAvailabilitySlot(user: AuthenticatedUser, dto: CreateAvailabilitySlotDto) {
    const profile = await this.lawyers.profileForLawyer(user);
    const start = new Date(dto.start);
    const end = new Date(dto.end);
    if (!(start < end)) {
      throw badRequest('Slot start must be before end.');
    }
    return this.prisma.availabilitySlot.create({
      data: { lawyerProfileId: profile.id, startAt: start, endAt: end },
    });
  }

  async removeAvailabilitySlot(user: AuthenticatedUser, slotId: string) {
    const profile = await this.lawyers.profileForLawyer(user);
    const slot = await this.prisma.availabilitySlot.findUnique({ where: { id: slotId } });
    if (!slot || slot.lawyerProfileId !== profile.id) {
      throw notFound('Slot not found.');
    }
    if (slot.isBooked) {
      throw conflict('Cannot remove a booked slot — cancel the consultation instead.');
    }
    await this.prisma.availabilitySlot.delete({ where: { id: slotId } });
  }

  // ---------------------------------------------------------------------------
  // Booking
  // ---------------------------------------------------------------------------

  async book(user: AuthenticatedUser, dto: CreateConsultationDto): Promise<Consultation> {
    if (user.role !== 'client') {
      throw forbidden('Only individual (client) accounts can book consultations.');
    }

    const client = await this.prisma.user.findUniqueOrThrow({ where: { id: user.id } });
    const lawyerProfile = await this.prisma.lawyerProfile.findUnique({
      where: { id: dto.lawyerId },
    });
    if (!lawyerProfile || lawyerProfile.verificationStatus !== 'verified') {
      throw notFound('Lawyer not found.');
    }

    const offering = await this.prisma.lawyerConsultationOffering.findUnique({
      where: { lawyerProfileId_consultationType: { lawyerProfileId: lawyerProfile.id, consultationType: dto.type } },
    });
    if (!offering || !offering.isActive) {
      throw badRequest('This lawyer does not offer that consultation type.');
    }

    const scheduledAt = new Date(dto.scheduledAt);
    const slot = await this.prisma.availabilitySlot.findFirst({
      where: { lawyerProfileId: lawyerProfile.id, startAt: scheduledAt },
    });
    if (!slot) {
      throw notFound('Slot not found.');
    }

    return this.prisma.$transaction(async (tx) => {
      // Conditional UPDATE — the WHERE clause is re-checked after the row
      // lock is acquired, so under two concurrent bookings of the same
      // slot exactly one of these updates affects a row; the loser sees
      // count 0 and gets a clean 409 instead of a double-booked slot.
      const claimed = await tx.availabilitySlot.updateMany({
        where: { id: slot.id, isBooked: false },
        data: { isBooked: true },
      });
      if (claimed.count === 0) {
        throw conflict('This slot was just booked by someone else.');
      }

      const consultation = await tx.consultation.create({
        data: {
          clientUserId: client.id,
          lawyerProfileId: lawyerProfile.id,
          availabilitySlotId: slot.id,
          lawyerName: lawyerProfile.fullName,
          clientName: client.fullName,
          type: dto.type,
          status: 'pendingApproval',
          scheduledAt,
          price: offering.price,
          notes: dto.notes ?? '',
        },
      });
      await this.notifications.notify(tx, {
        userId: lawyerProfile.userId,
        type: 'consultationRequested',
        relatedId: consultation.id,
        params: { actorName: client.fullName, scheduledAt: scheduledAt.toISOString() },
      });
      return consultation;
    });
  }

  // ---------------------------------------------------------------------------
  // List / detail
  // ---------------------------------------------------------------------------

  async list(user: AuthenticatedUser): Promise<Consultation[]> {
    const where =
      user.role === 'lawyer'
        ? { lawyerProfileId: (await this.lawyers.profileForLawyer(user)).id }
        : { clientUserId: user.id };
    return this.prisma.consultation.findMany({ where, orderBy: { scheduledAt: 'desc' } });
  }

  async getById(user: AuthenticatedUser, id: string): Promise<Consultation> {
    return this.consultationForParticipant(user, id);
  }

  // ---------------------------------------------------------------------------
  // Lifecycle transitions
  // ---------------------------------------------------------------------------

  async accept(user: AuthenticatedUser, id: string): Promise<Consultation> {
    const profile = await this.lawyers.profileForLawyer(user);
    const consultation = await this.consultationOwnedByLawyer(profile.id, id);
    this.assertTransition(consultation.status, 'confirmed');
    return this.prisma.$transaction(async (tx) => {
      const updated = await this.transition(tx, consultation, 'confirmed');
      await this.notifyOtherParty(tx, user, updated, 'consultationAccepted');
      return updated;
    });
  }

  async decline(user: AuthenticatedUser, id: string, reason?: string): Promise<Consultation> {
    const profile = await this.lawyers.profileForLawyer(user);
    const consultation = await this.consultationOwnedByLawyer(profile.id, id);
    this.assertTransition(consultation.status, 'declined');
    return this.transitionAndFreeSlot(user, consultation, 'declined', 'consultationRejected', reason);
  }

  async cancel(user: AuthenticatedUser, id: string, reason?: string): Promise<Consultation> {
    const consultation = await this.consultationForParticipant(user, id);
    this.assertTransition(consultation.status, 'cancelled');
    return this.transitionAndFreeSlot(user, consultation, 'cancelled', 'consultationCancelled', reason);
  }

  // Either participant can report completion — matches `markMissed`/
  // `markFailed` below. Originally lawyer-only (Part 4), but Part 5's
  // voice/video call screens call this from whichever side presses "End
  // Call" first, client included, so restricting it to the lawyer made a
  // client-ended call silently strand its consultation at `confirmed`
  // forever (docs/plans/individual-user-rollout.md Part 5 notes).
  async complete(user: AuthenticatedUser, id: string): Promise<Consultation> {
    const consultation = await this.consultationForParticipant(user, id);
    this.assertTransition(consultation.status, 'completed');
    return this.prisma.$transaction(async (tx) => {
      const updated = await this.transition(tx, consultation, 'completed');
      await this.notifyOtherParty(tx, user, updated, 'consultationCompleted');
      return updated;
    });
  }

  async markMissed(user: AuthenticatedUser, id: string): Promise<Consultation> {
    const consultation = await this.consultationForParticipant(user, id);
    this.assertTransition(consultation.status, 'missed');
    return this.prisma.$transaction((tx) => this.transition(tx, consultation, 'missed'));
  }

  async markFailed(user: AuthenticatedUser, id: string): Promise<Consultation> {
    const consultation = await this.consultationForParticipant(user, id);
    this.assertTransition(consultation.status, 'failed');
    return this.prisma.$transaction((tx) => this.transition(tx, consultation, 'failed'));
  }

  async reschedule(user: AuthenticatedUser, id: string, dto: RescheduleConsultationDto): Promise<Consultation> {
    if (user.role !== 'client') {
      throw forbidden('Only the client can reschedule a consultation.');
    }
    const consultation = await this.consultationForParticipant(user, id);
    if (consultation.status !== 'confirmed') {
      throw badRequest(`Cannot reschedule a consultation in status "${consultation.status}".`);
    }

    const newScheduledAt = new Date(dto.scheduledAt);
    const newSlot = await this.prisma.availabilitySlot.findFirst({
      where: { lawyerProfileId: consultation.lawyerProfileId, startAt: newScheduledAt },
    });
    if (!newSlot) {
      throw notFound('Slot not found.');
    }

    return this.prisma.$transaction(async (tx) => {
      const claimed = await tx.availabilitySlot.updateMany({
        where: { id: newSlot.id, isBooked: false },
        data: { isBooked: true },
      });
      if (claimed.count === 0) {
        throw conflict('This slot was just booked by someone else.');
      }
      await tx.availabilitySlot.update({
        where: { id: consultation.availabilitySlotId },
        data: { isBooked: false },
      });
      const updated = await tx.consultation.update({
        where: { id },
        data: { availabilitySlotId: newSlot.id, scheduledAt: newScheduledAt },
      });
      await this.notifyOtherParty(tx, user, updated, 'consultationRescheduled');
      return updated;
    });
  }

  // ---------------------------------------------------------------------------
  // Reviews
  // ---------------------------------------------------------------------------

  async createReview(user: AuthenticatedUser, consultationId: string, dto: CreateReviewDto) {
    if (user.role !== 'client') {
      throw forbidden('Only the client can review a consultation.');
    }
    const consultation = await this.consultationForParticipant(user, consultationId);
    if (consultation.status !== 'completed') {
      throw badRequest('Only a completed consultation can be reviewed.');
    }

    const existing = await this.prisma.review.findUnique({
      where: { consultationId_reviewerUserId: { consultationId, reviewerUserId: user.id } },
    });
    if (existing) {
      throw conflict('You already reviewed this consultation.');
    }

    return this.prisma.$transaction(async (tx) => {
      const review = await tx.review.create({
        data: {
          lawyerProfileId: consultation.lawyerProfileId,
          consultationId,
          reviewerUserId: user.id,
          rating: dto.rating,
          comment: dto.comment,
        },
      });

      const agg = await tx.review.aggregate({
        where: { lawyerProfileId: consultation.lawyerProfileId },
        _avg: { rating: true },
        _count: true,
      });
      await tx.lawyerProfile.update({
        where: { id: consultation.lawyerProfileId },
        data: { rating: agg._avg.rating ?? 0, reviewsCount: agg._count },
      });

      return review;
    });
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  private async consultationForParticipant(user: AuthenticatedUser, id: string): Promise<Consultation> {
    const consultation = await this.prisma.consultation.findUnique({ where: { id } });
    if (!consultation) {
      throw notFound('Consultation not found.');
    }
    const isClient = consultation.clientUserId === user.id;
    const isLawyer =
      user.role === 'lawyer' && (await this.lawyers.profileForLawyer(user)).id === consultation.lawyerProfileId;
    if (!isClient && !isLawyer) {
      throw forbidden('You are not a participant in this consultation.');
    }
    return consultation;
  }

  private async consultationOwnedByLawyer(lawyerProfileId: string, id: string): Promise<Consultation> {
    const consultation = await this.prisma.consultation.findUnique({ where: { id } });
    if (!consultation || consultation.lawyerProfileId !== lawyerProfileId) {
      throw notFound('Consultation not found.');
    }
    return consultation;
  }

  private async transitionAndFreeSlot(
    actor: AuthenticatedUser,
    consultation: Consultation,
    status: ConsultationStatus,
    notificationType: NotificationType,
    cancellationReason?: string,
  ): Promise<Consultation> {
    return this.prisma.$transaction(async (tx) => {
      const updated = await this.transition(
        tx,
        consultation,
        status,
        cancellationReason ? { cancellationReason } : {},
      );
      await tx.availabilitySlot.update({
        where: { id: consultation.availabilitySlotId },
        data: { isBooked: false },
      });
      await this.notifyOtherParty(tx, actor, updated, notificationType);
      return updated;
    });
  }

  /**
   * Moves [consultation] to [to] only if its status is still the one the
   * caller checked. Two concurrent requests (accept + cancel, a double
   * tap) cannot both win: the loser gets a 409 and sends no notification.
   */
  private async transition(
    tx: Prisma.TransactionClient,
    consultation: Consultation,
    to: ConsultationStatus,
    data: Prisma.ConsultationUpdateManyMutationInput = {},
  ): Promise<Consultation> {
    const moved = await tx.consultation.updateMany({
      where: { id: consultation.id, status: consultation.status },
      data: { ...data, status: to },
    });
    if (moved.count === 0) {
      throw conflict('This consultation was just changed. Refresh and try again.');
    }
    return tx.consultation.findUniqueOrThrow({ where: { id: consultation.id } });
  }

  /** Tells the participant who did not act what [actor] just did. */
  private async notifyOtherParty(
    tx: Prisma.TransactionClient,
    actor: AuthenticatedUser,
    consultation: Consultation,
    type: NotificationType,
  ): Promise<void> {
    const actorIsClient = actor.id === consultation.clientUserId;
    const recipientUserId = actorIsClient
      ? (
          await tx.lawyerProfile.findUniqueOrThrow({
            where: { id: consultation.lawyerProfileId },
            select: { userId: true },
          })
        ).userId
      : consultation.clientUserId;
    await this.notifications.notify(tx, {
      userId: recipientUserId,
      type,
      relatedId: consultation.id,
      params: {
        actorName: actorIsClient ? consultation.clientName : consultation.lawyerName,
        scheduledAt: consultation.scheduledAt.toISOString(),
      },
    });
  }

  private assertTransition(from: ConsultationStatus, to: ConsultationStatus): void {
    if (!ALLOWED_TRANSITIONS[from]?.includes(to)) {
      throw badRequest(`Invalid consultation status transition: ${from} -> ${to}`);
    }
  }
}
