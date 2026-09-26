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
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiTooManyRequestsResponse,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { ApiErrorResponseDto } from '../common/openapi/api-error.dto';
import { BEARER_AUTH } from '../common/openapi/setup-openapi';
import { AuthService } from './auth.service';
import { TokensResponseDto, UserResponseDto } from './dto/auth-responses.dto';
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
import { RegisterDto } from './dto/register.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

/** Tight limits for the credential-guessing surface (docs/backend/14-security.md). */
const STRICT_THROTTLE = { default: { limit: 8, ttl: 60_000 } };

@ApiTags('auth')
@ApiTooManyRequestsResponse({ type: ApiErrorResponseDto })
@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('register')
  @Throttle(STRICT_THROTTLE)
  async register(
    @Body() dto: RegisterDto,
    @ClientContext() ctx: RequestContext,
  ) {
    return { data: await this.auth.register(dto, ctx) };
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @Throttle(STRICT_THROTTLE)
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
  async updateProfile(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateProfileDto,
  ) {
    return { data: { user: await this.auth.updateProfile(user.id, dto) } };
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
