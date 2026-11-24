import { ConflictException, NotFoundException } from '@nestjs/common';
import type { PrismaService } from '../../prisma/prisma.service';
import { AdminCompaniesService } from './admin-companies.service';

function setup(status: string | null) {
  const row = (verificationStatus: string) => ({
    id: 'c1',
    name: 'Acme',
    commercialRegistrationNumber: '123',
    verificationStatus,
    createdAt: new Date(),
    owner: { id: 'u1', fullName: 'Owner', email: 'o@x.com', phone: null },
    _count: { members: 2 },
  });
  const prisma = {
    organization: {
      findUnique: jest.fn().mockResolvedValue(status ? row(status) : null),
      update: jest.fn(({ data }: { data: { verificationStatus: string } }) =>
        Promise.resolve(row(data.verificationStatus)),
      ),
    },
  };
  return {
    prisma,
    service: new AdminCompaniesService(prisma as unknown as PrismaService),
  };
}

describe('AdminCompaniesService.decide', () => {
  it('verifies a pending company and reports before/after', async () => {
    const { service, prisma } = setup('pending');
    const out = await service.decide('c1', 'verified');
    expect(prisma.organization.update).toHaveBeenCalledWith(
      expect.objectContaining({ data: { verificationStatus: 'verified' } }),
    );
    expect(out.before.verificationStatus).toBe('pending');
    expect(out.company.verificationStatus).toBe('verified');
    expect(out.company.membersCount).toBe(2);
  });

  it('refuses to decide twice', async () => {
    const { service } = setup('verified');
    await expect(service.decide('c1', 'rejected')).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it('answers 404 for an unknown company', async () => {
    const { service } = setup(null);
    await expect(service.decide('c1', 'verified')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });
});
