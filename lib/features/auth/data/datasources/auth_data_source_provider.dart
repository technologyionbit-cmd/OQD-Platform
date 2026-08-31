import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/auth/data/datasources/auth_mock_data_source.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_remote_data_source.dart';

/// The ONE place that decides which [AuthRemoteDataSource] implementation
/// the app runs against. Today that's [AuthMockDataSource] because the
/// backend contract isn't available yet. When it is, this becomes:
///
/// ```dart
/// final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
///   return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
/// });
/// ```
///
/// No other file changes — the repository, controller, and every screen
/// depend on [AuthRemoteDataSource], never on [AuthMockDataSource] directly.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) => AuthMockDataSource());
