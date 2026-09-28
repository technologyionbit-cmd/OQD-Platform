import { ApiProperty } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import type { AuthTokens, AuthUserView } from '../auth.types';

/**
 * OpenAPI response schemas for the auth endpoints — documentation only;
 * the controllers keep returning the plain {@link AuthUserView} /
 * {@link AuthTokens} shapes these describe.
 */
export class AuthUserDto implements AuthUserView {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ example: 'محمد الأحمد' })
  fullName!: string;

  @ApiProperty({ format: 'email' })
  email!: string;

  @ApiProperty({ enum: UserRole, enumName: 'UserRole' })
  role!: UserRole;

  @ApiProperty({
    description:
      'False until the emailed code is entered (POST /auth/email/verify). ' +
      'Sensitive actions answer 403 EMAIL_NOT_VERIFIED until then.',
  })
  emailVerified!: boolean;
}

export class AuthTokensDto implements AuthTokens {
  @ApiProperty({ description: 'JWT, short-lived (JWT_ACCESS_TTL).' })
  accessToken!: string;

  @ApiProperty({
    description:
      'Opaque, single-use: every refresh rotates it, and presenting a ' +
      'used one revokes all of the user’s sessions.',
  })
  refreshToken!: string;
}

class UserPayloadDto {
  @ApiProperty({ type: AuthUserDto })
  user!: AuthUserDto;
}

class TokensPayloadDto {
  @ApiProperty({ type: AuthTokensDto })
  tokens!: AuthTokensDto;
}

class SessionPayloadDto {
  @ApiProperty({ type: AuthUserDto })
  user!: AuthUserDto;

  @ApiProperty({ type: AuthTokensDto })
  tokens!: AuthTokensDto;
}

export class SessionResponseDto {
  @ApiProperty({ type: SessionPayloadDto })
  data!: SessionPayloadDto;
}

export class UserResponseDto {
  @ApiProperty({ type: UserPayloadDto })
  data!: UserPayloadDto;
}

export class TokensResponseDto {
  @ApiProperty({ type: TokensPayloadDto })
  data!: TokensPayloadDto;
}
