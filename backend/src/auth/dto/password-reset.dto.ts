import { IsEmail, Matches, MaxLength } from 'class-validator';
import { StrongPassword } from './password.rules';

export const CODE_RE = /^[0-9]{6}$/;

/** Password reset works by email only for now; a phone channel would add
 *  its own field rather than overload this one. */
export class ForgotPasswordDto {
  @IsEmail()
  @MaxLength(254)
  email!: string;
}

export class VerifyOtpDto {
  @IsEmail()
  @MaxLength(254)
  email!: string;

  @Matches(CODE_RE, { message: 'Enter the 6-digit code.' })
  code!: string;
}

export class ResetPasswordDto {
  @IsEmail()
  @MaxLength(254)
  email!: string;

  @Matches(CODE_RE, { message: 'Enter the 6-digit code.' })
  code!: string;

  @StrongPassword()
  newPassword!: string;
}
