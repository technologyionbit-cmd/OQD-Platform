import { Matches } from 'class-validator';
import { CODE_RE } from './password-reset.dto';

export class VerifyPhoneDto {
  /** The 6-digit code texted to the account's phone number. */
  @Matches(CODE_RE, { message: 'Enter the 6-digit code.' })
  code!: string;
}
