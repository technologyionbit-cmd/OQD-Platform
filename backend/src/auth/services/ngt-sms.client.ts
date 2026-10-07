import type { SmsConfig } from '../../config/configuration';

export interface SmsSendResult {
  ok: boolean;
  /** e.g. "I01" / "E05" — never includes the message text (carries the OTP). */
  code: string;
}

/**
 * `+9627XXXXXXXX` / `07XXXXXXXX` / `9627XXXXXXXX` -> `9627XXXXXXXX`
 * (NGT wants digits only, with country code).
 */
export function toNgtMobileNumber(phone: string): string {
  const digits = phone.replace(/\D/g, '');
  if (digits.startsWith('00')) return digits.slice(2);
  if (digits.startsWith('0')) return `962${digits.slice(1)}`;
  return digits;
}

/**
 * Thin wrapper around the NGT SMSPRO HTTPS interface — a GET gateway that
 * answers `I0x-...` on success or `E0x-...` on failure (or a bare
 * "SUCCESS"/"ERROR" with response=JSON).
 */
export async function sendNgtSms(
  cfg: SmsConfig,
  phone: string,
  message: string,
): Promise<SmsSendResult> {
  const url = new URL(cfg.baseUrl);
  url.searchParams.set('login_name', cfg.loginName);
  url.searchParams.set('login_password', cfg.loginPassword);
  url.searchParams.set('msg', message);
  url.searchParams.set('mobile_number', toNgtMobileNumber(phone));
  url.searchParams.set('from', cfg.senderId);
  url.searchParams.set('charset', 'UTF-8');
  url.searchParams.set('response', 'JSON');
  url.searchParams.set('otp_msg', '1');

  const res = await fetch(url, { signal: AbortSignal.timeout(8000) });
  const status = extractStatus(await res.text());
  const normalized = status.toUpperCase();
  const ok = normalized.startsWith('I0') || normalized === 'SUCCESS';
  const dash = status.indexOf('-');
  return { ok, code: dash > 0 ? status.slice(0, dash) : status };
}

function extractStatus(responseText: string): string {
  const trimmed = responseText.trim();
  try {
    const parsed = JSON.parse(trimmed) as Record<string, unknown>;
    const candidate = Object.values(parsed).find((v) => typeof v === 'string');
    if (typeof candidate === 'string') return candidate;
  } catch {
    // Not JSON — use the raw text.
  }
  return trimmed;
}
