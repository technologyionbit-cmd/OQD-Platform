import { ConflictException } from '@nestjs/common';
import type { PasswordService } from '../auth/services/password.service';
import { AdminAdminsService } from './admins/admin-admins';
import type { NotificationsService } from '../notifications/notifications.service';
import type { PrismaService } from '../prisma/prisma.service';
import { CONTRACT_TEMPLATES } from '../contracts/contract-templates';
import { validateFields } from './contract-templates/admin-contract-templates';
import { AdminLawyersService } from './lawyers/admin-lawyers.service';
import { AdminConsultationsService } from './consultations/admin-consultations';
import {
  AdminNotificationsService,
  type SendNotificationDto,
} from './notifications/admin-notifications';

const label = { ar: 'ح', en: 'f' };
const field = (id: string, extra: object = {}) => ({
  id,
  type: 'text',
  label,
  isRequired: true,
  ...extra,
});

describe('validateFields', () => {
  it('accepts every built-in template', () => {
    for (const t of CONTRACT_TEMPLATES) {
      expect(validateFields(t.fields as unknown[]).errors).toEqual([]);
    }
  });

  it('requires partyA and partyB, unique ids and known types', () => {
    const { errors } = validateFields([
      field('partyA'),
      field('partyA'),
      field('x', { type: 'weird' }),
    ]);
    expect(errors.join('|')).toContain('partyA: duplicate id');
    expect(errors.join('|')).toContain('x: unknown type');
    expect(errors.join('|')).toContain('partyB: every template needs');
  });

  it('needs options for a dropdown, with unique values', () => {
    const base = [field('partyA'), field('partyB')];
    expect(
      validateFields([...base, field('d', { type: 'dropdown' })]).errors,
    ).toContain('d: a dropdown needs 1 to 30 options.');
    const dup = { value: 'a', label };
    expect(
      validateFields([
        ...base,
        field('d', { type: 'dropdown', options: [dup, dup] }),
      ]).errors.join('|'),
    ).toContain('duplicate option value');
    expect(
      validateFields([
        ...base,
        field('d', { type: 'dropdown', options: [dup] }),
      ]).errors,
    ).toEqual([]);
  });
});

describe('AdminConsultationsService.cancel', () => {
  function setup(status: string) {
    const tx = {
      consultation: { updateMany: jest.fn().mockResolvedValue({ count: 1 }) },
      availabilitySlot: { update: jest.fn() },
    };
    const prisma = {
      consultation: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'c1',
          status,
          clientUserId: 'client',
          availabilitySlotId: 'slot',
          scheduledAt: new Date('2026-12-01T10:00:00Z'),
          lawyerProfile: { userId: 'lawyer' },
        }),
      },
      $transaction: jest.fn((fn: (t: unknown) => Promise<unknown>) => fn(tx)),
    };
    const notify = jest.fn();
    const service = new AdminConsultationsService(
      prisma as unknown as PrismaService,
      { notify } as unknown as NotificationsService,
    );
    return { service, tx, notify };
  }

  it('cancels, frees the slot and notifies both people', async () => {
    const { service, tx, notify } = setup('confirmed');
    const out = await service.cancel('c1', 'duplicate booking');
    expect(tx.consultation.updateMany).toHaveBeenCalledWith({
      where: { id: 'c1', status: 'confirmed' },
      data: { cancellationReason: 'duplicate booking', status: 'cancelled' },
    });
    expect(tx.availabilitySlot.update).toHaveBeenCalledWith({
      where: { id: 'slot' },
      data: { isBooked: false },
    });
    expect(notify.mock.calls.map((c) => (c as [unknown, { userId: string }])[1].userId)).toEqual([
      'client',
      'lawyer',
    ]);
    expect(out.after.status).toBe('cancelled');
  });

  it('refuses a finished consultation', async () => {
    const { service, notify } = setup('completed');
    await expect(service.cancel('c1', 'abc')).rejects.toBeInstanceOf(
      ConflictException,
    );
    expect(notify).not.toHaveBeenCalled();
  });

  it('only completes a confirmed consultation', async () => {
    const { service } = setup('pendingApproval');
    await expect(service.complete('c1')).rejects.toBeInstanceOf(
      ConflictException,
    );
  });
});

describe('AdminNotificationsService.send', () => {
  const dto = (over: Partial<SendNotificationDto>): SendNotificationDto => ({
    audience: 'all',
    titleAr: 'ع',
    titleEn: 'T',
    bodyAr: 'ن',
    bodyEn: 'B',
    ...over,
  });

  function setup(users: { id: string }[]) {
    const createMany = jest.fn().mockResolvedValue({});
    const findMany = jest.fn().mockResolvedValue(users);
    const prisma = {
      user: { findMany, findFirst: jest.fn().mockResolvedValue(users[0] ?? null) },
      notification: { createMany },
    };
    return {
      service: new AdminNotificationsService(prisma as unknown as PrismaService),
      createMany,
      findMany,
    };
  }

  it('sends an adminMessage to each active non-admin user', async () => {
    const { service, createMany, findMany } = setup([{ id: 'a' }, { id: 'b' }]);
    const out = await service.send(dto({}));
    expect(out.sent).toBe(2);
    expect(JSON.stringify(findMany.mock.calls[0])).toContain('"status":"active"');
    expect(JSON.stringify(findMany.mock.calls[0])).not.toContain('admin');
    const data = (createMany.mock.calls[0] as [{ data: { type: string }[] }])[0].data;
    expect(data.map((d) => d.type)).toEqual(['adminMessage', 'adminMessage']);
  });

  it('answers 404 for a user that is not active', async () => {
    const { service, createMany } = setup([]);
    await expect(
      service.send(dto({ audience: 'user', userId: 'nobody' })),
    ).rejects.toThrow('not found');
    expect(createMany).not.toHaveBeenCalled();
  });
});

describe('AdminAdminsService', () => {
  const actor = { id: 'me', role: 'admin' as const, sessionId: 's' };
  const row = (over: object = {}) => ({
    id: 'a2',
    fullName: 'Second',
    email: 's@x.com',
    phone: '+962791111111',
    status: 'active',
    adminFullAccess: false,
    adminPermissions: ['users.view'],
    lastLoginAt: null,
    createdAt: new Date(),
    ...over,
  });

  function setup(target: object | null, otherFullAdmins = 1) {
    const prisma = {
      user: {
        findFirst: jest.fn().mockResolvedValue(target),
        findUnique: jest.fn(),
        count: jest.fn().mockResolvedValue(otherFullAdmins),
        create: jest.fn(({ data }: { data: object }) => Promise.resolve(row(data))),
        update: jest.fn(({ data }: { data: object }) => Promise.resolve(row(data))),
      },
      refreshToken: { updateMany: jest.fn() },
      $transaction: jest.fn((arg: unknown): Promise<unknown> =>
        typeof arg === 'function'
          ? (arg as (c: unknown) => Promise<unknown>)(prisma)
          : Promise.all(arg as Promise<unknown>[]),
      ),
    };
    const passwords = { hash: jest.fn().mockResolvedValue('HASH') };
    return {
      prisma,
      service: new AdminAdminsService(
        prisma as unknown as PrismaService,
        passwords as unknown as PasswordService,
      ),
    };
  }

  it('creates an admin with cleaned permissions and a hashed password', async () => {
    const { prisma, service } = setup(null);
    await service.create({
      fullName: 'New',
      email: 'n@x.com',
      phone: '+962792222222',
      password: 'Password123',
      fullAccess: false,
      permissions: ['contracts.manage', 'nope'],
    });
    const data = (prisma.user.create.mock.calls[0] as [{ data: Record<string, unknown> }])[0].data;
    expect(data.role).toBe('admin');
    expect(data.passwordHash).toBe('HASH');
    expect(data.adminPermissions).toEqual(['contracts.view', 'contracts.manage']);
  });

  it('refuses an email or phone that is already taken', async () => {
    const { service } = setup({ email: 'taken' });
    await expect(
      service.create({
        fullName: 'New', email: 'n@x.com', phone: '+962792222222',
        password: 'Password123', fullAccess: true, permissions: [],
      }),
    ).rejects.toBeInstanceOf(ConflictException);
  });

  it('cannot change your own access', async () => {
    const { service } = setup(row({ id: 'me' }));
    await expect(
      service.updateAccess(actor, 'me', { fullAccess: false, permissions: [] }),
    ).rejects.toBeInstanceOf(ConflictException);
  });

  it('keeps at least one active full-access admin', async () => {
    const { service } = setup(row({ adminFullAccess: true }), 0);
    await expect(
      service.updateAccess(actor, 'a2', { fullAccess: false, permissions: [] }),
    ).rejects.toBeInstanceOf(ConflictException);
    await expect(service.setActive(actor, 'a2', false)).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it('deactivating ends the sessions', async () => {
    const { prisma, service } = setup(row());
    await service.setActive(actor, 'a2', false);
    expect(prisma.refreshToken.updateMany).toHaveBeenCalledWith({
      where: { userId: 'a2', revokedAt: null },
      data: { revokedAt: expect.any(Date) as Date },
    });
  });
});

describe('AdminLawyersService', () => {
  function setup(profile: object | null, review: object | null = null) {
    const tx = {
      lawyerProfile: {
        updateMany: jest.fn().mockResolvedValue({ count: 1 }),
        update: jest.fn(),
      },
      review: {
        delete: jest.fn(),
        aggregate: jest.fn().mockResolvedValue({ _avg: { rating: 4 }, _count: 2 }),
      },
    };
    const prisma = {
      lawyerProfile: { findUnique: jest.fn().mockResolvedValue(profile) },
      review: { findFirst: jest.fn().mockResolvedValue(review) },
      $transaction: jest.fn((fn: (t: unknown) => Promise<unknown>) => fn(tx)),
    };
    const notify = jest.fn();
    return {
      tx,
      notify,
      service: new AdminLawyersService(
        prisma as unknown as PrismaService,
        { notify } as unknown as NotificationsService,
      ),
    };
  }

  it('revokes only a verified lawyer and tells them why', async () => {
    const { service, tx, notify } = setup({ userId: 'u', verificationStatus: 'verified' });
    await service.revokeVerification('admin', 'p1', 'fake licence');
    expect(tx.lawyerProfile.updateMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 'p1', verificationStatus: 'verified' },
      }),
    );
    expect(notify).toHaveBeenCalledWith(
      tx,
      expect.objectContaining({ userId: 'u', type: 'lawyerVerificationRejected', params: { reason: 'fake licence' } }),
    );
  });

  it('refuses to revoke a lawyer who is not verified', async () => {
    const { service, notify } = setup({ userId: 'u', verificationStatus: 'pending' });
    await expect(service.revokeVerification('admin', 'p1', 'x')).rejects.toBeInstanceOf(ConflictException);
    expect(notify).not.toHaveBeenCalled();
  });

  it('removing a review recomputes the rating from what is left', async () => {
    const { service, tx } = setup({}, { id: 'r1', rating: 1, comment: 'bad' });
    await service.removeReview('p1', 'r1');
    expect(tx.review.delete).toHaveBeenCalledWith({ where: { id: 'r1' } });
    expect(tx.lawyerProfile.update).toHaveBeenCalledWith({
      where: { id: 'p1' },
      data: { rating: 4, reviewsCount: 2 },
    });
  });

  it('answers 404 for a review of another lawyer', async () => {
    const { service } = setup({}, null);
    await expect(service.removeReview('p1', 'r1')).rejects.toThrow('Review not found');
  });
});
