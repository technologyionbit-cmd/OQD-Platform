import { LawyerSpecialty } from '@prisma/client';
import {
  IsEmail,
  IsEnum,
  IsIn,
  IsNotEmpty,
  IsString,
  Matches,
  MaxLength,
  MinLength,
  ValidateIf,
} from 'class-validator';

export const ACCOUNT_TYPES = ['individual', 'company', 'lawyer'] as const;
export type AccountType = (typeof ACCOUNT_TYPES)[number];

const PHONE_RE = /^\+?[0-9]{8,15}$/;
const PASSWORD_RE = /^(?=.*[A-Za-z])(?=.*\d).+$/;

/**
 * The three registration shapes the frontend's `RegisterRequest` union
 * sends, expressed as one DTO discriminated by `accountType`
 * (docs/backend/02-auth-and-authorization.md §1). Fields not relevant to
 * the chosen type are skipped by `@ValidateIf` rather than rejected, so a
 * stray extra field never blocks a valid submission.
 */
export class RegisterDto {
  @IsIn(ACCOUNT_TYPES)
  accountType!: AccountType;

  @IsEmail()
  @MaxLength(254)
  email!: string;

  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters.' })
  @MaxLength(128)
  @Matches(PASSWORD_RE, {
    message: 'Password must contain at least one letter and one number.',
  })
  password!: string;

  @Matches(PHONE_RE, { message: 'Enter a valid phone number.' })
  phone!: string;

  // individual + lawyer
  @ValidateIf((o: RegisterDto) => o.accountType !== 'company')
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  fullName?: string;

  // company
  @ValidateIf((o: RegisterDto) => o.accountType === 'company')
  @IsString()
  @IsNotEmpty()
  @MaxLength(160)
  companyName?: string;

  @ValidateIf((o: RegisterDto) => o.accountType === 'company')
  @IsString()
  @IsNotEmpty()
  @MaxLength(60)
  commercialRegistrationNumber?: string;

  // lawyer
  @ValidateIf((o: RegisterDto) => o.accountType === 'lawyer')
  @IsString()
  @IsNotEmpty()
  @MaxLength(60)
  barLicenseNumber?: string;

  @ValidateIf((o: RegisterDto) => o.accountType === 'lawyer')
  @IsEnum(LawyerSpecialty)
  mainSpecialty?: LawyerSpecialty;
}
