import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/features/contracts/data/repositories/contracts_repository_impl.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field_type.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_template.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_draft_state.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contracts_controller.dart';
import 'package:aqd_ionbit/features/documents/presentation/providers/documents_controller.dart';

/// Drives the type-selection → form → preview flow. One provider instead
/// of per-screen state because the selected template and filled values
/// must survive navigating between those three screens.
class ContractDraftController extends Notifier<ContractDraftState> {
  @override
  ContractDraftState build() => const ContractDraftState();

  void selectTemplate(ContractTemplate template) {
    state = ContractDraftState(template: template);
  }

  /// Loads an existing draft back into the flow for the "Edit draft"
  /// action on the details screen — same template, its saved values.
  void startEditing({required Contract contract, required ContractTemplate template}) {
    state = ContractDraftState(template: template, fieldValues: Map.of(contract.fieldValues), editingContractId: contract.id);
  }

  void setFieldValue(String fieldId, String value) {
    final fieldValues = Map<String, String>.of(state.fieldValues)..[fieldId] = value;
    final errors = Map<String, String>.of(state.errors)..remove(fieldId);
    state = state.copyWith(fieldValues: fieldValues, errors: errors);
  }

  /// Required-ness plus a type-appropriate format check per field — kept
  /// here once instead of scattered across the form/preview screens.
  bool validate(AppLocalizations l10n) {
    final template = state.template;
    if (template == null) return false;

    final errors = <String, String>{};
    for (final field in template.fields) {
      final value = state.fieldValues[field.id]?.trim();
      if (field.isRequired && (value == null || value.isEmpty)) {
        errors[field.id] = l10n.validationRequired;
        continue;
      }
      if (value == null || value.isEmpty) continue;

      switch (field.type) {
        case ContractFieldType.email:
          if (!Validators.isValidEmail(value)) errors[field.id] = l10n.validationInvalidEmail;
        case ContractFieldType.phone:
          if (!Validators.isValidPhone(value)) errors[field.id] = l10n.validationInvalidPhone;
        case ContractFieldType.number:
        case ContractFieldType.currency:
          if (num.tryParse(value) == null) errors[field.id] = l10n.validationInvalidNumber;
        case ContractFieldType.date:
          if (DateTime.tryParse(value) == null) errors[field.id] = l10n.validationInvalidDate;
        case ContractFieldType.text:
        case ContractFieldType.multiline:
        case ContractFieldType.dropdown:
          break;
      }
    }

    state = state.copyWith(errors: errors);
    return errors.isEmpty;
  }

  Future<Result<Contract>> saveDraft() => _persist(generate: false);

  Future<Result<Contract>> generate() => _persist(generate: true);

  Future<Result<Contract>> _persist({required bool generate}) async {
    final template = state.template;
    if (template == null) {
      throw StateError('ContractDraftController._persist called with no template selected');
    }

    final repository = ref.read(contractsRepositoryProvider);
    final result = generate
        ? await repository.generateContract(template: template, fieldValues: state.fieldValues, contractId: state.editingContractId)
        : await repository.saveDraft(template: template, fieldValues: state.fieldValues, contractId: state.editingContractId);

    if (result.isSuccess) {
      await ref.read(contractsControllerProvider.notifier).refresh();
      // Generating (not just drafting) a contract is the one point where
      // it becomes a real document — see DocumentsController's doc comment.
      if (generate) {
        final contract = result.valueOrNull!;
        await ref
            .read(documentsControllerProvider.notifier)
            .addFromGeneratedContract(contractId: contract.id, title: contract.title);
      }
      state = const ContractDraftState();
    }
    return result;
  }

  void reset() => state = const ContractDraftState();
}

final contractDraftControllerProvider = NotifierProvider<ContractDraftController, ContractDraftState>(ContractDraftController.new);
