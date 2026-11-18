import type { PrismaService } from '../prisma/prisma.service';
import { LawyersService } from './lawyers.service';

describe('LawyersService.findReviews', () => {
  const review = {
    id: 'r1',
    reviewerUserId: 'user-internal-uuid',
    rating: 5,
    comment: 'Great',
    createdAt: new Date('2026-01-01T00:00:00Z'),
  };

  function build(profile: { id: string; verificationStatus: string } | null) {
    const prisma = {
      lawyerProfile: { findUnique: jest.fn().mockResolvedValue(profile) },
      review: { findMany: jest.fn(), count: jest.fn() },
      $transaction: jest.fn().mockResolvedValue([[review], 1]),
    };
    return new LawyersService(prisma as unknown as PrismaService);
  }

  it('does not expose the reviewer user id', async () => {
    const service = build({ id: 'l1', verificationStatus: 'verified' });
    const result = await service.findReviews('l1', {});
    expect(result.data).toEqual([
      { id: 'r1', rating: 5, comment: 'Great', createdAt: review.createdAt },
    ]);
    expect(JSON.stringify(result)).not.toContain('user-internal-uuid');
    expect(result.meta).toEqual({ page: 1, limit: 20, total: 1 });
  });

  it('answers 404 for a lawyer that is not verified', async () => {
    const service = build({ id: 'l1', verificationStatus: 'pending' });
    await expect(service.findReviews('l1', {})).rejects.toMatchObject({
      status: 404,
    });
  });

  it('answers 404 for an unknown lawyer', async () => {
    const service = build(null);
    await expect(service.findReviews('l1', {})).rejects.toMatchObject({
      status: 404,
    });
  });
});
