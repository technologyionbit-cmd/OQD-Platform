import { IsBoolean, IsOptional, IsUUID } from 'class-validator';

/**
 * Both fields optional and independent: a single call may just toggle a
 * document, just mark the procedure started, or both at once. Mirrors
 * `GovProceduresProgressController.toggleDocument`/`.start` on the
 * frontend (lib/features/gov_documents/presentation/providers/gov_procedures_provider.dart).
 */
export class UpdateGovProcedureProgressDto {
  @IsOptional()
  @IsUUID()
  toggleDocumentId?: string;

  @IsOptional()
  @IsBoolean()
  start?: boolean;
}
