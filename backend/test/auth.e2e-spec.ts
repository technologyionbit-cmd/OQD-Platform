import { INestApplication } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import type { Server } from 'node:http';
import request from 'supertest';
import { createE2EApp } from './support/e2e-app';
import { apiError, ok, storedPhone, testPhone } from './support/e2e-helpers';
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
  phone: string;
  role: string;
  phoneVerified: boolean;
}
interface Tokens {
  accessToken: string;
  refreshToken: string;
}
interface SessionView {
  id: string;
  current: boolean;
}

describe('Auth (e2e)', () => {
  let app: INestApplication;
  let http: Server;
  const prisma = new PrismaClient();

  const tag = Date.now();
  const terms = { acceptTerms: true, termsVersion: DEFAULT_TERMS_VERSION };
  const individual = {
    accountType: 'individual',
    fullName: 'Ahmad Client',
    phone: testPhone(),
    email: `ahmad.${tag}@test.com`,
    password: 'Password123',
    ...terms,
  };
  const company = {
    accountType: 'company',
    companyName: 'Rowad Legal',
    commercialRegistrationNumber: `CR-${tag}`,
    phone: testPhone(),
    email: `company.${tag}@test.com`,
    password: 'Password123',
    ...terms,
  };
  const lawyer = {
    accountType: 'lawyer',
    fullName: 'Sara Lawyer',
    barLicenseNumber: `BAR-${tag}`,
    mainSpecialty: 'commercial',
    phone: testPhone(),
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

  const login = (phone: string, password: string) =>
    request(http).post('/v1/auth/login').send({ phone, password });

  describe('registration', () => {
    it('registers an individual and returns user + tokens', async () => {
      const res = await request(http)
        .post('/v1/auth/register')
        .send(individual);
      expect(res.status).toBe(201);

      const data = ok<{ user: UserView; tokens: Tokens }>(res);
      expect(data.user).toMatchObject({
        email: individual.email,
        phone: storedPhone(individual.phone),
        role: 'client',
        fullName: individual.fullName,
        phoneVerified: false,
      });

      const stored = await prisma.user.findUnique({
        where: { email: individual.email },
      });
      expect(stored?.termsVersion).toBe(DEFAULT_TERMS_VERSION);
      expect(stored?.termsAcceptedAt).toBeInstanceOf(Date);
      expect(typeof data.tokens.accessToken).toBe('string');
      expect(typeof data.tokens.refreshToken).toBe('string');
    });

    it('texts the sign-up code to the normalized number', () => {
      expect(
        app.get(OtpService).peekDevCode(storedPhone(individual.phone)),
      ).toMatch(/^\d{6}$/);
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
        .send({
          ...individual,
          phone: testPhone(),
          email: individual.email.toUpperCase(),
        });
      expect(res.status).toBe(422);
      expect(apiError(res).code).toBe('EMAIL_ALREADY_REGISTERED');
      expect(apiError(res).errors?.email).toBeDefined();
    });

    it('rejects a number already in use, in any spelling, with PHONE_ALREADY_REGISTERED', async () => {
      const res = await request(http)
        .post('/v1/auth/register')
        .send({
          ...individual,
          email: `samephone.${tag}@test.com`,
          phone: storedPhone(individual.phone),
        });
      expect(res.status).toBe(422);
      expect(apiError(res).code).toBe('PHONE_ALREADY_REGISTERED');
      expect(apiError(res).errors?.phone).toBeDefined();
    });

    it('rejects a number that is not a Jordanian mobile', async () => {
      const res = await request(http)
        .post('/v1/auth/register')
        .send({
          ...individual,
          email: `badphone.${tag}@test.com`,
          phone: '+966501234567',
        });
      expect(res.status).toBe(422);
      expect(apiError(res).errors?.phone).toBeDefined();
    });

    it('rejects a taken commercial registration number with its own code', async () => {
      const res = await request(http)
        .post('/v1/auth/register')
        .send({
          ...company,
          phone: testPhone(),
          email: `company2.${tag}@test.com`,
        });
      expect(res.status).toBe(422);
      expect(apiError(res).code).toBe('COMMERCIAL_REGISTRATION_TAKEN');
      expect(apiError(res).errors?.commercialRegistrationNumber).toBeDefined();
    });

    it('rejects a taken bar license number with its own code', async () => {
      const res = await request(http)
        .post('/v1/auth/register')
        .send({
          ...lawyer,
          phone: testPhone(),
          email: `lawyer2.${tag}@test.com`,
        });
      expect(res.status).toBe(422);
      expect(apiError(res).code).toBe('BAR_LICENSE_TAKEN');
      expect(apiError(res).errors?.barLicenseNumber).toBeDefined();
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
      expect(apiError(res).errors?.acceptTerms).toBeDefined();
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
      expect(apiError(res).code).toBe('TERMS_VERSION_OUTDATED');
      expect(apiError(res).errors?.termsVersion).toBeDefined();
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
      expect(apiError(res).errors?.password).toBeDefined();
    });

    it('rejects a weak password with a 422', async () => {
      const res = await request(http)
        .post('/v1/auth/register')
        .send({
          ...individual,
          email: `weak.${tag}@test.com`,
          password: 'short',
        });
      expect(res.status).toBe(422);
      expect(apiError(res).errors?.password).toBeDefined();
    });
  });

  describe('login + session lifecycle', () => {
    it('logs in with the phone number in any spelling', async () => {
      const res = await login(individual.phone, individual.password);
      expect(res.status).toBe(200);
      expect(ok<{ user: UserView }>(res).user.email).toBe(individual.email);

      const international = await login(
        storedPhone(individual.phone),
        individual.password,
      );
      expect(international.status).toBe(200);
    });

    it('no longer signs in with the email', async () => {
      const res = await request(http)
        .post('/v1/auth/login')
        .send({ email: individual.email, password: individual.password });
      expect(res.status).toBe(422);
    });

    it('returns a generic 401 for a bad password', async () => {
      const res = await login(individual.phone, 'WrongPass123');
      expect(res.status).toBe(401);
      expect(apiError(res).code).toBe('UNAUTHORIZED');
    });

    it('answers an unknown number exactly like a wrong password', async () => {
      const unknown = await login(testPhone(), 'WrongPass123');
      const wrongPassword = await login(individual.phone, 'WrongPass123');

      expect(unknown.status).toBe(401);
      expect(unknown.body).toEqual(wrongPassword.body);
    });

    it('limits attempts per number regardless of IP, with Retry-After', async () => {
      // An unknown number on purpose: the limit must behave identically for
      // accounts that don't exist, or it would reveal which ones do.
      const target = testPhone();
      for (let i = 0; i < 10; i++) {
        expect((await login(target, `Guess${i}pass`)).status).toBe(401);
      }

      // Another spelling of the same number shares the counter.
      const blocked = await login(storedPhone(target), 'Guess10pass');

      expect(blocked.status).toBe(429);
      expect(apiError(blocked).code).toBe('TOO_MANY_REQUESTS');
      expect(Number(blocked.headers['retry-after'])).toBeGreaterThan(0);
      // Other accounts are unaffected.
      expect((await login(individual.phone, individual.password)).status).toBe(
        200,
      );
    });

    it('refuses an inactive account with ACCOUNT_INACTIVE after a correct password', async () => {
      await prisma.user.update({
        where: { email: company.email },
        data: { status: 'suspended' },
      });
      try {
        const res = await login(company.phone, company.password);
        expect(res.status).toBe(403);
        expect(apiError(res).code).toBe('ACCOUNT_INACTIVE');

        // Without the right password it stays an indistinguishable 401.
        const guess = await login(company.phone, 'WrongPass123');
        expect(guess.status).toBe(401);
      } finally {
        await prisma.user.update({
          where: { email: company.email },
          data: { status: 'active' },
        });
      }
    });

    it('refreshes, rotates the refresh token, and detects reuse', async () => {
      const session = await login(individual.phone, individual.password);
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

      const session = await login(individual.phone, individual.password);
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
      const first = await login(lawyer.phone, lawyer.password);
      await login(lawyer.phone, lawyer.password);
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

  describe('password reset (texted code)', () => {
    const forgot = (phone: string) =>
      request(http).post('/v1/auth/password/forgot').send({ phone });

    it('runs forgot -> verify -> reset, verifies the phone and ends old sessions', async () => {
      const session = await login(company.phone, company.password);
      const staleAccess = ok<{ tokens: Tokens }>(session).tokens.accessToken;
      expect(ok<{ user: UserView }>(session).user.phoneVerified).toBe(false);

      // Any spelling of the number reaches the same account.
      const sent = await forgot(storedPhone(company.phone));
      expect(sent.status).toBe(204);

      const code = app.get(OtpService).peekDevCode(storedPhone(company.phone))!;
      expect(code).toMatch(/^\d{6}$/);
      const wrong = code === '000000' ? '111111' : '000000';

      const badVerify = await request(http)
        .post('/v1/auth/password/verify-otp')
        .send({ phone: company.phone, code: wrong });
      expect(badVerify.status).toBe(422);
      expect(apiError(badVerify).code).toBe('INVALID_VERIFICATION_CODE');

      const goodVerify = await request(http)
        .post('/v1/auth/password/verify-otp')
        .send({ phone: company.phone, code });
      expect(goodVerify.status).toBe(204);

      const reset = await request(http)
        .post('/v1/auth/password/reset')
        .send({ phone: company.phone, code, newPassword: 'Rotated123' });
      expect(reset.status).toBe(204);
      company.password = 'Rotated123';

      const stale = await request(http)
        .get('/v1/auth/me')
        .set('authorization', `Bearer ${staleAccess}`);
      expect(stale.status).toBe(401);

      const fresh = await login(company.phone, 'Rotated123');
      expect(fresh.status).toBe(200);
      expect(ok<{ user: UserView }>(fresh).user.phoneVerified).toBe(true);

      // The code is used up.
      const reused = await request(http)
        .post('/v1/auth/password/reset')
        .send({ phone: company.phone, code, newPassword: 'Rotated456' });
      expect(reused.status).toBe(422);
      expect(apiError(reused).code).toBe('INVALID_VERIFICATION_CODE');
    });

    it('rejects a reset with a wrong code (422 INVALID_VERIFICATION_CODE)', async () => {
      const res = await request(http).post('/v1/auth/password/reset').send({
        phone: company.phone,
        code: '000000',
        newPassword: 'Rotated999',
      });
      expect(res.status).toBe(422);
      expect(apiError(res).code).toBe('INVALID_VERIFICATION_CODE');
    });

    it('answers an unknown number with 204 and sends it nothing usable', async () => {
      const phone = testPhone();
      expect((await forgot(phone)).status).toBe(204);

      // Even the stored code resets nothing: no account owns the number.
      const code = app.get(OtpService).peekDevCode(storedPhone(phone))!;
      const res = await request(http)
        .post('/v1/auth/password/reset')
        .send({ phone, code, newPassword: 'Rotated123' });
      expect(res.status).toBe(422);
      expect(apiError(res).code).toBe('INVALID_VERIFICATION_CODE');
    });

    it('limits sends per number the same way for unknown numbers', async () => {
      const phone = testPhone();
      expect((await forgot(phone)).status).toBe(204);

      const again = await forgot(storedPhone(phone));
      expect(again.status).toBe(429);
      expect(Number(again.headers['retry-after'])).toBeGreaterThan(0);
    });

    it('refuses anything but a Jordanian mobile number', async () => {
      const res = await request(http)
        .post('/v1/auth/password/forgot')
        .send({ email: individual.email });
      expect(res.status).toBe(422);
      expect(apiError(res).code).toBe('VALIDATION_ERROR');

      const landline = await forgot('065000000');
      expect(landline.status).toBe(422);
      expect(apiError(landline).errors?.phone).toBeDefined();
    });
  });

  describe('phone verification', () => {
    const verifier = {
      ...individual,
      fullName: 'Verify Me',
      phone: testPhone(),
      email: `verifier.${tag}@test.com`,
    };
    const verifierPhone = storedPhone(verifier.phone);
    let access = '';
    const auth = () => ({ authorization: `Bearer ${access}` });
    const someId = '00000000-0000-4000-8000-000000000000';

    /** Moves every code for [phone] back in time, as if the cooldown had
     *  passed, without the spec having to wait. */
    const ageCodes = async (phone: string, seconds: number) => {
      await prisma.$executeRaw`
        UPDATE verification_codes
        SET created_at = created_at - make_interval(secs => ${seconds})
        WHERE destination = ${phone}`;
    };

    beforeAll(async () => {
      const res = await request(http).post('/v1/auth/register').send(verifier);
      access = ok<{ tokens: Tokens }>(res).tokens.accessToken;
    });

    it('blocks sensitive actions with 403 PHONE_NOT_VERIFIED until verified', async () => {
      const book = await request(http)
        .post('/v1/consultations')
        .set(auth())
        .send({});
      expect(book.status).toBe(403);
      expect(apiError(book).code).toBe('PHONE_NOT_VERIFIED');

      const review = await request(http)
        .post(`/v1/consultations/${someId}/reviews`)
        .set(auth())
        .send({});
      expect(review.status).toBe(403);
      expect(apiError(review).code).toBe('PHONE_NOT_VERIFIED');

      // Everything else keeps working.
      const list = await request(http).get('/v1/consultations').set(auth());
      expect(list.status).toBe(200);
    });

    it('requires a session for verify and resend', async () => {
      const verify = await request(http)
        .post('/v1/auth/phone/verify')
        .send({ code: '123456' });
      expect(verify.status).toBe(401);

      const resend = await request(http).post('/v1/auth/phone/resend');
      expect(resend.status).toBe(401);
    });

    it('no longer serves the email verification endpoints', async () => {
      const res = await request(http)
        .post('/v1/auth/email/verify')
        .set(auth())
        .send({ code: '123456' });
      expect(res.status).toBe(404);
    });

    it('refuses a resend inside the cooldown with 429 + Retry-After', async () => {
      const res = await request(http).post('/v1/auth/phone/resend').set(auth());
      expect(res.status).toBe(429);
      expect(apiError(res).code).toBe('TOO_MANY_REQUESTS');
      const retryAfter = Number(res.headers['retry-after']);
      expect(retryAfter).toBeGreaterThan(0);
      expect(retryAfter).toBeLessThanOrEqual(60);
    });

    it('rejects a wrong code with INVALID_VERIFICATION_CODE', async () => {
      const signUpCode = app.get(OtpService).peekDevCode(verifierPhone);
      const wrong = signUpCode === '000000' ? '111111' : '000000';

      const res = await request(http)
        .post('/v1/auth/phone/verify')
        .set(auth())
        .send({ code: wrong });
      expect(res.status).toBe(422);
      expect(apiError(res).code).toBe('INVALID_VERIFICATION_CODE');
      expect(apiError(res).errors?.code).toBeDefined();
    });

    it('resends after the cooldown and retires the previous code', async () => {
      const otp = app.get(OtpService);
      const oldCode = otp.peekDevCode(verifierPhone)!;
      await ageCodes(verifierPhone, 61);

      const res = await request(http).post('/v1/auth/phone/resend').set(auth());
      expect(res.status).toBe(204);

      const newCode = otp.peekDevCode(verifierPhone)!;
      if (newCode !== oldCode) {
        const stale = await request(http)
          .post('/v1/auth/phone/verify')
          .set(auth())
          .send({ code: oldCode });
        expect(apiError(stale).code).toBe('INVALID_VERIFICATION_CODE');
      }
    });

    it('verifies with the latest code and unlocks sensitive actions', async () => {
      const code = app.get(OtpService).peekDevCode(verifierPhone)!;

      const res = await request(http)
        .post('/v1/auth/phone/verify')
        .set(auth())
        .send({ code });
      expect(res.status).toBe(200);
      expect(ok<{ user: UserView }>(res).user.phoneVerified).toBe(true);

      const me = await request(http).get('/v1/auth/me').set(auth());
      expect(ok<{ user: UserView }>(me).user.phoneVerified).toBe(true);

      // Past the gate: the unknown consultation is now a plain 404.
      const review = await request(http)
        .post(`/v1/consultations/${someId}/reviews`)
        .set(auth())
        .send({ rating: 5 });
      expect(review.status).not.toBe(403);
    });

    it('treats verify and resend as no-ops once verified', async () => {
      const again = await request(http)
        .post('/v1/auth/phone/verify')
        .set(auth())
        .send({ code: '000000' });
      expect(again.status).toBe(200);
      expect(ok<{ user: UserView }>(again).user.phoneVerified).toBe(true);

      const resend = await request(http)
        .post('/v1/auth/phone/resend')
        .set(auth());
      expect(resend.status).toBe(204);
    });

    it('changes the email without any code and keeps the phone verified', async () => {
      const newEmail = `verifier.changed.${tag}@test.com`;
      const res = await request(http)
        .patch('/v1/auth/me')
        .set(auth())
        .send({ fullName: verifier.fullName, email: newEmail });
      expect(res.status).toBe(200);
      expect(ok<{ user: UserView }>(res).user).toMatchObject({
        email: newEmail,
        phoneVerified: true,
      });
    });

    it('refuses a profile email that another account uses', async () => {
      const res = await request(http)
        .patch('/v1/auth/me')
        .set(auth())
        .send({ fullName: verifier.fullName, email: lawyer.email });
      expect(res.status).toBe(422);
      expect(apiError(res).code).toBe('EMAIL_ALREADY_REGISTERED');
    });

    it('caps codes per account per hour', async () => {
      const capped = {
        ...individual,
        phone: testPhone(),
        email: `capped.${tag}@test.com`,
      };
      const cappedPhone = storedPhone(capped.phone);
      const reg = await request(http).post('/v1/auth/register').send(capped);
      const token = ok<{ tokens: Tokens }>(reg).tokens.accessToken;
      const user = ok<{ user: UserView }>(reg).user;

      // Sign-up code + 4 more = the default hourly cap of 5, all older
      // than the cooldown.
      for (let i = 0; i < 4; i++) {
        await app
          .get(OtpService)
          .issue(cappedPhone, 'phoneVerification', user.id);
      }
      await ageCodes(cappedPhone, 120);

      const res = await request(http)
        .post('/v1/auth/phone/resend')
        .set('authorization', `Bearer ${token}`);
      expect(res.status).toBe(429);
      const retryAfter = Number(res.headers['retry-after']);
      expect(retryAfter).toBeGreaterThan(60);
      expect(retryAfter).toBeLessThanOrEqual(3600);
    });
  });

  describe('change password', () => {
    it('re-verifies the current password and keeps the caller signed in', async () => {
      const session = await login(individual.phone, individual.password);
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

      const oldPw = await login(individual.phone, individual.password);
      expect(oldPw.status).toBe(401);

      individual.password = 'Changed123';
    });
  });
});
