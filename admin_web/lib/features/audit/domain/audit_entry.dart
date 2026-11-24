import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_entry.freezed.dart';
part 'audit_entry.g.dart';

@freezed
abstract class AuditActor with _$AuditActor {
  const factory AuditActor({required String id, required String fullName, required String email}) = _AuditActor;

  factory AuditActor.fromJson(Map<String, dynamic> json) => _$AuditActorFromJson(json);
}

/// One row of the audit list.
@freezed
abstract class AuditEntry with _$AuditEntry {
  const factory AuditEntry({
    required String id,
    required String action,
    required String method,
    required String path,
    required int statusCode,
    required DateTime createdAt,
    String? entityType,
    String? entityId,
    String? ipAddress,
    AuditActor? actor,
  }) = _AuditEntry;

  const AuditEntry._();

  factory AuditEntry.fromJson(Map<String, dynamic> json) => _$AuditEntryFromJson(json);

  bool get succeeded => statusCode < 400;
}

/// A row with everything: the state before/after and the request.
@freezed
abstract class AuditDetail with _$AuditDetail {
  const factory AuditDetail({
    required String id,
    required String action,
    required String method,
    required String path,
    required int statusCode,
    required DateTime createdAt,
    String? entityType,
    String? entityId,
    String? ipAddress,
    String? userAgent,
    AuditActor? actor,
    Object? before,
    Object? after,
    Object? meta,
  }) = _AuditDetail;

  factory AuditDetail.fromJson(Map<String, dynamic> json) => _$AuditDetailFromJson(json);
}
