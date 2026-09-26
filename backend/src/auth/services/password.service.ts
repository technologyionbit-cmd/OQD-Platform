import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcryptjs';
import { randomBytes } from 'crypto';
import type { AuthConfig } from '../../config/configuration';

/**
 * The single place passwords are hashed/verified. bcrypt with a cost of
 * >= 12 (docs/backend/02-auth-and-authorization.md §7). Never logs, never
 * returns, and never stores a plaintext password.
 */
@Injectable()
export class PasswordService {
  private readonly rounds: number;

  /**
   * A hash of a random secret at the real cost factor, compared against
   * when there is no account — so "no such email" costs the same bcrypt
   * work as "wrong password" and response time can't reveal which emails
   * are registered. Computed once, lazily.
   */
  private dummyHash?: Promise<string>;

  constructor(configService: ConfigService) {
    this.rounds = configService.get<AuthConfig>('auth')!.bcryptRounds;
  }

  hash(plain: string): Promise<string> {
    return bcrypt.hash(plain, this.rounds);
  }

  verify(plain: string, hash: string): Promise<boolean> {
    return bcrypt.compare(plain, hash);
  }

  /**
   * Constant-work check for sign-in: with no stored hash (unknown account)
   * it still runs a full bcrypt comparison, then reports `false`.
   */
  async verifyOrBurn(plain: string, hash: string | null): Promise<boolean> {
    if (hash !== null) return this.verify(plain, hash);
    this.dummyHash ??= this.hash(randomBytes(32).toString('hex'));
    await this.verify(plain, await this.dummyHash);
    return false;
  }
}
