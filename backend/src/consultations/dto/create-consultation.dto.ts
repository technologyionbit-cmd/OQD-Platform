import { ConsultationType } from '@prisma/client';
import { IsEnum, IsISO8601, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

/**
 * `price` is deliberately not accepted here — the server always computes
 * it from the matching `LawyerConsultationOffering` at booking time
 * (docs/plans/individual-user-rollout.md Part 4), never from client input.
 */
export class CreateConsultationDto {
  @IsUUID()
  lawyerId!: string;

  @IsEnum(ConsultationType)
  type!: ConsultationType;

  @IsISO8601()
  scheduledAt!: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  notes?: string;
}
