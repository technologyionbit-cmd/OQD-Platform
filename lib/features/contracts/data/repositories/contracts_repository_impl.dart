import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/contracts/data/datasources/contracts_data_source_provider.dart';
import 'package:aqd_ionbit/features/contracts/data/datasources/contracts_remote_data_source.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_template.dart';
import 'package:aqd_ionbit/features/contracts/domain/repositories/contracts_repository.dart';

class ContractsRepositoryImpl implements ContractsRepository {
  ContractsRepositoryImpl({required ContractsRemoteDataSource remoteDataSource, ApiErrorMapper errorMapper = const ApiErrorMapper()})
    : _remote = remoteDataSource,
      _errorMapper = errorMapper;

  final ContractsRemoteDataSource _remote;
  final ApiErrorMapper _errorMapper;

  @override
  Future<Result<List<ContractTemplate>>> getTemplates({required Locale locale}) {
    return _guard(() => _remote.getTemplates(locale));
  }

  @override
  Future<Result<List<Contract>>> getContracts() => _guard(_remote.getContracts);

  @override
  Future<Result<Contract>> getContractById(String id) => _guard(() => _remote.getContractById(id));

  @override
  Future<Result<Contract>> saveDraft({required ContractTemplate template, required Map<String, String> fieldValues, String? contractId}) {
    return _guard(() => _remote.saveDraft(template: template, fieldValues: fieldValues, contractId: contractId));
  }

  @override
  Future<Result<Contract>> generateContract({
    required ContractTemplate template,
    required Map<String, String> fieldValues,
    String? contractId,
  }) {
    return _guard(() => _remote.generateContract(template: template, fieldValues: fieldValues, contractId: contractId));
  }

  @override
  Future<Result<Contract>> signContract(String id) => _guard(() => _remote.signContract(id));

  @override
  Future<Result<void>> deleteContract(String id) => _guard(() => _remote.deleteContract(id));

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } catch (e) {
      return Result.failure(_errorMapper.map(e));
    }
  }
}

final contractsRepositoryProvider = Provider<ContractsRepository>((ref) {
  return ContractsRepositoryImpl(remoteDataSource: ref.watch(contractsRemoteDataSourceProvider));
});
