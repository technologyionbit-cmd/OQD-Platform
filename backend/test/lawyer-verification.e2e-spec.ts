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
  lawyerSignup,
  ok,
  type TestAccount,
} from './support/e2e-helpers';

/**
 * A lawyer's own profile (PATCH /lawyers/me), sending verification
 * documents, and the admin review that makes the lawyer bookable.
 * Requires PostgreSQL reachable at DATABASE_URL.
 */

interface MyProfile {
  id: string;
  bio: string;
  specialties: string[];
  consultationTypes: string[];
  pricing: Record<string, number>;
  verificationStatus: string;
  verificationRejectionReason: string | null;
}
interface PendingLawyer {
  lawyerProfileId: string;
  documents: { id: string; mimeType: string; originalName: string }[];
}

const PNG = Buffer.from([
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0, 0, 0, 0,
]);
const PDF = Buffer.from('%PDF-1.7\n%test\n');

describe('Lawyer profile and verification (e2e)', () => {
  let app: INestApplication;
  let http: Server;
  const prisma = new PrismaClient();
  const tag = Date.now();
  const accounts = {} as Record<'lawyer' | 'admin' | 'client', TestAccount>;
  let profileId = '';

  const profile = {
    bio: 'Commercial lawyer with ten years of practice.',
    yearsOfExperience: 10,
    specialties: ['commercial', 'corporate'],
    pricing: { video: 150, written: 60 },
  };

  beforeAll(async () => {
    app = await createE2EApp();
    http = app.getHttpServer() as Server;
    const register = accountRegistrar(http, 'verify', tag);
    accounts.lawyer = await register('lawyer', lawyerSignup(`BAR-V-${tag}`));
    accounts.admin = await register('admin', individualSignup);
    accounts.client = await register('client', individualSignup);
    await prisma.user.update({
      where: { id: accounts.admin.id },
      data: { role: 'admin' },
    });
    profileId = (
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

  it('saves the profile, prices and specialties', async () => {
    const res = await request(http)
      .patch('/v1/lawyers/me')
      .set(bearer(accounts.lawyer))
      .send(profile);
    expect(res.status).toBe(200);
    expect(ok<MyProfile>(res)).toMatchObject({
      bio: profile.bio,
      specialties: ['commercial', 'corporate'],
      pricing: { video: 150, written: 60 },
    });

    // Dropping a type deactivates it instead of deleting it.
    const narrowed = await request(http)
      .patch('/v1/lawyers/me')
      .set(bearer(accounts.lawyer))
      .send({ ...profile, pricing: { video: 175 } });
    expect(ok<MyProfile>(narrowed).consultationTypes).toEqual(['video']);
    const written = await prisma.lawyerConsultationOffering.findFirstOrThrow({
      where: { lawyerProfileId: profileId, consultationType: 'written' },
    });
    expect(written.isActive).toBe(false);
  });

  it('refuses bad prices and non-lawyers', async () => {
    const bad = await request(http)
      .patch('/v1/lawyers/me')
      .set(bearer(accounts.lawyer))
      .send({ ...profile, pricing: { video: -5, phone: 10 } });
    expect(bad.status).toBe(422);
    expect(apiError(bad).code).toBe('VALIDATION_ERROR');

    const empty = await request(http)
      .patch('/v1/lawyers/me')
      .set(bearer(accounts.lawyer))
      .send({ ...profile, pricing: {} });
    expect(empty.status).toBe(422);

    const asClient = await request(http)
      .patch('/v1/lawyers/me')
      .set(bearer(accounts.client))
      .send(profile);
    expect(asClient.status).toBe(403);
  });

  it('accepts only real JPEG, PNG or PDF documents', async () => {
    const fake = await request(http)
      .post('/v1/lawyers/me/verification')
      .set(bearer(accounts.lawyer))
      .attach(
        'documents',
        Buffer.from('<html>not a pdf</html>'),
        'license.pdf',
      );
    expect(fake.status).toBe(422);

    const none = await request(http)
      .post('/v1/lawyers/me/verification')
      .set(bearer(accounts.lawyer));
    expect(none.status).toBe(422);
  });

  it('moves a submission to pending review, once', async () => {
    const sent = await request(http)
      .post('/v1/lawyers/me/verification')
      .set(bearer(accounts.lawyer))
      .attach('documents', PNG, 'id-card.png')
      .attach('documents', PDF, 'bar-card.pdf');
    expect(sent.status).toBe(201);
    expect(ok<MyProfile>(sent).verificationStatus).toBe('pending');

    const again = await request(http)
      .post('/v1/lawyers/me/verification')
      .set(bearer(accounts.lawyer))
      .attach('documents', PNG, 'id-card.png');
    expect(again.status).toBe(409);
  });

  it('keeps the review routes for admins only', async () => {
    const asLawyer = await request(http)
      .get('/v1/admin/lawyer-verifications')
      .set(bearer(accounts.lawyer));
    expect(asLawyer.status).toBe(403);
    const anonymous = await request(http).get('/v1/admin/lawyer-verifications');
    expect(anonymous.status).toBe(401);
  });

  it('lets an admin read the documents and reject with a reason', async () => {
    const list = await request(http)
      .get('/v1/admin/lawyer-verifications')
      .set(bearer(accounts.admin));
    expect(list.status).toBe(200);
    const mine = ok<PendingLawyer[]>(list).find(
      (row) => row.lawyerProfileId === profileId,
    )!;
    expect(mine.documents.map((d) => d.mimeType).sort()).toEqual([
      'application/pdf',
      'image/png',
    ]);

    const pdf = mine.documents.find((d) => d.mimeType === 'application/pdf')!;
    const file = await request(http)
      .get(`/v1/admin/lawyer-verifications/${profileId}/documents/${pdf.id}`)
      .set(bearer(accounts.admin))
      .buffer(true)
      .parse((res, done) => {
        const chunks: Buffer[] = [];
        res.on('data', (chunk: Buffer) => chunks.push(chunk));
        res.on('end', () => done(null, Buffer.concat(chunks)));
      });
    expect(file.status).toBe(200);
    expect(file.headers['content-disposition']).toMatch(/^attachment/);
    expect((file.body as Buffer).equals(PDF)).toBe(true);

    const rejected = await request(http)
      .post(`/v1/admin/lawyer-verifications/${profileId}/reject`)
      .set(bearer(accounts.admin))
      .send({ reason: 'The bar card photo is blurry.' });
    expect(rejected.status).toBe(204);

    const me = ok<MyProfile>(
      await request(http).get('/v1/lawyers/me').set(bearer(accounts.lawyer)),
    );
    expect(me).toMatchObject({
      verificationStatus: 'rejected',
      verificationRejectionReason: 'The bar card photo is blurry.',
    });
    const inbox = await request(http)
      .get('/v1/notifications')
      .set(bearer(accounts.lawyer));
    expect(
      (
        inbox.body as {
          data: { type: string; params: Record<string, string> }[];
        }
      ).data[0],
    ).toMatchObject({
      type: 'lawyerVerificationRejected',
      params: { reason: 'The bar card photo is blurry.' },
    });
  });

  it('makes the lawyer public once an admin approves a new submission', async () => {
    const resent = await request(http)
      .post('/v1/lawyers/me/verification')
      .set(bearer(accounts.lawyer))
      .attach('documents', PDF, 'bar-card-clear.pdf');
    expect(resent.status).toBe(201);

    const approved = await request(http)
      .post(`/v1/admin/lawyer-verifications/${profileId}/approve`)
      .set(bearer(accounts.admin));
    expect(approved.status).toBe(204);
    const twice = await request(http)
      .post(`/v1/admin/lawyer-verifications/${profileId}/approve`)
      .set(bearer(accounts.admin));
    expect(twice.status).toBe(409);

    const publicView = await request(http)
      .get(`/v1/lawyers/${profileId}`)
      .set(bearer(accounts.client));
    expect(publicView.status).toBe(200);
    const inbox = await request(http)
      .get('/v1/notifications')
      .set(bearer(accounts.lawyer));
    expect((inbox.body as { data: { type: string }[] }).data[0].type).toBe(
      'lawyerVerificationApproved',
    );
  });
});
