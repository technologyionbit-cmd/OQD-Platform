import { StreamableFile } from '@nestjs/common';
import type { ReadStream } from 'node:fs';
import { badRequest } from '../common/errors/api-exceptions';

/** Official PDFs live in their own folder on the private upload disk. */
export const OFFICIAL_PDF_FOLDER = 'official-pdfs';
export const OFFICIAL_PDF_MAX_BYTES = 10 * 1024 * 1024;

/** The part of a multer file this code uses. */
export interface UploadedPdf {
  buffer: Buffer;
  originalname: string;
  size: number;
}

/**
 * Checks an uploaded file really is a PDF from its first bytes (the name
 * and Content-Type a client sends are not trusted) and returns the name
 * to show for it.
 */
export function checkPdfUpload(file: UploadedPdf | undefined): {
  buffer: Buffer;
  displayName: string;
} {
  if (!file) throw badRequest('Send the PDF in the "file" field.');
  if (file.size > OFFICIAL_PDF_MAX_BYTES) {
    throw badRequest('The PDF is larger than 10 MB.');
  }
  if (file.buffer.subarray(0, 5).toString('latin1') !== '%PDF-') {
    throw badRequest('Only PDF files are accepted.');
  }
  const base = (file.originalname.split(/[\\/]/).pop() ?? '')
    // eslint-disable-next-line no-control-regex
    .replace(/[\u0000-\u001f\u007f]/g, '')
    .trim()
    .slice(0, 200);
  return { buffer: file.buffer, displayName: base || 'official.pdf' };
}

/** A download response: always an attachment, never shown inline. */
export function pdfDownload(stream: ReadStream, fileName: string) {
  const ascii = fileName.replace(/[^\x20-\x7e]/g, '_').replace(/["\\]/g, '_');
  return new StreamableFile(stream, {
    type: 'application/pdf',
    disposition: `attachment; filename="${ascii}"; filename*=UTF-8''${encodeURIComponent(fileName)}`,
  });
}
