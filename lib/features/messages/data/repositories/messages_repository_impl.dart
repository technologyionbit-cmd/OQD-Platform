import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/messages/data/datasources/messages_data_source_provider.dart';
import 'package:aqd_ionbit/features/messages/data/datasources/messages_remote_data_source.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message_type.dart';
import 'package:aqd_ionbit/features/messages/domain/repositories/messages_repository.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  MessagesRepositoryImpl({required MessagesRemoteDataSource remoteDataSource, ApiErrorMapper errorMapper = const ApiErrorMapper()})
    : _remote = remoteDataSource,
      _errorMapper = errorMapper;

  final MessagesRemoteDataSource _remote;
  final ApiErrorMapper _errorMapper;

  @override
  Future<Result<List<Message>>> getMessages(String consultationId) => _guard(() => _remote.getMessages(consultationId));

  @override
  Future<Result<Message>> sendMessage({
    required String consultationId,
    required String senderId,
    required UserRole senderRole,
    required MessageType type,
    String text = '',
    String? attachmentUrl,
  }) {
    return _guard(
      () => _remote.sendMessage(
        consultationId: consultationId,
        senderId: senderId,
        senderRole: senderRole,
        type: type,
        text: text,
        attachmentUrl: attachmentUrl,
      ),
    );
  }

  @override
  Future<Result<void>> markAllRead({required String consultationId, required UserRole viewerRole}) {
    return _guard(() => _remote.markAllRead(consultationId: consultationId, viewerRole: viewerRole));
  }

  @override
  Future<Result<Map<String, int>>> getUnreadCounts({required UserRole viewerRole}) {
    return _guard(() => _remote.getUnreadCounts(viewerRole: viewerRole));
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } catch (e) {
      return Result.failure(_errorMapper.map(e));
    }
  }
}

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepositoryImpl(remoteDataSource: ref.watch(messagesRemoteDataSourceProvider));
});
