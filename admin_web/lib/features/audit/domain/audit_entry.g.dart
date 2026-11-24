// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditActor _$AuditActorFromJson(Map<String, dynamic> json) => _AuditActor(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$AuditActorToJson(_AuditActor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
    };

_AuditEntry _$AuditEntryFromJson(Map<String, dynamic> json) => _AuditEntry(
  id: json['id'] as String,
  action: json['action'] as String,
  method: json['method'] as String,
  path: json['path'] as String,
  statusCode: (json['statusCode'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  entityType: json['entityType'] as String?,
  entityId: json['entityId'] as String?,
  ipAddress: json['ipAddress'] as String?,
  actor:
      json['actor'] == null
          ? null
          : AuditActor.fromJson(json['actor'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuditEntryToJson(_AuditEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'method': instance.method,
      'path': instance.path,
      'statusCode': instance.statusCode,
      'createdAt': instance.createdAt.toIso8601String(),
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'ipAddress': instance.ipAddress,
      'actor': instance.actor,
    };

_AuditDetail _$AuditDetailFromJson(Map<String, dynamic> json) => _AuditDetail(
  id: json['id'] as String,
  action: json['action'] as String,
  method: json['method'] as String,
  path: json['path'] as String,
  statusCode: (json['statusCode'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  entityType: json['entityType'] as String?,
  entityId: json['entityId'] as String?,
  ipAddress: json['ipAddress'] as String?,
  userAgent: json['userAgent'] as String?,
  actor:
      json['actor'] == null
          ? null
          : AuditActor.fromJson(json['actor'] as Map<String, dynamic>),
  before: json['before'],
  after: json['after'],
  meta: json['meta'],
);

Map<String, dynamic> _$AuditDetailToJson(_AuditDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'method': instance.method,
      'path': instance.path,
      'statusCode': instance.statusCode,
      'createdAt': instance.createdAt.toIso8601String(),
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'actor': instance.actor,
      'before': instance.before,
      'after': instance.after,
      'meta': instance.meta,
    };
