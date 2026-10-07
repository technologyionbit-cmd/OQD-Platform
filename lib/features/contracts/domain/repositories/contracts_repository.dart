import 'dart:ui' show Locale;

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_template.dart';

/// The implementation (`ContractsRepositoryImpl`) is backed by a mock data
/// source until the real Aqd backend contract is available — nothing above
/// this interface knows or cares which. [Locale] (from `dart:ui`, not a
/// widget import) is here because template content is meant to come back
/// already localized per request — see [ContractTemplate].
abstract interface class ContractsRepository {
  Future<Result<List<ContractTemplate>>> getTemplates({required Locale locale});

  Future<Result<List<Contract>>> getContracts();

  Future<Result<Contract>> getContractById(String id);

  /// Creates a new draft, or updates [contractId] if it's an edit of an
  /// existing one — same operation either way, just whether an id is
  /// already assigned.
  Future<Result<Contract>> saveDraft({
    required ContractTemplate template,
    required Map<String, String> fieldValues,
    required Locale locale,
    String? contractId,
  });

  /// Finalizes the contract from a template + filled values into its
  /// generated form (status moves to pending-signature). Mirrors
  /// [saveDraft]'s create-or-update shape.
  Future<Result<Contract>> generateContract({
    required ContractTemplate template,
    required Map<String, String> fieldValues,
    required Locale locale,
    String? contractId,
  });

  /// Moves a pending-signature contract to signed — mock e-signature only.
  Future<Result<Contract>> signContract(String id);

  Future<Result<void>> deleteContract(String id);
}
