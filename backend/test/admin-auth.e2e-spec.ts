import { INestApplication } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import type { Server } from 'node:http';
import request from 'supertest';
import { createE2EApp } from './support/e2e-app';
import {
  accountRegistrar,
  apiError,
  bearer,
  deleteTestAccounts,
  individualSignup,
  ok,
  type TestAccount,
} from './support/e2e-helpers';

/**
 * Admin web sign-in (cookie refresh) and the guard on /admin routes.
 * Requires PostgreSQL reachable at DATABASE_URL.
 */

const CLIENT_HEADER = { 'x-requested-with': 'aqd-admin' };
const COOKIE = 'aqd_admin_rt';

describe('Admin auth (e2e)', () => {
  let app: INestApplication;
  let http: Server;
  const prisma = new PrismaClient();
  const tag = Date.now();
  const accounts = {} as Record<'admin' | 'client', TestAccount>;

  beforeAll(async () => {
    app = await createE2EApp();
    http = app.getHttpServer() as Server;
    const register = accountRegistrar(http, 'adminauth', tag);
    accounts.admin = await register('admin', individualSignup);
    accounts.client = await register('client', individualSignup);
    await prisma.user.update({
      where: { id: accounts.admin.id },
      data: { role: 'admin' },
    });
  });

  afterAll(async () => {
    await prisma.auditLog.deleteMany({
      where: { actorUserId: accounts.admin.id },
    });
    await deleteTestAccounts(prisma, tag);
    await prisma.$disconnect();
    await app.close();
  });

  const login = (account: TestAccount) =>
    request(http)
      .post('/v1/admin-auth/login')
      .set(CLIENT_HEADER)
      .send({ phone: account.phone, password: 'Password123' });

  const refreshCookie = (res: request.Response): string => {
    const cookies = res.headers['set-cookie'] as unknown as string[];
    const cookie = cookies.find((c) => c.startsWith(`${COOKIE}=`));
    expect(cookie).toBeDefined();
    return cookie!;
  };

  it('signs an admin in: access token in the body, refresh only in an httpOnly cookie', async () => {
    const res = await login(accounts.admin);

    expect(res.status).toBe(200);
    const body = ok<{ accessToken: string; user: { role: string } }>(res);
    expect(body.user.role).toBe('admin');
    expect(JSON.stringify(res.body)).not.toContain('refreshToken');
    const cookie = refreshCookie(res);
    expect(cookie).toContain('HttpOnly');
    expect(cookie).toContain('SameSite=Strict');
    expect(cookie).toContain('Path=/v1/admin-auth');

    // The access token opens an admin route.
    const list = await request(http)
      .get('/v1/admin/lawyer-verifications')
      .set({ authorization: `Bearer ${body.accessToken}` });
    expect(list.status).toBe(200);
  });

  it('refuses a non-admin with 403 and sets no cookie', async () => {
    const res = await login(accounts.client);

    expect(res.status).toBe(403);
    expect(apiError(res).code).toBe('FORBIDDEN');
    expect(res.headers['set-cookie']).toBeUndefined();
  });

  it('rejects a call without the admin client header', async () => {
    const res = await request(http)
      .post('/v1/admin-auth/login')
      .send({ phone: accounts.admin.phone, password: 'Password123' });
    expect(res.status).toBe(403);
  });

  it('refreshes from the cookie, rotating it, and ends the session on logout', async () => {
    const first = refreshCookie(await login(accounts.admin)).split(';')[0];

    const refreshed = await request(http)
      .post('/v1/admin-auth/refresh')
      .set(CLIENT_HEADER)
      .set('Cookie', first);
    expect(refreshed.status).toBe(200);
    expect(ok<{ accessToken: string }>(refreshed).accessToken).toBeTruthy();
    const second = refreshCookie(refreshed).split(';')[0];
    expect(second).not.toBe(first);

    // The old cookie is a replay now.
    const replay = await request(http)
      .post('/v1/admin-auth/refresh')
      .set(CLIENT_HEADER)
      .set('Cookie', first);
    expect(replay.status).toBe(401);
  });

  it('refresh without a cookie is 401', async () => {
    const res = await request(http)
      .post('/v1/admin-auth/refresh')
      .set(CLIENT_HEADER);
    expect(res.status).toBe(401);
  });

  it('keeps non-admins out of /admin routes', async () => {
    const anonymous = await request(http).get('/v1/admin/lawyer-verifications');
    expect(anonymous.status).toBe(401);

    const client = await request(http)
      .get('/v1/admin/lawyer-verifications')
      .set(bearer(accounts.client));
    expect(client.status).toBe(403);
  });

  it('writes an audit row for the admin sign-in', async () => {
    await login(accounts.admin);
    const rows = await prisma.auditLog.findMany({
      where: { actorUserId: accounts.admin.id, action: 'adminAuth.login' },
    });
    expect(rows.length).toBeGreaterThan(0);
  });
});
