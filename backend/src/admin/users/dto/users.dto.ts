import { UserRole, UserStatus } from '@prisma/client';
import { Transform } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsDateString,
  IsEnum,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';
import { PageQueryDto } from '../../../common/pagination/page-query.dto';

export const USER_SORT_FIELDS = [
  'createdAt',
  'fullName',
  'email',
  'lastLoginAt',
] as const;
export type UserSortField = (typeof USER_SORT_FIELDS)[number];

export const MAX_BULK_IDS = 100;

/** How soft-deleted accounts take part in a list. */
export const DELETED_FILTERS = ['exclude', 'only', 'include'] as const;
export type DeletedFilter = (typeof DELETED_FILTERS)[number];

export class QueryUsersDto extends PageQueryDto {
  @IsOptional()
  @IsEnum(UserRole)
  role?: UserRole;

  @IsOptional()
  @IsEnum(UserStatus)
  status?: UserStatus;

  @IsOptional()
  @IsIn(DELETED_FILTERS)
  deleted: DeletedFilter = 'exclude';

  /** Created on or after this instant (ISO 8601). */
  @IsOptional()
  @IsDateString()
  createdFrom?: string;

  /** Created before this instant (ISO 8601). */
  @IsOptional()
  @IsDateString()
  createdTo?: string;
}

const trim = ({ value }: { value: unknown }): unknown =>
  typeof value === 'string' ? value.trim() : value;

/** Why an admin did something to an account; kept in the audit log. */
export class ReasonDto {
  @Transform(trim)
  @IsString()
  @MinLength(3)
  @MaxLength(500)
  reason!: string;
}

export const BULK_ACTIONS = ['suspend', 'activate', 'revokeSessions'] as const;
export type BulkAction = (typeof BULK_ACTIONS)[number];

export class BulkUsersDto {
  @IsIn(BULK_ACTIONS)
  action!: BulkAction;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(MAX_BULK_IDS)
  @IsUUID('all', { each: true })
  ids!: string[];

  /** Required for `suspend`. */
  @IsOptional()
  @Transform(trim)
  @IsString()
  @MinLength(3)
  @MaxLength(500)
  reason?: string;
}
