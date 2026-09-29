import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiConflictResponse,
  ApiForbiddenResponse,
  ApiNotFoundResponse,
  ApiOperation,
  ApiTags,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
import type { AuthenticatedUser, RequestContext } from '../auth/auth.types';
import { ClientContext } from '../auth/decorators/client-context.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { RequireVerifiedEmail } from '../auth/guards/email-verified.guard';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiErrorResponseDto } from '../common/openapi/api-error.dto';
import { BEARER_AUTH } from '../common/openapi/setup-openapi';
import { ContractsService } from './contracts.service';
import {
  CreateContractDto,
  GenerateContractDto,
  ListContractsQueryDto,
  LocaleQueryDto,
  UpdateContractDto,
} from './dto/contract.dto';

@ApiTags('contracts')
@ApiBearerAuth(BEARER_AUTH)
@Controller('contract-templates')
@UseGuards(JwtAuthGuard)
export class ContractTemplatesController {
  constructor(private readonly contracts: ContractsService) {}

  @Get()
  @ApiOperation({
    summary: 'Contract templates',
    description:
      'The template catalog with titles, field labels and dropdown option ' +
      'labels in `locale` (ar or en). Dropdown values are stable across ' +
      'languages; contracts store the value.',
  })
  list(@Query() query: LocaleQueryDto) {
    return { data: this.contracts.templates(query.locale ?? 'ar') };
  }
}

@ApiTags('contracts')
@ApiBearerAuth(BEARER_AUTH)
@ApiNotFoundResponse({
  type: ApiErrorResponseDto,
  description: 'No such contract, or it belongs to someone else.',
})
@ApiForbiddenResponse({
  type: ApiErrorResponseDto,
  description: 'Writes by a lawyer account (FORBIDDEN).',
})
@ApiConflictResponse({
  type: ApiErrorResponseDto,
  description: "CONTRACT_STATUS_CONFLICT: the contract's status forbids it.",
})
@Controller('contracts')
@UseGuards(JwtAuthGuard)
export class ContractsController {
  constructor(private readonly contracts: ContractsService) {}

  @Get()
  @ApiOperation({ summary: "The caller's contracts, newest change first" })
  list(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: ListContractsQueryDto,
  ) {
    return this.contracts.list(user, query);
  }

  @Get(':id')
  async getById(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return { data: await this.contracts.getById(user, id) };
  }

  @Post()
  @ApiOperation({
    summary: 'Save a new draft',
    description: 'Fields may be incomplete; filled ones must be valid.',
  })
  @ApiUnprocessableEntityResponse({
    type: ApiErrorResponseDto,
    description: 'VALIDATION_ERROR with errors per field id.',
  })
  async create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateContractDto,
  ) {
    return { data: await this.contracts.create(user, dto) };
  }

  @Patch(':id')
  @ApiOperation({ summary: "Replace a draft's field values" })
  @ApiUnprocessableEntityResponse({ type: ApiErrorResponseDto })
  async update(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateContractDto,
  ) {
    return { data: await this.contracts.update(user, id, dto) };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a draft' })
  async remove(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<void> {
    await this.contracts.remove(user, id);
  }

  @Post(':id/generate')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Generate the contract text',
    description:
      'Every required field must be filled. Moves the draft to ' +
      'pendingSignature with text built on the server.',
  })
  @ApiUnprocessableEntityResponse({
    type: ApiErrorResponseDto,
    description: 'VALIDATION_ERROR with errors per field id.',
  })
  async generate(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: GenerateContractDto,
  ) {
    return { data: await this.contracts.generate(user, id, dto.locale) };
  }

  @Post(':id/sign')
  @HttpCode(HttpStatus.OK)
  @RequireVerifiedEmail()
  @ApiOperation({
    summary: 'Sign a generated contract',
    description:
      'Records who signed, when, and from which IP and client. Needs a ' +
      'verified email (403 EMAIL_NOT_VERIFIED).',
  })
  async sign(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientContext() ctx: RequestContext,
  ) {
    return { data: await this.contracts.sign(user, id, ctx) };
  }
}
