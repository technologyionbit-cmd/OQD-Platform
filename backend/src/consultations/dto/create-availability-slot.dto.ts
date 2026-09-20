import { IsISO8601 } from 'class-validator';

/** Lawyer self-service — creates one hourly-or-custom slot on their own calendar. */
export class CreateAvailabilitySlotDto {
  @IsISO8601()
  start!: string;

  @IsISO8601()
  end!: string;
}
