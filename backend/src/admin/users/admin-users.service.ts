import { Injectable } from '@nestjs/common';
import { Prisma, type User } from '@prisma/client';
import type { AuthenticatedUser } from '../../auth/auth.types';
import { AuthService } from '../../auth/auth.service';
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
import { PrismaService } from '../../prisma/prisma.service';
import { toCsv } from '../common/csv';
import {
  USER_SORT_FIELDS,
  type UserSortField,
  type BulkAction,
  type BulkUsersDto,
  type QueryUsersDto,
} from './dto/users.dto';

/** One export never exceeds this, so a click cannot dump the whole table. */
export const MAX_EXPORT_ROWS = 10_000;

/** What a list row exposes. Never the password hash. */
const LIST_SELECT = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
  phoneVerifiedAt: true,
  role: true,
  status: true,
  lastLoginAt: true,
  createdAt: true,
  deletedAt: true,
  suspendedAt: true,
} satisfies Prisma.UserSelect;

/** The account state an audit row records before and after a change. */
export interface AccountState {
  status: string;
  suspendedAt: Date | null;
  suspendedReason: string | null;
  deletedAt: Date | null;
}

export interface Change {
  before: AccountState;
  after: AccountState;
}

export interface BulkResult {
  succeeded: string[];
  skipped: { id: string; reason: string }[];
}

const stateOf = (user: User): AccountState => ({
  status: user.status,
  suspendedAt: user.suspendedAt,
  suspendedReason: user.suspendedReason,
  deletedAt: user.deletedAt,
});

@Injectable()
export class AdminUsersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auth: AuthService,
  ) {}

  // ---------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------

  async list(query: QueryUsersDto) {
    const where = this.where(query);
    const field = pickSort(query.sort, USER_SORT_FIELDS, 'createdAt');
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.user.findMany({
        where,
        select: LIST_SELECT,
        orderBy: this.orderBy(field, query.order),
        ...pageArgs(query),
      }),
      this.prisma.user.count({ where }),
    ]);
    return paginated(rows, total, query);
  }

  async detail(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: {
        ...LIST_SELECT,
        termsAcceptedAt: true,
        termsVersion: true,
        twoFactorEnabled: true,
        suspendedReason: true,
        suspendedById: true,
        lawyerProfile: {
          select: {
            id: true,
            verificationStatus: true,
            rating: true,
            reviewsCount: true,
          },
        },
        ownedOrganizations: {
          select: { id: true, name: true, verificationStatus: true },
        },
        _count: {
          select: { bookedConsultations: true, contracts: true },
        },
      },
    });
    if (!user) throw notFound('User not found.');

    const [sessions, suspendedBy] = await Promise.all([
      this.prisma.refreshToken.findMany({
        where: { userId: id, revokedAt: null, expiresAt: { gt: new Date() } },
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          deviceLabel: true,
          ipAddress: true,
          createdAt: true,
          lastUsedAt: true,
        },
      }),
      user.suspendedById
        ? this.prisma.user.findUnique({
            where: { id: user.suspendedById },
            select: { id: true, fullName: true },
          })
        : null,
    ]);
    return { ...user, sessions, suspendedBy };
  }

  /** CSV of the users matching [query] (all pages), capped. */
  async exportCsv(query: QueryUsersDto): Promise<{ csv: string; rows: number }> {
    const field = pickSort(query.sort, USER_SORT_FIELDS, 'createdAt');
    const users = await this.prisma.user.findMany({
      where: this.where(query),
      select: LIST_SELECT,
      orderBy: this.orderBy(field, query.order),
      take: MAX_EXPORT_ROWS,
    });
    const csv = toCsv(
      [
        'id',
        'fullName',
        'email',
        'phone',
        'role',
        'status',
        'phoneVerified',
        'createdAt',
        'lastLoginAt',
        'deletedAt',
      ],
      users.map((u) => [
        u.id,
        u.fullName,
        u.email,
        u.phone,
        u.role,
        u.status,
        u.phoneVerifiedAt !== null,
        u.createdAt,
        u.lastLoginAt,
        u.deletedAt,
      ]),
    );
    return { csv, rows: users.length };
  }

  // ---------------------------------------------------------------------
  // Single-account actions. Each returns the before/after for the audit log.
  // ---------------------------------------------------------------------

  async suspend(
    actor: AuthenticatedUser,
    id: string,
    reason: string,
  ): Promise<Change> {
    const user = await this.manageable(actor, id);
    if (user.deletedAt) throw conflict('This account was removed.');
    if (user.status === 'suspended') {
      throw conflict('This account is already suspended.');
    }
    const updated = await this.prisma.$transaction(async (tx) => {
      const next = await tx.user.update({
        where: { id },
        data: {
          status: 'suspended',
          suspendedAt: new Date(),
          suspendedReason: reason,
          suspendedById: actor.id,
        },
      });
      // Their access tokens die with their sessions, at once.
      await this.revokeSessionsIn(tx, id);
      return next;
    });
    return { before: stateOf(user), after: stateOf(updated) };
  }

  async activate(actor: AuthenticatedUser, id: string): Promise<Change> {
    const user = await this.manageable(actor, id);
    if (user.deletedAt) throw conflict('This account was removed.');
    if (user.status === 'active') {
      throw conflict('This account is already active.');
    }
    if (user.status === 'pendingDeletion') {
      throw conflict('The owner asked to delete this account.');
    }
    const updated = await this.prisma.user.update({
      where: { id },
      data: {
        status: 'active',
        suspendedAt: null,
        suspendedReason: null,
        suspendedById: null,
      },
    });
    return { before: stateOf(user), after: stateOf(updated) };
  }

  /** Signs the account out everywhere. Returns how many sessions ended. */
  async revokeSessions(actor: AuthenticatedUser, id: string): Promise<number> {
    await this.manageable(actor, id);
    return this.revokeSessionsIn(this.prisma, id);
  }

  /**
   * Ends every session and texts the account a password-reset code (the
   * same flow as "forgot password", with its own send limits). The admin
   * never sees or sets the password.
   */
  async resetPassword(actor: AuthenticatedUser, id: string): Promise<void> {
    const user = await this.manageable(actor, id);
    if (user.deletedAt || user.status !== 'active') {
      throw conflict('Only an active account can be sent a reset code.');
    }
    if (!user.phone) {
      throw conflict('This account has no phone number to send a code to.');
    }
    await this.auth.forgotPassword({ phone: user.phone });
    await this.revokeSessionsIn(this.prisma, id);
  }

  /** Soft delete: the row stays, the account stops working. */
  async softDelete(actor: AuthenticatedUser, id: string): Promise<Change> {
    const user = await this.manageable(actor, id);
    if (user.deletedAt) throw conflict('This account was already removed.');
    const updated = await this.prisma.$transaction(async (tx) => {
      const next = await tx.user.update({
        where: { id },
        data: { deletedAt: new Date() },
      });
      await this.revokeSessionsIn(tx, id);
      return next;
    });
    return { before: stateOf(user), after: stateOf(updated) };
  }

  async restore(actor: AuthenticatedUser, id: string): Promise<Change> {
    const user = await this.manageable(actor, id);
    if (!user.deletedAt) throw conflict('This account is not removed.');
    const updated = await this.prisma.user.update({
      where: { id },
      data: { deletedAt: null },
    });
    return { before: stateOf(user), after: stateOf(updated) };
  }

  // ---------------------------------------------------------------------
  // Bulk
  // ---------------------------------------------------------------------

  /** Applies one action to many accounts; each one succeeds or is skipped
   *  with a reason, so one bad row never blocks the rest. */
  async bulk(actor: AuthenticatedUser, dto: BulkUsersDto): Promise<BulkResult> {
    if (dto.action === 'suspend' && !dto.reason) {
      throw validationFailed({ reason: ['A reason is required to suspend.'] });
    }
    const result: BulkResult = { succeeded: [], skipped: [] };
    for (const id of new Set(dto.ids)) {
      try {
        await this.applyBulk(actor, dto.action, id, dto.reason ?? '');
        result.succeeded.push(id);
      } catch (error) {
        result.skipped.push({ id, reason: this.reasonOf(error) });
      }
    }
    return result;
  }

  private async applyBulk(
    actor: AuthenticatedUser,
    action: BulkAction,
    id: string,
    reason: string,
  ): Promise<void> {
    switch (action) {
      case 'suspend':
        await this.suspend(actor, id, reason);
        return;
      case 'activate':
        await this.activate(actor, id);
        return;
      case 'revokeSessions':
        await this.revokeSessions(actor, id);
        return;
    }
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  /**
   * The target of a change. Admin accounts are never touched here (they
   * are managed from Settings, with their own safeguards), and nobody can
   * act on their own account, so an admin cannot lock themselves out.
   */
  private async manageable(actor: AuthenticatedUser, id: string): Promise<User> {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw notFound('User not found.');
    if (user.id === actor.id) {
      throw conflict('You cannot do this to your own account.');
    }
    if (user.role === 'admin') {
      throw conflict('Admin accounts are managed from Settings.');
    }
    return user;
  }

  /**
   * Prisma accepts `{ sort, nulls }` only on columns that can be null
   * (`lastLoginAt`); the others take a plain direction. The id is the
   * tie-break so pages never overlap.
   */
  private orderBy(
    field: UserSortField,
    order: 'asc' | 'desc',
  ): Prisma.UserOrderByWithRelationInput[] {
    const primary: Prisma.UserOrderByWithRelationInput =
      field === 'lastLoginAt'
        ? { lastLoginAt: { sort: order, nulls: 'last' } }
        : field === 'fullName'
          ? { fullName: order }
          : field === 'email'
            ? { email: order }
            : { createdAt: order };
    return [primary, { id: 'asc' }];
  }

  private async revokeSessionsIn(
    db: Pick<PrismaService, 'refreshToken'> | Prisma.TransactionClient,
    userId: string,
  ): Promise<number> {
    const { count } = await db.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    return count;
  }

  private reasonOf(error: unknown): string {
    const response = (
      error as { getResponse?: () => unknown } | undefined
    )?.getResponse?.();
    if (response && typeof response === 'object' && 'message' in response) {
      const message = (response).message;
      if (typeof message === 'string') return message;
    }
    return 'Could not be changed.';
  }

  private where(query: QueryUsersDto): Prisma.UserWhereInput {
    const search = query.q?.trim();
    const digits = search?.replace(/\D/g, '') ?? '';
    const createdAt: Prisma.DateTimeFilter = {};
    if (query.createdFrom) createdAt.gte = new Date(query.createdFrom);
    if (query.createdTo) createdAt.lt = new Date(query.createdTo);

    return {
      ...(query.role ? { role: query.role } : {}),
      ...(query.status ? { status: query.status } : {}),
      ...(query.deleted === 'only'
        ? { deletedAt: { not: null } }
        : query.deleted === 'exclude'
          ? { deletedAt: null }
          : {}),
      ...(Object.keys(createdAt).length > 0 ? { createdAt } : {}),
      ...(search
        ? {
            OR: [
              { fullName: { contains: search, mode: 'insensitive' } },
              { email: { contains: search, mode: 'insensitive' } },
              // 0791234567 and +962791234567 both find +962791234567.
              ...(digits.length >= 4
                ? [{ phone: { contains: digits.replace(/^(962|0)/, '') } }]
                : []),
            ],
          }
        : {}),
    };
  }
}
