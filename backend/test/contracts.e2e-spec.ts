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
 * Contracts end to end: templates, the draft -> generate -> sign flow,
 * owner-only access, and the lawyer read-only rule.
 * Requires PostgreSQL reachable at DATABASE_URL.
 */

interface ContractView {
  id: string;
  templateId: string;
  title: string;
  status: string;
  fieldValues: Record<string, string>;
  parties: string[];
  generatedContent: string;
  signedAt: string | null;
}

describe('Contracts (e2e)', () => {
  let app: INestApplication;
  let http: Server;
  const prisma = new PrismaClient();
  const tag = Date.now();
  const accounts = {} as Record<'owner' | 'other' | 'lawyer', TestAccount>;

  const draft = {
    templateId: 'employment',
    locale: 'en',
    fieldValues: {
      partyA: 'Acme Co',
      partyB: 'Sara Haddad',
      position: 'Engineer',
      employmentType: 'fullTime',
      salary: '1200',
    },
  };
  const rest = { startDate: '2026-10-01', duration: '12' };

  beforeAll(async () => {
    app = await createE2EApp();
    http = app.getHttpServer() as Server;
    const register = accountRegistrar(http, 'contracts', tag);
    accounts.owner = await register('owner', individualSignup);
    accounts.other = await register('other', individualSignup);
    accounts.lawyer = await register('lawyer', lawyerSignup(`BAR-C-${tag}`));
  });

  afterAll(async () => {
    await deleteTestAccounts(prisma, tag);
    await prisma.$disconnect();
    await app.close();
  });

  it('serves templates in the requested language with stable option values', async () => {
    const ar = await request(http)
      .get('/v1/contract-templates?locale=ar')
      .set(bearer(accounts.owner));
    const en = await request(http)
      .get('/v1/contract-templates?locale=en')
      .set(bearer(accounts.owner));
    type Template = {
      id: string;
      title: string;
      fields: { id: string; options: { value: string; label: string }[] }[];
    };
    const arEmployment = ok<Template[]>(ar).find((t) => t.id === 'employment')!;
    const enEmployment = ok<Template[]>(en).find((t) => t.id === 'employment')!;
    expect(arEmployment.title).toBe('عقد عمل');
    expect(enEmployment.title).toBe('Employment Contract');

    const options = (t: Template) =>
      t.fields.find((f) => f.id === 'employmentType')!.options;
    expect(options(arEmployment).map((o) => o.value)).toEqual(
      options(enEmployment).map((o) => o.value),
    );

    const anonymous = await request(http).get('/v1/contract-templates');
    expect(anonymous.status).toBe(401);
  });

  it('runs draft -> edit -> generate -> sign for the owner', async () => {
    const created = await request(http)
      .post('/v1/contracts')
      .set(bearer(accounts.owner))
      .send(draft);
    expect(created.status).toBe(201);
    const contract = ok<ContractView>(created);
    expect(contract).toMatchObject({
      status: 'draft',
      title: 'Employment Contract',
      parties: ['Acme Co', 'Sara Haddad'],
    });

    // Incomplete: generating names the missing fields.
    const early = await request(http)
      .post(`/v1/contracts/${contract.id}/generate`)
      .set(bearer(accounts.owner))
      .send({});
    expect(early.status).toBe(422);
    expect(Object.keys(apiError(early).errors ?? {}).sort()).toEqual([
      'duration',
      'startDate',
    ]);

    const edited = await request(http)
      .patch(`/v1/contracts/${contract.id}`)
      .set(bearer(accounts.owner))
      .send({ fieldValues: { ...draft.fieldValues, ...rest } });
    expect(edited.status).toBe(200);

    const generated = await request(http)
      .post(`/v1/contracts/${contract.id}/generate`)
      .set(bearer(accounts.owner))
      .send({ locale: 'ar' });
    expect(generated.status).toBe(200);
    const text = ok<ContractView>(generated);
    expect(text.status).toBe('pendingSignature');
    expect(text.title).toBe('عقد عمل');
    expect(text.generatedContent).toContain('نوع الدوام: دوام كامل');

    // No more edits once generated.
    const late = await request(http)
      .patch(`/v1/contracts/${contract.id}`)
      .set(bearer(accounts.owner))
      .send({ fieldValues: draft.fieldValues });
    expect(late.status).toBe(409);
    expect(apiError(late).code).toBe('CONTRACT_STATUS_CONFLICT');

    // Signing needs a verified email.
    const unverified = await request(http)
      .post(`/v1/contracts/${contract.id}/sign`)
      .set(bearer(accounts.owner));
    expect(unverified.status).toBe(403);
    expect(apiError(unverified).code).toBe('EMAIL_NOT_VERIFIED');

    await prisma.user.update({
      where: { email: `contracts.owner.${tag}@test.com` },
      data: { emailVerifiedAt: new Date() },
    });
    const signed = await request(http)
      .post(`/v1/contracts/${contract.id}/sign`)
      .set(bearer(accounts.owner))
      .set('user-agent', 'e2e-agent');
    expect(signed.status).toBe(200);
    expect(ok<ContractView>(signed).status).toBe('signed');
    expect(ok<ContractView>(signed).signedAt).not.toBeNull();

    const evidence = await prisma.contractSignature.findMany({
      where: { contractId: contract.id },
    });
    expect(evidence).toHaveLength(1);
    expect(evidence[0].userAgent).toBe('e2e-agent');

    const twice = await request(http)
      .post(`/v1/contracts/${contract.id}/sign`)
      .set(bearer(accounts.owner));
    expect(twice.status).toBe(409);

    const list = await request(http)
      .get('/v1/contracts')
      .set(bearer(accounts.owner));
    expect(ok<ContractView[]>(list).map((c) => c.id)).toContain(contract.id);
  });

  it("keeps each account's contracts private", async () => {
    const created = await request(http)
      .post('/v1/contracts')
      .set(bearer(accounts.owner))
      .send(draft);
    const id = ok<ContractView>(created).id;

    const read = await request(http)
      .get(`/v1/contracts/${id}`)
      .set(bearer(accounts.other));
    expect(read.status).toBe(404);

    const remove = await request(http)
      .delete(`/v1/contracts/${id}`)
      .set(bearer(accounts.other));
    expect(remove.status).toBe(404);

    const list = await request(http)
      .get('/v1/contracts')
      .set(bearer(accounts.other));
    expect(ok<ContractView[]>(list)).toEqual([]);

    const own = await request(http)
      .delete(`/v1/contracts/${id}`)
      .set(bearer(accounts.owner));
    expect(own.status).toBe(204);
  });

  it('lets a lawyer read but never write', async () => {
    const create = await request(http)
      .post('/v1/contracts')
      .set(bearer(accounts.lawyer))
      .send(draft);
    expect(create.status).toBe(403);

    const list = await request(http)
      .get('/v1/contracts')
      .set(bearer(accounts.lawyer));
    expect(list.status).toBe(200);
  });

  it('rejects unknown templates, unknown fields and bad values', async () => {
    const template = await request(http)
      .post('/v1/contracts')
      .set(bearer(accounts.owner))
      .send({ ...draft, templateId: 'nope' });
    expect(template.status).toBe(422);

    const fields = await request(http)
      .post('/v1/contracts')
      .set(bearer(accounts.owner))
      .send({
        ...draft,
        fieldValues: { injected: 'x', salary: 'lots', employmentType: 'boss' },
      });
    expect(fields.status).toBe(422);
    expect(Object.keys(apiError(fields).errors ?? {}).sort()).toEqual([
      'employmentType',
      'injected',
      'salary',
    ]);
  });
});
