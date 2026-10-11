import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiForbiddenResponse,
  ApiNoContentResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiTooManyRequestsResponse,
  ApiUnauthorizedResponse,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { ApiErrorResponseDto } from '../common/openapi/api-error.dto';
import { BEARER_AUTH } from '../common/openapi/setup-openapi';
import { AuthService } from './auth.service';
import {
  SessionResponseDto,
  TokensResponseDto,
  UserResponseDto,
} from './dto/auth-responses.dto';
import type { AuthenticatedUser } from './auth.types';
import { ClientContext } from './decorators/client-context.decorator';
import { CurrentUser } from './decorators/current-user.decorator';
import type { RequestContext } from './auth.types';
import {
  ChangePasswordDto,
  LoginDto,
  LogoutDto,
  RefreshDto,
  UpdateProfileDto,
} from './dto/credentials.dto';
import {
  ForgotPasswordDto,
  ResetPasswordDto,
  VerifyOtpDto,
} from './dto/password-reset.dto';
import { VerifyPhoneDto } from './dto/phone-verification.dto';
import { RegisterDto } from './dto/register.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { LoginAttemptsGuard } from './guards/login-attempts.guard';

/** Tight limits for the credential-guessing surface (docs/backend/14-security.md). */
const STRICT_THROTTLE = { default: { limit: 8, ttl: 60_000 } };

@ApiTags('auth')
@ApiTooManyRequestsResponse({ type: ApiErrorResponseDto })
@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('register')
  @Throttle(STRICT_THROTTLE)
  @ApiOperation({
    summary: 'Create an account',
    description:
      'Signs the user in at once and texts a 6-digit verification code ' +
      'to the phone number (Jordanian mobile, any common spelling; stored ' +
      'as +9627XXXXXXXX). The account works, but sensitive actions answer ' +
      '403 PHONE_NOT_VERIFIED until POST /auth/phone/verify succeeds. ' +
      'Passwords: 8+ characters, at most 72 bytes (UTF-8), at least one ' +
      'letter and one number.',
  })
  @ApiCreatedResponse({ type: SessionResponseDto })
  @ApiUnprocessableEntityResponse({
    type: ApiErrorResponseDto,
    description:
      'VALIDATION_ERROR (errors per field), EMAIL_ALREADY_REGISTERED, ' +
      'PHONE_ALREADY_REGISTERED, COMMERCIAL_REGISTRATION_TAKEN, ' +
      'BAR_LICENSE_TAKEN, or ' +
      'TERMS_VERSION_OUTDATED (termsVersion is not the current one).',
  })
  async register(
    @Body() dto: RegisterDto,
    @ClientContext() ctx: RequestContext,
  ) {
    return { data: await this.auth.register(dto, ctx) };
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @Throttle(STRICT_THROTTLE)
  @UseGuards(LoginAttemptsGuard)
  @ApiOperation({
    summary: 'Sign in',
    description:
      'Signs in with the phone number and password. Wrong number and ' +
      'wrong password are indistinguishable (same 401, same timing). ' +
      'Limited per IP and per number (LOGIN_MAX_ATTEMPTS per ' +
      'LOGIN_ATTEMPT_WINDOW_MINUTES); a 429 carries Retry-After in seconds.',
  })
  @ApiOkResponse({ type: SessionResponseDto })
  @ApiUnauthorizedResponse({
    type: ApiErrorResponseDto,
    description: 'Invalid phone number or password (code UNAUTHORIZED).',
  })
  @ApiForbiddenResponse({
    type: ApiErrorResponseDto,
    description: 'Correct credentials, inactive account (ACCOUNT_INACTIVE).',
  })
  async login(@Body() dto: LoginDto, @ClientContext() ctx: RequestContext) {
    return { data: await this.auth.login(dto, ctx) };
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Rotate the session',
    description:
      'Exchanges a refresh token for a new pair; the presented token is ' +
      'revoked. 401 means the session is over (expired, revoked, reused, ' +
      'or the account is inactive) — the client must sign out. Any other ' +
      'failure is transient and must not sign the user out.',
  })
  @ApiOkResponse({ type: TokensResponseDto })
  @ApiUnauthorizedResponse({ type: ApiErrorResponseDto })
  async refresh(@Body() dto: RefreshDto, @ClientContext() ctx: RequestContext) {
    return { data: await this.auth.refresh(dto, ctx) };
  }

  @Post('logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  async logout(@Body() dto: LogoutDto): Promise<void> {
    await this.auth.logout(dto);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth(BEARER_AUTH)
  @ApiOperation({
    summary: 'Current user',
    description:
      'Used on app start to verify a stored session. 401 when the access ' +
      'token is invalid/expired, the session was revoked, or the account ' +
      'is no longer active.',
  })
  @ApiOkResponse({ type: UserResponseDto })
  @ApiUnauthorizedResponse({ type: ApiErrorResponseDto })
  async me(@CurrentUser() user: AuthenticatedUser) {
    return { data: { user: await this.auth.me(user.id) } };
  }

  @Patch('me')
  @Throttle(STRICT_THROTTLE)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth(BEARER_AUTH)
  @ApiOperation({
    summary: 'Update name and email',
    description:
      'Every save needs the current password (422 VALIDATION_ERROR on ' +
      'currentPassword when wrong). The email is contact information only ' +
      '(no code, no sign-in); 422 EMAIL_ALREADY_REGISTERED when another ' +
      'account uses it. A verified lawyer who changes their name goes back ' +
      'to pending review and leaves the marketplace until approved again.',
  })
  @ApiOkResponse({ type: UserResponseDto })
  async updateProfile(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateProfileDto,
  ) {
    return { data: { user: await this.auth.updateProfile(user.id, dto) } };
  }

  @Post('phone/verify')
  @HttpCode(HttpStatus.OK)
  @Throttle(STRICT_THROTTLE)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth(BEARER_AUTH)
  @ApiOperation({
    summary: 'Verify the account phone number',
    description:
      'Checks the latest code texted to the signed-in user. Already ' +
      'verified: returns the user unchanged. OTP_MAX_ATTEMPTS wrong tries ' +
      'lock the code (VERIFICATION_CODE_LOCKED) until a new one is sent.',
  })
  @ApiOkResponse({ type: UserResponseDto })
  @ApiUnprocessableEntityResponse({
    type: ApiErrorResponseDto,
    description:
      'INVALID_VERIFICATION_CODE (wrong or expired) or ' +
      'VERIFICATION_CODE_LOCKED.',
  })
  @ApiUnauthorizedResponse({ type: ApiErrorResponseDto })
  async verifyPhone(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: VerifyPhoneDto,
  ) {
    return { data: { user: await this.auth.verifyPhone(user.id, dto.code) } };
  }

  @Post('phone/resend')
  @HttpCode(HttpStatus.NO_CONTENT)
  @Throttle(STRICT_THROTTLE)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth(BEARER_AUTH)
  @ApiOperation({
    summary: 'Text a new phone verification code',
    description:
      'One code per OTP_RESEND_COOLDOWN_SECONDS and at most ' +
      'OTP_MAX_PER_HOUR per account (the sign-up code ' +
      'counts). Over the limit: 429 with Retry-After in seconds. Does ' +
      'nothing for an already verified account.',
  })
  @ApiNoContentResponse()
  @ApiUnauthorizedResponse({ type: ApiErrorResponseDto })
  async resendPhoneVerification(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<void> {
    await this.auth.resendPhoneVerification(user.id);
  }

  @Post('password/forgot')
  @HttpCode(HttpStatus.NO_CONTENT)
  @Throttle(STRICT_THROTTLE)
  @ApiOperation({
    summary: 'Text a password reset code',
    description:
      'Always 204, whether or not an account uses the number, so the ' +
      'answer reveals nothing; only an account phone receives a code. ' +
      'Per number: one code ' +
      'per OTP_RESEND_COOLDOWN_SECONDS and at most OTP_MAX_PER_HOUR; over ' +
      'the limit, 429 with Retry-After in seconds.',
  })
  @ApiNoContentResponse()
  @ApiUnprocessableEntityResponse({
    type: ApiErrorResponseDto,
    description: 'VALIDATION_ERROR (not a Jordanian mobile number).',
  })
  async forgotPassword(@Body() dto: ForgotPasswordDto): Promise<void> {
    await this.auth.forgotPassword(dto);
  }

  @Post('password/verify-otp')
  @HttpCode(HttpStatus.NO_CONTENT)
  @Throttle(STRICT_THROTTLE)
  @ApiOperation({
    summary: 'Check a password reset code',
    description:
      'Lets the app confirm the code before asking for a new password. ' +
      'The code stays usable for POST /auth/password/reset. Wrong tries ' +
      'count: OTP_MAX_ATTEMPTS lock the code until a new one is sent.',
  })
  @ApiNoContentResponse({ description: 'The code is right.' })
  @ApiUnprocessableEntityResponse({
    type: ApiErrorResponseDto,
    description:
      'INVALID_VERIFICATION_CODE (wrong or expired) or ' +
      'VERIFICATION_CODE_LOCKED.',
  })
  async verifyOtp(@Body() dto: VerifyOtpDto): Promise<void> {
    await this.auth.verifyOtp(dto);
  }

  @Post('password/reset')
  @HttpCode(HttpStatus.NO_CONTENT)
  @Throttle(STRICT_THROTTLE)
  @ApiOperation({
    summary: 'Set a new password with the texted code',
    description:
      'Uses the code up, marks the phone verified and revokes every ' +
      'session, so the user signs in again with the new password. ' +
      'Passwords follow the registration rules.',
  })
  @ApiNoContentResponse()
  @ApiUnprocessableEntityResponse({
    type: ApiErrorResponseDto,
    description:
      'VALIDATION_ERROR (errors per field), INVALID_VERIFICATION_CODE ' +
      '(wrong, expired or already used) or VERIFICATION_CODE_LOCKED.',
  })
  async resetPassword(@Body() dto: ResetPasswordDto): Promise<void> {
    await this.auth.resetPassword(dto);
  }

  @Post('password/change')
  @HttpCode(HttpStatus.NO_CONTENT)
  @UseGuards(JwtAuthGuard)
  async changePassword(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: ChangePasswordDto,
  ): Promise<void> {
    await this.auth.changePassword(user.id, user.sessionId, dto);
  }

  @Get('sessions')
  @UseGuards(JwtAuthGuard)
  async sessions(@CurrentUser() user: AuthenticatedUser) {
    return { data: await this.auth.listSessions(user.id, user.sessionId) };
  }

  @Delete('sessions/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @UseGuards(JwtAuthGuard)
  async revokeSession(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ): Promise<void> {
    await this.auth.revokeSession(user.id, id);
  }

  @Delete('sessions')
  @HttpCode(HttpStatus.NO_CONTENT)
  @UseGuards(JwtAuthGuard)
  async revokeOtherSessions(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<void> {
    await this.auth.revokeOtherSessions(user.id, user.sessionId);
  }
}
