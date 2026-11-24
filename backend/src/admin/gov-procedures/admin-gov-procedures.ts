import {
  Body,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Injectable,
  Param,
  ParseUUIDPipe,
  Post,
  Put,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiConsumes, ApiOperation } from '@nestjs/swagger';
import { GovProcedureAccessType } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { notFound } from '../../common/errors/api-exceptions';
import { PrismaService } from '../../prisma/prisma.service';
import { FileStorageService } from '../../storage/file-storage.service';
import {
  checkPdfUpload,
  OFFICIAL_PDF_FOLDER,
  OFFICIAL_PDF_MAX_BYTES,
  type UploadedPdf,
} from '../../storage/official-pdf';
import { AuditAction, AuditNoter } from '../audit/audit.decorators';
import type { AuditNoteFn } from '../audit/audit.types';
import { AdminController } from '../common/admin-controller.decorator';

/** Text in both app languages. */
export class LocalizedTextDto {
  @IsString()
  @MinLength(1)
  @MaxLength(400)
  ar!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(400)
  en!: string;
}

export class RequiredDocumentDto {
  /** Present for an existing document, so users' ticked boxes survive. */
  @IsOptional()
  @IsUUID()
  id?: string;

  @ValidateNested()
  @Type(() => LocalizedTextDto)
  title!: LocalizedTextDto;
}

export class ProcedureStepDto {
  @IsOptional()
  @IsUUID()
  id?: string;

  @ValidateNested()
  @Type(() => LocalizedTextDto)
  title!: LocalizedTextDto;

  @ValidateNested()
  @Type(() => LocalizedTextDto)
  description!: LocalizedTextDto;
}

export class UpdateGovProcedureDto {
  @IsEnum(GovProcedureAccessType)
  accessType!: GovProcedureAccessType;

  @ValidateNested()
  @Type(() => LocalizedTextDto)
  durationLabel!: LocalizedTextDto;

  @IsArray()
  @ArrayMaxSize(30)
  @ValidateNested({ each: true })
  @Type(() => RequiredDocumentDto)
  requiredDocuments!: RequiredDocumentDto[];

  @IsArray()
  @ArrayMaxSize(30)
  @ValidateNested({ each: true })
  @Type(() => ProcedureStepDto)
  steps!: ProcedureStepDto[];
}

type Localized = { ar: string; en: string };

const asLocalized = (value: unknown): Localized => {
  const v = (value ?? {}) as Partial<Localized>;
  return { ar: v.ar ?? '', en: v.en ?? '' };
};

@Injectable()
export class AdminGovProceduresService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: FileStorageService,
  ) {}

  /** The whole catalog is four rows, so no paging. */
  async list() {
    const rows = await this.prisma.govProcedure.findMany({
      orderBy: { type: 'asc' },
      select: {
        id: true,
        type: true,
        accessType: true,
        durationLabel: true,
        pdfStorageKey: true,
        pdfFileName: true,
        updatedAt: true,
        _count: {
          select: { requiredDocuments: true, steps: true, progress: true },
        },
      },
    });
    return rows.map(({ _count, pdfStorageKey, ...r }) => ({
      ...r,
      hasPdf: pdfStorageKey !== null,
      documentsCount: _count.requiredDocuments,
      stepsCount: _count.steps,
      startedByCount: _count.progress,
    }));
  }

  async detail(id: string) {
    const row = await this.prisma.govProcedure.findUnique({
      where: { id },
      include: {
        requiredDocuments: { orderBy: { sortOrder: 'asc' } },
        steps: { orderBy: { sortOrder: 'asc' } },
      },
    });
    if (!row) throw notFound('Procedure not found.');
    return {
      id: row.id,
      type: row.type,
      accessType: row.accessType,
      hasPdf: row.pdfStorageKey !== null,
      pdfFileName: row.pdfFileName,
      durationLabel: asLocalized(row.durationLabel),
      requiredDocuments: row.requiredDocuments.map((d) => ({
        id: d.id,
        title: asLocalized(d.title),
      })),
      steps: row.steps.map((s) => ({
        id: s.id,
        title: asLocalized(s.title),
        description: asLocalized(s.description),
      })),
    };
  }

  /** Stores (or replaces) the official PDF. */
  async setPdf(id: string, file: UploadedPdf | undefined) {
    const { buffer, displayName } = checkPdfUpload(file);
    const current = await this.prisma.govProcedure.findUnique({
      where: { id },
      select: { pdfStorageKey: true },
    });
    if (!current) throw notFound('Procedure not found.');
    const key = await this.storage.save(OFFICIAL_PDF_FOLDER, 'pdf', buffer);
    try {
      await this.prisma.govProcedure.update({
        where: { id },
        data: { pdfStorageKey: key, pdfFileName: displayName },
      });
    } catch (error) {
      await this.storage.remove(key);
      throw error;
    }
    if (current.pdfStorageKey) await this.storage.remove(current.pdfStorageKey);
    return { fileName: displayName, size: buffer.length };
  }

  async clearPdf(id: string) {
    const current = await this.prisma.govProcedure.findUnique({
      where: { id },
      select: { pdfStorageKey: true, pdfFileName: true },
    });
    if (!current) throw notFound('Procedure not found.');
    await this.prisma.govProcedure.update({
      where: { id },
      data: { pdfStorageKey: null, pdfFileName: null },
    });
    if (current.pdfStorageKey) await this.storage.remove(current.pdfStorageKey);
    return { fileName: current.pdfFileName };
  }

  /**
   * Replaces a procedure's content. Rows that keep their id are updated in
   * place (so progress that points at a document survives), new rows are
   * created, and rows left out are deleted. Order follows the array.
   */
  async update(id: string, dto: UpdateGovProcedureDto) {
    const before = await this.detail(id);
    await this.prisma.$transaction(async (tx) => {
      await tx.govProcedure.update({
        where: { id },
        data: {
          accessType: dto.accessType,
          durationLabel: { ar: dto.durationLabel.ar, en: dto.durationLabel.en },
        },
      });

      const keepDocs = new Set(
        before.requiredDocuments.map((d) => d.id),
      );
      const docIds = dto.requiredDocuments.flatMap((d) =>
        d.id && keepDocs.has(d.id) ? [d.id] : [],
      );
      await tx.govRequiredDocument.deleteMany({
        where: { procedureId: id, id: { notIn: docIds } },
      });
      for (const [i, doc] of dto.requiredDocuments.entries()) {
        const title = { ar: doc.title.ar, en: doc.title.en };
        if (doc.id && keepDocs.has(doc.id)) {
          await tx.govRequiredDocument.update({
            where: { id: doc.id },
            data: { title, sortOrder: i },
          });
        } else {
          await tx.govRequiredDocument.create({
            data: { procedureId: id, title, sortOrder: i },
          });
        }
      }

      const keepSteps = new Set(before.steps.map((s) => s.id));
      const stepIds = dto.steps.flatMap((s) =>
        s.id && keepSteps.has(s.id) ? [s.id] : [],
      );
      await tx.govProcedureStep.deleteMany({
        where: { procedureId: id, id: { notIn: stepIds } },
      });
      for (const [i, step] of dto.steps.entries()) {
        const data = {
          title: { ar: step.title.ar, en: step.title.en },
          description: { ar: step.description.ar, en: step.description.en },
          sortOrder: i,
        };
        if (step.id && keepSteps.has(step.id)) {
          await tx.govProcedureStep.update({ where: { id: step.id }, data });
        } else {
          await tx.govProcedureStep.create({
            data: { procedureId: id, ...data },
          });
        }
      }
    });
    return { before, after: await this.detail(id) };
  }
}

/** The government-procedure catalog the app reads, editable by staff. */
@AdminController('gov-procedures', 'govProcedures')
export class AdminGovProceduresController {
  constructor(private readonly procedures: AdminGovProceduresService) {}

  @Get()
  @ApiOperation({ summary: 'The procedure catalog with how many users use each' })
  async list() {
    return { data: await this.procedures.list() };
  }

  @Get(':id')
  @ApiOperation({ summary: 'One procedure with its documents and steps' })
  async detail(@Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.procedures.detail(id) };
  }

  @Post(':id/pdf')
  @HttpCode(HttpStatus.OK)
  @AuditAction('govProcedure.uploadPdf')
  @ApiConsumes('multipart/form-data')
  @ApiOperation({
    summary: 'Upload the official PDF (multipart field "file", max 10 MB)',
  })
  @UseInterceptors(
    FileInterceptor('file', {
      limits: { fileSize: OFFICIAL_PDF_MAX_BYTES, files: 1 },
    }),
  )
  async uploadPdf(
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFile() file: UploadedPdf | undefined,
    @AuditNoter() note: AuditNoteFn,
  ) {
    const result = await this.procedures.setPdf(id, file);
    note({ entityType: 'govProcedure', entityId: id, meta: result });
    return { data: result };
  }

  @Delete(':id/pdf')
  @HttpCode(HttpStatus.NO_CONTENT)
  @AuditAction('govProcedure.removePdf')
  @ApiOperation({ summary: 'Remove the official PDF' })
  async removePdf(
    @Param('id', ParseUUIDPipe) id: string,
    @AuditNoter() note: AuditNoteFn,
  ): Promise<void> {
    const result = await this.procedures.clearPdf(id);
    note({ entityType: 'govProcedure', entityId: id, meta: result });
  }

  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @AuditAction('govProcedure.update')
  @ApiOperation({
    summary: 'Replace a procedure\'s duration, access type, documents and steps',
  })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateGovProcedureDto,
    @AuditNoter() note: AuditNoteFn,
  ) {
    const { before, after } = await this.procedures.update(id, dto);
    note({ entityType: 'govProcedure', entityId: id, before, after });
    return { data: after };
  }
}
