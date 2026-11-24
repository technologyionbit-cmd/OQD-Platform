import {
  Body,
  Get,
  HttpCode,
  HttpStatus,
  Injectable,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import { ApiConflictResponse, ApiOperation } from '@nestjs/swagger';
import { ContractCategory, ContractStatus } from '@prisma/client';
import type { Prisma } from '@prisma/client';
import { IsEnum, IsOptional } from 'class-validator';
import {
  PageQueryDto,
  pageArgs,
  paginated,
  pickSort,
} from '../../common/pagination/page-query.dto';
import { conflict, notFound } from '../../common/errors/api-exceptions';
import { ApiErrorResponseDto } from '../../common/openapi/api-error.dto';
import { PrismaService } from '../../prisma/prisma.service';
import { AuditAction, AuditNoter } from '../audit/audit.decorators';
import type { AuditNoteFn } from '../audit/audit.types';
import { ReasonDto } from '../users/dto/users.dto';
import { AdminController } from '../common/admin-controller.decorator';

const CANCELLABLE: ContractStatus[] = ['draft', 'pendingSignature'];
const SORT_FIELDS = ['updatedAt', 'createdAt', 'title'] as const;

export class QueryAdminContractsDto extends PageQueryDto {
  @IsOptional()
  @IsEnum(ContractStatus)
  status?: ContractStatus;

  @IsOptional()
  @IsEnum(ContractCategory)
  category?: ContractCategory;
}

@Injectable()
export class AdminContractsService {
  constructor(private readonly prisma: PrismaService) {}

  async list(query: QueryAdminContractsDto) {
    const where = this.where(query);
    const field = pickSort(query.sort, SORT_FIELDS, 'updatedAt');
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.contract.findMany({
        where,
        orderBy: [{ [field]: query.order }, { id: 'asc' }],
        ...pageArgs(query),
        // The generated text and field values are private to the owner;
        // the admin list shows metadata only.
        select: {
          id: true,
          title: true,
          category: true,
          status: true,
          locale: true,
          parties: true,
          signedAt: true,
          createdAt: true,
          updatedAt: true,
          owner: { select: { id: true, fullName: true, email: true } },
          _count: { select: { signatures: true } },
        },
      }),
      this.prisma.contract.count({ where }),
    ]);
    return paginated(
      rows.map(({ _count, ...r }) => ({ ...r, signaturesCount: _count.signatures })),
      total,
      query,
    );
  }

  /** Metadata and who signed; never the field values or generated text. */
  async detail(id: string) {
    const row = await this.prisma.contract.findUnique({
      where: { id },
      select: {
        id: true,
        title: true,
        category: true,
        status: true,
        locale: true,
        templateKey: true,
        templateVersion: true,
        parties: true,
        generatedAt: true,
        signedAt: true,
        createdAt: true,
        updatedAt: true,
        owner: { select: { id: true, fullName: true, email: true } },
        signatures: {
          orderBy: { signedAt: 'asc' },
          select: {
            signedAt: true,
            ipAddress: true,
            user: { select: { id: true, fullName: true, email: true } },
          },
        },
      },
    });
    if (!row) throw notFound('Contract not found.');
    return { ...row, canCancel: CANCELLABLE.includes(row.status) };
  }

  /** Cancels an unsigned contract. A signed one is evidence and stays. */
  async cancel(id: string) {
    const current = await this.prisma.contract.findUnique({
      where: { id },
      select: { status: true },
    });
    if (!current) throw notFound('Contract not found.');
    if (!CANCELLABLE.includes(current.status)) {
      throw conflict(`A ${current.status} contract cannot be cancelled.`);
    }
    const moved = await this.prisma.contract.updateMany({
      where: { id, status: current.status },
      data: { status: 'cancelled' },
    });
    if (moved.count === 0) throw conflict('This contract was just changed.');
    return {
      before: { status: current.status },
      after: { status: 'cancelled' },
    };
  }

  private where(q: QueryAdminContractsDto): Prisma.ContractWhereInput {
    const search = q.q?.trim();
    return {
      ...(q.status && { status: q.status }),
      ...(q.category && { category: q.category }),
      ...(search && {
        OR: [
          { title: { contains: search, mode: 'insensitive' } },
          { owner: { fullName: { contains: search, mode: 'insensitive' } } },
          { owner: { email: { contains: search, mode: 'insensitive' } } },
        ],
      }),
    };
  }
}

/** Metadata of every contract, never its content; unsigned ones can be cancelled. */
@AdminController('contracts', 'contracts')
export class AdminContractsController {
  constructor(private readonly contracts: AdminContractsService) {}

  @Get()
  @ApiOperation({ summary: 'Search contracts: status, category, title, owner' })
  list(@Query() query: QueryAdminContractsDto) {
    return this.contracts.list(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'One contract: metadata and signatures, no content' })
  async detail(@Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.contracts.detail(id) };
  }

  @Post(':id/cancel')
  @HttpCode(HttpStatus.NO_CONTENT)
  @AuditAction('contract.cancel')
  @ApiConflictResponse({ type: ApiErrorResponseDto })
  @ApiOperation({ summary: 'Cancel an unsigned contract; the reason is audited' })
  async cancel(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReasonDto,
    @AuditNoter() note: AuditNoteFn,
  ): Promise<void> {
    const { before, after } = await this.contracts.cancel(id);
    note({
      entityType: 'contract',
      entityId: id,
      before,
      after,
      meta: { reason: dto.reason },
    });
  }
}
