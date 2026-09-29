import 'dart:ui' show Locale;

import 'package:dio/dio.dart';

import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/contracts/data/datasources/contracts_remote_data_source.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_category.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field_option.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field_type.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_status.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_template.dart';

/// Dio-backed implementation talking to `<apiBaseUrl>/contract-templates`
/// and `<apiBaseUrl>/contracts` (docs/plans/individual-user-rollout.md
/// part 6). The server builds the contract text from the template, so
/// this layer only ever sends the template id and the field values.
class ContractsRemoteDataSourceImpl implements ContractsRemoteDataSource {
  ContractsRemoteDataSourceImpl(this._dio, {ApiErrorMapper errorMapper = const ApiErrorMapper()}) : _errorMapper = errorMapper;

  final Dio _dio;
  final ApiErrorMapper _errorMapper;

  @override
  Future<List<ContractTemplate>> getTemplates(Locale locale) {
    return _call(() async {
      final res = await _dio.get<Map<String, dynamic>>('/contract-templates', queryParameters: {'locale': _languageOf(locale)});
      return _rows(res.data).map(_parseTemplate).toList(growable: false);
    });
  }

  @override
  Future<List<Contract>> getContracts() {
    return _call(() async {
      final res = await _dio.get<Map<String, dynamic>>('/contracts');
      return _rows(res.data).map(_parseContract).toList(growable: false);
    });
  }

  @override
  Future<Contract> getContractById(String id) {
    return _call(() async {
      final res = await _dio.get<Map<String, dynamic>>('/contracts/$id');
      return _parseContract(_data(res.data));
    });
  }

  @override
  Future<Contract> saveDraft({
    required ContractTemplate template,
    required Map<String, String> fieldValues,
    required Locale locale,
    String? contractId,
  }) {
    return _call(() => _saveDraft(template: template, fieldValues: fieldValues, locale: locale, contractId: contractId));
  }

  /// Saves the latest values first, so the text is built from exactly
  /// what the user sees, then asks the server to generate it.
  @override
  Future<Contract> generateContract({
    required ContractTemplate template,
    required Map<String, String> fieldValues,
    required Locale locale,
    String? contractId,
  }) {
    return _call(() async {
      final draft = await _saveDraft(template: template, fieldValues: fieldValues, locale: locale, contractId: contractId);
      final res = await _dio.post<Map<String, dynamic>>('/contracts/${draft.id}/generate', data: {'locale': _languageOf(locale)});
      return _parseContract(_data(res.data));
    });
  }

  @override
  Future<Contract> signContract(String id) {
    return _call(() async {
      final res = await _dio.post<Map<String, dynamic>>('/contracts/$id/sign');
      return _parseContract(_data(res.data));
    });
  }

  @override
  Future<void> deleteContract(String id) {
    return _call(() => _dio.delete<void>('/contracts/$id'));
  }

  Future<Contract> _saveDraft({
    required ContractTemplate template,
    required Map<String, String> fieldValues,
    required Locale locale,
    String? contractId,
  }) async {
    final body = {'fieldValues': fieldValues, 'locale': _languageOf(locale)};
    final res = contractId == null
        ? await _dio.post<Map<String, dynamic>>('/contracts', data: {'templateId': template.id, ...body})
        : await _dio.patch<Map<String, dynamic>>('/contracts/$contractId', data: body);
    return _parseContract(_data(res.data));
  }

  /// The server writes contracts in Arabic or English only.
  static String _languageOf(Locale locale) => locale.languageCode == 'en' ? 'en' : 'ar';

  static Map<String, dynamic> _data(Map<String, dynamic>? body) => body!['data'] as Map<String, dynamic>;

  static List<Map<String, dynamic>> _rows(Map<String, dynamic>? body) => (body!['data'] as List).cast<Map<String, dynamic>>();

  static ContractTemplate _parseTemplate(Map<String, dynamic> json) {
    return ContractTemplate(
      id: json['id'] as String,
      category: ContractCategory.values.byName(json['category'] as String),
      title: json['title'] as String,
      fields: (json['fields'] as List).cast<Map<String, dynamic>>().map(_parseField).toList(growable: false),
    );
  }

  static ContractField _parseField(Map<String, dynamic> json) {
    return ContractField(
      id: json['id'] as String,
      label: json['label'] as String,
      type: ContractFieldType.values.byName(json['type'] as String),
      isRequired: json['isRequired'] as bool,
      options: [
        for (final option in (json['options'] as List? ?? const []).cast<Map<String, dynamic>>())
          ContractFieldOption(value: option['value'] as String, label: option['label'] as String),
      ],
    );
  }

  static Contract _parseContract(Map<String, dynamic> json) {
    return Contract(
      id: json['id'] as String,
      title: json['title'] as String,
      category: ContractCategory.values.byName(json['category'] as String),
      status: ContractStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      parties: (json['parties'] as List).cast<String>(),
      fieldValues: (json['fieldValues'] as Map).cast<String, String>(),
      templateId: json['templateId'] as String,
      generatedContent: json['generatedContent'] as String? ?? '',
    );
  }

  /// Runs [action], translating any [DioException] (or unexpected error)
  /// into a typed `Failure` before it escapes this layer.
  Future<T> _call<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      throw _errorMapper.map(error);
    }
  }
}
