import { INestApplication } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import type { Server } from 'node:http';
import request from 'supertest';
import { createE2EApp } from './support/e2e-app';
import { OtpService } from '../src/auth/services/otp.service';
import { DEFAULT_TERMS_VERSION } from '../src/config/configuration';

/**
 * End-to-end auth coverage (docs/backend/02-auth-and-authorization.md,
 * docs/backend/16-backend-roadmap.md Phase 1 acceptance criteria).
 * Requires PostgreSQL reachable at DATABASE_URL.
 */

interface UserView {
  id: string;
  fullName: string;
  email: string;
  role: string;
  emailVerified: boolean;
}
interface Tokens {
  accessToken: string;
  refreshToken: string;
}
interface SessionView {
  id: string;
  current: boolean;
}
interface ErrorBody {
  message: string;
  code: string;
  errors?: Record<string, string[]>;
}

const ok = <T>(res: request.Response): T => (res.body as { data: T }).data;
const err = (res: request.Response): ErrorBody =>
  (res.body as { error: ErrorBody }).error;

describe('Auth (e2e)', () => {
  let app: INestApplication;
  let http: Server;
  const prisma = new PrismaClient();

  const tag = Date.now();
  const terms = { acceptTerms: true, termsVersion: DEFAULT_TERMS_VERSION };
  const individual = {
    accountType: 'individual',
    fullName: 'Ahmad Client',
    phone: '0791234567',
    email: `ahmad.${tag}@test.com`,
    password: 'Password123',
    ...terms,
  };
  const company = {
    accountType: 'company',
    companyName: 'Rowad Legal',
    commercialRegistrationNumber: `CR-${tag}`,
    phone: '0791111111',
    email: `company.${tag}@test.com`,
    password: 'Password123',
    ...terms,
  };
  const lawyer = {
    accountType: 'lawyer',
    fullName: 'Sara Lawyer',
    barLicenseNumber: `BAR-${tag}`,
    mainSpecialty: 'commercial',
    phone: '0792222222',
    email: `lawyer.${tag}@test.com`,
    password: 'Password123',
    ...terms,
  };

  beforeAll(async () => {
    app = await createE2EApp();
    http = app.getHttpServer() as Server;
  });

  afterAll(async () => {
    const users = await prisma.user.findMany({
      where: { email: { endsWith: `.${tag}@test.com` } },
      select: { id: true },
    });
    const ids = users.map((u) => u.id);
    // organizations.owner_user_id is ON DELETE RESTRICT — clear orgs first.
    await prisma.organization.deleteMany({
      where: { ownerUserId: { in: ids } },
    });
    await prisma.user.deleteMany({ where: { id: { in: ids } } });
    await prisma.$disconnect();
    await app.close();
  });

  const login = (email: string, password: string) =>
    request(http).post('/v1/auth/login').send({ email, password });

  describe('registration', () => {
    it('registers an individual and returns user + tokens', async () => {
      const res = await request(http)
        .post('/v1/auth/register')
        .send(individual);
      expect(res.status).toBe(201);

      const data = ok<{ user: UserView; tokens: Tokens }>(res);
      expect(data.user).toMatchObject({
        email: individual.email,
        role: 'client',
        fullName: individual.fullName,
        emailVerified: false,
      });

      const stored = await prisma.user.findUnique({
        where: { email: individual.email },
      });
      expect(stored?.termsVersion).toBe(DEFAULT_TERMS_VERSION);
      expect(stored?.termsAcceptedAt).toBeInstanceOf(Date);
      expect(typeof data.tokens.accessToken).toBe('string');
      expect(typeof data.tokens.refreshToken).toBe('string');
    });

    it('registers a company and auto-creates the organization + owner member', async () => {
      const res = await request(http).post('/v1/auth/register').send(company);
      expect(res.status).toBe(201);

      const data = ok<{ user: UserView }>(res);
      expect(data.user.role).toBe('company');

      const org = await prisma.organization.findUnique({
        where: {
          commercialRegistrationNumber: company.commercialRegistrationNumber,
        },
        include: { members: true },
      });
      expect(org?.ownerUserId).toBe(data.user.id);
      expect(org?.members).toHaveLength(1);
      expect(org?.members[0]).toMatchObject({
        role: 'owner',
        status: 'active',
      });
    });

    it('registers a lawyer and stores the registration detail', async () => {
      const res = await request(http).post('/v1/auth/register').send(lawyer);
      expect(res.status).toBe(201);

      const data = ok<{ user: UserView }>(res);
      expect(data.user.role).toBe('lawyer');

      const detail = await prisma.lawyerRegistrationDetail.findUnique({
        where: { userId: data.user.id },
      });
      expect(detail).toMatchObject({
        barLicenseNumber: lawyer.barLicenseNumber,
        mainSpecialty: 'commercial',
      });
    });

    it('rejects a duplicate email with EMAIL_ALREADY_REGISTERED on the email field', async () => {
      const res = await request(http)
        .post('/v1/auth/register')
        .send({ ...individual, email: individual.email.toUpperCase() });
      expect(res.status).toBe(422);
      expect(err(res).code).toBe('EMAIL_ALREADY_REGISTERED');
      expect(err(res).errors?.email).toBeDefined();
    });

    it('rejects a taken commercial registration number with its own code', async () => {
      const res = await request(http)
        .post('/v1/auth/register')
        .send({ ...company, email: `company2.${tag}@test.com` });
      expect(res.status).toBe(422);
      expect(err(res).code).toBe('COMMERCIAL_REGISTRATION_TAKEN');
      expect(err(res).errors?.commercialRegistrationNumber).toBeDefined();
    });

    it('rejects a taken bar license number with its own code', async () => {
      const res = await request(http)
        .post('/v1/auth/register')
        .send({ ...lawyer, email: `lawyer2.${tag}@test.com` });
      expect(res.status).toBe(422);
      expect(err(res).code).toBe('BAR_LICENSE_TAKEN');
      expect(err(res).errors?.barLicenseNumber).toBeDefined();
    });

    it('requires explicit acceptance of the terms', async () => {
      const res = await request(http)
        .post('/v1/auth/register')
        .send({
          ...individual,
          email: `noterms.${tag}@test.com`,
          acceptTerms: false,
        });
      expect(res.status).toBe(422);
      expect(err(res).errors?.acceptTerms).toBeDefined();
    });

    it('rejects an outdated terms version with TERMS_VERSION_OUTDATED', async () => {
      const res = await request(http)
        .post('/v1/auth/register')
        .send({
          ...individual,
          email: `oldterms.${tag}@test.com`,
          termsVersion: '2000-01-01',
        });
      expect(res.status).toBe(422);
      expect(err(res).code).toBe('TERMS_VERSION_OUTDATED');
      expect(err(res).errors?.termsVersion).toBeDefined();
    });

    it('rejects a password over 72 bytes (bcrypt would truncate it)', async () => {
      const res = await request(http)
        .post('/v1/auth/register')
        .send({
          ...individual,
          email: `longpw.${tag}@test.com`,
          password: 'a1' + 'ب'.repeat(36),
        });
      expect(res.status).toBe(422);
      expect(err(res).errors?.password).toBeDefined();
    });

    it('rejects a weak password with a 422', async () => {
      const res = await request(http).post('/v1/auth/register').send({
        ...individual,
        email: `weak.${tag}@test.com`,
        password: 'short',
      });
      expect(res.status).toBe(422);
      expect(err(res).errors?.password).toBeDefined();
    });
  });

  describe('login + session lifecycle', () => {
    it('logs in with valid credentials', async () => {
      const res = await login(individual.email, individual.password);
      expect(res.status).toBe(200);
      expect(ok<{ user: UserView }>(res).user.email).toBe(individual.email);
    });

    it('returns a generic 401 for a bad password', async () => {
      const res = await login(individual.email, 'WrongPass123');
      expect(res.status).toBe(401);
      expect(err(res).code).toBe('UNAUTHORIZED');
    });

    it('answers an unknown email exactly like a wrong password', async () => {
      const unknown = await login(`nobody.${tag}@test.com`, 'WrongPass123');
      const wrongPassword = await login(individual.email, 'WrongPass123');

      expect(unknown.status).toBe(401);
      expect(unknown.body).toEqual(wrongPassword.body);
    });

    it('limits attempts per email regardless of IP, with Retry-After', async () => {
      // An unknown email on purpose: the limit must behave identically for
      // accounts that don't exist, or it would reveal which ones do.
      const target = `bruteforce.${tag}@test.com`;
      for (let i = 0; i < 10; i++) {
        expect((await login(target, `Guess${i}pass`)).status).toBe(401);
      }

      const blocked = await login(target, 'Guess10pass');

      expect(blocked.status).toBe(429);
      expect(err(blocked).code).toBe('TOO_MANY_REQUESTS');
      expect(Number(blocked.headers['retry-after'])).toBeGreaterThan(0);
      // Other accounts are unaffected.
      expect((await login(individual.email, individual.password)).status).toBe(
        200,
      );
    });

    it('refuses an inactive account with ACCOUNT_INACTIVE after a correct password', async () => {
      await prisma.user.update({
        where: { email: company.email },
        data: { status: 'suspended' },
      });
      try {
        const res = await login(company.email, company.password);
        expect(res.status).toBe(403);
        expect(err(res).code).toBe('ACCOUNT_INACTIVE');

        // Without the right password it stays an indistinguishable 401.
        const guess = await login(company.email, 'WrongPass123');
        expect(guess.status).toBe(401);
      } finally {
        await prisma.user.update({
          where: { email: company.email },
          data: { status: 'active' },
        });
      }
    });

    it('refreshes, rotates the refresh token, and detects reuse', async () => {
      const session = await login(individual.email, individual.password);
      const oldRefresh = ok<{ tokens: Tokens }>(session).tokens.refreshToken;

      const refreshed = await request(http)
        .post('/v1/auth/refresh')
        .send({ refreshToken: oldRefresh });
      expect(refreshed.status).toBe(200);
      const rotated = ok<{ tokens: Tokens }>(refreshed).tokens.refreshToken;
      expect(rotated).not.toBe(oldRefresh);

      const reuse = await request(http)
        .post('/v1/auth/refresh')
        .send({ refreshToken: oldRefresh });
      expect(reuse.status).toBe(401);

      // reuse detection revokes the whole family — the rotated token is dead too
      const afterFamilyRevoke = await request(http)
        .post('/v1/auth/refresh')
        .send({ refreshToken: rotated });
      expect(afterFamilyRevoke.status).toBe(401);
    });

    it('refuses an unknown or oversized refresh token without a 5xx', async () => {
      // The app signs the user out only on these refusals (401/4xx); a 5xx
      // would be treated as transient and retried forever.
      const unknown = await request(http)
        .post('/v1/auth/refresh')
        .send({ refreshToken: 'not-a-real-token' });
      expect(unknown.status).toBe(401);

      const oversized = await request(http)
        .post('/v1/auth/refresh')
        .send({ refreshToken: 'x'.repeat(257) });
      expect(oversized.status).toBe(422);
    });

    it('GET /auth/me answers a malformed bearer token with 401, not 5xx', async () => {
      const res = await request(http)
        .get('/v1/auth/me')
        .set('authorization', 'Bearer not.a.jwt');
      expect(res.status).toBe(401);
    });

    it('GET /auth/me returns 401 without a token and the user with one', async () => {
      const anon = await request(http).get('/v1/auth/me');
      expect(anon.status).toBe(401);

      const session = await login(individual.email, individual.password);
      const me = await request(http)
        .get('/v1/auth/me')
        .set(
          'authorization',
          `Bearer ${ok<{ tokens: Tokens }>(session).tokens.accessToken}`,
        );
      expect(me.status).toBe(200);
      expect(ok<{ user: UserView }>(me).user.email).toBe(individual.email);
    });

    it('lists active sessions and revokes the others', async () => {
      const first = await login(lawyer.email, lawyer.password);
      await login(lawyer.email, lawyer.password);
      const access = ok<{ tokens: Tokens }>(first).tokens.accessToken;

      const list = await request(http)
        .get('/v1/auth/sessions')
        .set('authorization', `Bearer ${access}`);
      const sessions = ok<SessionView[]>(list);
      expect(sessions.length).toBeGreaterThanOrEqual(2);
      expect(sessions.filter((s) => s.current)).toHaveLength(1);

      const revoked = await request(http)
        .delete('/v1/auth/sessions')
        .set('authorization', `Bearer ${access}`);
      expect(revoked.status).toBe(204);

      const after = await request(http)
        .get('/v1/auth/sessions')
        .set('authorization', `Bearer ${access}`);
      expect(ok<SessionView[]>(after)).toHaveLength(1);
    });
  });

  describe('password reset (OTP)', () => {
    it('runs forgot -> verify -> reset and invalidates old sessions', async () => {
      const session = await login(company.email, company.password);
      const staleAccess = ok<{ tokens: Tokens }>(session).tokens.accessToken;

      const forgot = await request(http)
        .post('/v1/auth/password/forgot')
        .send({ destination: company.email });
      expect(forgot.status).toBe(204);

      const code = app.get(OtpService).peekDevCode(company.email);
      expect(code).toMatch(/^\d{6}$/);

      const badVerify = await request(http)
        .post('/v1/auth/password/verify-otp')
        .send({ destination: company.email, code: '000000' });
      expect(ok<{ valid: boolean }>(badVerify).valid).toBe(false);

      const goodVerify = await request(http)
        .post('/v1/auth/password/verify-otp')
        .send({ destination: company.email, code });
      expect(ok<{ valid: boolean }>(goodVerify).valid).toBe(true);

      const reset = await request(http)
        .post('/v1/auth/password/reset')
        .send({ destination: company.email, code, newPassword: 'Rotated123' });
      expect(reset.status).toBe(204);
      company.password = 'Rotated123';

      const stale = await request(http)
        .get('/v1/auth/me')
        .set('authorization', `Bearer ${staleAccess}`);
      expect(stale.status).toBe(401);

      const fresh = await login(company.email, 'Rotated123');
      expect(fresh.status).toBe(200);
    });

    it('rejects a reset with a wrong code (422)', async () => {
      const res = await request(http).post('/v1/auth/password/reset').send({
        destination: company.email,
        code: '000000',
        newPassword: 'Rotated999',
      });
      expect(res.status).toBe(422);
    });

    it('always returns 204 for forgot-password on an unknown destination', async () => {
      const res = await request(http)
        .post('/v1/auth/password/forgot')
        .send({ destination: `nobody.${tag}@test.com` });
      expect(res.status).toBe(204);
    });
  });

  describe('email verification', () => {
    const verifier = {
      ...individual,
      fullName: 'Verify Me',
      email: `verifier.${tag}@test.com`,
    };
    let access = '';
    const auth = () => ({ authorization: `Bearer ${access}` });
    const someId = '00000000-0000-4000-8000-000000000000';

    /** Moves every code of this account back in time, as if the cooldown
     *  had passed, without the spec having to wait. */
    const ageCodes = async (email: string, seconds: number) => {
      await prisma.$executeRaw`
        UPDATE verification_codes
        SET created_at = created_at - make_interval(secs => ${seconds})
        WHERE destination = ${email}`;
    };

    beforeAll(async () => {
      const res = await request(http).post('/v1/auth/register').send(verifier);
      access = ok<{ tokens: Tokens }>(res).tokens.accessToken;
    });

    it('blocks sensitive actions with 403 EMAIL_NOT_VERIFIED until verified', async () => {
      const book = await request(http)
        .post('/v1/consultations')
        .set(auth())
        .send({});
      expect(book.status).toBe(403);
      expect(err(book).code).toBe('EMAIL_NOT_VERIFIED');

      const review = await request(http)
        .post(`/v1/consultations/${someId}/reviews`)
        .set(auth())
        .send({});
      expect(review.status).toBe(403);
      expect(err(review).code).toBe('EMAIL_NOT_VERIFIED');

      // Everything else keeps working.
      const list = await request(http).get('/v1/consultations').set(auth());
      expect(list.status).toBe(200);
    });

    it('requires a session for verify and resend', async () => {
      const verify = await request(http)
        .post('/v1/auth/email/verify')
        .send({ code: '123456' });
      expect(verify.status).toBe(401);

      const resend = await request(http).post('/v1/auth/email/resend');
      expect(resend.status).toBe(401);
    });

    it('refuses a resend inside the cooldown with 429 + Retry-After', async () => {
      const res = await request(http)
        .post('/v1/auth/email/resend')
        .set(auth());
      expect(res.status).toBe(429);
      expect(err(res).code).toBe('TOO_MANY_REQUESTS');
      const retryAfter = Number(res.headers['retry-after']);
      expect(retryAfter).toBeGreaterThan(0);
      expect(retryAfter).toBeLessThanOrEqual(60);
    });

    it('rejects a wrong code with INVALID_VERIFICATION_CODE', async () => {
      const signUpCode = app.get(OtpService).peekDevCode(verifier.email);
      const wrong = signUpCode === '000000' ? '111111' : '000000';

      const res = await request(http)
        .post('/v1/auth/email/verify')
        .set(auth())
        .send({ code: wrong });
      expect(res.status).toBe(422);
      expect(err(res).code).toBe('INVALID_VERIFICATION_CODE');
      expect(err(res).errors?.code).toBeDefined();
    });

    it('resends after the cooldown and retires the previous code', async () => {
      const otp = app.get(OtpService);
      const oldCode = otp.peekDevCode(verifier.email)!;
      await ageCodes(verifier.email, 61);

      const res = await request(http)
        .post('/v1/auth/email/resend')
        .set(auth());
      expect(res.status).toBe(204);

      const newCode = otp.peekDevCode(verifier.email)!;
      if (newCode !== oldCode) {
        const stale = await request(http)
          .post('/v1/auth/email/verify')
          .set(auth())
          .send({ code: oldCode });
        expect(err(stale).code).toBe('INVALID_VERIFICATION_CODE');
      }
    });

    it('verifies with the latest code and unlocks sensitive actions', async () => {
      const code = app.get(OtpService).peekDevCode(verifier.email)!;

      const res = await request(http)
        .post('/v1/auth/email/verify')
        .set(auth())
        .send({ code });
      expect(res.status).toBe(200);
      expect(ok<{ user: UserView }>(res).user.emailVerified).toBe(true);

      const me = await request(http).get('/v1/auth/me').set(auth());
      expect(ok<{ user: UserView }>(me).user.emailVerified).toBe(true);

      // Past the gate: the unknown consultation is now a plain 404.
      const review = await request(http)
        .post(`/v1/consultations/${someId}/reviews`)
        .set(auth())
        .send({ rating: 5 });
      expect(review.status).not.toBe(403);
    });

    it('treats verify and resend as no-ops once verified', async () => {
      const again = await request(http)
        .post('/v1/auth/email/verify')
        .set(auth())
        .send({ code: '000000' });
      expect(again.status).toBe(200);
      expect(ok<{ user: UserView }>(again).user.emailVerified).toBe(true);

      const resend = await request(http)
        .post('/v1/auth/email/resend')
        .set(auth());
      expect(resend.status).toBe(204);
    });

    it('marks a changed email unverified again', async () => {
      const newEmail = `verifier.changed.${tag}@test.com`;
      const res = await request(http)
        .patch('/v1/auth/me')
        .set(auth())
        .send({ fullName: verifier.fullName, email: newEmail });
      expect(res.status).toBe(200);
      expect(ok<{ user: UserView }>(res).user.emailVerified).toBe(false);
      expect(app.get(OtpService).peekDevCode(newEmail)).toMatch(/^\d{6}$/);
    });

    it('refuses a profile email that another account uses', async () => {
      const res = await request(http)
        .patch('/v1/auth/me')
        .set(auth())
        .send({ fullName: verifier.fullName, email: lawyer.email });
      expect(res.status).toBe(422);
      expect(err(res).code).toBe('EMAIL_ALREADY_REGISTERED');
    });

    it('caps codes per account per hour', async () => {
      const capped = { ...individual, email: `capped.${tag}@test.com` };
      const reg = await request(http).post('/v1/auth/register').send(capped);
      const token = ok<{ tokens: Tokens }>(reg).tokens.accessToken;
      const user = ok<{ user: UserView }>(reg).user;

      // Sign-up code + 4 more = the default hourly cap of 5, all older
      // than the cooldown.
      for (let i = 0; i < 4; i++) {
        await app
          .get(OtpService)
          .issue(capped.email, 'emailVerification', user.id);
      }
      await ageCodes(capped.email, 120);

      const res = await request(http)
        .post('/v1/auth/email/resend')
        .set('authorization', `Bearer ${token}`);
      expect(res.status).toBe(429);
      const retryAfter = Number(res.headers['retry-after']);
      expect(retryAfter).toBeGreaterThan(60);
      expect(retryAfter).toBeLessThanOrEqual(3600);
    });
  });

  describe('change password', () => {
    it('re-verifies the current password and keeps the caller signed in', async () => {
      const session = await login(individual.email, individual.password);
      const access = ok<{ tokens: Tokens }>(session).tokens.accessToken;

      const wrong = await request(http)
        .post('/v1/auth/password/change')
        .set('authorization', `Bearer ${access}`)
        .send({ currentPassword: 'Nope1234', newPassword: 'Changed123' });
      expect(wrong.status).toBe(422);

      const done = await request(http)
        .post('/v1/auth/password/change')
        .set('authorization', `Bearer ${access}`)
        .send({
          currentPassword: individual.password,
          newPassword: 'Changed123',
        });
      expect(done.status).toBe(204);

      const stillMe = await request(http)
        .get('/v1/auth/me')
        .set('authorization', `Bearer ${access}`);
      expect(stillMe.status).toBe(200);

      const oldPw = await login(individual.email, individual.password);
      expect(oldPw.status).toBe(401);

      individual.password = 'Changed123';
    });
  });
});
