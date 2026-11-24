import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import type { ContractTemplate, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import {
  CONTRACT_TEMPLATES,
  findTemplate,
  type ContractTemplateDefinition,
} from './contract-templates';

/** A stored template as the rest of the code uses it. */
export function toDefinition(row: ContractTemplate): ContractTemplateDefinition {
  return {
    key: row.key,
    version: row.version,
    category: row.category,
    title: row.title as unknown as ContractTemplateDefinition['title'],
    fields: row.fields as unknown as ContractTemplateDefinition['fields'],
  };
}

/**
 * Where contract templates are read from: the database, which staff edit
 * from the admin app. The built-in catalog only seeds it: on start, any
 * built-in template that has no row yet is inserted. A template staff
 * changed or switched off is never put back.
 */
@Injectable()
export class ContractTemplateStore implements OnModuleInit {
  private readonly logger = new Logger(ContractTemplateStore.name);

  constructor(private readonly prisma: PrismaService) {}

  async onModuleInit(): Promise<void> {
    try {
      const { count } = await this.prisma.contractTemplate.createMany({
        data: CONTRACT_TEMPLATES.map((t) => ({
          key: t.key,
          version: t.version,
          category: t.category,
          title: t.title as unknown as Prisma.InputJsonValue,
          fields: t.fields as unknown as Prisma.InputJsonValue,
        })),
        skipDuplicates: true,
      });
      if (count > 0) this.logger.log(`Seeded ${count} contract templates`);
    } catch (error) {
      // Never block start-up: without the table (migration not applied yet)
      // reads fall back to the built-in catalog.
      this.logger.error(`Could not seed contract templates: ${String(error)}`);
    }
  }

  /** Templates people can start a contract from. */
  async listActive(): Promise<ContractTemplateDefinition[]> {
    try {
      const rows = await this.prisma.contractTemplate.findMany({
        where: { isActive: true },
        orderBy: { createdAt: 'asc' },
      });
      return rows.map(toDefinition);
    } catch {
      return [...CONTRACT_TEMPLATES];
    }
  }

  /** Keys of the templates that have an official PDF. */
  async keysWithPdf(): Promise<Set<string>> {
    try {
      const rows = await this.prisma.contractTemplate.findMany({
        where: { pdfStorageKey: { not: null } },
        select: { key: true },
      });
      return new Set(rows.map((r) => r.key));
    } catch {
      return new Set();
    }
  }

  /** The official PDF of an active template, or null. */
  async pdfOf(
    key: string,
  ): Promise<{ storageKey: string; fileName: string } | null> {
    const row = await this.prisma.contractTemplate.findFirst({
      where: { key, isActive: true, pdfStorageKey: { not: null } },
      select: { pdfStorageKey: true, pdfFileName: true },
    });
    return row?.pdfStorageKey
      ? { storageKey: row.pdfStorageKey, fileName: row.pdfFileName ?? 'contract.pdf' }
      : null;
  }

  /** One template by key, active or not (existing contracts still need it). */
  async find(
    key: string,
    { activeOnly = false }: { activeOnly?: boolean } = {},
  ): Promise<ContractTemplateDefinition | undefined> {
    try {
      const row = await this.prisma.contractTemplate.findUnique({
        where: { key },
      });
      if (!row || (activeOnly && !row.isActive)) return undefined;
      return toDefinition(row);
    } catch {
      return findTemplate(key);
    }
  }
}
