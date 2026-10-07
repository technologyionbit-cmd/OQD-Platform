import 'dart:ui' show Locale;

import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_template.dart';

/// Wire-level contract for the contracts feature. Mirrors what a real REST
/// API would look like so swapping [ContractsMockDataSource] for a
/// Dio-backed implementation later is a same-signature, same-callers
/// change. Throws a [Failure] on any failure path — never a raw exception.
abstract interface class ContractsRemoteDataSource {
  Future<List<ContractTemplate>> getTemplates(Locale locale);

  Future<List<Contract>> getContracts();

  Future<Contract> getContractById(String id);

  Future<Contract> saveDraft({required ContractTemplate template, required Map<String, String> fieldValues, required Locale locale, String? contractId});

  Future<Contract> generateContract({required ContractTemplate template, required Map<String, String> fieldValues, required Locale locale, String? contractId});

  /// Moves a pending-signature contract to signed — mock e-signature only,
  /// no real cryptographic signing.
  Future<Contract> signContract(String id);

  Future<void> deleteContract(String id);
}
