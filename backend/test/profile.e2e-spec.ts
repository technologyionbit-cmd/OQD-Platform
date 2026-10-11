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
 * PATCH /v1/auth/me end to end: every save needs the current password,
 * names must not be blank, and a lawyer's new name reaches the marketplace
 * (sending a verified lawyer back to review). Requires PostgreSQL
 * reachable at DATABASE_URL.
 */

interface UserView {
  fullName: string;
  email: string;
}

describe('Profile (e2e)', () => {
  let app: INestApplication;
  let http: Server;
  const prisma = new PrismaClient();
  const tag = Date.now();
  const password = 'Password123';
  const accounts = {} as Record<'client' | 'lawyer', TestAccount>;

  const patchMe = (account: TestAccount, body: Record<string, string>) =>
    request(http).patch('/v1/auth/me').set(bearer(account)).send(body);

  beforeAll(async () => {
    app = await createE2EApp();
    http = app.getHttpServer() as Server;
    const register = accountRegistrar(http, 'profile', tag);
    accounts.client = await register('client', individualSignup);
    accounts.lawyer = await register('lawyer', lawyerSignup(`BAR-P-${tag}`));
  });

  afterAll(async () => {
    await deleteTestAccounts(prisma, tag);
    await prisma.$disconnect();
    await app.close();
  });

  it('refuses a save without the current password', async () => {
    const { fullName, email } = accounts.client;
    const res = await patchMe(accounts.client, { fullName, email });
    expect(res.status).toBe(422);
    expect(apiError(res).errors).toHaveProperty('currentPassword');
  });

  it('refuses a wrong current password and changes nothing', async () => {
    const res = await patchMe(accounts.client, {
      fullName: 'Someone Else',
      email: accounts.client.email,
      currentPassword: 'Wrong12345',
    });
    expect(res.status).toBe(422);
    expect(apiError(res).errors).toHaveProperty('currentPassword');

    const user = await prisma.user.findUniqueOrThrow({
      where: { id: accounts.client.id },
    });
    expect(user.fullName).toBe(accounts.client.fullName);
  });

  it('refuses a name made only of spaces', async () => {
    const res = await patchMe(accounts.client, {
      fullName: '   ',
      email: accounts.client.email,
      currentPassword: password,
    });
    expect(res.status).toBe(422);
    expect(apiError(res).errors).toHaveProperty('fullName');
  });

  it('holds a person to the person-name length', async () => {
    const res = await patchMe(accounts.client, {
      fullName: 'a'.repeat(121),
      email: accounts.client.email,
      currentPassword: password,
    });
    expect(res.status).toBe(422);
    expect(apiError(res).errors).toHaveProperty('fullName');
  });

  it('saves name and email with the right password', async () => {
    const email = `profile.client.changed.${tag}@test.com`;
    const res = await patchMe(accounts.client, {
      fullName: '  Ahmad Changed  ',
      email,
      currentPassword: password,
    });
    expect(res.status).toBe(200);
    expect(ok<{ user: UserView }>(res).user).toMatchObject({
      fullName: 'Ahmad Changed',
      email,
    });
  });

  it('copies an unverified lawyer’s new name to the lawyer profile', async () => {
    const res = await patchMe(accounts.lawyer, {
      fullName: 'Sara Renamed',
      email: accounts.lawyer.email,
      currentPassword: password,
    });
    expect(res.status).toBe(200);

    const profile = await prisma.lawyerProfile.findUniqueOrThrow({
      where: { userId: accounts.lawyer.id },
    });
    expect(profile.fullName).toBe('Sara Renamed');
    expect(profile.verificationStatus).toBe('unverified');
  });

  it('sends a verified lawyer who changes their name back to review', async () => {
    const { id: profileId } = await prisma.lawyerProfile.update({
      where: { userId: accounts.lawyer.id },
      data: { verificationStatus: 'verified' },
    });
    const listedIds = async (query: string) => {
      const res = await request(http)
        .get('/v1/lawyers')
        .query({ query })
        .set(bearer(accounts.client));
      expect(res.status).toBe(200);
      return ok<{ id: string }[]>(res).map((l) => l.id);
    };
    expect(await listedIds('Sara Renamed')).toContain(profileId);

    // Same name: nothing to review.
    const same = await patchMe(accounts.lawyer, {
      fullName: 'Sara Renamed',
      email: accounts.lawyer.email,
      currentPassword: password,
    });
    expect(same.status).toBe(200);
    let profile = await prisma.lawyerProfile.findUniqueOrThrow({
      where: { id: profileId },
    });
    expect(profile.verificationStatus).toBe('verified');

    const renamed = await patchMe(accounts.lawyer, {
      fullName: 'Sara Other',
      email: accounts.lawyer.email,
      currentPassword: password,
    });
    expect(renamed.status).toBe(200);
    profile = await prisma.lawyerProfile.findUniqueOrThrow({
      where: { id: profileId },
    });
    expect(profile).toMatchObject({
      fullName: 'Sara Other',
      verificationStatus: 'pending',
    });

    expect(await listedIds('Sara Other')).not.toContain(profileId);
  });
});
