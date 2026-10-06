import { Injectable } from '@nestjs/common';
import { badRequest, notFound } from '../common/errors/api-exceptions';
import { PrismaService } from '../prisma/prisma.service';
import type { UpdateGovProcedureProgressDto } from './dto/update-progress.dto';

/** Sort order shared by requiredDocuments/steps includes across every query. */
const CHILD_ORDER = { sortOrder: 'asc' as const };

@Injectable()
export class GovProceduresService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.govProcedure.findMany({
      include: {
        requiredDocuments: { orderBy: CHILD_ORDER },
        steps: { orderBy: CHILD_ORDER },
      },
      orderBy: { type: 'asc' },
    });
  }

  async findById(id: string) {
    const procedure = await this.prisma.govProcedure.findUnique({
      where: { id },
      include: {
        requiredDocuments: { orderBy: CHILD_ORDER },
        steps: { orderBy: CHILD_ORDER },
      },
    });
    if (!procedure) {
      throw notFound('Government procedure not found.');
    }
    return procedure;
  }

  async getProgress(userId: string, procedureId: string) {
    await this.assertProcedureExists(procedureId);
    const progress = await this.prisma.userGovProcedureProgress.findUnique({
      where: { userId_procedureId: { userId, procedureId } },
    });
    return (
      progress ?? {
        userId,
        procedureId,
        startedAt: null,
        checkedDocumentIds: [] as string[],
      }
    );
  }

  async updateProgress(
    userId: string,
    procedureId: string,
    dto: UpdateGovProcedureProgressDto,
  ) {
    const requiredDocumentIds = await this.requiredDocumentIds(procedureId);

    const existing = await this.prisma.userGovProcedureProgress.findUnique({
      where: { userId_procedureId: { userId, procedureId } },
    });
    const checked = new Set(existing?.checkedDocumentIds ?? []);

    if (dto.toggleDocumentId) {
      if (!requiredDocumentIds.has(dto.toggleDocumentId)) {
        throw badRequest('Document does not belong to this procedure.');
      }
      if (!checked.delete(dto.toggleDocumentId)) {
        checked.add(dto.toggleDocumentId);
      }
    }

    return this.prisma.userGovProcedureProgress.upsert({
      where: { userId_procedureId: { userId, procedureId } },
      create: {
        userId,
        procedureId,
        checkedDocumentIds: [...checked],
        startedAt: dto.start ? new Date() : null,
      },
      update: {
        checkedDocumentIds: [...checked],
        // Never un-set a start once recorded; `start` is a one-way flag.
        ...(dto.start ? { startedAt: existing?.startedAt ?? new Date() } : {}),
      },
    });
  }

  private async assertProcedureExists(id: string): Promise<void> {
    const exists = await this.prisma.govProcedure.findUnique({
      where: { id },
      select: { id: true },
    });
    if (!exists) {
      throw notFound('Government procedure not found.');
    }
  }

  private async requiredDocumentIds(procedureId: string): Promise<Set<string>> {
    const procedure = await this.prisma.govProcedure.findUnique({
      where: { id: procedureId },
      include: { requiredDocuments: { select: { id: true } } },
    });
    if (!procedure) {
      throw notFound('Government procedure not found.');
    }
    return new Set(procedure.requiredDocuments.map((doc) => doc.id));
  }
}
