import { Matches } from 'class-validator';
import { StrongPassword } from './password.rules';
import { JordanMobile } from './phone.rules';

export const CODE_RE = /^[0-9]{6}$/;

/** Password reset works by a code texted to the account's phone number. */
export class ForgotPasswordDto {
  @JordanMobile()
  phone!: string;
}

export class VerifyOtpDto {
  @JordanMobile()
  phone!: string;

  @Matches(CODE_RE, { message: 'Enter the 6-digit code.' })
  code!: string;
}

export class ResetPasswordDto {
  @JordanMobile()
  phone!: string;

  @Matches(CODE_RE, { message: 'Enter the 6-digit code.' })
  code!: string;

  @StrongPassword()
  newPassword!: string;
}
