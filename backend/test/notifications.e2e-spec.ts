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
 * Notifications end to end: consultation changes notify the other
 * participant, each account sees only its own, and the lawyer's own
 * profile at /v1/lawyers/me. Requires PostgreSQL reachable at DATABASE_URL.
 */

interface NotificationView {
  id: string;
  type: string;
  relatedId: string | null;
  params: Record<string, string>;
  isRead: boolean;
}
interface NotificationList {
  data: NotificationView[];
  meta: { unreadCount: number };
}

describe('Notifications (e2e)', () => {
  let app: INestApplication;
  let http: Server;
  const prisma = new PrismaClient();
  const tag = Date.now();
  const accounts = {} as Record<'client' | 'other' | 'lawyer', TestAccount>;
  let lawyerProfileId = '';
  const slotStart = new Date(Date.now() + 3 * 24 * 60 * 60 * 1000);
  slotStart.setUTCMinutes(0, 0, 0);

  const inbox = async (key: keyof typeof accounts) => {
    const res = await request(http)
      .get('/v1/notifications')
      .set(bearer(accounts[key]));
    expect(res.status).toBe(200);
    return res.body as NotificationList;
  };

  beforeAll(async () => {
    app = await createE2EApp();
    http = app.getHttpServer() as Server;
    const register = accountRegistrar(http, 'notify', tag);
    accounts.client = await register('client', individualSignup);
    accounts.other = await register('other', individualSignup);
    accounts.lawyer = await register('lawyer', lawyerSignup(`BAR-N-${tag}`));
    await prisma.user.update({
      where: { id: accounts.client.id },
      data: { phoneVerifiedAt: new Date() },
    });
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

  it('shows a lawyer their own profile, hidden from the public until verified', async () => {
    const mine = await request(http)
      .get('/v1/lawyers/me')
      .set(bearer(accounts.lawyer));
    expect(mine.status).toBe(200);
    expect(ok<{ id: string; verificationStatus: string }>(mine)).toMatchObject({
      id: lawyerProfileId,
      verificationStatus: 'unverified',
    });

    const asClient = await request(http)
      .get('/v1/lawyers/me')
      .set(bearer(accounts.client));
    expect(asClient.status).toBe(403);

    const publicView = await request(http)
      .get(`/v1/lawyers/${lawyerProfileId}`)
      .set(bearer(accounts.client));
    expect(publicView.status).toBe(404);
  });

  it('notifies the other participant of each consultation change', async () => {
    await prisma.lawyerProfile.update({
      where: { id: lawyerProfileId },
      data: {
        verificationStatus: 'verified',
        offerings: { create: { consultationType: 'video', price: 50 } },
      },
    });
    const slot = await request(http)
      .post('/v1/lawyers/me/availability')
      .set(bearer(accounts.lawyer))
      .send({
        start: slotStart.toISOString(),
        end: new Date(slotStart.getTime() + 60 * 60 * 1000).toISOString(),
      });
    expect(slot.status).toBe(201);

    const booked = await request(http)
      .post('/v1/consultations')
      .set(bearer(accounts.client))
      .send({
        lawyerId: lawyerProfileId,
        type: 'video',
        scheduledAt: slotStart.toISOString(),
      });
    expect(booked.status).toBe(201);
    const consultationId = ok<{ id: string }>(booked).id;

    let lawyerInbox = await inbox('lawyer');
    expect(lawyerInbox.meta.unreadCount).toBe(1);
    expect(lawyerInbox.data[0]).toMatchObject({
      type: 'consultationRequested',
      relatedId: consultationId,
      isRead: false,
      params: {
        actorName: accounts.client.fullName,
        scheduledAt: slotStart.toISOString(),
      },
    });
    expect((await inbox('client')).data).toHaveLength(0);

    const accepted = await request(http)
      .post(`/v1/consultations/${consultationId}/accept`)
      .set(bearer(accounts.lawyer));
    expect(accepted.status).toBe(201);
    const clientInbox = await inbox('client');
    expect(clientInbox.data[0]).toMatchObject({
      type: 'consultationAccepted',
      params: { actorName: accounts.lawyer.fullName },
    });

    // A repeated accept changes nothing and notifies no one again.
    const again = await request(http)
      .post(`/v1/consultations/${consultationId}/accept`)
      .set(bearer(accounts.lawyer));
    expect(again.status).toBe(400);
    expect((await inbox('client')).data).toHaveLength(1);

    const cancelled = await request(http)
      .post(`/v1/consultations/${consultationId}/cancel`)
      .set(bearer(accounts.client))
      .send({});
    expect(cancelled.status).toBe(201);
    lawyerInbox = await inbox('lawyer');
    expect(lawyerInbox.data.map((n) => n.type)).toEqual([
      'consultationCancelled',
      'consultationRequested',
    ]);
  });

  it('lets only the owner read or delete a notification', async () => {
    const [latest, older] = (await inbox('lawyer')).data;

    const foreignRead = await request(http)
      .post(`/v1/notifications/${latest.id}/read`)
      .set(bearer(accounts.other));
    expect(foreignRead.status).toBe(404);
    const foreignDelete = await request(http)
      .delete(`/v1/notifications/${latest.id}`)
      .set(bearer(accounts.other));
    expect(foreignDelete.status).toBe(404);

    const read = await request(http)
      .post(`/v1/notifications/${latest.id}/read`)
      .set(bearer(accounts.lawyer));
    expect(read.status).toBe(204);
    expect((await inbox('lawyer')).meta.unreadCount).toBe(1);

    const readAll = await request(http)
      .post('/v1/notifications/read-all')
      .set(bearer(accounts.lawyer));
    expect(readAll.status).toBe(204);
    expect((await inbox('lawyer')).meta.unreadCount).toBe(0);

    const deleted = await request(http)
      .delete(`/v1/notifications/${older.id}`)
      .set(bearer(accounts.lawyer));
    expect(deleted.status).toBe(204);
    expect((await inbox('lawyer')).data.map((n) => n.id)).toEqual([latest.id]);
  });

  it('requires a signed-in caller', async () => {
    const res = await request(http).get('/v1/notifications');
    expect(res.status).toBe(401);
  });
});
