import type { PrismaClient } from '@prisma/client';
import { randomInt } from 'node:crypto';
import type { Server } from 'node:http';
import request from 'supertest';
import { DEFAULT_TERMS_VERSION } from '../../src/config/configuration';

/** Shared by the e2e specs: response readers and test accounts. */

export interface ApiErrorBody {
  message: string;
  code: string;
  errors?: Record<string, string[]>;
}

export const ok = <T>(res: request.Response): T =>
  (res.body as { data: T }).data;

export const apiError = (res: request.Response): ApiErrorBody =>
  (res.body as { error: ApiErrorBody }).error;

/** A fresh Jordanian mobile number in the local spelling the app sends
 *  (07XXXXXXXX), so sign-ups never collide on the unique phone column. */
export function testPhone(): string {
  return `079${randomInt(0, 10_000_000).toString().padStart(7, '0')}`;
}

/** How the API stores and returns [testPhone]: +9627XXXXXXXX. */
export const storedPhone = (local: string): string => `+962${local.slice(1)}`;

export interface TestAccount {
  id: string;
  email: string;
  phone: string;
  fullName: string;
  token: string;
}

/** Sign-up fields for a lawyer account (the rest is filled in below). */
export const lawyerSignup = (barLicenseNumber: string) => ({
  accountType: 'lawyer',
  barLicenseNumber,
  mainSpecialty: 'commercial',
});

export const individualSignup = { accountType: 'individual' };

/**
 * Returns `register(key, signup)`, which creates `<prefix>.<key>.<tag>@test.com`
 * through the real API. [deleteTestAccounts] removes them afterwards.
 */
export function accountRegistrar(http: Server, prefix: string, tag: number) {
  return async (
    key: string,
    signup: Record<string, string>,
  ): Promise<TestAccount> => {
    const email = `${prefix}.${key}.${tag}@test.com`;
    const phone = testPhone();
    const fullName = `${prefix} ${key}`;
    const res = await request(http)
      .post('/v1/auth/register')
      .send({
        fullName,
        phone,
        email,
        password: 'Password123',
        acceptTerms: true,
        termsVersion: DEFAULT_TERMS_VERSION,
        ...signup,
      });
    expect(res.status).toBe(201);
    const body = ok<{ user: { id: string }; tokens: { accessToken: string } }>(
      res,
    );
    return {
      id: body.user.id,
      email,
      phone: storedPhone(phone),
      fullName,
      token: body.tokens.accessToken,
    };
  };
}

export const bearer = (account: TestAccount) => ({
  authorization: `Bearer ${account.token}`,
});

export async function deleteTestAccounts(
  prisma: PrismaClient,
  tag: number,
): Promise<void> {
  await prisma.user.deleteMany({
    where: { email: { endsWith: `.${tag}@test.com` } },
  });
}
