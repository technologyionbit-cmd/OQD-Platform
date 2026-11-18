import { INestApplication } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import type { Server } from 'node:http';
import request from 'supertest';
import { createE2EApp } from './support/e2e-app';
import {
  accountRegistrar,
  bearer,
  deleteTestAccounts,
  individualSignup,
  lawyerSignup,
  ok,
  type TestAccount,
} from './support/e2e-helpers';

/**
 * Public marketplace access (AUD-01 / TST-02) and availability rules
 * (BIZ-02 / PERF-01). Requires PostgreSQL reachable at DATABASE_URL.
 */
describe('Lawyers: public browsing and availability (e2e)', () => {
  let app: INestApplication;
  let http: Server;
  const prisma = new PrismaClient();
  const tag = Date.now();
  const accounts = {} as Record<'client' | 'lawyer', TestAccount>;
  let lawyerProfileId = '';
  const HOUR = 60 * 60 * 1000;
  const at = (offsetMs: number) => {
    const d = new Date(Date.now() + offsetMs);
    d.setUTCMinutes(0, 0, 0);
    return d;
  };

  beforeAll(async () => {
    app = await createE2EApp();
    http = app.getHttpServer() as Server;
    const register = accountRegistrar(http, 'publ', tag);
    accounts.client = await register('client', individualSignup);
    accounts.lawyer = await register('lawyer', lawyerSignup(`BAR-P-${tag}`));
    lawyerProfileId = (
      await prisma.lawyerProfile.findUniqueOrThrow({
        where: { userId: accounts.lawyer.id },
      })
    ).id;
  });

  afterAll(async () => {
    await deleteTestAccounts(prisma, tag);
    await prisma.$disconnect();
    await app.close();
  });

  it('hides an unverified lawyer from anonymous visitors', async () => {
    const res = await request(http).get(`/v1/lawyers/${lawyerProfileId}`);
    expect(res.status).toBe(404);
  });

  it('lets an anonymous visitor list and open a verified lawyer, without private fields', async () => {
    await prisma.lawyerProfile.update({
      where: { id: lawyerProfileId },
      data: {
        verificationStatus: 'verified',
        offerings: { create: { consultationType: 'video', price: 50 } },
      },
    });

    const list = await request(http).get('/v1/lawyers');
    expect(list.status).toBe(200);
    const listed = (list.body as { data: { id: string }[] }).data;
    expect(listed.some((l) => l.id === lawyerProfileId)).toBe(true);

    const one = await request(http).get(`/v1/lawyers/${lawyerProfileId}`);
    expect(one.status).toBe(200);
    const view = ok<Record<string, unknown>>(one);
    expect(view.id).toBe(lawyerProfileId);
    for (const forbidden of [
      'phone',
      'email',
      'userId',
      'barLicenseNumber',
    ]) {
      expect(view).not.toHaveProperty(forbidden);
    }
  });

  it('keeps the lawyer-only and reviewer endpoints behind authentication', async () => {
    expect((await request(http).get('/v1/lawyers/me')).status).toBe(401);
    expect(
      (await request(http).get(`/v1/lawyers/${lawyerProfileId}/reviews`))
        .status,
    ).toBe(401);
    expect(
      (await request(http).get('/v1/lawyers/me').set(bearer(accounts.client)))
        .status,
    ).toBe(403);
  });

  it('serves reviews without reviewer ids to a signed-in user', async () => {
    const res = await request(http)
      .get(`/v1/lawyers/${lawyerProfileId}/reviews`)
      .set(bearer(accounts.client));
    expect(res.status).toBe(200);
    expect(JSON.stringify(res.body)).not.toContain('reviewerUserId');
  });

  it('rejects past, over-long and overlapping slots; accepts a valid one', async () => {
    const post = (start: Date, end: Date) =>
      request(http)
        .post('/v1/lawyers/me/availability')
        .set(bearer(accounts.lawyer))
        .send({ start: start.toISOString(), end: end.toISOString() });

    expect((await post(at(-3 * HOUR), at(-2 * HOUR))).status).toBe(400);
    expect((await post(at(2 * HOUR), at(12 * HOUR))).status).toBe(400);

    const start = at(48 * HOUR);
    expect((await post(start, new Date(start.getTime() + HOUR))).status).toBe(
      201,
    );
    expect(
      (
        await post(
          new Date(start.getTime() + 30 * 60 * 1000),
          new Date(start.getTime() + 90 * 60 * 1000),
        )
      ).status,
    ).toBe(409);
  });

  it('does not list slots that already started, and refuses to book one', async () => {
    const past = await prisma.availabilitySlot.create({
      data: {
        lawyerProfileId,
        startAt: at(-5 * HOUR),
        endAt: at(-4 * HOUR),
      },
    });

    const res = await request(http)
      .get(`/v1/lawyers/${lawyerProfileId}/availability`)
      .set(bearer(accounts.client));
    expect(res.status).toBe(200);
    const slots = ok<{ id: string }[]>(res);
    expect(slots.some((s) => s.id === past.id)).toBe(false);

    await prisma.user.update({
      where: { id: accounts.client.id },
      data: { phoneVerifiedAt: new Date() },
    });
    const booked = await request(http)
      .post('/v1/consultations')
      .set(bearer(accounts.client))
      .send({
        lawyerId: lawyerProfileId,
        type: 'video',
        scheduledAt: past.startAt.toISOString(),
      });
    expect(booked.status).toBe(400);
  });
});
