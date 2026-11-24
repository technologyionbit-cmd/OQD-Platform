import { csvCell, toCsv } from './csv';

describe('csv', () => {
  it('quotes commas, quotes and newlines', () => {
    expect(csvCell('a,b')).toBe('"a,b"');
    expect(csvCell('say "hi"')).toBe('"say ""hi"""');
    expect(csvCell('line1\nline2')).toBe('"line1\nline2"');
  });

  it.each(['=1+1', '+1', '-1', '@SUM(A1)', '\tcmd'])(
    'neutralises the formula start %j',
    (cell) => {
      expect(csvCell(cell).replace(/^"/, '')).toMatch(/^'/);
    },
  );

  it('writes empty, numbers, booleans and dates', () => {
    expect(csvCell(null)).toBe('');
    expect(csvCell(undefined)).toBe('');
    expect(csvCell(5)).toBe('5');
    expect(csvCell(true)).toBe('true');
    expect(csvCell(new Date('2026-01-01T00:00:00Z'))).toBe('2026-01-01T00:00:00.000Z');
  });

  it('builds BOM + header + CRLF rows, keeping Arabic intact', () => {
    const csv = toCsv(['name', 'n'], [['ليلى', 1]]);
    expect(csv.charCodeAt(0)).toBe(0xfeff);
    expect(csv.slice(1)).toBe('name,n\r\nليلى,1\r\n');
  });
});
