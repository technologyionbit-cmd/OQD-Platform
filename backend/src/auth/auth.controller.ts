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
import { VerifyEmailDto } from './dto/email-verification.dto';
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
      'Signs the user in at once and emails a 6-digit verification code ' +
      '(logged on the server until an email provider exists). The account ' +
      'works, but sensitive actions answer 403 EMAIL_NOT_VERIFIED until ' +
      'POST /auth/email/verify succeeds. Passwords: 8+ characters, at most ' +
      '72 bytes (UTF-8), at least one letter and one number.',
  })
  @ApiCreatedResponse({ type: SessionResponseDto })
  @ApiUnprocessableEntityResponse({
    type: ApiErrorResponseDto,
    description:
      'VALIDATION_ERROR (errors per field), EMAIL_ALREADY_REGISTERED, ' +
      'COMMERCIAL_REGISTRATION_TAKEN, BAR_LICENSE_TAKEN, or ' +
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
      'Wrong email and wrong password are indistinguishable (same 401, ' +
      'same timing). Limited per IP and per email (LOGIN_MAX_ATTEMPTS per ' +
      'LOGIN_ATTEMPT_WINDOW_MINUTES); a 429 carries Retry-After in seconds.',
  })
  @ApiOkResponse({ type: SessionResponseDto })
  @ApiUnauthorizedResponse({
    type: ApiErrorResponseDto,
    description: 'Invalid email or password (code UNAUTHORIZED).',
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
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth(BEARER_AUTH)
  @ApiOperation({
    summary: 'Update name and email',
    description:
      'Changing the email marks it unverified and sends a new code. ' +
      '422 EMAIL_ALREADY_REGISTERED when another account uses it.',
  })
  @ApiOkResponse({ type: UserResponseDto })
  async updateProfile(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateProfileDto,
  ) {
    return { data: { user: await this.auth.updateProfile(user.id, dto) } };
  }

  @Post('email/verify')
  @HttpCode(HttpStatus.OK)
  @Throttle(STRICT_THROTTLE)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth(BEARER_AUTH)
  @ApiOperation({
    summary: 'Verify the account email',
    description:
      'Checks the latest code sent to the signed-in user. Already ' +
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
  async verifyEmail(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: VerifyEmailDto,
  ) {
    return { data: { user: await this.auth.verifyEmail(user.id, dto.code) } };
  }

  @Post('email/resend')
  @HttpCode(HttpStatus.NO_CONTENT)
  @Throttle(STRICT_THROTTLE)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth(BEARER_AUTH)
  @ApiOperation({
    summary: 'Send a new email verification code',
    description:
      'One code per EMAIL_VERIFICATION_RESEND_COOLDOWN_SECONDS and at most ' +
      'EMAIL_VERIFICATION_MAX_PER_HOUR per account (the sign-up code ' +
      'counts). Over the limit: 429 with Retry-After in seconds. Does ' +
      'nothing for an already verified account.',
  })
  @ApiNoContentResponse()
  @ApiUnauthorizedResponse({ type: ApiErrorResponseDto })
  async resendEmailVerification(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<void> {
    await this.auth.resendEmailVerification(user.id);
  }

  @Post('password/forgot')
  @HttpCode(HttpStatus.NO_CONTENT)
  @Throttle(STRICT_THROTTLE)
  async forgotPassword(@Body() dto: ForgotPasswordDto): Promise<void> {
    await this.auth.forgotPassword(dto);
  }

  @Post('password/verify-otp')
  @HttpCode(HttpStatus.OK)
  @Throttle(STRICT_THROTTLE)
  async verifyOtp(@Body() dto: VerifyOtpDto) {
    return { data: await this.auth.verifyOtp(dto) };
  }

  @Post('password/reset')
  @HttpCode(HttpStatus.NO_CONTENT)
  @Throttle(STRICT_THROTTLE)
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
