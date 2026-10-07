import { LawyerSpecialty } from '@prisma/client';
import {
  Equals,
  IsEmail,
  IsEnum,
  IsIn,
  IsNotEmpty,
  IsString,
  Matches,
  MaxLength,
  ValidateIf,
} from 'class-validator';
import { StrongPassword } from './password.rules';

export const ACCOUNT_TYPES = ['individual', 'company', 'lawyer'] as const;
export type AccountType = (typeof ACCOUNT_TYPES)[number];

const PHONE_RE = /^\+?[0-9]{8,15}$/;

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

  @StrongPassword()
  password!: string;

  @Matches(PHONE_RE, { message: 'Enter a valid phone number.' })
  phone!: string;

  /** Must be `true`: the user ticked the terms/privacy checkbox. */
  @Equals(true, { message: 'You must accept the terms to register.' })
  acceptTerms!: boolean;

  /** The terms version the user saw. Must equal the server's current
   *  version (TERMS_VERSION), else 422 TERMS_VERSION_OUTDATED. */
  @IsString()
  @IsNotEmpty()
  @MaxLength(32)
  termsVersion!: string;

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
