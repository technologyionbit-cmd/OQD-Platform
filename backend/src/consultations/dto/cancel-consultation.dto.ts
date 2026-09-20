import { IsOptional, IsString, MaxLength } from 'class-validator';

export class CancelConsultationDto {
  @IsOptional()
  @IsString()
  @MaxLength(500)
  cancellationReason?: string;
}
