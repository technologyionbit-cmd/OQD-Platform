import { Injectable } from '@nestjs/common';
import { ConsultationType, type LawyerProfile } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { UpdateMyProfileDto } from './dto/update-my-profile.dto';

/** Upper bound for one consultation's price, as a sanity check. */
const MAX_PRICE = 100000;
import { forbidden, notFound, validationFailed } from '../common/errors/api-exceptions';
import { PrismaService } from '../prisma/prisma.service';
import type { QueryLawyersDto } from './dto/query-lawyers.dto';
import type { QueryReviewsDto } from './dto/query-reviews.dto';

const PROFILE_INCLUDE = {
  specialties: true,
  offerings: { where: { isActive: true } },
} as const;

type ProfileWithRelations = LawyerProfile & {
  specialties: { specialty: string }[];
  offerings: { consultationType: string; price: unknown }[];
};

@Injectable()
export class LawyersService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(query: QueryLawyersDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 50;

    const where = {
      // docs/backend/09-lawyers-marketplace.md §3 item 4 — unverified
      // lawyers are excluded from public search by default.
      verificationStatus: 'verified' as const,
      ...(query.query
        ? { fullName: { contains: query.query, mode: 'insensitive' as const } }
        : {}),
      ...(query.specialty
        ? { specialties: { some: { specialty: query.specialty } } }
        : {}),
      ...(query.minRating !== undefined ? { rating: { gte: query.minRating } } : {}),
    };

    const [rows, total] = await this.prisma.$transaction([
      this.prisma.lawyerProfile.findMany({
        where,
        include: PROFILE_INCLUDE,
        orderBy: { rating: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.lawyerProfile.count({ where }),
    ]);

    return {
      data: rows.map((row) => this.toView(row)),
      meta: { page, limit, total },
    };
  }

  /** A public profile: only verified lawyers, like the search. */
  async findById(id: string) {
    const row = await this.prisma.lawyerProfile.findUnique({
      where: { id },
      include: PROFILE_INCLUDE,
    });
    if (!row || row.verificationStatus !== 'verified') {
      throw notFound('Lawyer not found.');
    }
    return this.toView(row);
  }

  /** The signed-in lawyer's own profile, whatever its verification state. */
  async findMine(user: AuthenticatedUser) {
    const { id } = await this.profileForLawyer(user);
    const row = await this.prisma.lawyerProfile.findUniqueOrThrow({
      where: { id },
      include: PROFILE_INCLUDE,
    });
    return {
      ...this.toView(row),
      verificationRejectionReason: row.verificationRejectionReason,
    };
  }

  /**
   * Replaces the lawyer's bio, experience, specialties and offerings. A
   * consultation type missing from `pricing` is deactivated, not deleted,
   * so past bookings keep the price they were made at.
   */
  async updateMine(user: AuthenticatedUser, dto: UpdateMyProfileDto) {
    const profile = await this.profileForLawyer(user);
    const pricing = this.checkPricing(dto.pricing);

    await this.prisma.$transaction(async (tx) => {
      await tx.lawyerProfile.update({
        where: { id: profile.id },
        data: { bio: dto.bio, yearsOfExperience: dto.yearsOfExperience },
      });
      await tx.lawyerProfileSpecialty.deleteMany({ where: { lawyerProfileId: profile.id } });
      await tx.lawyerProfileSpecialty.createMany({
        data: dto.specialties.map((specialty) => ({ lawyerProfileId: profile.id, specialty })),
      });
      await tx.lawyerConsultationOffering.updateMany({
        where: { lawyerProfileId: profile.id, consultationType: { notIn: pricing.map(([type]) => type) } },
        data: { isActive: false },
      });
      for (const [consultationType, price] of pricing) {
        await tx.lawyerConsultationOffering.upsert({
          where: { lawyerProfileId_consultationType: { lawyerProfileId: profile.id, consultationType } },
          create: { lawyerProfileId: profile.id, consultationType, price, isActive: true },
          update: { price, isActive: true },
        });
      }
    });
    return this.findMine(user);
  }

  /** The caller's own profile row; 403 for any account that is not a lawyer. */
  async profileForLawyer(user: AuthenticatedUser): Promise<LawyerProfile> {
    if (user.role !== 'lawyer') {
      throw forbidden('Only lawyer accounts have a lawyer profile.');
    }
    const row = await this.prisma.lawyerProfile.findUnique({ where: { userId: user.id } });
    if (!row) {
      throw notFound('Lawyer not found.');
    }
    return row;
  }

  private checkPricing(raw: Record<string, unknown>): [ConsultationType, number][] {
    const errors: string[] = [];
    const entries: [ConsultationType, number][] = [];
    for (const [key, value] of Object.entries(raw)) {
      if (!(Object.values(ConsultationType) as string[]).includes(key)) {
        errors.push(`Unknown consultation type "${key}".`);
      } else if (typeof value !== 'number' || !Number.isFinite(value) || value <= 0 || value > MAX_PRICE) {
        errors.push(`The ${key} price must be a number above 0 and at most ${MAX_PRICE}.`);
      } else {
        entries.push([key as ConsultationType, Math.round(value * 100) / 100]);
      }
    }
    if (entries.length === 0 && errors.length === 0) errors.push('Offer at least one consultation type.');
    if (errors.length > 0) {
      throw validationFailed({ pricing: errors });
    }
    return entries;
  }

  async findReviews(lawyerProfileId: string, query: QueryReviewsDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;

    const exists = await this.prisma.lawyerProfile.findUnique({
      where: { id: lawyerProfileId },
      select: { id: true },
    });
    if (!exists) {
      throw notFound('Lawyer not found.');
    }

    const [rows, total] = await this.prisma.$transaction([
      this.prisma.review.findMany({
        where: { lawyerProfileId },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.review.count({ where: { lawyerProfileId } }),
    ]);

    return {
      data: rows.map((row) => ({
        id: row.id,
        reviewerUserId: row.reviewerUserId,
        rating: row.rating,
        comment: row.comment,
        createdAt: row.createdAt,
      })),
      meta: { page, limit, total },
    };
  }

  // barLicenseNumber is intentionally never included in this mapping
  // (docs/backend/14-security.md §Sensitive data — PII-adjacent, must
  // never appear in list/detail responses).
  private toView(row: ProfileWithRelations) {
    return {
      id: row.id,
      fullName: row.fullName,
      specialties: row.specialties.map((s) => s.specialty),
      bio: row.bio,
      yearsOfExperience: row.yearsOfExperience,
      rating: Number(row.rating),
      reviewsCount: row.reviewsCount,
      consultationTypes: row.offerings.map((o) => o.consultationType),
      pricing: Object.fromEntries(row.offerings.map((o) => [o.consultationType, Number(o.price)])),
      verificationStatus: row.verificationStatus,
    };
  }
}
