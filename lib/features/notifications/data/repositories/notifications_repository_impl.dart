import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_data_source_provider.dart';
import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';
import 'package:aqd_ionbit/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({required NotificationsRemoteDataSource remoteDataSource, ApiErrorMapper errorMapper = const ApiErrorMapper()})
    : _remote = remoteDataSource,
      _errorMapper = errorMapper;

  final NotificationsRemoteDataSource _remote;
  final ApiErrorMapper _errorMapper;

  @override
  Future<Result<List<AppNotification>>> getNotifications() => _guard(_remote.getNotifications);

  @override
  Future<Result<void>> markAsRead(String id) => _guard(() => _remote.markAsRead(id));

  @override
  Future<Result<void>> markAllAsRead() => _guard(_remote.markAllAsRead);

  @override
  Future<Result<void>> deleteNotification(String id) => _guard(() => _remote.deleteNotification(id));

  @override
  Future<Result<AppNotification>> create({
    required NotificationType type,
    required String title,
    required String body,
    String? relatedId,
    String? recipientUserId,
  }) {
    return _guard(() => _remote.create(type: type, title: title, body: body, relatedId: relatedId, recipientUserId: recipientUserId));
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } catch (e) {
      return Result.failure(_errorMapper.map(e));
    }
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(remoteDataSource: ref.watch(notificationsRemoteDataSourceProvider));
});
