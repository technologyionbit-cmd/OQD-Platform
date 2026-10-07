import { Matches } from 'class-validator';
import { CODE_RE } from './password-reset.dto';

export class VerifyEmailDto {
  /** The 6-digit code sent to the account's email. */
  @Matches(CODE_RE, { message: 'Enter the 6-digit code.' })
  code!: string;
}
