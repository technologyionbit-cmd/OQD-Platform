import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_remote_data_source.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_remote_data_source_impl.dart';

/// The ONE place that decides which [LawyersRemoteDataSource]
/// implementation the app runs against (docs/backend/15-mock-to-real-migration.md).
final lawyersRemoteDataSourceProvider = Provider<LawyersRemoteDataSource>((ref) {
  return LawyersRemoteDataSourceImpl(ref.watch(dioProvider));
});
