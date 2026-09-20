import { IsISO8601 } from 'class-validator';

export class RescheduleConsultationDto {
  @IsISO8601()
  scheduledAt!: string;
}
