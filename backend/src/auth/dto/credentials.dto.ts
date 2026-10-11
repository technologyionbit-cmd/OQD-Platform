import { IsEmail, IsNotEmpty, IsString, MaxLength } from 'class-validator';
import { COMPANY_NAME_MAX_LENGTH, DisplayName } from './name.rules';
import { StrongPassword } from './password.rules';
import { JordanMobile } from './phone.rules';

/** Issued tokens are 64 chars (48 random bytes, base64url); anything far
 *  longer is not ours and is rejected before it is hashed or queried. */
const REFRESH_TOKEN_MAX_LENGTH = 256;

export class LoginDto {
  @JordanMobile()
  phone!: string;

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
  /** Company accounts keep their company name here, hence the company
   *  limit; the service holds people to the shorter person-name limit. */
  @DisplayName(COMPANY_NAME_MAX_LENGTH)
  fullName!: string;

  @IsEmail()
  @MaxLength(254)
  email!: string;

  /** Required for every save, so an unlocked device alone cannot change
   *  who the account belongs to. */
  @IsString()
  @IsNotEmpty()
  @MaxLength(128)
  currentPassword!: string;
}

export class ChangePasswordDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(128)
  currentPassword!: string;

  @StrongPassword()
  newPassword!: string;
}
