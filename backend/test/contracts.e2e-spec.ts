import { INestApplication } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import type { Server } from 'node:http';
import request from 'supertest';
import { createE2EApp } from './support/e2e-app';
import { DEFAULT_TERMS_VERSION } from '../src/config/configuration';

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
interface ErrorBody {
  code: string;
  errors?: Record<string, string[]>;
}

const ok = <T>(res: request.Response): T => (res.body as { data: T }).data;
const err = (res: request.Response): ErrorBody =>
  (res.body as { error: ErrorBody }).error;

describe('Contracts (e2e)', () => {
  let app: INestApplication;
  let http: Server;
  const prisma = new PrismaClient();
  const tag = Date.now();
  const tokens: Record<'owner' | 'other' | 'lawyer', string> = {
    owner: '',
    other: '',
    lawyer: '',
  };

  const register = async (
    key: keyof typeof tokens,
    extra: Record<string, string>,
  ) => {
    const res = await request(http)
      .post('/v1/auth/register')
      .send({
        fullName: `Contracts ${key}`,
        phone: '0791234567',
        email: `contracts.${key}.${tag}@test.com`,
        password: 'Password123',
        acceptTerms: true,
        termsVersion: DEFAULT_TERMS_VERSION,
        ...extra,
      });
    expect(res.status).toBe(201);
    tokens[key] = ok<{ tokens: { accessToken: string } }>(
      res,
    ).tokens.accessToken;
  };

  const as = (key: keyof typeof tokens) => ({
    authorization: `Bearer ${tokens[key]}`,
  });

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
    await register('owner', { accountType: 'individual' });
    await register('other', { accountType: 'individual' });
    await register('lawyer', {
      accountType: 'lawyer',
      barLicenseNumber: `BAR-C-${tag}`,
      mainSpecialty: 'commercial',
    });
  });

  afterAll(async () => {
    await prisma.user.deleteMany({
      where: { email: { endsWith: `.${tag}@test.com` } },
    });
    await prisma.$disconnect();
    await app.close();
  });

  it('serves templates in the requested language with stable option values', async () => {
    const ar = await request(http)
      .get('/v1/contract-templates?locale=ar')
      .set(as('owner'));
    const en = await request(http)
      .get('/v1/contract-templates?locale=en')
      .set(as('owner'));
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
      .set(as('owner'))
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
      .set(as('owner'))
      .send({});
    expect(early.status).toBe(422);
    expect(Object.keys(err(early).errors ?? {}).sort()).toEqual([
      'duration',
      'startDate',
    ]);

    const edited = await request(http)
      .patch(`/v1/contracts/${contract.id}`)
      .set(as('owner'))
      .send({ fieldValues: { ...draft.fieldValues, ...rest } });
    expect(edited.status).toBe(200);

    const generated = await request(http)
      .post(`/v1/contracts/${contract.id}/generate`)
      .set(as('owner'))
      .send({ locale: 'ar' });
    expect(generated.status).toBe(200);
    const text = ok<ContractView>(generated);
    expect(text.status).toBe('pendingSignature');
    expect(text.title).toBe('عقد عمل');
    expect(text.generatedContent).toContain('نوع الدوام: دوام كامل');

    // No more edits once generated.
    const late = await request(http)
      .patch(`/v1/contracts/${contract.id}`)
      .set(as('owner'))
      .send({ fieldValues: draft.fieldValues });
    expect(late.status).toBe(409);
    expect(err(late).code).toBe('CONTRACT_STATUS_CONFLICT');

    // Signing needs a verified email.
    const unverified = await request(http)
      .post(`/v1/contracts/${contract.id}/sign`)
      .set(as('owner'));
    expect(unverified.status).toBe(403);
    expect(err(unverified).code).toBe('EMAIL_NOT_VERIFIED');

    await prisma.user.update({
      where: { email: `contracts.owner.${tag}@test.com` },
      data: { emailVerifiedAt: new Date() },
    });
    const signed = await request(http)
      .post(`/v1/contracts/${contract.id}/sign`)
      .set(as('owner'))
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
      .set(as('owner'));
    expect(twice.status).toBe(409);

    const list = await request(http).get('/v1/contracts').set(as('owner'));
    expect(ok<ContractView[]>(list).map((c) => c.id)).toContain(contract.id);
  });

  it("keeps each account's contracts private", async () => {
    const created = await request(http)
      .post('/v1/contracts')
      .set(as('owner'))
      .send(draft);
    const id = ok<ContractView>(created).id;

    const read = await request(http)
      .get(`/v1/contracts/${id}`)
      .set(as('other'));
    expect(read.status).toBe(404);

    const remove = await request(http)
      .delete(`/v1/contracts/${id}`)
      .set(as('other'));
    expect(remove.status).toBe(404);

    const list = await request(http).get('/v1/contracts').set(as('other'));
    expect(ok<ContractView[]>(list)).toEqual([]);

    const own = await request(http)
      .delete(`/v1/contracts/${id}`)
      .set(as('owner'));
    expect(own.status).toBe(204);
  });

  it('lets a lawyer read but never write', async () => {
    const create = await request(http)
      .post('/v1/contracts')
      .set(as('lawyer'))
      .send(draft);
    expect(create.status).toBe(403);

    const list = await request(http).get('/v1/contracts').set(as('lawyer'));
    expect(list.status).toBe(200);
  });

  it('rejects unknown templates, unknown fields and bad values', async () => {
    const template = await request(http)
      .post('/v1/contracts')
      .set(as('owner'))
      .send({ ...draft, templateId: 'nope' });
    expect(template.status).toBe(422);

    const fields = await request(http)
      .post('/v1/contracts')
      .set(as('owner'))
      .send({
        ...draft,
        fieldValues: { injected: 'x', salary: 'lots', employmentType: 'boss' },
      });
    expect(fields.status).toBe(422);
    expect(Object.keys(err(fields).errors ?? {}).sort()).toEqual([
      'employmentType',
      'injected',
      'salary',
    ]);
  });
});
