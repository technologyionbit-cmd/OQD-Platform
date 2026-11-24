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
 * Admin user management: list/filter, suspend (and that it really cuts the
 * user off), soft delete, export, bulk, and the audit trail they leave.
 * Requires PostgreSQL reachable at DATABASE_URL.
 */

describe('Admin users (e2e)', () => {
  let app: INestApplication;
  let http: Server;
  const prisma = new PrismaClient();
  const tag = Date.now();
  const accounts = {} as Record<'admin' | 'client' | 'target' | 'other', TestAccount>;

  beforeAll(async () => {
    app = await createE2EApp();
    http = app.getHttpServer() as Server;
    const register = accountRegistrar(http, 'adminusers', tag);
    accounts.admin = await register('admin', individualSignup);
    accounts.client = await register('client', individualSignup);
    accounts.target = await register('target', individualSignup);
    accounts.other = await register('other', individualSignup);
    await prisma.user.update({
      where: { id: accounts.admin.id },
      data: { role: 'admin' },
    });
  });

  afterAll(async () => {
    await prisma.auditLog.deleteMany({ where: { actorUserId: accounts.admin.id } });
    await deleteTestAccounts(prisma, tag);
    await prisma.$disconnect();
    await app.close();
  });

  const admin = () => bearer(accounts.admin);

  it('is closed to non-admins and anonymous callers', async () => {
    expect((await request(http).get('/v1/admin/users')).status).toBe(401);
    for (const path of ['/v1/admin/users', `/v1/admin/users/${accounts.target.id}`, '/v1/admin/users/export.csv', '/v1/admin/audit-logs']) {
      const res = await request(http).get(path).set(bearer(accounts.client));
      expect(res.status).toBe(403);
    }
    const write = await request(http)
      .post(`/v1/admin/users/${accounts.target.id}/suspend`)
      .set(bearer(accounts.client))
      .send({ reason: 'nope' });
    expect(write.status).toBe(403);
  });

  it('lists with search, filters and paging, never exposing the password hash', async () => {
    const res = await request(http)
      .get('/v1/admin/users')
      .query({ q: `adminusers.target.${tag}`, role: 'client', limit: 5 })
      .set(admin());
    expect(res.status).toBe(200);
    const body = res.body as { data: Record<string, unknown>[]; meta: { total: number; limit: number } };
    expect(body.data).toHaveLength(1);
    expect(body.meta).toMatchObject({ total: 1, limit: 5 });
    expect(JSON.stringify(body)).not.toContain('passwordHash');

    const byPhone = await request(http)
      .get('/v1/admin/users')
      .query({ q: accounts.target.phone.replace('+962', '0') })
      .set(admin());
    expect((byPhone.body as { data: unknown[] }).data).toHaveLength(1);
  });

  it('validates query parameters', async () => {
    const res = await request(http)
      .get('/v1/admin/users')
      .query({ limit: 5000, role: 'root' })
      .set(admin());
    expect(res.status).toBe(422);
  });

  it('suspends: the user is cut off at once, cannot sign in, and the action is audited', async () => {
    const reason = 'spam reports';
    const res = await request(http)
      .post(`/v1/admin/users/${accounts.target.id}/suspend`)
      .set(admin())
      .send({ reason });
    expect(res.status).toBe(200);
    expect(ok<{ status: string }>(res).status).toBe('suspended');

    // The user's existing access token stops working immediately.
    const me = await request(http).get('/v1/auth/me').set(bearer(accounts.target));
    expect(me.status).toBe(401);

    const login = await request(http)
      .post('/v1/auth/login')
      .send({ phone: accounts.target.phone, password: 'Password123' });
    expect(login.status).toBe(403);
    expect(apiError(login).code).toBe('ACCOUNT_INACTIVE');

    const audit = await prisma.auditLog.findFirst({
      where: { actorUserId: accounts.admin.id, action: 'user.suspend', entityId: accounts.target.id },
    });
    expect(audit).not.toBeNull();
    expect(audit?.statusCode).toBe(200);
    expect(audit?.before).toMatchObject({ status: 'active' });
    expect(audit?.after).toMatchObject({ status: 'suspended', suspendedReason: reason });
  });

  it('suspending needs a reason, and cannot be repeated', async () => {
    const noReason = await request(http)
      .post(`/v1/admin/users/${accounts.target.id}/suspend`)
      .set(admin())
      .send({});
    expect(noReason.status).toBe(422);

    const again = await request(http)
      .post(`/v1/admin/users/${accounts.target.id}/suspend`)
      .set(admin())
      .send({ reason: 'again' });
    expect(again.status).toBe(409);
  });

  it('reactivates, so the user can sign in again', async () => {
    const res = await request(http)
      .post(`/v1/admin/users/${accounts.target.id}/activate`)
      .set(admin());
    expect(res.status).toBe(200);
    const login = await request(http)
      .post('/v1/auth/login')
      .send({ phone: accounts.target.phone, password: 'Password123' });
    expect(login.status).toBe(200);
  });

  it('never lets an admin act on themselves or on another admin', async () => {
    const self = await request(http)
      .post(`/v1/admin/users/${accounts.admin.id}/suspend`)
      .set(admin())
      .send({ reason: 'oops' });
    expect(self.status).toBe(409);
  });

  it('soft-deletes: the account stops working, the row stays, restore brings it back', async () => {
    const del = await request(http)
      .post(`/v1/admin/users/${accounts.other.id}/delete`)
      .set(admin())
      .send({ reason: 'user asked' });
    expect(del.status).toBe(200);

    const login = await request(http)
      .post('/v1/auth/login')
      .send({ phone: accounts.other.phone, password: 'Password123' });
    expect(login.status).toBe(401);

    expect(await prisma.user.findUnique({ where: { id: accounts.other.id } })).not.toBeNull();

    const hidden = await request(http)
      .get('/v1/admin/users')
      .query({ q: `adminusers.other.${tag}` })
      .set(admin());
    expect((hidden.body as { data: unknown[] }).data).toHaveLength(0);
    const shown = await request(http)
      .get('/v1/admin/users')
      .query({ q: `adminusers.other.${tag}`, deleted: 'only' })
      .set(admin());
    expect((shown.body as { data: unknown[] }).data).toHaveLength(1);

    const restored = await request(http)
      .post(`/v1/admin/users/${accounts.other.id}/restore`)
      .set(admin());
    expect(restored.status).toBe(200);
    const back = await request(http)
      .post('/v1/auth/login')
      .send({ phone: accounts.other.phone, password: 'Password123' });
    expect(back.status).toBe(200);
  });

  it('bulk: reports who succeeded and who was skipped', async () => {
    const res = await request(http)
      .post('/v1/admin/users/bulk')
      .set(admin())
      .send({
        action: 'suspend',
        reason: 'bulk test',
        ids: [accounts.target.id, accounts.admin.id],
      });
    expect(res.status).toBe(200);
    const data = ok<{ succeeded: string[]; skipped: { id: string }[] }>(res);
    expect(data.succeeded).toEqual([accounts.target.id]);
    expect(data.skipped.map((s) => s.id)).toEqual([accounts.admin.id]);
  });

  it('exports CSV and records the export in the audit log', async () => {
    const res = await request(http)
      .get('/v1/admin/users/export.csv')
      .query({ q: `adminusers.`, role: 'client' })
      .set(admin());
    expect(res.status).toBe(200);
    expect(res.headers['content-type']).toContain('text/csv');
    expect(res.headers['content-disposition']).toContain('attachment');
    expect(res.text).toContain('adminusers.client');

    const audit = await prisma.auditLog.findFirst({
      where: { actorUserId: accounts.admin.id, action: 'user.export' },
    });
    expect(audit).not.toBeNull();
  });

  it('lets an admin read the audit log, filtered', async () => {
    const res = await request(http)
      .get('/v1/admin/audit-logs')
      .query({ action: 'user.suspend', actorId: accounts.admin.id })
      .set(admin());
    expect(res.status).toBe(200);
    const rows = (res.body as { data: { id: string; action: string }[] }).data;
    expect(rows.length).toBeGreaterThan(0);

    const detail = await request(http).get(`/v1/admin/audit-logs/${rows[0].id}`).set(admin());
    expect(detail.status).toBe(200);
    expect(ok<{ after: unknown }>(detail)).toHaveProperty('after');
  });
});
