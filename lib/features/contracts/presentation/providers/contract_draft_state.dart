import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/contracts/domain/entities/contract_template.dart';

part 'contract_draft_state.freezed.dart';

/// In-progress "create/edit contract" state — spans the type-selection,
/// form, and preview screens, so it lives in a provider (not any one
/// screen's State) and survives navigating between them.
@freezed
abstract class ContractDraftState with _$ContractDraftState {
  const factory ContractDraftState({
    ContractTemplate? template,
    @Default(<String, String>{}) Map<String, String> fieldValues,
    @Default(<String, String>{}) Map<String, String> errors,
    /// Set only when editing an already-saved draft — `save`/`generate`
    /// then update that contract instead of creating a new one.
    String? editingContractId,
  }) = _ContractDraftState;
}
