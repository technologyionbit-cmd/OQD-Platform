// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminUser _$AdminUserFromJson(Map<String, dynamic> json) => _AdminUser(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  phone: json['phone'] as String?,
  fullAccess: json['fullAccess'] as bool? ?? false,
  permissions:
      (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$AdminUserToJson(_AdminUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
      'role': instance.role,
      'phone': instance.phone,
      'fullAccess': instance.fullAccess,
      'permissions': instance.permissions,
    };
