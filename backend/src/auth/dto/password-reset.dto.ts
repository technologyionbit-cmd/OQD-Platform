import {
  IsNotEmpty,
  IsString,
  Length,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

const PASSWORD_RE = /^(?=.*[A-Za-z])(?=.*\d).+$/;
const CODE_RE = /^[0-9]{6}$/;

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

  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters.' })
  @MaxLength(128)
  @Matches(PASSWORD_RE, {
    message: 'Password must contain at least one letter and one number.',
  })
  newPassword!: string;
}
