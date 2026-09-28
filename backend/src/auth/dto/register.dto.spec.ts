import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { ChangePasswordDto } from './credentials.dto';
import { ResetPasswordDto } from './password-reset.dto';
import { RegisterDto } from './register.dto';

const valid = {
  accountType: 'individual',
  fullName: 'Ahmad Client',
  phone: '0791234567',
  email: 'ahmad@test.com',
  password: 'Password123',
  acceptTerms: true,
  termsVersion: '2026-09-28',
};

async function failedFields(body: Record<string, unknown>) {
  const errors = await validate(plainToInstance(RegisterDto, body));
  return errors.map((e) => e.property);
}

describe('RegisterDto', () => {
  it('accepts a complete individual sign-up', async () => {
    expect(await failedFields(valid)).toEqual([]);
  });

  it.each([
    ['missing', undefined],
    ['false', false],
    ['a truthy string', 'true'],
  ])('rejects acceptTerms when %s', async (_, acceptTerms) => {
    expect(await failedFields({ ...valid, acceptTerms })).toEqual([
      'acceptTerms',
    ]);
  });

  it('requires termsVersion', async () => {
    expect(await failedFields({ ...valid, termsVersion: '' })).toEqual([
      'termsVersion',
    ]);
  });

  it('accepts a password of exactly 72 bytes', async () => {
    // 36 two-byte Arabic letters would have no digit/Latin letter, so mix:
    // "a1" + 35 × "ب" (2 bytes each) = 2 + 70 = 72 bytes.
    const password = 'a1' + 'ب'.repeat(35);
    expect(Buffer.byteLength(password)).toBe(72);
    expect(await failedFields({ ...valid, password })).toEqual([]);
  });

  it('rejects a password over 72 bytes even when under 72 characters', async () => {
    const password = 'a1' + 'ب'.repeat(36); // 38 characters, 74 bytes
    expect(await failedFields({ ...valid, password })).toEqual(['password']);
  });

  it.each(['short1', 'lettersonly', '12345678'])(
    'rejects the weak password %p',
    async (password) => {
      expect(await failedFields({ ...valid, password })).toEqual(['password']);
    },
  );
});

describe('password byte limit on change and reset', () => {
  const tooLong = 'a1' + 'x'.repeat(71); // 73 bytes

  it('applies to ChangePasswordDto.newPassword', async () => {
    const errors = await validate(
      plainToInstance(ChangePasswordDto, {
        currentPassword: 'Old12345',
        newPassword: tooLong,
      }),
    );
    expect(errors.map((e) => e.property)).toEqual(['newPassword']);
  });

  it('applies to ResetPasswordDto.newPassword', async () => {
    const errors = await validate(
      plainToInstance(ResetPasswordDto, {
        destination: 'a@test.com',
        code: '123456',
        newPassword: tooLong,
      }),
    );
    expect(errors.map((e) => e.property)).toEqual(['newPassword']);
  });
});
