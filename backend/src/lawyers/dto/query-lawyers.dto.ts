import { Type } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { LawyerSpecialty } from '@prisma/client';

/**
 * All optional, additive-only — an empty query mirrors the mock's
 * `getLawyers()` behaviour of returning the full (verified) list
 * (docs/plans/individual-user-rollout.md Part 3, correction 1).
 */
export class QueryLawyersDto {
  @IsOptional()
  @IsString()
  @MaxLength(120)
  query?: string;

  @IsOptional()
  @IsEnum(LawyerSpecialty)
  specialty?: LawyerSpecialty;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(5)
  minRating?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 50;
}
