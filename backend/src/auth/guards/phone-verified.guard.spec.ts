import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import type { PrismaService } from '../../prisma/prisma.service';
import { PhoneVerifiedGuard } from './phone-verified.guard';

describe('PhoneVerifiedGuard', () => {
  const guardFor = (phoneVerifiedAt: Date | null | undefined) =>
    new PhoneVerifiedGuard({
      user: {
        findUnique: () =>
          Promise.resolve(
            phoneVerifiedAt === undefined ? null : { phoneVerifiedAt },
          ),
      },
    } as unknown as PrismaService);

  const contextFor = (user?: { id: string }) =>
    ({
      switchToHttp: () => ({ getRequest: () => ({ user }) }),
    }) as unknown as ExecutionContext;

  it('lets a verified user through', async () => {
    await expect(
      guardFor(new Date()).canActivate(contextFor({ id: 'u1' })),
    ).resolves.toBe(true);
  });

  it.each([
    ['an unverified user', null, { id: 'u1' }],
    ['a deleted user', undefined, { id: 'u1' }],
    ['a request without a user', new Date(), undefined],
  ])('refuses %s with 403 PHONE_NOT_VERIFIED', async (_, verifiedAt, user) => {
    const error = await guardFor(verifiedAt)
      .canActivate(contextFor(user))
      .catch((e: unknown) => e);

    expect(error).toBeInstanceOf(ForbiddenException);
    expect((error as ForbiddenException).getResponse()).toMatchObject({
      code: 'PHONE_NOT_VERIFIED',
    });
  });
});
