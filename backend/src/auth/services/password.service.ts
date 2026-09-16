import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcryptjs';
import type { AuthConfig } from '../../config/configuration';

/**
 * The single place passwords are hashed/verified. bcrypt with a cost of
 * >= 12 (docs/backend/02-auth-and-authorization.md §7). Never logs, never
 * returns, and never stores a plaintext password.
 */
@Injectable()
export class PasswordService {
  private readonly rounds: number;

  constructor(configService: ConfigService) {
    this.rounds = configService.get<AuthConfig>('auth')!.bcryptRounds;
  }

  hash(plain: string): Promise<string> {
    return bcrypt.hash(plain, this.rounds);
  }

  verify(plain: string, hash: string): Promise<boolean> {
    return bcrypt.compare(plain, hash);
  }
}
