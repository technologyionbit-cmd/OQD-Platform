import type { AuthenticatedUser } from '../auth/auth.types';
import type { LawyersService } from '../lawyers/lawyers.service';
import type { NotificationsService } from '../notifications/notifications.service';
import type { PrismaService } from '../prisma/prisma.service';
import {
  ConsultationsService,
  MAX_SLOT_DURATION_MS,
} from './consultations.service';

const HOUR = 3_600_000;
const lawyer = { id: 'u-lawyer', role: 'lawyer' } as AuthenticatedUser;
const client = { id: 'u-client', role: 'client' } as AuthenticatedUser;

function build() {
  const prisma = {
    availabilitySlot: {
      findFirst: jest.fn().mockResolvedValue(null),
      findMany: jest.fn().mockResolvedValue([]),
      create: jest
        .fn()
        .mockImplementation(({ data }: { data: unknown }) =>
          Promise.resolve(data),
        ),
    },
    lawyerProfile: {
      findUnique: jest.fn().mockResolvedValue({
        id: 'lp1',
        userId: 'u-lawyer',
        fullName: 'L',
        verificationStatus: 'verified',
      }),
    },
    lawyerConsultationOffering: {
      findUnique: jest.fn().mockResolvedValue({ isActive: true, price: 10 }),
    },
    user: {
      findUniqueOrThrow: jest
        .fn()
        .mockResolvedValue({ id: 'u-client', fullName: 'C' }),
    },
    consultation: { findUnique: jest.fn() },
    $transaction: jest.fn(),
  };
  const lawyers = {
    profileForLawyer: jest.fn().mockResolvedValue({ id: 'lp1' }),
  };
  const service = new ConsultationsService(
    prisma as unknown as PrismaService,
    {} as NotificationsService,
    lawyers as unknown as LawyersService,
  );
  return { service, prisma };
}

const iso = (offsetMs: number) => new Date(Date.now() + offsetMs).toISOString();

describe('ConsultationsService availability (BIZ-02, PERF-01)', () => {
  it('rejects a slot that starts in the past', async () => {
    const { service, prisma } = build();
    await expect(
      service.addAvailabilitySlot(lawyer, {
        start: iso(-2 * HOUR),
        end: iso(-HOUR),
      }),
    ).rejects.toMatchObject({ status: 400 });
    expect(prisma.availabilitySlot.create).not.toHaveBeenCalled();
  });

  it('rejects start >= end', async () => {
    const { service } = build();
    await expect(
      service.addAvailabilitySlot(lawyer, {
        start: iso(2 * HOUR),
        end: iso(HOUR),
      }),
    ).rejects.toMatchObject({ status: 400 });
  });

  it('rejects a slot longer than the cap', async () => {
    const { service } = build();
    await expect(
      service.addAvailabilitySlot(lawyer, {
        start: iso(HOUR),
        end: iso(HOUR + MAX_SLOT_DURATION_MS + 60_000),
      }),
    ).rejects.toMatchObject({ status: 400 });
  });

  it('rejects a slot overlapping one the lawyer already published (409)', async () => {
    const { service, prisma } = build();
    prisma.availabilitySlot.findFirst.mockResolvedValue({ id: 'existing' });
    await expect(
      service.addAvailabilitySlot(lawyer, {
        start: iso(HOUR),
        end: iso(2 * HOUR),
      }),
    ).rejects.toMatchObject({ status: 409 });
    expect(prisma.availabilitySlot.create).not.toHaveBeenCalled();
  });

  it("creates a valid future, non-overlapping slot on the lawyer's own profile", async () => {
    const { service, prisma } = build();
    await service.addAvailabilitySlot(lawyer, {
      start: iso(HOUR),
      end: iso(2 * HOUR),
    });
    expect(prisma.availabilitySlot.create).toHaveBeenCalledWith({
      data: expect.objectContaining({ lawyerProfileId: 'lp1' }) as unknown,
    });
  });

  it('lists only slots that have not started', async () => {
    const { service, prisma } = build();
    await service.getAvailability('lp1');
    expect(prisma.availabilitySlot.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          lawyerProfileId: 'lp1',
          startAt: { gte: expect.any(Date) as Date },
        },
      }),
    );
  });
});

describe('ConsultationsService.book (BIZ-02)', () => {
  it('rejects booking a slot that already started', async () => {
    const { service, prisma } = build();
    prisma.availabilitySlot.findFirst.mockResolvedValue({
      id: 's1',
      startAt: new Date(Date.now() - HOUR),
    });
    await expect(
      service.book(client, {
        lawyerId: 'lp1',
        type: 'video',
        scheduledAt: iso(-HOUR),
      } as never),
    ).rejects.toMatchObject({ status: 400 });
    expect(prisma.$transaction).not.toHaveBeenCalled();
  });

  it('only clients can book', async () => {
    const { service } = build();
    await expect(
      service.book(lawyer, {
        lawyerId: 'lp1',
        type: 'video',
        scheduledAt: iso(HOUR),
      } as never),
    ).rejects.toMatchObject({ status: 403 });
  });
});

describe('ConsultationsService.reschedule (BIZ-02)', () => {
  it('rejects rescheduling into a past slot', async () => {
    const { service, prisma } = build();
    prisma.consultation.findUnique.mockResolvedValue({
      id: 'c1',
      clientUserId: 'u-client',
      lawyerProfileId: 'lp1',
      status: 'confirmed',
    });
    prisma.availabilitySlot.findFirst.mockResolvedValue({
      id: 's2',
      startAt: new Date(Date.now() - HOUR),
    });
    await expect(
      service.reschedule(client, 'c1', { scheduledAt: iso(-HOUR) }),
    ).rejects.toMatchObject({ status: 400 });
    expect(prisma.$transaction).not.toHaveBeenCalled();
  });
});
