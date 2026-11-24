/**
 * Minimal CSV writer for admin exports.
 *
 * Spreadsheet apps run a cell as a formula when it starts with `=`, `+`,
 * `-`, `@` (or a tab/CR). A user-chosen name like `=HYPERLINK(...)` would
 * then execute on the admin's machine, so such cells get a leading `'`.
 */
/** Byte-order mark; lets Excel open the file as UTF-8. */
const BOM = String.fromCharCode(0xfeff);
const FORMULA_START = /^[=+\-@\t\r]/;

export function csvCell(value: unknown): string {
  if (value === null || value === undefined) return '';
  let text: string;
  if (value instanceof Date) text = value.toISOString();
  else if (typeof value === 'string') text = value;
  else if (typeof value === 'number' || typeof value === 'boolean') {
    text = String(value);
  } else text = JSON.stringify(value);
  if (FORMULA_START.test(text)) text = `'${text}`;
  return /[",\r\n]/.test(text) ? `"${text.replace(/"/g, '""')}"` : text;
}

/** Header + rows, CRLF separated, with a BOM so Excel reads UTF-8 (Arabic). */
export function toCsv(
  headers: readonly string[],
  rows: readonly (readonly unknown[])[],
): string {
  const lines = [headers, ...rows].map((row) => row.map(csvCell).join(','));
  return `${BOM}${lines.join('\r\n')}\r\n`;
}
