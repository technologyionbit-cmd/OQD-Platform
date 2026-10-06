import 'package:dio/dio.dart';

import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';

/// Dio-backed implementation talking to `<apiBaseUrl>/notifications`.
class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl(this._dio, {ApiErrorMapper errorMapper = const ApiErrorMapper()}) : _errorMapper = errorMapper;

  final Dio _dio;
  final ApiErrorMapper _errorMapper;

  @override
  Future<List<AppNotification>> getNotifications() {
    return _errorMapper.guard(() async {
      final res = await _dio.get<Map<String, dynamic>>('/notifications');
      final rows = (res.data!['data'] as List).cast<Map<String, dynamic>>();
      return rows.map(_parse).nonNulls.toList(growable: false);
    });
  }

  @override
  Future<void> markAsRead(String id) => _errorMapper.guard(() => _dio.post<void>('/notifications/$id/read'));

  @override
  Future<void> markAllAsRead() => _errorMapper.guard(() => _dio.post<void>('/notifications/read-all'));

  @override
  Future<void> deleteNotification(String id) => _errorMapper.guard(() => _dio.delete<void>('/notifications/$id'));

  /// Null for a type this app version does not know yet (a newer server),
  /// so one unknown row never breaks the whole list.
  static AppNotification? _parse(Map<String, dynamic> json) {
    final type = NotificationType.values.asNameMap()[json['type']];
    if (type == null) return null;
    final params = json['params'];
    return AppNotification(
      id: json['id'] as String,
      type: type,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      isRead: json['isRead'] as bool,
      relatedId: json['relatedId'] as String?,
      params:
          params is Map
              ? {
                for (final e in params.entries)
                  if (e.value is String) e.key as String: e.value as String,
              }
              : const {},
    );
  }
}
