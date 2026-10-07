import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import type { PrismaService } from '../../prisma/prisma.service';
import { EmailVerifiedGuard } from './email-verified.guard';

describe('EmailVerifiedGuard', () => {
  const guardFor = (emailVerifiedAt: Date | null | undefined) =>
    new EmailVerifiedGuard({
      user: {
        findUnique: () =>
          Promise.resolve(
            emailVerifiedAt === undefined ? null : { emailVerifiedAt },
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
  ])('refuses %s with 403 EMAIL_NOT_VERIFIED', async (_, verifiedAt, user) => {
    const error = await guardFor(verifiedAt)
      .canActivate(contextFor(user))
      .catch((e: unknown) => e);

    expect(error).toBeInstanceOf(ForbiddenException);
    expect((error as ForbiddenException).getResponse()).toMatchObject({
      code: 'EMAIL_NOT_VERIFIED',
    });
  });
});
