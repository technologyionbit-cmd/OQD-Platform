import {
  IsNotEmpty,
  IsString,
  Length,
  Matches,
  MaxLength,
} from 'class-validator';
import { StrongPassword } from './password.rules';

export const CODE_RE = /^[0-9]{6}$/;

/** `destination` is channel-agnostic — an email or a phone number. The
 *  server infers the channel from its shape (docs §4). */
export class ForgotPasswordDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(254)
  destination!: string;
}

export class VerifyOtpDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(254)
  destination!: string;

  @Matches(CODE_RE, { message: 'Enter the 6-digit code.' })
  code!: string;
}

export class ResetPasswordDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(254)
  destination!: string;

  @Length(6, 6)
  @Matches(CODE_RE, { message: 'Enter the 6-digit code.' })
  code!: string;

  @StrongPassword()
  newPassword!: string;
}
