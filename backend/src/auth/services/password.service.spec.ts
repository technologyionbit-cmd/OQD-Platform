import { ConfigService } from '@nestjs/config';
import { PasswordService } from './password.service';

describe('PasswordService', () => {
  const service = new PasswordService({
    get: () => ({ bcryptRounds: 10 }),
  } as unknown as ConfigService);

  it('produces a verifiable, non-reversible hash', async () => {
    const hash = await service.hash('Password123');
    expect(hash).not.toContain('Password123');
    expect(await service.verify('Password123', hash)).toBe(true);
  });

  it('rejects a wrong password', async () => {
    const hash = await service.hash('Password123');
    expect(await service.verify('WrongPass123', hash)).toBe(false);
  });

  describe('verifyOrBurn', () => {
    it('verifies against the stored hash when there is one', async () => {
      const hash = await service.hash('Password123');
      expect(await service.verifyOrBurn('Password123', hash)).toBe(true);
      expect(await service.verifyOrBurn('WrongPass123', hash)).toBe(false);
    });

    it('still does a full bcrypt comparison when there is no account', async () => {
      const verify = jest.spyOn(service, 'verify');

      expect(await service.verifyOrBurn('Password123', null)).toBe(false);
      expect(verify).toHaveBeenCalledTimes(1);
      verify.mockRestore();
    });
  });

  it('salts — the same input hashes differently each time', async () => {
    const a = await service.hash('Password123');
    const b = await service.hash('Password123');
    expect(a).not.toBe(b);
  });
});
