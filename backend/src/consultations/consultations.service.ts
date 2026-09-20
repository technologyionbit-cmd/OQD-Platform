import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { Consultation, ConsultationStatus } from '@prisma/client';
import { ApiErrorCode } from '../common/errors/api-error-codes';
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
  constructor(private readonly prisma: PrismaService) {}

  // ---------------------------------------------------------------------------
  // Availability
  // ---------------------------------------------------------------------------

  async getAvailability(lawyerProfileId: string) {
    const exists = await this.prisma.lawyerProfile.findUnique({
      where: { id: lawyerProfileId },
      select: { id: true },
    });
    if (!exists) throw this.notFoundLawyer();

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
    const profile = await this.lawyerProfileForUser(user);
    const start = new Date(dto.start);
    const end = new Date(dto.end);
    if (!(start < end)) {
      throw new BadRequestException({
        message: 'Slot start must be before end.',
        code: ApiErrorCode.BAD_REQUEST,
      });
    }
    return this.prisma.availabilitySlot.create({
      data: { lawyerProfileId: profile.id, startAt: start, endAt: end },
    });
  }

  async removeAvailabilitySlot(user: AuthenticatedUser, slotId: string) {
    const profile = await this.lawyerProfileForUser(user);
    const slot = await this.prisma.availabilitySlot.findUnique({ where: { id: slotId } });
    if (!slot || slot.lawyerProfileId !== profile.id) {
      throw new NotFoundException({ message: 'Slot not found.', code: ApiErrorCode.NOT_FOUND });
    }
    if (slot.isBooked) {
      throw new ConflictException({
        message: 'Cannot remove a booked slot — cancel the consultation instead.',
        code: ApiErrorCode.CONFLICT,
      });
    }
    await this.prisma.availabilitySlot.delete({ where: { id: slotId } });
  }

  // ---------------------------------------------------------------------------
  // Booking
  // ---------------------------------------------------------------------------

  async book(user: AuthenticatedUser, dto: CreateConsultationDto): Promise<Consultation> {
    if (user.role !== 'client') {
      throw this.forbidden('Only individual (client) accounts can book consultations.');
    }

    const client = await this.prisma.user.findUniqueOrThrow({ where: { id: user.id } });
    const lawyerProfile = await this.prisma.lawyerProfile.findUnique({
      where: { id: dto.lawyerId },
    });
    if (!lawyerProfile || lawyerProfile.verificationStatus !== 'verified') {
      throw this.notFoundLawyer();
    }

    const offering = await this.prisma.lawyerConsultationOffering.findUnique({
      where: { lawyerProfileId_consultationType: { lawyerProfileId: lawyerProfile.id, consultationType: dto.type } },
    });
    if (!offering || !offering.isActive) {
      throw new BadRequestException({
        message: 'This lawyer does not offer that consultation type.',
        code: ApiErrorCode.BAD_REQUEST,
      });
    }

    const scheduledAt = new Date(dto.scheduledAt);
    const slot = await this.prisma.availabilitySlot.findFirst({
      where: { lawyerProfileId: lawyerProfile.id, startAt: scheduledAt },
    });
    if (!slot) {
      throw new NotFoundException({ message: 'Slot not found.', code: ApiErrorCode.NOT_FOUND });
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
        throw new ConflictException({
          message: 'This slot was just booked by someone else.',
          code: ApiErrorCode.CONFLICT,
        });
      }

      return tx.consultation.create({
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
    });
  }

  // ---------------------------------------------------------------------------
  // List / detail
  // ---------------------------------------------------------------------------

  async list(user: AuthenticatedUser): Promise<Consultation[]> {
    const where =
      user.role === 'lawyer'
        ? { lawyerProfileId: (await this.lawyerProfileForUser(user)).id }
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
    const profile = await this.lawyerProfileForUser(user);
    const consultation = await this.consultationOwnedByLawyer(profile.id, id);
    this.assertTransition(consultation.status, 'confirmed');
    return this.prisma.consultation.update({ where: { id }, data: { status: 'confirmed' } });
  }

  async decline(user: AuthenticatedUser, id: string, reason?: string): Promise<Consultation> {
    const profile = await this.lawyerProfileForUser(user);
    const consultation = await this.consultationOwnedByLawyer(profile.id, id);
    this.assertTransition(consultation.status, 'declined');
    return this.transitionAndFreeSlot(consultation, 'declined', reason);
  }

  async cancel(user: AuthenticatedUser, id: string, reason?: string): Promise<Consultation> {
    const consultation = await this.consultationForParticipant(user, id);
    this.assertTransition(consultation.status, 'cancelled');
    return this.transitionAndFreeSlot(consultation, 'cancelled', reason);
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
    return this.prisma.consultation.update({ where: { id }, data: { status: 'completed' } });
  }

  async markMissed(user: AuthenticatedUser, id: string): Promise<Consultation> {
    const consultation = await this.consultationForParticipant(user, id);
    this.assertTransition(consultation.status, 'missed');
    return this.prisma.consultation.update({ where: { id }, data: { status: 'missed' } });
  }

  async markFailed(user: AuthenticatedUser, id: string): Promise<Consultation> {
    const consultation = await this.consultationForParticipant(user, id);
    this.assertTransition(consultation.status, 'failed');
    return this.prisma.consultation.update({ where: { id }, data: { status: 'failed' } });
  }

  async reschedule(user: AuthenticatedUser, id: string, dto: RescheduleConsultationDto): Promise<Consultation> {
    if (user.role !== 'client') {
      throw this.forbidden('Only the client can reschedule a consultation.');
    }
    const consultation = await this.consultationForParticipant(user, id);
    if (consultation.status !== 'confirmed') {
      throw new BadRequestException({
        message: `Cannot reschedule a consultation in status "${consultation.status}".`,
        code: ApiErrorCode.BAD_REQUEST,
      });
    }

    const newScheduledAt = new Date(dto.scheduledAt);
    const newSlot = await this.prisma.availabilitySlot.findFirst({
      where: { lawyerProfileId: consultation.lawyerProfileId, startAt: newScheduledAt },
    });
    if (!newSlot) {
      throw new NotFoundException({ message: 'Slot not found.', code: ApiErrorCode.NOT_FOUND });
    }

    return this.prisma.$transaction(async (tx) => {
      const claimed = await tx.availabilitySlot.updateMany({
        where: { id: newSlot.id, isBooked: false },
        data: { isBooked: true },
      });
      if (claimed.count === 0) {
        throw new ConflictException({
          message: 'This slot was just booked by someone else.',
          code: ApiErrorCode.CONFLICT,
        });
      }
      await tx.availabilitySlot.update({
        where: { id: consultation.availabilitySlotId },
        data: { isBooked: false },
      });
      return tx.consultation.update({
        where: { id },
        data: { availabilitySlotId: newSlot.id, scheduledAt: newScheduledAt },
      });
    });
  }

  // ---------------------------------------------------------------------------
  // Reviews
  // ---------------------------------------------------------------------------

  async createReview(user: AuthenticatedUser, consultationId: string, dto: CreateReviewDto) {
    if (user.role !== 'client') {
      throw this.forbidden('Only the client can review a consultation.');
    }
    const consultation = await this.consultationForParticipant(user, consultationId);
    if (consultation.status !== 'completed') {
      throw new BadRequestException({
        message: 'Only a completed consultation can be reviewed.',
        code: ApiErrorCode.BAD_REQUEST,
      });
    }

    const existing = await this.prisma.review.findUnique({
      where: { consultationId_reviewerUserId: { consultationId, reviewerUserId: user.id } },
    });
    if (existing) {
      throw new ConflictException({
        message: 'You already reviewed this consultation.',
        code: ApiErrorCode.CONFLICT,
      });
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

  private async lawyerProfileForUser(user: AuthenticatedUser) {
    if (user.role !== 'lawyer') {
      throw this.forbidden('Only lawyer accounts can manage availability.');
    }
    const profile = await this.prisma.lawyerProfile.findUnique({ where: { userId: user.id } });
    if (!profile) {
      throw this.notFoundLawyer();
    }
    return profile;
  }

  private async consultationForParticipant(user: AuthenticatedUser, id: string): Promise<Consultation> {
    const consultation = await this.prisma.consultation.findUnique({ where: { id } });
    if (!consultation) {
      throw this.notFoundConsultation();
    }
    const isClient = consultation.clientUserId === user.id;
    const isLawyer =
      user.role === 'lawyer' && (await this.prisma.lawyerProfile.findUnique({ where: { userId: user.id } }))?.id === consultation.lawyerProfileId;
    if (!isClient && !isLawyer) {
      throw this.forbidden('You are not a participant in this consultation.');
    }
    return consultation;
  }

  private async consultationOwnedByLawyer(lawyerProfileId: string, id: string): Promise<Consultation> {
    const consultation = await this.prisma.consultation.findUnique({ where: { id } });
    if (!consultation || consultation.lawyerProfileId !== lawyerProfileId) {
      throw this.notFoundConsultation();
    }
    return consultation;
  }

  private async transitionAndFreeSlot(
    consultation: Consultation,
    status: ConsultationStatus,
    cancellationReason?: string,
  ): Promise<Consultation> {
    return this.prisma.$transaction(async (tx) => {
      await tx.availabilitySlot.update({
        where: { id: consultation.availabilitySlotId },
        data: { isBooked: false },
      });
      return tx.consultation.update({
        where: { id: consultation.id },
        data: { status, ...(cancellationReason ? { cancellationReason } : {}) },
      });
    });
  }

  private assertTransition(from: ConsultationStatus, to: ConsultationStatus): void {
    if (!ALLOWED_TRANSITIONS[from]?.includes(to)) {
      throw new BadRequestException({
        message: `Invalid consultation status transition: ${from} -> ${to}`,
        code: ApiErrorCode.BAD_REQUEST,
      });
    }
  }

  private notFoundLawyer(): NotFoundException {
    return new NotFoundException({ message: 'Lawyer not found.', code: ApiErrorCode.NOT_FOUND });
  }

  private notFoundConsultation(): NotFoundException {
    return new NotFoundException({ message: 'Consultation not found.', code: ApiErrorCode.NOT_FOUND });
  }

  private forbidden(message: string): ForbiddenException {
    return new ForbiddenException({ message, code: ApiErrorCode.FORBIDDEN });
  }
}
