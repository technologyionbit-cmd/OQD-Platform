import 'reflect-metadata';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { PageQueryDto, pageArgs, paginated, pickSort } from './page-query.dto';

describe('pagination', () => {
  it('defaults to page 1, 20 per page', async () => {
    const q = plainToInstance(PageQueryDto, {});
    expect(await validate(q)).toHaveLength(0);
    expect(q).toMatchObject({ page: 1, limit: 20, order: 'desc' });
  });

  it('coerces query strings and rejects out-of-range values', async () => {
    const ok = plainToInstance(PageQueryDto, { page: '3', limit: '50' });
    expect(await validate(ok)).toHaveLength(0);
    expect(ok.page).toBe(3);
    for (const bad of [{ limit: '500' }, { page: '0' }, { order: 'up' }]) {
      const errors = await validate(plainToInstance(PageQueryDto, bad));
      expect(errors.length).toBeGreaterThan(0);
    }
  });

  it('computes skip/take and meta', () => {
    expect(pageArgs({ page: 3, limit: 20 })).toEqual({ skip: 40, take: 20 });
    expect(paginated([1], 45, { page: 1, limit: 20 }).meta).toEqual({
      page: 1,
      limit: 20,
      total: 45,
      totalPages: 3,
    });
    expect(paginated([], 0, { page: 1, limit: 20 }).meta.totalPages).toBe(1);
  });

  it('only sorts by whitelisted fields', () => {
    const allowed = ['createdAt', 'fullName'] as const;
    expect(pickSort('fullName', allowed, 'createdAt')).toBe('fullName');
    expect(pickSort('passwordHash', allowed, 'createdAt')).toBe('createdAt');
  });
});
