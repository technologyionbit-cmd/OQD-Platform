import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_remote_data_source.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_remote_data_source_impl.dart';

/// The ONE place that decides which [ConsultationsRemoteDataSource]
/// implementation the app runs against (docs/backend/15-mock-to-real-migration.md).
final consultationsRemoteDataSourceProvider = Provider<ConsultationsRemoteDataSource>((ref) {
  return ConsultationsRemoteDataSourceImpl(ref.watch(dioProvider));
});
