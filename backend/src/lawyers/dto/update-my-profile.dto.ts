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
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { LawyerSpecialty } from '@prisma/client';

/**
 * The lawyer's own editable profile. `pricing` maps each consultation
 * type the lawyer offers to its price; a type left out stops being
 * offered (its old price stays on past bookings). Checked further in
 * LawyersService.updateMine.
 */
export class UpdateMyProfileDto {
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

  @IsObject()
  pricing!: Record<string, unknown>;
}

export class RejectVerificationDto {
  @IsString()
  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string' ? value.trim() : value,
  )
  @IsNotEmpty()
  @MaxLength(500)
  reason!: string;
}
