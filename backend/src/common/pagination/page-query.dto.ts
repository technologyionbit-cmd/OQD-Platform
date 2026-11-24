import { Type } from 'class-transformer';
import {
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

export const MAX_PAGE_SIZE = 100;

/**
 * Page/limit paging for the admin tables (which need "jump to page N" and
 * a total, unlike the app's cursor lists). Feature queries extend this
 * and whitelist their own `sort` values.
 */
export class PageQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100_000)
  page: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(MAX_PAGE_SIZE)
  limit: number = 20;

  /** Free-text search; what it matches is up to each endpoint. */
  @IsOptional()
  @IsString()
  @MaxLength(100)
  q?: string;

  @IsOptional()
  @IsString()
  @MaxLength(40)
  sort?: string;

  @IsOptional()
  @IsIn(['asc', 'desc'])
  order: 'asc' | 'desc' = 'desc';
}

export interface PageMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface Paginated<T> {
  data: T[];
  meta: PageMeta;
}

/** Prisma `skip`/`take` for a page query. */
export const pageArgs = (query: Pick<PageQueryDto, 'page' | 'limit'>) => ({
  skip: (query.page - 1) * query.limit,
  take: query.limit,
});

/** The `{ data, meta }` envelope every admin list answers with. */
export function paginated<T>(
  data: T[],
  total: number,
  query: Pick<PageQueryDto, 'page' | 'limit'>,
): Paginated<T> {
  return {
    data,
    meta: {
      page: query.page,
      limit: query.limit,
      total,
      totalPages: Math.max(1, Math.ceil(total / query.limit)),
    },
  };
}

/** Returns [value] if it is one of [allowed], else [fallback]. */
export function pickSort<T extends string>(
  value: string | undefined,
  allowed: readonly T[],
  fallback: T,
): T {
  return allowed.includes(value as T) ? (value as T) : fallback;
}
