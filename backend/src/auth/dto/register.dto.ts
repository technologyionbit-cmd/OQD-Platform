import { LawyerSpecialty } from '@prisma/client';
import {
  Equals,
  IsEmail,
  IsEnum,
  IsIn,
  IsNotEmpty,
  IsString,
  MaxLength,
  ValidateIf,
} from 'class-validator';
import {
  COMPANY_NAME_MAX_LENGTH,
  DisplayName,
  PERSON_NAME_MAX_LENGTH,
} from './name.rules';
import { StrongPassword } from './password.rules';
import { JordanMobile } from './phone.rules';

export const ACCOUNT_TYPES = ['individual', 'company', 'lawyer'] as const;
export type AccountType = (typeof ACCOUNT_TYPES)[number];

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

  /** Signs the account in and receives every code. */
  @JordanMobile()
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
  @DisplayName(PERSON_NAME_MAX_LENGTH)
  fullName?: string;

  // company
  @ValidateIf((o: RegisterDto) => o.accountType === 'company')
  @DisplayName(COMPANY_NAME_MAX_LENGTH)
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
