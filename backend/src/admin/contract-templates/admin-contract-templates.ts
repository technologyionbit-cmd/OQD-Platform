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
import {
  ApiConflictResponse,
  ApiConsumes,
  ApiOperation,
} from '@nestjs/swagger';
import { ContractCategory, Prisma } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';
import {
  CONTRACT_FIELD_TYPES,
  PARTY_FIELD_IDS,
  type ContractFieldDefinition,
} from '../../contracts/contract-templates';
import { conflict, notFound, validationFailed } from '../../common/errors/api-exceptions';
import { ApiErrorResponseDto } from '../../common/openapi/api-error.dto';
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

class TitleDto {
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  ar!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(120)
  en!: string;
}

export class CreateContractTemplateDto {
  /** Stable id the app and contracts refer to. Cannot change later. */
  @IsString()
  @Matches(/^[a-z][a-zA-Z0-9]{1,39}$/, {
    message: 'key: letters and digits, starting with a lowercase letter.',
  })
  key!: string;

  @IsEnum(ContractCategory)
  category!: ContractCategory;

  @ValidateNested()
  @Type(() => TitleDto)
  title!: TitleDto;

  /** Checked field by field in the service. */
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(40)
  fields!: unknown[];

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class UpdateContractTemplateDto {
  @IsEnum(ContractCategory)
  category!: ContractCategory;

  @ValidateNested()
  @Type(() => TitleDto)
  title!: TitleDto;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(40)
  fields!: unknown[];

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

const FIELD_ID = /^[a-zA-Z][a-zA-Z0-9]{0,39}$/;

const isText = (v: unknown, max: number): v is string =>
  typeof v === 'string' && v.trim().length > 0 && v.length <= max;

const isLocalized = (v: unknown, max: number): boolean => {
  const o = v as { ar?: unknown; en?: unknown } | null;
  return !!o && isText(o.ar, max) && isText(o.en, max);
};

/** Returns what is wrong with a submitted field list (empty when fine). */
export function validateFields(
  input: unknown[],
): { errors: string[]; fields: ContractFieldDefinition[] } {
  const errors: string[] = [];
  const fields: ContractFieldDefinition[] = [];
  const seen = new Set<string>();

  input.forEach((raw, i) => {
    const at = `#${i + 1}`;
    const f = raw as Record<string, unknown> | null;
    if (!f || typeof f !== 'object') {
      errors.push(`${at}: not an object.`);
      return;
    }
    if (typeof f.id !== 'string' || !FIELD_ID.test(f.id)) {
      errors.push(`${at}: id must be letters and digits, starting with a letter.`);
      return;
    }
    if (seen.has(f.id)) errors.push(`${f.id}: duplicate id.`);
    seen.add(f.id);

    if (!CONTRACT_FIELD_TYPES.includes(f.type as never)) {
      errors.push(`${f.id}: unknown type.`);
    }
    if (!isLocalized(f.label, 120)) {
      errors.push(`${f.id}: label needs Arabic and English text.`);
    }
    if (typeof f.isRequired !== 'boolean') {
      errors.push(`${f.id}: isRequired must be true or false.`);
    }

    let options: ContractFieldDefinition['options'];
    if (f.type === 'dropdown') {
      const list = Array.isArray(f.options) ? (f.options as unknown[]) : [];
      if (list.length === 0 || list.length > 30) {
        errors.push(`${f.id}: a dropdown needs 1 to 30 options.`);
      }
      const values = new Set<string>();
      for (const o of list as { value?: unknown; label?: unknown }[]) {
        if (!isText(o?.value, 50) || !isLocalized(o?.label, 120)) {
          errors.push(`${f.id}: every option needs a value and an Arabic and English label.`);
          break;
        }
        if (values.has(o.value as string)) {
          errors.push(`${f.id}: duplicate option value "${String(o.value)}".`);
        }
        values.add(o.value as string);
      }
      options = list as ContractFieldDefinition['options'];
    }
    fields.push({
      id: f.id,
      type: f.type as ContractFieldDefinition['type'],
      label: f.label as ContractFieldDefinition['label'],
      isRequired: f.isRequired as boolean,
      ...(options && { options }),
    });
  });

  for (const party of PARTY_FIELD_IDS) {
    if (!seen.has(party)) errors.push(`${party}: every template needs this field.`);
  }
  return { errors, fields };
}

const toJson = (v: unknown) => v as Prisma.InputJsonValue;

@Injectable()
export class AdminContractTemplatesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: FileStorageService,
  ) {}

  async list() {
    const [rows, usage] = await Promise.all([
      this.prisma.contractTemplate.findMany({ orderBy: { createdAt: 'asc' } }),
      this.prisma.contract.groupBy({
        by: ['templateKey'],
        _count: { _all: true },
      }),
    ]);
    const used = new Map(usage.map((u) => [u.templateKey, u._count._all]));
    return rows.map((row) => ({
      id: row.id,
      key: row.key,
      version: row.version,
      category: row.category,
      title: row.title,
      isActive: row.isActive,
      fieldsCount: Array.isArray(row.fields) ? row.fields.length : 0,
      hasPdf: row.pdfStorageKey !== null,
      pdfFileName: row.pdfFileName,
      contractsCount: used.get(row.key) ?? 0,
      updatedAt: row.updatedAt,
    }));
  }

  async detail(id: string) {
    const row = await this.prisma.contractTemplate.findUnique({ where: { id } });
    if (!row) throw notFound('Template not found.');
    const { pdfStorageKey, ...rest } = row;
    return { ...rest, hasPdf: pdfStorageKey !== null };
  }

  /** Stores (or replaces) the official PDF. */
  async setPdf(id: string, file: UploadedPdf | undefined) {
    const { buffer, displayName } = checkPdfUpload(file);
    const current = await this.prisma.contractTemplate.findUnique({
      where: { id },
      select: { pdfStorageKey: true },
    });
    if (!current) throw notFound('Template not found.');
    const key = await this.storage.save(OFFICIAL_PDF_FOLDER, 'pdf', buffer);
    try {
      await this.prisma.contractTemplate.update({
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
    const current = await this.prisma.contractTemplate.findUnique({
      where: { id },
      select: { pdfStorageKey: true, pdfFileName: true },
    });
    if (!current) throw notFound('Template not found.');
    await this.prisma.contractTemplate.update({
      where: { id },
      data: { pdfStorageKey: null, pdfFileName: null },
    });
    if (current.pdfStorageKey) await this.storage.remove(current.pdfStorageKey);
    return { fileName: current.pdfFileName };
  }


  async create(dto: CreateContractTemplateDto) {
    const { errors, fields } = validateFields(dto.fields);
    if (errors.length > 0) throw validationFailed({ fields: errors });
    if (await this.prisma.contractTemplate.findUnique({ where: { key: dto.key } })) {
      throw conflict('A template with this key already exists.');
    }
    return this.prisma.contractTemplate.create({
      data: {
        key: dto.key,
        category: dto.category,
        title: toJson(dto.title),
        fields: toJson(fields),
        isActive: dto.isActive ?? true,
      },
    });
  }

  /** Version goes up only when what contracts are built from changed. */
  async update(id: string, dto: UpdateContractTemplateDto) {
    const before = await this.detail(id);
    const { errors, fields } = validateFields(dto.fields);
    if (errors.length > 0) throw validationFailed({ fields: errors });

    const title = { ar: dto.title.ar, en: dto.title.en };
    const content = (c: string, t: unknown, f: unknown) =>
      JSON.stringify([c, t, f]);
    const changed =
      content(before.category, before.title, before.fields) !==
      content(dto.category, title, fields);

    const after = await this.prisma.contractTemplate.update({
      where: { id },
      data: {
        category: dto.category,
        title: toJson(title),
        fields: toJson(fields),
        ...(dto.isActive !== undefined && { isActive: dto.isActive }),
        ...(changed && { version: { increment: 1 } }),
      },
    });
    return { before, after };
  }
}

/** The contract templates the app offers, managed by staff. */
@AdminController('contract-templates', 'contractTemplates')
export class AdminContractTemplatesController {
  constructor(private readonly templates: AdminContractTemplatesService) {}

  @Get()
  @ApiOperation({ summary: 'All templates, with how many contracts use each' })
  async list() {
    return { data: await this.templates.list() };
  }

  @Get(':id')
  @ApiOperation({ summary: 'One template with its fields' })
  async detail(@Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.templates.detail(id) };
  }

  @Post()
  @AuditAction('contractTemplate.create')
  @ApiConflictResponse({ type: ApiErrorResponseDto })
  @ApiOperation({ summary: 'Add a template; it appears in the app at once' })
  async create(
    @Body() dto: CreateContractTemplateDto,
    @AuditNoter() note: AuditNoteFn,
  ) {
    const created = await this.templates.create(dto);
    note({ entityType: 'contractTemplate', entityId: created.id, after: created });
    return { data: created };
  }

  @Post(':id/pdf')
  @HttpCode(HttpStatus.OK)
  @AuditAction('contractTemplate.uploadPdf')
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
    const result = await this.templates.setPdf(id, file);
    note({ entityType: 'contractTemplate', entityId: id, meta: result });
    return { data: result };
  }

  @Delete(':id/pdf')
  @HttpCode(HttpStatus.NO_CONTENT)
  @AuditAction('contractTemplate.removePdf')
  @ApiOperation({ summary: 'Remove the official PDF' })
  async removePdf(
    @Param('id', ParseUUIDPipe) id: string,
    @AuditNoter() note: AuditNoteFn,
  ): Promise<void> {
    const result = await this.templates.clearPdf(id);
    note({ entityType: 'contractTemplate', entityId: id, meta: result });
  }

  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @AuditAction('contractTemplate.update')
  @ApiOperation({ summary: 'Change a template, or switch it on or off' })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateContractTemplateDto,
    @AuditNoter() note: AuditNoteFn,
  ) {
    const { before, after } = await this.templates.update(id, dto);
    note({ entityType: 'contractTemplate', entityId: id, before, after });
    return { data: after };
  }
}
