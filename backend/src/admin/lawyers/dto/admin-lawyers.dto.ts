import { LawyerSpecialty, LawyerVerificationStatus } from '@prisma/client';
import { Transform } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  ArrayUnique,
  IsArray,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsObject,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { PageQueryDto } from '../../../common/pagination/page-query.dto';

export const LAWYER_SORT_FIELDS = [
  'createdAt',
  'fullName',
  'yearsOfExperience',
  'rating',
] as const;

export class QueryAdminLawyersDto extends PageQueryDto {
  @IsOptional()
  @IsEnum(LawyerVerificationStatus)
  verification?: LawyerVerificationStatus;
}

/** The lawyer's public profile, as staff may correct it. */
export class UpdateAdminLawyerDto {
  @IsString()
  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string' ? value.trim() : value,
  )
  @IsNotEmpty()
  @MaxLength(2000)
  bio!: string;

  @IsInt()
  @Min(0)
  @Max(70)
  yearsOfExperience!: number;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(8)
  @ArrayUnique()
  @IsEnum(LawyerSpecialty, { each: true })
  specialties!: LawyerSpecialty[];

  /** Consultation type -> price. A type left out stops being offered. */
  @IsObject()
  pricing!: Record<string, unknown>;
}
