import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import type { Contract, ContractStatus, Prisma } from '@prisma/client';
import { ApiErrorCode } from '../common/errors/api-error-codes';
import { PrismaService } from '../prisma/prisma.service';
import type { AuthenticatedUser, RequestContext } from '../auth/auth.types';
import {
  buildContractContent,
  checkFieldValues,
  partiesOf,
  type FieldValues,
} from './contract-fields';
import {
  CONTRACT_TEMPLATES,
  findTemplate,
  type ContractLocale,
  type ContractTemplateDefinition,
} from './contract-templates';
import type {
  CreateContractDto,
  ListContractsQueryDto,
  UpdateContractDto,
} from './dto/contract.dto';

/** What the API returns for a contract. */
export interface ContractView {
  id: string;
  templateId: string;
  templateVersion: number;
  title: string;
  category: Contract['category'];
  status: ContractStatus;
  locale: string;
  fieldValues: FieldValues;
  parties: string[];
  generatedContent: string;
  createdAt: Date;
  updatedAt: Date;
  generatedAt: Date | null;
  signedAt: Date | null;
}

/**
 * Contracts belong to the account that created them; every read and write
 * is scoped to the owner, and anyone else gets the same 404 as for a
 * contract that does not exist. Lawyers only ever read: every write
 * answers 403, whatever the app shows (docs/plans/individual-user-rollout
 * part 6).
 */
@Injectable()
export class ContractsService {
  constructor(private readonly prisma: PrismaService) {}

  templates(locale: ContractLocale) {
    return CONTRACT_TEMPLATES.map((template) => ({
      id: template.key,
      version: template.version,
      category: template.category,
      title: template.title[locale],
      fields: template.fields.map((field) => ({
        id: field.id,
        type: field.type,
        label: field.label[locale],
        isRequired: field.isRequired,
        options: (field.options ?? []).map((option) => ({
          value: option.value,
          label: option.label[locale],
        })),
      })),
    }));
  }

  async list(user: AuthenticatedUser, query: ListContractsQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 50;
    const where = { ownerUserId: user.id };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.contract.findMany({
        where,
        orderBy: { updatedAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.contract.count({ where }),
    ]);
    return { data: rows.map(toView), meta: { page, limit, total } };
  }

  async getById(user: AuthenticatedUser, id: string): Promise<ContractView> {
    return toView(await this.owned(user, id));
  }

  async create(
    user: AuthenticatedUser,
    dto: CreateContractDto,
  ): Promise<ContractView> {
    this.assertMayWrite(user);
    const template = findTemplate(dto.templateId)!;
    const locale = dto.locale ?? 'ar';
    const values = this.checked(template, dto.fieldValues, false);

    const created = await this.prisma.contract.create({
      data: {
        ownerUserId: user.id,
        templateKey: template.key,
        templateVersion: template.version,
        category: template.category,
        locale,
        title: template.title[locale],
        fieldValues: values,
        parties: partiesOf(values),
      },
    });
    return toView(created);
  }

  /** Replaces a draft's field values. */
  async update(
    user: AuthenticatedUser,
    id: string,
    dto: UpdateContractDto,
  ): Promise<ContractView> {
    this.assertMayWrite(user);
    const contract = await this.owned(user, id);
    const template = this.templateOf(contract);
    const values = this.checked(template, dto.fieldValues, false);
    const locale = dto.locale ?? (contract.locale as ContractLocale);

    return toView(
      await this.transition(contract, 'draft', {
        locale,
        title: template.title[locale],
        fieldValues: values,
        parties: partiesOf(values),
      }),
    );
  }

  async remove(user: AuthenticatedUser, id: string): Promise<void> {
    this.assertMayWrite(user);
    const contract = await this.owned(user, id);
    const deleted = await this.prisma.contract.deleteMany({
      where: { id: contract.id, status: 'draft' },
    });
    if (deleted.count === 0) throw statusConflict();
  }

  /**
   * Turns a complete draft into the contract text, ready to sign. The
   * text is built here from the template, in [locale].
   */
  async generate(
    user: AuthenticatedUser,
    id: string,
    requestedLocale?: ContractLocale,
  ): Promise<ContractView> {
    this.assertMayWrite(user);
    const contract = await this.owned(user, id);
    const template = this.templateOf(contract);
    const locale = requestedLocale ?? (contract.locale as ContractLocale);
    const values = this.checked(
      template,
      contract.fieldValues as Record<string, unknown>,
      true,
    );

    return toView(
      await this.transition(contract, 'draft', {
        status: 'pendingSignature',
        locale,
        title: template.title[locale],
        generatedContent: buildContractContent(template, values, locale),
        generatedAt: new Date(),
      }),
    );
  }

  /** The owner signs; the signature row keeps when and from where. */
  async sign(
    user: AuthenticatedUser,
    id: string,
    ctx: RequestContext,
  ): Promise<ContractView> {
    this.assertMayWrite(user);
    const contract = await this.owned(user, id);
    const signedAt = new Date();

    const signed = await this.prisma.$transaction(async (tx) => {
      const moved = await tx.contract.updateMany({
        where: { id: contract.id, status: 'pendingSignature' },
        data: { status: 'signed', signedAt },
      });
      if (moved.count === 0) throw statusConflict();
      await tx.contractSignature.create({
        data: {
          contractId: contract.id,
          userId: user.id,
          ipAddress: ctx.ipAddress,
          userAgent: ctx.deviceLabel,
          signedAt,
        },
      });
      return tx.contract.findUniqueOrThrow({ where: { id: contract.id } });
    });
    return toView(signed);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  private assertMayWrite(user: AuthenticatedUser): void {
    if (user.role === 'lawyer') {
      throw new ForbiddenException({
        message: 'Lawyers cannot create or change contracts.',
        code: ApiErrorCode.FORBIDDEN,
      });
    }
  }

  /** The caller's contract, or 404 — also for someone else's. */
  private async owned(user: AuthenticatedUser, id: string): Promise<Contract> {
    const contract = await this.prisma.contract.findFirst({
      where: { id, ownerUserId: user.id },
    });
    if (!contract) {
      throw new NotFoundException({
        message: 'Contract not found.',
        code: ApiErrorCode.NOT_FOUND,
      });
    }
    return contract;
  }

  private templateOf(contract: Contract): ContractTemplateDefinition {
    // Keys are never removed from the catalog while contracts use them.
    return findTemplate(contract.templateKey)!;
  }

  private checked(
    template: ContractTemplateDefinition,
    submitted: Record<string, unknown>,
    requireAll: boolean,
  ): FieldValues {
    const { values, errors } = checkFieldValues(template, submitted, {
      requireAll,
    });
    if (Object.keys(errors).length > 0) {
      throw new UnprocessableEntityException({
        message: 'Some contract fields are missing or invalid.',
        code: ApiErrorCode.VALIDATION_ERROR,
        errors,
      });
    }
    return values;
  }

  /** Updates [contract] only while it still has status [from], so two
   *  racing requests cannot both act on the same state. */
  private async transition(
    contract: Contract,
    from: ContractStatus,
    data: Prisma.ContractUpdateManyMutationInput,
  ): Promise<Contract> {
    const moved = await this.prisma.contract.updateMany({
      where: { id: contract.id, status: from },
      data,
    });
    if (moved.count === 0) throw statusConflict();
    return this.prisma.contract.findUniqueOrThrow({
      where: { id: contract.id },
    });
  }
}

function statusConflict(): ConflictException {
  return new ConflictException({
    message: 'The contract is not in a state that allows this.',
    code: ApiErrorCode.CONTRACT_STATUS_CONFLICT,
  });
}

function toView(contract: Contract): ContractView {
  return {
    id: contract.id,
    templateId: contract.templateKey,
    templateVersion: contract.templateVersion,
    title: contract.title,
    category: contract.category,
    status: contract.status,
    locale: contract.locale,
    fieldValues: contract.fieldValues as FieldValues,
    parties: contract.parties,
    generatedContent: contract.generatedContent ?? '',
    createdAt: contract.createdAt,
    updatedAt: contract.updatedAt,
    generatedAt: contract.generatedAt,
    signedAt: contract.signedAt,
  };
}
