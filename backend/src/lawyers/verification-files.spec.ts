import {
  cleanOriginalName,
  detectVerificationFileType,
} from './verification-files';

describe('detectVerificationFileType', () => {
  it('recognizes JPEG, PNG and PDF by their first bytes', () => {
    expect(
      detectVerificationFileType(Buffer.from([0xff, 0xd8, 0xff, 0xe0, 0x00]))
        ?.extension,
    ).toBe('jpg');
    expect(
      detectVerificationFileType(
        Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00]),
      )?.extension,
    ).toBe('png');
    expect(
      detectVerificationFileType(Buffer.from('%PDF-1.7\n'))?.extension,
    ).toBe('pdf');
  });

  it('refuses anything else, whatever it is called', () => {
    expect(
      detectVerificationFileType(
        Buffer.from('<html><script>alert(1)</script>'),
      ),
    ).toBeNull();
    expect(detectVerificationFileType(Buffer.from('MZ\x90\x00'))).toBeNull();
    expect(detectVerificationFileType(Buffer.alloc(0))).toBeNull();
  });
});

describe('cleanOriginalName', () => {
  it('keeps only the base name without control characters', () => {
    expect(cleanOriginalName('../../etc/passwd')).toBe('passwd');
    expect(cleanOriginalName('C:\\docs\\bar card.pdf')).toBe('bar card.pdf');
    expect(cleanOriginalName('id\u0000.png')).toBe('id.png');
  });

  it('falls back to a neutral name', () => {
    expect(cleanOriginalName(undefined)).toBe('document');
    expect(cleanOriginalName('   ')).toBe('document');
  });
});
