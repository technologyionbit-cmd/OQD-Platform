import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import type { JwtConfig } from '../config/configuration';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { OtpService } from './services/otp.service';
import { PasswordService } from './services/password.service';
import { TokenService } from './services/token.service';

@Module({
  imports: [
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        const jwt = configService.get<JwtConfig>('jwt')!;
        return {
          secret: jwt.accessSecret,
          // `expiresIn` accepts the `ms` string form ("15m") at runtime;
          // its published type is narrower than `string`, hence the cast.
          signOptions: {
            expiresIn: jwt.accessTtl as unknown as number,
          },
        };
      },
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    PasswordService,
    TokenService,
    OtpService,
    JwtAuthGuard,
  ],
  // The auth surface other feature modules need to protect their own
  // routes (docs/plans/individual-user-rollout.md). A `@UseGuards(Class)`
  // reference is resolved in the *consuming* module's injector, so
  // TokenService must be exported too — importing modules re-declare
  // JwtAuthGuard as their own provider and it resolves TokenService from
  // here via the module import.
  exports: [JwtAuthGuard, TokenService],
})
export class AuthModule {}
