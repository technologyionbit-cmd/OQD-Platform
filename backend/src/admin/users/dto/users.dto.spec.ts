import 'reflect-metadata';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { BulkUsersDto, QueryUsersDto, ReasonDto } from './users.dto';

const UUID = '3f2b6c1e-8a4d-4c1b-9e57-0d2f6a1b7c33';

const errorsFor = async <T extends object>(cls: new () => T, plain: object) =>
  (await validate(plainToInstance(cls, plain), { whitelist: true, forbidNonWhitelisted: true })).map(
    (e) => e.property,
  );

describe('QueryUsersDto', () => {
  it('accepts valid filters and defaults deleted to exclude', async () => {
    const dto = plainToInstance(QueryUsersDto, { role: 'lawyer', status: 'active', page: '2' });
    expect(await validate(dto)).toHaveLength(0);
    expect(dto.deleted).toBe('exclude');
  });

  it.each([
    [{ role: 'root' }, 'role'],
    [{ status: 'gone' }, 'status'],
    [{ deleted: 'maybe' }, 'deleted'],
    [{ createdFrom: 'yesterday' }, 'createdFrom'],
    [{ limit: '1000' }, 'limit'],
    [{ unknown: '1' }, 'unknown'],
  ])('rejects %j', async (plain, property) => {
    expect(await errorsFor(QueryUsersDto, plain)).toContain(property);
  });
});

describe('ReasonDto', () => {
  it('trims and needs 3 to 500 characters', async () => {
    expect(await errorsFor(ReasonDto, { reason: '  ab  ' })).toContain('reason');
    expect(await errorsFor(ReasonDto, {})).toContain('reason');
    expect(await errorsFor(ReasonDto, { reason: 'x'.repeat(501) })).toContain('reason');
    expect(await errorsFor(ReasonDto, { reason: ' spam account ' })).toHaveLength(0);
  });
});

describe('BulkUsersDto', () => {
  it('accepts a valid request', async () => {
    expect(await errorsFor(BulkUsersDto, { action: 'activate', ids: [UUID] })).toHaveLength(0);
  });

  it.each([
    [{ action: 'delete', ids: [UUID] }, 'action'],
    [{ action: 'activate', ids: [] }, 'ids'],
    [{ action: 'activate', ids: ['nope'] }, 'ids'],
    [{ action: 'activate', ids: Array(101).fill(UUID) }, 'ids'],
    [{ action: 'activate' }, 'ids'],
  ])('rejects %j', async (plain, property) => {
    expect(await errorsFor(BulkUsersDto, plain)).toContain(property);
  });
});
