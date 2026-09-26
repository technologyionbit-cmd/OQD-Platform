import {
  IsEmail,
  IsNotEmpty,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

const PASSWORD_RE = /^(?=.*[A-Za-z])(?=.*\d).+$/;

/** Issued tokens are 64 chars (48 random bytes, base64url); anything far
 *  longer is not ours and is rejected before it is hashed or queried. */
const REFRESH_TOKEN_MAX_LENGTH = 256;

export class LoginDto {
  @IsEmail()
  @MaxLength(254)
  email!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(128)
  password!: string;
}

export class RefreshDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(REFRESH_TOKEN_MAX_LENGTH)
  refreshToken!: string;
}

export class LogoutDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(REFRESH_TOKEN_MAX_LENGTH)
  refreshToken!: string;
}

export class UpdateProfileDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  fullName!: string;

  @IsEmail()
  @MaxLength(254)
  email!: string;
}

export class ChangePasswordDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(128)
  currentPassword!: string;

  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters.' })
  @MaxLength(128)
  @Matches(PASSWORD_RE, {
    message: 'Password must contain at least one letter and one number.',
  })
  newPassword!: string;
}
