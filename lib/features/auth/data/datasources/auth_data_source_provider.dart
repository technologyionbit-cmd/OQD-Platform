import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_remote_data_source_impl.dart';

/// The ONE place that decides which [AuthRemoteDataSource] implementation
/// the app runs against — the real NestJS backend (`backend/`), reached
/// through the shared [dioProvider].
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
});
