import { BadRequestException } from '@nestjs/common';
import type { PrismaService } from '../prisma/prisma.service';
import { AdminContractTemplatesService } from '../admin/contract-templates/admin-contract-templates';
import { AdminGovProceduresService } from '../admin/gov-procedures/admin-gov-procedures';
import { GovProceduresService } from '../gov-procedures/gov-procedures.service';
import type { FileStorageService } from './file-storage.service';
import { checkPdfUpload, OFFICIAL_PDF_MAX_BYTES } from './official-pdf';

const pdf = (name = 'form.pdf', body = '%PDF-1.4 test') => ({
  buffer: Buffer.from(body),
  originalname: name,
  size: Buffer.byteLength(body),
});

describe('checkPdfUpload', () => {
  it('accepts a real PDF and cleans its name', () => {
    const out = checkPdfUpload(pdf('C:\\fakepath\\عقد عمل.pdf'));
    expect(out.displayName).toBe('عقد عمل.pdf');
  });

  it('refuses a missing file, a non-PDF renamed to .pdf, and a huge one', () => {
    expect(() => checkPdfUpload(undefined)).toThrow(BadRequestException);
    expect(() => checkPdfUpload(pdf('a.pdf', '<html>nope</html>'))).toThrow(BadRequestException);
    expect(() => checkPdfUpload({ ...pdf(), size: OFFICIAL_PDF_MAX_BYTES + 1 })).toThrow(BadRequestException);
  });
});

function storage() {
  return {
    save: jest.fn().mockResolvedValue('official-pdfs/new.pdf'),
    remove: jest.fn().mockResolvedValue(undefined),
    open: jest.fn().mockResolvedValue('STREAM'),
  };
}

describe.each([
  ['contract templates', 'contractTemplate', (p: unknown, s: unknown) => new AdminContractTemplatesService(p as PrismaService, s as FileStorageService)],
  ['gov procedures', 'govProcedure', (p: unknown, s: unknown) => new AdminGovProceduresService(p as PrismaService, s as FileStorageService)],
])('admin official PDF for %s', (_label, model, make) => {
  function setup(current: object | null, failUpdate = false) {
    const prisma = {
      [model]: {
        findUnique: jest.fn().mockResolvedValue(current),
        update: failUpdate ? jest.fn().mockRejectedValue(new Error('db')) : jest.fn().mockResolvedValue({}),
      },
    };
    const st = storage();
    return { prisma, st, service: make(prisma, st) as unknown as {
      setPdf: (id: string, f: unknown) => Promise<{ fileName: string }>;
      clearPdf: (id: string) => Promise<unknown>;
    } };
  }

  it('stores the new file, then deletes the one it replaces', async () => {
    const { prisma, st, service } = setup({ pdfStorageKey: 'official-pdfs/old.pdf' });
    const out = await service.setPdf('id', pdf('new.pdf'));
    expect(out.fileName).toBe('new.pdf');
    expect(st.save).toHaveBeenCalledWith('official-pdfs', 'pdf', expect.any(Buffer));
    expect((prisma[model as keyof typeof prisma] as { update: jest.Mock }).update).toHaveBeenCalledWith({
      where: { id: 'id' },
      data: { pdfStorageKey: 'official-pdfs/new.pdf', pdfFileName: 'new.pdf' },
    });
    expect(st.remove).toHaveBeenCalledWith('official-pdfs/old.pdf');
  });

  it('removes the new file again when the database write fails', async () => {
    const { st, service } = setup({ pdfStorageKey: null }, true);
    await expect(service.setPdf('id', pdf())).rejects.toThrow('db');
    expect(st.remove).toHaveBeenCalledWith('official-pdfs/new.pdf');
  });

  it('stores nothing for a missing record or a fake PDF', async () => {
    const missing = setup(null);
    await expect(missing.service.setPdf('id', pdf())).rejects.toThrow('not found');
    const fake = setup({ pdfStorageKey: null });
    await expect(fake.service.setPdf('id', pdf('x.pdf', 'MZ...'))).rejects.toBeInstanceOf(BadRequestException);
    expect(fake.st.save).not.toHaveBeenCalled();
  });

  it('clearing deletes the stored file', async () => {
    const { st, service } = setup({ pdfStorageKey: 'official-pdfs/old.pdf', pdfFileName: 'old.pdf' });
    await service.clearPdf('id');
    expect(st.remove).toHaveBeenCalledWith('official-pdfs/old.pdf');
  });
});

describe('GovProceduresService (what the app sees)', () => {
  it('shows whether a PDF exists but never where it is stored', async () => {
    const row = { id: 'p', type: 'x', pdfStorageKey: 'official-pdfs/secret.pdf', pdfFileName: 'secret.pdf', requiredDocuments: [], steps: [] };
    const prisma = { govProcedure: { findMany: jest.fn().mockResolvedValue([row]), findUnique: jest.fn().mockResolvedValue(row) } };
    const service = new GovProceduresService(prisma as unknown as PrismaService, storage() as unknown as FileStorageService);
    const [list] = (await service.findAll()) as unknown as Record<string, unknown>[];
    const one = (await service.findById('p')) as unknown as Record<string, unknown>;
    for (const out of [list, one]) {
      expect(out.hasPdf).toBe(true);
      expect(JSON.stringify(out)).not.toContain('secret.pdf');
      expect(out).not.toHaveProperty('pdfStorageKey');
    }
  });

  it('answers 404 when there is no PDF', async () => {
    const prisma = { govProcedure: { findUnique: jest.fn().mockResolvedValue({ pdfStorageKey: null, pdfFileName: null }) } };
    const service = new GovProceduresService(prisma as unknown as PrismaService, storage() as unknown as FileStorageService);
    await expect(service.openPdf('p')).rejects.toThrow('no PDF');
  });
});
