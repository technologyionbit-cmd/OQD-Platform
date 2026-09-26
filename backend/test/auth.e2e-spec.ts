import { INestApplication } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import type { Server } from 'node:http';
import request from 'supertest';
import { createE2EApp } from './support/e2e-app';
import { OtpService } from '../src/auth/services/otp.service';

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
  const individual = {
    accountType: 'individual',
    fullName: 'Ahmad Client',
    phone: '0791234567',
    email: `ahmad.${tag}@test.com`,
    password: 'Password123',
  };
  const company = {
    accountType: 'company',
    companyName: 'Rowad Legal',
    commercialRegistrationNumber: `CR-${tag}`,
    phone: '0791111111',
    email: `company.${tag}@test.com`,
    password: 'Password123',
  };
  const lawyer = {
    accountType: 'lawyer',
    fullName: 'Sara Lawyer',
    barLicenseNumber: `BAR-${tag}`,
    mainSpecialty: 'commercial',
    phone: '0792222222',
    email: `lawyer.${tag}@test.com`,
    password: 'Password123',
  };

  beforeAll(async () => {
    app = await createE2EApp();
    http = app.getHttpServer() as Server;
  });

  afterAll(async () => {
    const emails = [individual.email, company.email, lawyer.email];
    const users = await prisma.user.findMany({
      where: { email: { in: emails } },
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
      });
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

    it('rejects a duplicate email with a 422 field error', async () => {
      const res = await request(http)
        .post('/v1/auth/register')
        .send(individual);
      expect(res.status).toBe(422);
      expect(err(res).errors?.email).toBeDefined();
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
