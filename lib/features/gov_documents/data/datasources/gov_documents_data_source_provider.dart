import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/features/gov_documents/data/datasources/gov_documents_remote_data_source.dart';
import 'package:aqd_ionbit/features/gov_documents/data/datasources/gov_documents_remote_data_source_impl.dart';

/// The ONE place that decides which [GovDocumentsRemoteDataSource]
/// implementation the app runs against (docs/backend/15-mock-to-real-migration.md).
final govDocumentsRemoteDataSourceProvider = Provider<GovDocumentsRemoteDataSource>((ref) {
  return GovDocumentsRemoteDataSourceImpl(ref.watch(dioProvider));
});
