import { Transform } from 'class-transformer';
import {
  IsDateString,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
} from 'class-validator';
import { PageQueryDto } from '../../../common/pagination/page-query.dto';

export const AUDIT_SORT_FIELDS = ['createdAt', 'action'] as const;

const trim = ({ value }: { value: unknown }): unknown =>
  typeof value === 'string' ? value.trim() : value;

export class QueryAuditLogsDto extends PageQueryDto {
  /** The admin who did it. */
  @IsOptional()
  @IsUUID()
  actorId?: string;

  /** Matches the action name anywhere, e.g. `user.` or `suspend`. */
  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(120)
  action?: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(60)
  entityType?: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(100)
  entityId?: string;

  /** `success` = HTTP status below 400, `failure` = 400 and above. */
  @IsOptional()
  @IsIn(['success', 'failure'])
  outcome?: 'success' | 'failure';

  @IsOptional()
  @IsDateString()
  from?: string;

  @IsOptional()
  @IsDateString()
  to?: string;
}
