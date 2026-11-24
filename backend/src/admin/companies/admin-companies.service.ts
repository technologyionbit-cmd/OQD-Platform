import { Injectable } from '@nestjs/common';
import type { OrganizationVerificationStatus, Prisma } from '@prisma/client';
import { conflict, notFound } from '../../common/errors/api-exceptions';
import {
  pageArgs,
  paginated,
  pickSort,
} from '../../common/pagination/page-query.dto';
import { PrismaService } from '../../prisma/prisma.service';
import {
  COMPANY_SORT_FIELDS,
  type QueryAdminCompaniesDto,
} from './dto/admin-companies.dto';

const SELECT = {
  id: true,
  name: true,
  commercialRegistrationNumber: true,
  verificationStatus: true,
  createdAt: true,
  owner: { select: { id: true, fullName: true, email: true, phone: true } },
  _count: { select: { members: true } },
} satisfies Prisma.OrganizationSelect;

type Row = Prisma.OrganizationGetPayload<{ select: typeof SELECT }>;

function present({ owner, _count, ...row }: Row) {
  return {
    ...row,
    owner,
    membersCount: _count.members,
  };
}

/** States a verification decision may start from. */
const DECIDABLE: OrganizationVerificationStatus[] = ['unverified', 'pending'];

@Injectable()
export class AdminCompaniesService {
  constructor(private readonly prisma: PrismaService) {}

  async list(query: QueryAdminCompaniesDto) {
    const where = this.where(query);
    const field = pickSort(query.sort, COMPANY_SORT_FIELDS, 'createdAt');
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.organization.findMany({
        where,
        select: SELECT,
        orderBy: [{ [field]: query.order }, { id: 'asc' }],
        ...pageArgs(query),
      }),
      this.prisma.organization.count({ where }),
    ]);
    return paginated(rows.map(present), total, query);
  }

  /** Verify or reject; returns the state before and after, for the audit row. */
  async decide(id: string, to: 'verified' | 'rejected') {
    const org = await this.prisma.organization.findUnique({
      where: { id },
      select: SELECT,
    });
    if (!org) throw notFound('Company not found.');
    if (!DECIDABLE.includes(org.verificationStatus)) {
      throw conflict(`This company is already ${org.verificationStatus}.`);
    }
    const updated = await this.prisma.organization.update({
      where: { id },
      data: { verificationStatus: to },
      select: SELECT,
    });
    return {
      before: { verificationStatus: org.verificationStatus },
      after: { verificationStatus: updated.verificationStatus },
      company: present(updated),
    };
  }

  private where(query: QueryAdminCompaniesDto): Prisma.OrganizationWhereInput {
    const search = query.q?.trim();
    return {
      ...(query.verification && { verificationStatus: query.verification }),
      ...(search && {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          {
            commercialRegistrationNumber: {
              contains: search,
              mode: 'insensitive',
            },
          },
          { owner: { fullName: { contains: search, mode: 'insensitive' } } },
          { owner: { email: { contains: search, mode: 'insensitive' } } },
        ],
      }),
    };
  }
}
