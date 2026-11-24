import 'package:freezed_annotation/freezed_annotation.dart';

part 'managed_user.freezed.dart';
part 'managed_user.g.dart';

/// A user as listed in the users table.
@freezed
abstract class ManagedUser with _$ManagedUser {
  const factory ManagedUser({
    required String id,
    required String fullName,
    required String email,
    required String role,
    required String status,
    required DateTime createdAt,
    String? phone,
    DateTime? phoneVerifiedAt,
    DateTime? lastLoginAt,
    DateTime? deletedAt,
    DateTime? suspendedAt,
  }) = _ManagedUser;

  const ManagedUser._();

  factory ManagedUser.fromJson(Map<String, dynamic> json) => _$ManagedUserFromJson(json);

  bool get isRemoved => deletedAt != null;
  bool get isAdmin => role == 'admin';
}

@freezed
abstract class SessionInfo with _$SessionInfo {
  const factory SessionInfo({
    required String id,
    required DateTime createdAt,
    String? deviceLabel,
    String? ipAddress,
    DateTime? lastUsedAt,
  }) = _SessionInfo;

  factory SessionInfo.fromJson(Map<String, dynamic> json) => _$SessionInfoFromJson(json);
}

@freezed
abstract class LawyerSummary with _$LawyerSummary {
  const factory LawyerSummary({
    required String id,
    required String verificationStatus,
    required int reviewsCount,
    // Postgres decimals come back as a string or a number.
    @JsonKey(fromJson: _toDouble) required double rating,
  }) = _LawyerSummary;

  factory LawyerSummary.fromJson(Map<String, dynamic> json) => _$LawyerSummaryFromJson(json);
}

@freezed
abstract class OrganizationSummary with _$OrganizationSummary {
  const factory OrganizationSummary({
    required String id,
    required String name,
    required String verificationStatus,
  }) = _OrganizationSummary;

  factory OrganizationSummary.fromJson(Map<String, dynamic> json) => _$OrganizationSummaryFromJson(json);
}

@freezed
abstract class AdminRef with _$AdminRef {
  const factory AdminRef({required String id, required String fullName}) = _AdminRef;

  factory AdminRef.fromJson(Map<String, dynamic> json) => _$AdminRefFromJson(json);
}

@freezed
abstract class RecordCounts with _$RecordCounts {
  const factory RecordCounts({
    @Default(0) int bookedConsultations,
    @Default(0) int contracts,
  }) = _RecordCounts;

  factory RecordCounts.fromJson(Map<String, dynamic> json) => _$RecordCountsFromJson(json);
}

/// One user with everything the detail screen shows.
@freezed
abstract class UserDetail with _$UserDetail {
  const factory UserDetail({
    required String id,
    required String fullName,
    required String email,
    required String role,
    required String status,
    required DateTime createdAt,
    @Default(false) bool twoFactorEnabled,
    @Default(<SessionInfo>[]) List<SessionInfo> sessions,
    @Default(<OrganizationSummary>[]) List<OrganizationSummary> ownedOrganizations,
    @JsonKey(name: '_count') @Default(RecordCounts()) RecordCounts counts,
    String? phone,
    DateTime? phoneVerifiedAt,
    DateTime? lastLoginAt,
    DateTime? deletedAt,
    DateTime? suspendedAt,
    String? suspendedReason,
    DateTime? termsAcceptedAt,
    String? termsVersion,
    LawyerSummary? lawyerProfile,
    AdminRef? suspendedBy,
  }) = _UserDetail;

  const UserDetail._();

  factory UserDetail.fromJson(Map<String, dynamic> json) => _$UserDetailFromJson(json);

  bool get isRemoved => deletedAt != null;
  bool get isAdmin => role == 'admin';
  bool get isSuspended => status == 'suspended';
}

/// Outcome of a bulk action: ids done, and ids skipped with the reason.
@freezed
abstract class BulkResult with _$BulkResult {
  const factory BulkResult({
    required List<String> succeeded,
    required List<BulkSkip> skipped,
  }) = _BulkResult;

  factory BulkResult.fromJson(Map<String, dynamic> json) => _$BulkResultFromJson(json);
}

@freezed
abstract class BulkSkip with _$BulkSkip {
  const factory BulkSkip({required String id, required String reason}) = _BulkSkip;

  factory BulkSkip.fromJson(Map<String, dynamic> json) => _$BulkSkipFromJson(json);
}

double _toDouble(Object? value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
