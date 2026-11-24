import { Injectable } from '@nestjs/common';
import { ConsultationType, type Prisma } from '@prisma/client';
import {
  conflict,
  notFound,
  validationFailed,
} from '../../common/errors/api-exceptions';
import {
  pageArgs,
  paginated,
  pickSort,
} from '../../common/pagination/page-query.dto';
import { NotificationsService } from '../../notifications/notifications.service';
import { PrismaService } from '../../prisma/prisma.service';
import {
  LAWYER_SORT_FIELDS,
  type QueryAdminLawyersDto,
  type UpdateAdminLawyerDto,
} from './dto/admin-lawyers.dto';

/** Same ceiling the lawyer sees when pricing their own consultations. */
const MAX_PRICE = 100_000;

@Injectable()
export class AdminLawyersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
  ) {}

  async list(query: QueryAdminLawyersDto) {
    const where = this.where(query);
    const field = pickSort(query.sort, LAWYER_SORT_FIELDS, 'createdAt');
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.lawyerProfile.findMany({
        where,
        orderBy: [{ [field]: query.order }, { id: 'asc' }],
        ...pageArgs(query),
        select: {
          id: true,
          fullName: true,
          barLicenseNumber: true,
          yearsOfExperience: true,
          rating: true,
          reviewsCount: true,
          verificationStatus: true,
          verificationRejectionReason: true,
          createdAt: true,
          user: {
            select: { id: true, email: true, phone: true, status: true },
          },
          specialties: { select: { specialty: true } },
          _count: { select: { consultations: true } },
        },
      }),
      this.prisma.lawyerProfile.count({ where }),
    ]);

    return paginated(
      rows.map(({ specialties, _count, rating, user, ...row }) => ({
        ...row,
        rating: Number(rating),
        userId: user.id,
        email: user.email,
        phone: user.phone,
        accountStatus: user.status,
        specialties: specialties.map((s) => s.specialty),
        consultationsCount: _count.consultations,
      })),
      total,
      query,
    );
  }

  /** Everything the admin may need on one lawyer, reviews included. */
  async detail(id: string) {
    const row = await this.prisma.lawyerProfile.findUnique({
      where: { id },
      include: {
        user: {
          select: { id: true, email: true, phone: true, status: true },
        },
        specialties: true,
        offerings: true,
        reviews: {
          orderBy: { createdAt: 'desc' },
          take: 50,
          include: { reviewer: { select: { fullName: true } } },
        },
        _count: { select: { consultations: true } },
      },
    });
    if (!row) throw notFound('Lawyer not found.');
    return {
      id: row.id,
      userId: row.user.id,
      fullName: row.fullName,
      email: row.user.email,
      phone: row.user.phone,
      accountStatus: row.user.status,
      barLicenseNumber: row.barLicenseNumber,
      bio: row.bio,
      yearsOfExperience: row.yearsOfExperience,
      rating: Number(row.rating),
      reviewsCount: row.reviewsCount,
      verificationStatus: row.verificationStatus,
      rejectionReason: row.verificationRejectionReason,
      consultationsCount: row._count.consultations,
      specialties: row.specialties.map((s) => s.specialty),
      pricing: Object.fromEntries(
        row.offerings
          .filter((o) => o.isActive)
          .map((o) => [o.consultationType, Number(o.price)]),
      ),
      reviews: row.reviews.map((r) => ({
        id: r.id,
        rating: r.rating,
        comment: r.comment,
        reviewer: r.reviewer.fullName,
        createdAt: r.createdAt,
      })),
    };
  }

  /** Edits the public profile the way the lawyer would (same rules). */
  async update(id: string, dto: UpdateAdminLawyerDto) {
    const before = await this.detail(id);
    const pricing = this.checkPricing(dto.pricing);
    await this.prisma.$transaction(async (tx) => {
      await tx.lawyerProfile.update({
        where: { id },
        data: { bio: dto.bio, yearsOfExperience: dto.yearsOfExperience },
      });
      await tx.lawyerProfileSpecialty.deleteMany({
        where: { lawyerProfileId: id },
      });
      await tx.lawyerProfileSpecialty.createMany({
        data: dto.specialties.map((specialty) => ({
          lawyerProfileId: id,
          specialty,
        })),
      });
      await tx.lawyerConsultationOffering.updateMany({
        where: {
          lawyerProfileId: id,
          consultationType: { notIn: pricing.map(([type]) => type) },
        },
        data: { isActive: false },
      });
      for (const [consultationType, price] of pricing) {
        await tx.lawyerConsultationOffering.upsert({
          where: {
            lawyerProfileId_consultationType: {
              lawyerProfileId: id,
              consultationType,
            },
          },
          create: { lawyerProfileId: id, consultationType, price, isActive: true },
          update: { price, isActive: true },
        });
      }
    });
    return { before, after: await this.detail(id) };
  }

  /** Deletes one review and recomputes the lawyer's rating from the rest. */
  async removeReview(lawyerProfileId: string, reviewId: string) {
    const review = await this.prisma.review.findFirst({
      where: { id: reviewId, lawyerProfileId },
      select: { id: true, rating: true, comment: true },
    });
    if (!review) throw notFound('Review not found.');
    await this.prisma.$transaction(async (tx) => {
      await tx.review.delete({ where: { id: reviewId } });
      const agg = await tx.review.aggregate({
        where: { lawyerProfileId },
        _avg: { rating: true },
        _count: true,
      });
      await tx.lawyerProfile.update({
        where: { id: lawyerProfileId },
        data: { rating: agg._avg.rating ?? 0, reviewsCount: agg._count },
      });
    });
    return review;
  }

  /** Takes verification away from a verified lawyer; they are told why. */
  async revokeVerification(adminId: string, id: string, reason: string) {
    const profile = await this.prisma.lawyerProfile.findUnique({
      where: { id },
      select: { userId: true, verificationStatus: true },
    });
    if (!profile) throw notFound('Lawyer not found.');
    if (profile.verificationStatus !== 'verified') {
      throw conflict('Only a verified lawyer can have verification revoked.');
    }
    await this.prisma.$transaction(async (tx) => {
      const moved = await tx.lawyerProfile.updateMany({
        where: { id, verificationStatus: 'verified' },
        data: {
          verificationStatus: 'rejected',
          verificationRejectionReason: reason,
          verificationReviewedById: adminId,
          verificationReviewedAt: new Date(),
        },
      });
      if (moved.count === 0) throw conflict('The status just changed. Refresh.');
      await this.notifications.notify(tx, {
        userId: profile.userId,
        type: 'lawyerVerificationRejected',
        params: { reason },
      });
    });
    return {
      before: { verificationStatus: 'verified' },
      after: { verificationStatus: 'rejected' },
    };
  }

  private checkPricing(raw: Record<string, unknown>): [ConsultationType, number][] {
    const errors: string[] = [];
    const entries: [ConsultationType, number][] = [];
    for (const [key, value] of Object.entries(raw)) {
      if (!(Object.values(ConsultationType) as string[]).includes(key)) {
        errors.push(`Unknown consultation type "${key}".`);
      } else if (
        typeof value !== 'number' ||
        !Number.isFinite(value) ||
        value <= 0 ||
        value > MAX_PRICE
      ) {
        errors.push(`The ${key} price must be above 0 and at most ${MAX_PRICE}.`);
      } else {
        entries.push([key as ConsultationType, Math.round(value * 100) / 100]);
      }
    }
    if (entries.length === 0 && errors.length === 0) {
      errors.push('Offer at least one consultation type.');
    }
    if (errors.length > 0) throw validationFailed({ pricing: errors });
    return entries;
  }

  private where(query: QueryAdminLawyersDto): Prisma.LawyerProfileWhereInput {
    const search = query.q?.trim();
    return {
      user: { deletedAt: null },
      ...(query.verification && { verificationStatus: query.verification }),
      ...(search && {
        OR: [
          { fullName: { contains: search, mode: 'insensitive' } },
          { barLicenseNumber: { contains: search, mode: 'insensitive' } },
          { user: { email: { contains: search, mode: 'insensitive' } } },
          {
            user: {
              phone: {
                contains:
                  search.replace(/[^\d]/g, '').replace(/^(962|0)/, '') || search,
              },
            },
          },
        ],
      }),
    };
  }
}
