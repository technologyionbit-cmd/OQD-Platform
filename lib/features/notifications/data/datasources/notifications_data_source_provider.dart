import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_remote_data_source_impl.dart';

/// The ONE place that decides which [NotificationsRemoteDataSource]
/// implementation the app runs against (docs/backend/15-mock-to-real-migration.md).
/// Tests override it with `NotificationsMockDataSource`.
final notificationsRemoteDataSourceProvider = Provider<NotificationsRemoteDataSource>((ref) {
  return NotificationsRemoteDataSourceImpl(ref.watch(dioProvider));
});
