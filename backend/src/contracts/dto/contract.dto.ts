import { Type } from 'class-transformer';
import { IsIn, IsInt, IsObject, IsOptional, Max, Min } from 'class-validator';
import {
  CONTRACT_LOCALES,
  CONTRACT_TEMPLATE_KEYS,
  type ContractLocale,
} from '../contract-templates';

/** Language of template text and of a contract's generated content. */
export class LocaleQueryDto {
  @IsOptional()
  @IsIn(CONTRACT_LOCALES)
  locale?: ContractLocale = 'ar';
}

export class ListContractsQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 50;
}

/** Field values are checked against the template in the service. */
export class CreateContractDto {
  @IsIn(CONTRACT_TEMPLATE_KEYS)
  templateId!: string;

  @IsObject()
  fieldValues!: Record<string, unknown>;

  @IsOptional()
  @IsIn(CONTRACT_LOCALES)
  locale?: ContractLocale = 'ar';
}

export class UpdateContractDto {
  @IsObject()
  fieldValues!: Record<string, unknown>;

  @IsOptional()
  @IsIn(CONTRACT_LOCALES)
  locale?: ContractLocale;
}

export class GenerateContractDto {
  @IsOptional()
  @IsIn(CONTRACT_LOCALES)
  locale?: ContractLocale;
}
