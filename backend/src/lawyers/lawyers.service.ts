import { Injectable, NotFoundException } from '@nestjs/common';
import type { LawyerProfile } from '@prisma/client';
import { ApiErrorCode } from '../common/errors/api-error-codes';
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

  async findById(id: string) {
    const row = await this.prisma.lawyerProfile.findUnique({
      where: { id },
      include: PROFILE_INCLUDE,
    });
    if (!row) {
      throw this.notFound();
    }
    return this.toView(row);
  }

  async findReviews(lawyerProfileId: string, query: QueryReviewsDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;

    const exists = await this.prisma.lawyerProfile.findUnique({
      where: { id: lawyerProfileId },
      select: { id: true },
    });
    if (!exists) {
      throw this.notFound();
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

  private notFound(): NotFoundException {
    return new NotFoundException({
      message: 'Lawyer not found.',
      code: ApiErrorCode.NOT_FOUND,
    });
  }
}
