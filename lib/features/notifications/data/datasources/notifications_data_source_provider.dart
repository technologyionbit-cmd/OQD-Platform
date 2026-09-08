import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_mock_data_source.dart';
import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_remote_data_source.dart';

/// The ONE place that decides which [NotificationsRemoteDataSource]
/// implementation the app runs against — mirrors
/// `contracts_data_source_provider.dart`. Swapping in a real backend/push
/// service later means changing only this file.
final notificationsRemoteDataSourceProvider = Provider<NotificationsRemoteDataSource>((ref) => NotificationsMockDataSource());
