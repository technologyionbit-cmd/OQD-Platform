import 'package:dio/dio.dart';

import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/gov_documents/data/datasources/gov_documents_remote_data_source.dart';
import 'package:aqd_ionbit/features/gov_documents/domain/entities/gov_procedure.dart';

/// Dio-backed implementation talking to `<apiBaseUrl>/gov-procedures/*`
/// (docs/backend/01-domain-model.md §10, docs/plans/individual-user-rollout.md
/// Part 2). Transport errors are mapped to typed `Failure`s via
/// [ApiErrorMapper] so nothing above this layer ever sees a [DioException].
class GovDocumentsRemoteDataSourceImpl implements GovDocumentsRemoteDataSource {
  GovDocumentsRemoteDataSourceImpl(this._dio, {ApiErrorMapper errorMapper = const ApiErrorMapper()}) : _errorMapper = errorMapper;

  final Dio _dio;
  final ApiErrorMapper _errorMapper;

  /// `GovProcedureType` is the stable identity the app routes/keys progress
  /// by; the backend addresses procedures by an opaque uuid. Cached after
  /// the first successful [getGovProcedures] call (or lazily warmed by it)
  /// so progress calls never need the caller to already hold the full list.
  Map<GovProcedureType, String>? _idsByType;

  @override
  Future<List<GovProcedure>> getGovProcedures({required String locale}) {
    return _errorMapper.guard(() async {
      final res = await _dio.get<Map<String, dynamic>>('/gov-procedures');
      final rows = (res.data!['data'] as List).cast<Map<String, dynamic>>();
      _idsByType = {for (final row in rows) _parseType(row['type'] as String): row['id'] as String};
      return rows.map((row) => _parseProcedure(row, locale)).toList(growable: false);
    });
  }

  @override
  Future<GovProcedureProgress> getProgress(GovProcedureType type) {
    return _errorMapper.guard(() async {
      final id = await _resolveId(type);
      final res = await _dio.get<Map<String, dynamic>>('/gov-procedures/$id/progress');
      return _parseProgress(res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<GovProcedureProgress> updateProgress(GovProcedureType type, {String? toggleDocumentId, bool? start}) {
    return _errorMapper.guard(() async {
      final id = await _resolveId(type);
      final res = await _dio.patch<Map<String, dynamic>>(
        '/gov-procedures/$id/progress',
        data: {if (toggleDocumentId != null) 'toggleDocumentId': toggleDocumentId, if (start != null) 'start': start},
      );
      return _parseProgress(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<String> _resolveId(GovProcedureType type) async {
    var id = _idsByType?[type];
    if (id == null) {
      // Cold start (progress screen opened before the catalog list was ever
      // fetched in this session): warm the id cache. The display text this
      // fetch produces is discarded — only `_idsByType` is kept.
      await getGovProcedures(locale: 'ar');
      id = _idsByType?[type];
    }
    if (id == null) {
      throw StateError('Unknown gov procedure type: $type');
    }
    return id;
  }

  GovProcedure _parseProcedure(Map<String, dynamic> row, String locale) {
    final requiredDocuments = (row['requiredDocuments'] as List).cast<Map<String, dynamic>>();
    final steps = (row['steps'] as List).cast<Map<String, dynamic>>();
    return GovProcedure(
      id: row['id'] as String,
      type: _parseType(row['type'] as String),
      durationLabel: _localized(row['durationLabel'], locale),
      accessType: GovProcedureAccessType.values.byName(row['accessType'] as String),
      requiredDocuments: requiredDocuments
          .map((doc) => GovRequiredDocument(id: doc['id'] as String, title: _localized(doc['title'], locale)))
          .toList(growable: false),
      steps: steps
          .map(
            (step) => GovProcedureStep(
              order: (step['sortOrder'] as num).toInt() + 1,
              title: _localized(step['title'], locale),
              description: _localized(step['description'], locale),
            ),
          )
          .toList(growable: false),
    );
  }

  GovProcedureProgress _parseProgress(Map<String, dynamic> row) {
    return GovProcedureProgress(
      checkedDocumentIds: (row['checkedDocumentIds'] as List).cast<String>().toSet(),
      started: row['startedAt'] != null,
    );
  }

  GovProcedureType _parseType(String raw) => GovProcedureType.values.byName(raw);

  String _localized(dynamic jsonValue, String locale) {
    final map = jsonValue as Map<String, dynamic>;
    return (map[locale] ?? map['ar'] ?? map.values.first) as String;
  }
}
