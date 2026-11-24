// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'managed_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ManagedUser _$ManagedUserFromJson(Map<String, dynamic> json) => _ManagedUser(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  phone: json['phone'] as String?,
  phoneVerifiedAt:
      json['phoneVerifiedAt'] == null
          ? null
          : DateTime.parse(json['phoneVerifiedAt'] as String),
  lastLoginAt:
      json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
  deletedAt:
      json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
  suspendedAt:
      json['suspendedAt'] == null
          ? null
          : DateTime.parse(json['suspendedAt'] as String),
);

Map<String, dynamic> _$ManagedUserToJson(_ManagedUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
      'role': instance.role,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'phone': instance.phone,
      'phoneVerifiedAt': instance.phoneVerifiedAt?.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'suspendedAt': instance.suspendedAt?.toIso8601String(),
    };

_SessionInfo _$SessionInfoFromJson(Map<String, dynamic> json) => _SessionInfo(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  deviceLabel: json['deviceLabel'] as String?,
  ipAddress: json['ipAddress'] as String?,
  lastUsedAt:
      json['lastUsedAt'] == null
          ? null
          : DateTime.parse(json['lastUsedAt'] as String),
);

Map<String, dynamic> _$SessionInfoToJson(_SessionInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'deviceLabel': instance.deviceLabel,
      'ipAddress': instance.ipAddress,
      'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
    };

_LawyerSummary _$LawyerSummaryFromJson(Map<String, dynamic> json) =>
    _LawyerSummary(
      id: json['id'] as String,
      verificationStatus: json['verificationStatus'] as String,
      reviewsCount: (json['reviewsCount'] as num).toInt(),
      rating: _toDouble(json['rating']),
    );

Map<String, dynamic> _$LawyerSummaryToJson(_LawyerSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'verificationStatus': instance.verificationStatus,
      'reviewsCount': instance.reviewsCount,
      'rating': instance.rating,
    };

_OrganizationSummary _$OrganizationSummaryFromJson(Map<String, dynamic> json) =>
    _OrganizationSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      verificationStatus: json['verificationStatus'] as String,
    );

Map<String, dynamic> _$OrganizationSummaryToJson(
  _OrganizationSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'verificationStatus': instance.verificationStatus,
};

_AdminRef _$AdminRefFromJson(Map<String, dynamic> json) =>
    _AdminRef(id: json['id'] as String, fullName: json['fullName'] as String);

Map<String, dynamic> _$AdminRefToJson(_AdminRef instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
};

_RecordCounts _$RecordCountsFromJson(Map<String, dynamic> json) =>
    _RecordCounts(
      bookedConsultations: (json['bookedConsultations'] as num?)?.toInt() ?? 0,
      contracts: (json['contracts'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RecordCountsToJson(_RecordCounts instance) =>
    <String, dynamic>{
      'bookedConsultations': instance.bookedConsultations,
      'contracts': instance.contracts,
    };

_UserDetail _$UserDetailFromJson(Map<String, dynamic> json) => _UserDetail(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
  sessions:
      (json['sessions'] as List<dynamic>?)
          ?.map((e) => SessionInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SessionInfo>[],
  ownedOrganizations:
      (json['ownedOrganizations'] as List<dynamic>?)
          ?.map((e) => OrganizationSummary.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OrganizationSummary>[],
  counts:
      json['_count'] == null
          ? const RecordCounts()
          : RecordCounts.fromJson(json['_count'] as Map<String, dynamic>),
  phone: json['phone'] as String?,
  phoneVerifiedAt:
      json['phoneVerifiedAt'] == null
          ? null
          : DateTime.parse(json['phoneVerifiedAt'] as String),
  lastLoginAt:
      json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
  deletedAt:
      json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
  suspendedAt:
      json['suspendedAt'] == null
          ? null
          : DateTime.parse(json['suspendedAt'] as String),
  suspendedReason: json['suspendedReason'] as String?,
  termsAcceptedAt:
      json['termsAcceptedAt'] == null
          ? null
          : DateTime.parse(json['termsAcceptedAt'] as String),
  termsVersion: json['termsVersion'] as String?,
  lawyerProfile:
      json['lawyerProfile'] == null
          ? null
          : LawyerSummary.fromJson(
            json['lawyerProfile'] as Map<String, dynamic>,
          ),
  suspendedBy:
      json['suspendedBy'] == null
          ? null
          : AdminRef.fromJson(json['suspendedBy'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserDetailToJson(_UserDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
      'role': instance.role,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'twoFactorEnabled': instance.twoFactorEnabled,
      'sessions': instance.sessions,
      'ownedOrganizations': instance.ownedOrganizations,
      '_count': instance.counts,
      'phone': instance.phone,
      'phoneVerifiedAt': instance.phoneVerifiedAt?.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'suspendedAt': instance.suspendedAt?.toIso8601String(),
      'suspendedReason': instance.suspendedReason,
      'termsAcceptedAt': instance.termsAcceptedAt?.toIso8601String(),
      'termsVersion': instance.termsVersion,
      'lawyerProfile': instance.lawyerProfile,
      'suspendedBy': instance.suspendedBy,
    };

_BulkResult _$BulkResultFromJson(Map<String, dynamic> json) => _BulkResult(
  succeeded:
      (json['succeeded'] as List<dynamic>).map((e) => e as String).toList(),
  skipped:
      (json['skipped'] as List<dynamic>)
          .map((e) => BulkSkip.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$BulkResultToJson(_BulkResult instance) =>
    <String, dynamic>{
      'succeeded': instance.succeeded,
      'skipped': instance.skipped,
    };

_BulkSkip _$BulkSkipFromJson(Map<String, dynamic> json) =>
    _BulkSkip(id: json['id'] as String, reason: json['reason'] as String);

Map<String, dynamic> _$BulkSkipToJson(_BulkSkip instance) => <String, dynamic>{
  'id': instance.id,
  'reason': instance.reason,
};
