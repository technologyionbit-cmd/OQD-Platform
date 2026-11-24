import { OrganizationVerificationStatus } from '@prisma/client';
import { IsEnum, IsOptional } from 'class-validator';
import { PageQueryDto } from '../../../common/pagination/page-query.dto';

export const COMPANY_SORT_FIELDS = ['createdAt', 'name'] as const;

export class QueryAdminCompaniesDto extends PageQueryDto {
  @IsOptional()
  @IsEnum(OrganizationVerificationStatus)
  verification?: OrganizationVerificationStatus;
}
