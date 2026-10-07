/** Rules for the files a lawyer sends for verification. */
export const VERIFICATION_MAX_FILES = 3;
export const VERIFICATION_MAX_FILE_BYTES = 10 * 1024 * 1024;

export type VerificationFileType = {
  extension: 'jpg' | 'png' | 'pdf';
  mimeType: string;
};

/**
 * The file's real type from its first bytes. The name and the
 * Content-Type a client sends are not trusted: an HTML or script file
 * renamed to .pdf is refused here.
 */
export function detectVerificationFileType(
  data: Buffer,
): VerificationFileType | null {
  if (
    data.length >= 3 &&
    data[0] === 0xff &&
    data[1] === 0xd8 &&
    data[2] === 0xff
  ) {
    return { extension: 'jpg', mimeType: 'image/jpeg' };
  }
  if (
    data.length >= 8 &&
    data
      .subarray(0, 8)
      .equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]))
  ) {
    return { extension: 'png', mimeType: 'image/png' };
  }
  if (data.length >= 5 && data.subarray(0, 5).toString('latin1') === '%PDF-') {
    return { extension: 'pdf', mimeType: 'application/pdf' };
  }
  return null;
}

/** A display name safe to store and show: no path, no control characters. */
export function cleanOriginalName(name: string | undefined): string {
  const base = (name ?? '').split(/[\\/]/).pop() ?? '';
  const cleaned = base
    // eslint-disable-next-line no-control-regex
    .replace(/[\u0000-\u001f\u007f]/g, '')
    .trim()
    .slice(0, 200);
  return cleaned || 'document';
}
