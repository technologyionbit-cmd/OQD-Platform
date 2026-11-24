// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'managed_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ManagedUser {

 String get id; String get fullName; String get email; String get role; String get status; DateTime get createdAt; String? get phone; DateTime? get phoneVerifiedAt; DateTime? get lastLoginAt; DateTime? get deletedAt; DateTime? get suspendedAt;
/// Create a copy of ManagedUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManagedUserCopyWith<ManagedUser> get copyWith => _$ManagedUserCopyWithImpl<ManagedUser>(this as ManagedUser, _$identity);

  /// Serializes this ManagedUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManagedUser&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.phoneVerifiedAt, phoneVerifiedAt) || other.phoneVerifiedAt == phoneVerifiedAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.suspendedAt, suspendedAt) || other.suspendedAt == suspendedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,role,status,createdAt,phone,phoneVerifiedAt,lastLoginAt,deletedAt,suspendedAt);

@override
String toString() {
  return 'ManagedUser(id: $id, fullName: $fullName, email: $email, role: $role, status: $status, createdAt: $createdAt, phone: $phone, phoneVerifiedAt: $phoneVerifiedAt, lastLoginAt: $lastLoginAt, deletedAt: $deletedAt, suspendedAt: $suspendedAt)';
}


}

/// @nodoc
abstract mixin class $ManagedUserCopyWith<$Res>  {
  factory $ManagedUserCopyWith(ManagedUser value, $Res Function(ManagedUser) _then) = _$ManagedUserCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String email, String role, String status, DateTime createdAt, String? phone, DateTime? phoneVerifiedAt, DateTime? lastLoginAt, DateTime? deletedAt, DateTime? suspendedAt
});




}
/// @nodoc
class _$ManagedUserCopyWithImpl<$Res>
    implements $ManagedUserCopyWith<$Res> {
  _$ManagedUserCopyWithImpl(this._self, this._then);

  final ManagedUser _self;
  final $Res Function(ManagedUser) _then;

/// Create a copy of ManagedUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? role = null,Object? status = null,Object? createdAt = null,Object? phone = freezed,Object? phoneVerifiedAt = freezed,Object? lastLoginAt = freezed,Object? deletedAt = freezed,Object? suspendedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,phoneVerifiedAt: freezed == phoneVerifiedAt ? _self.phoneVerifiedAt : phoneVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,suspendedAt: freezed == suspendedAt ? _self.suspendedAt : suspendedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ManagedUser].
extension ManagedUserPatterns on ManagedUser {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManagedUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManagedUser() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManagedUser value)  $default,){
final _that = this;
switch (_that) {
case _ManagedUser():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManagedUser value)?  $default,){
final _that = this;
switch (_that) {
case _ManagedUser() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String email,  String role,  String status,  DateTime createdAt,  String? phone,  DateTime? phoneVerifiedAt,  DateTime? lastLoginAt,  DateTime? deletedAt,  DateTime? suspendedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManagedUser() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.role,_that.status,_that.createdAt,_that.phone,_that.phoneVerifiedAt,_that.lastLoginAt,_that.deletedAt,_that.suspendedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String email,  String role,  String status,  DateTime createdAt,  String? phone,  DateTime? phoneVerifiedAt,  DateTime? lastLoginAt,  DateTime? deletedAt,  DateTime? suspendedAt)  $default,) {final _that = this;
switch (_that) {
case _ManagedUser():
return $default(_that.id,_that.fullName,_that.email,_that.role,_that.status,_that.createdAt,_that.phone,_that.phoneVerifiedAt,_that.lastLoginAt,_that.deletedAt,_that.suspendedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String email,  String role,  String status,  DateTime createdAt,  String? phone,  DateTime? phoneVerifiedAt,  DateTime? lastLoginAt,  DateTime? deletedAt,  DateTime? suspendedAt)?  $default,) {final _that = this;
switch (_that) {
case _ManagedUser() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.role,_that.status,_that.createdAt,_that.phone,_that.phoneVerifiedAt,_that.lastLoginAt,_that.deletedAt,_that.suspendedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ManagedUser extends ManagedUser {
  const _ManagedUser({required this.id, required this.fullName, required this.email, required this.role, required this.status, required this.createdAt, this.phone, this.phoneVerifiedAt, this.lastLoginAt, this.deletedAt, this.suspendedAt}): super._();
  factory _ManagedUser.fromJson(Map<String, dynamic> json) => _$ManagedUserFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String email;
@override final  String role;
@override final  String status;
@override final  DateTime createdAt;
@override final  String? phone;
@override final  DateTime? phoneVerifiedAt;
@override final  DateTime? lastLoginAt;
@override final  DateTime? deletedAt;
@override final  DateTime? suspendedAt;

/// Create a copy of ManagedUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManagedUserCopyWith<_ManagedUser> get copyWith => __$ManagedUserCopyWithImpl<_ManagedUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ManagedUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManagedUser&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.phoneVerifiedAt, phoneVerifiedAt) || other.phoneVerifiedAt == phoneVerifiedAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.suspendedAt, suspendedAt) || other.suspendedAt == suspendedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,role,status,createdAt,phone,phoneVerifiedAt,lastLoginAt,deletedAt,suspendedAt);

@override
String toString() {
  return 'ManagedUser(id: $id, fullName: $fullName, email: $email, role: $role, status: $status, createdAt: $createdAt, phone: $phone, phoneVerifiedAt: $phoneVerifiedAt, lastLoginAt: $lastLoginAt, deletedAt: $deletedAt, suspendedAt: $suspendedAt)';
}


}

/// @nodoc
abstract mixin class _$ManagedUserCopyWith<$Res> implements $ManagedUserCopyWith<$Res> {
  factory _$ManagedUserCopyWith(_ManagedUser value, $Res Function(_ManagedUser) _then) = __$ManagedUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String email, String role, String status, DateTime createdAt, String? phone, DateTime? phoneVerifiedAt, DateTime? lastLoginAt, DateTime? deletedAt, DateTime? suspendedAt
});




}
/// @nodoc
class __$ManagedUserCopyWithImpl<$Res>
    implements _$ManagedUserCopyWith<$Res> {
  __$ManagedUserCopyWithImpl(this._self, this._then);

  final _ManagedUser _self;
  final $Res Function(_ManagedUser) _then;

/// Create a copy of ManagedUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? role = null,Object? status = null,Object? createdAt = null,Object? phone = freezed,Object? phoneVerifiedAt = freezed,Object? lastLoginAt = freezed,Object? deletedAt = freezed,Object? suspendedAt = freezed,}) {
  return _then(_ManagedUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,phoneVerifiedAt: freezed == phoneVerifiedAt ? _self.phoneVerifiedAt : phoneVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,suspendedAt: freezed == suspendedAt ? _self.suspendedAt : suspendedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SessionInfo {

 String get id; DateTime get createdAt; String? get deviceLabel; String? get ipAddress; DateTime? get lastUsedAt;
/// Create a copy of SessionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionInfoCopyWith<SessionInfo> get copyWith => _$SessionInfoCopyWithImpl<SessionInfo>(this as SessionInfo, _$identity);

  /// Serializes this SessionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deviceLabel, deviceLabel) || other.deviceLabel == deviceLabel)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,deviceLabel,ipAddress,lastUsedAt);

@override
String toString() {
  return 'SessionInfo(id: $id, createdAt: $createdAt, deviceLabel: $deviceLabel, ipAddress: $ipAddress, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class $SessionInfoCopyWith<$Res>  {
  factory $SessionInfoCopyWith(SessionInfo value, $Res Function(SessionInfo) _then) = _$SessionInfoCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, String? deviceLabel, String? ipAddress, DateTime? lastUsedAt
});




}
/// @nodoc
class _$SessionInfoCopyWithImpl<$Res>
    implements $SessionInfoCopyWith<$Res> {
  _$SessionInfoCopyWithImpl(this._self, this._then);

  final SessionInfo _self;
  final $Res Function(SessionInfo) _then;

/// Create a copy of SessionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? deviceLabel = freezed,Object? ipAddress = freezed,Object? lastUsedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deviceLabel: freezed == deviceLabel ? _self.deviceLabel : deviceLabel // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionInfo].
extension SessionInfoPatterns on SessionInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionInfo value)  $default,){
final _that = this;
switch (_that) {
case _SessionInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _SessionInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  String? deviceLabel,  String? ipAddress,  DateTime? lastUsedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionInfo() when $default != null:
return $default(_that.id,_that.createdAt,_that.deviceLabel,_that.ipAddress,_that.lastUsedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  String? deviceLabel,  String? ipAddress,  DateTime? lastUsedAt)  $default,) {final _that = this;
switch (_that) {
case _SessionInfo():
return $default(_that.id,_that.createdAt,_that.deviceLabel,_that.ipAddress,_that.lastUsedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  String? deviceLabel,  String? ipAddress,  DateTime? lastUsedAt)?  $default,) {final _that = this;
switch (_that) {
case _SessionInfo() when $default != null:
return $default(_that.id,_that.createdAt,_that.deviceLabel,_that.ipAddress,_that.lastUsedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionInfo implements SessionInfo {
  const _SessionInfo({required this.id, required this.createdAt, this.deviceLabel, this.ipAddress, this.lastUsedAt});
  factory _SessionInfo.fromJson(Map<String, dynamic> json) => _$SessionInfoFromJson(json);

@override final  String id;
@override final  DateTime createdAt;
@override final  String? deviceLabel;
@override final  String? ipAddress;
@override final  DateTime? lastUsedAt;

/// Create a copy of SessionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionInfoCopyWith<_SessionInfo> get copyWith => __$SessionInfoCopyWithImpl<_SessionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deviceLabel, deviceLabel) || other.deviceLabel == deviceLabel)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,deviceLabel,ipAddress,lastUsedAt);

@override
String toString() {
  return 'SessionInfo(id: $id, createdAt: $createdAt, deviceLabel: $deviceLabel, ipAddress: $ipAddress, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class _$SessionInfoCopyWith<$Res> implements $SessionInfoCopyWith<$Res> {
  factory _$SessionInfoCopyWith(_SessionInfo value, $Res Function(_SessionInfo) _then) = __$SessionInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, String? deviceLabel, String? ipAddress, DateTime? lastUsedAt
});




}
/// @nodoc
class __$SessionInfoCopyWithImpl<$Res>
    implements _$SessionInfoCopyWith<$Res> {
  __$SessionInfoCopyWithImpl(this._self, this._then);

  final _SessionInfo _self;
  final $Res Function(_SessionInfo) _then;

/// Create a copy of SessionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? deviceLabel = freezed,Object? ipAddress = freezed,Object? lastUsedAt = freezed,}) {
  return _then(_SessionInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deviceLabel: freezed == deviceLabel ? _self.deviceLabel : deviceLabel // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$LawyerSummary {

 String get id; String get verificationStatus; int get reviewsCount;// Postgres decimals come back as a string or a number.
@JsonKey(fromJson: _toDouble) double get rating;
/// Create a copy of LawyerSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LawyerSummaryCopyWith<LawyerSummary> get copyWith => _$LawyerSummaryCopyWithImpl<LawyerSummary>(this as LawyerSummary, _$identity);

  /// Serializes this LawyerSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LawyerSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.reviewsCount, reviewsCount) || other.reviewsCount == reviewsCount)&&(identical(other.rating, rating) || other.rating == rating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,verificationStatus,reviewsCount,rating);

@override
String toString() {
  return 'LawyerSummary(id: $id, verificationStatus: $verificationStatus, reviewsCount: $reviewsCount, rating: $rating)';
}


}

/// @nodoc
abstract mixin class $LawyerSummaryCopyWith<$Res>  {
  factory $LawyerSummaryCopyWith(LawyerSummary value, $Res Function(LawyerSummary) _then) = _$LawyerSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String verificationStatus, int reviewsCount,@JsonKey(fromJson: _toDouble) double rating
});




}
/// @nodoc
class _$LawyerSummaryCopyWithImpl<$Res>
    implements $LawyerSummaryCopyWith<$Res> {
  _$LawyerSummaryCopyWithImpl(this._self, this._then);

  final LawyerSummary _self;
  final $Res Function(LawyerSummary) _then;

/// Create a copy of LawyerSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? verificationStatus = null,Object? reviewsCount = null,Object? rating = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,reviewsCount: null == reviewsCount ? _self.reviewsCount : reviewsCount // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [LawyerSummary].
extension LawyerSummaryPatterns on LawyerSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LawyerSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LawyerSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LawyerSummary value)  $default,){
final _that = this;
switch (_that) {
case _LawyerSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LawyerSummary value)?  $default,){
final _that = this;
switch (_that) {
case _LawyerSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String verificationStatus,  int reviewsCount, @JsonKey(fromJson: _toDouble)  double rating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LawyerSummary() when $default != null:
return $default(_that.id,_that.verificationStatus,_that.reviewsCount,_that.rating);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String verificationStatus,  int reviewsCount, @JsonKey(fromJson: _toDouble)  double rating)  $default,) {final _that = this;
switch (_that) {
case _LawyerSummary():
return $default(_that.id,_that.verificationStatus,_that.reviewsCount,_that.rating);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String verificationStatus,  int reviewsCount, @JsonKey(fromJson: _toDouble)  double rating)?  $default,) {final _that = this;
switch (_that) {
case _LawyerSummary() when $default != null:
return $default(_that.id,_that.verificationStatus,_that.reviewsCount,_that.rating);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LawyerSummary implements LawyerSummary {
  const _LawyerSummary({required this.id, required this.verificationStatus, required this.reviewsCount, @JsonKey(fromJson: _toDouble) required this.rating});
  factory _LawyerSummary.fromJson(Map<String, dynamic> json) => _$LawyerSummaryFromJson(json);

@override final  String id;
@override final  String verificationStatus;
@override final  int reviewsCount;
// Postgres decimals come back as a string or a number.
@override@JsonKey(fromJson: _toDouble) final  double rating;

/// Create a copy of LawyerSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LawyerSummaryCopyWith<_LawyerSummary> get copyWith => __$LawyerSummaryCopyWithImpl<_LawyerSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LawyerSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LawyerSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.reviewsCount, reviewsCount) || other.reviewsCount == reviewsCount)&&(identical(other.rating, rating) || other.rating == rating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,verificationStatus,reviewsCount,rating);

@override
String toString() {
  return 'LawyerSummary(id: $id, verificationStatus: $verificationStatus, reviewsCount: $reviewsCount, rating: $rating)';
}


}

/// @nodoc
abstract mixin class _$LawyerSummaryCopyWith<$Res> implements $LawyerSummaryCopyWith<$Res> {
  factory _$LawyerSummaryCopyWith(_LawyerSummary value, $Res Function(_LawyerSummary) _then) = __$LawyerSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String verificationStatus, int reviewsCount,@JsonKey(fromJson: _toDouble) double rating
});




}
/// @nodoc
class __$LawyerSummaryCopyWithImpl<$Res>
    implements _$LawyerSummaryCopyWith<$Res> {
  __$LawyerSummaryCopyWithImpl(this._self, this._then);

  final _LawyerSummary _self;
  final $Res Function(_LawyerSummary) _then;

/// Create a copy of LawyerSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? verificationStatus = null,Object? reviewsCount = null,Object? rating = null,}) {
  return _then(_LawyerSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,reviewsCount: null == reviewsCount ? _self.reviewsCount : reviewsCount // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$OrganizationSummary {

 String get id; String get name; String get verificationStatus;
/// Create a copy of OrganizationSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationSummaryCopyWith<OrganizationSummary> get copyWith => _$OrganizationSummaryCopyWithImpl<OrganizationSummary>(this as OrganizationSummary, _$identity);

  /// Serializes this OrganizationSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,verificationStatus);

@override
String toString() {
  return 'OrganizationSummary(id: $id, name: $name, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class $OrganizationSummaryCopyWith<$Res>  {
  factory $OrganizationSummaryCopyWith(OrganizationSummary value, $Res Function(OrganizationSummary) _then) = _$OrganizationSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String verificationStatus
});




}
/// @nodoc
class _$OrganizationSummaryCopyWithImpl<$Res>
    implements $OrganizationSummaryCopyWith<$Res> {
  _$OrganizationSummaryCopyWithImpl(this._self, this._then);

  final OrganizationSummary _self;
  final $Res Function(OrganizationSummary) _then;

/// Create a copy of OrganizationSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? verificationStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganizationSummary].
extension OrganizationSummaryPatterns on OrganizationSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationSummary value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationSummary value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String verificationStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationSummary() when $default != null:
return $default(_that.id,_that.name,_that.verificationStatus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String verificationStatus)  $default,) {final _that = this;
switch (_that) {
case _OrganizationSummary():
return $default(_that.id,_that.name,_that.verificationStatus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String verificationStatus)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationSummary() when $default != null:
return $default(_that.id,_that.name,_that.verificationStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizationSummary implements OrganizationSummary {
  const _OrganizationSummary({required this.id, required this.name, required this.verificationStatus});
  factory _OrganizationSummary.fromJson(Map<String, dynamic> json) => _$OrganizationSummaryFromJson(json);

@override final  String id;
@override final  String name;
@override final  String verificationStatus;

/// Create a copy of OrganizationSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationSummaryCopyWith<_OrganizationSummary> get copyWith => __$OrganizationSummaryCopyWithImpl<_OrganizationSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,verificationStatus);

@override
String toString() {
  return 'OrganizationSummary(id: $id, name: $name, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class _$OrganizationSummaryCopyWith<$Res> implements $OrganizationSummaryCopyWith<$Res> {
  factory _$OrganizationSummaryCopyWith(_OrganizationSummary value, $Res Function(_OrganizationSummary) _then) = __$OrganizationSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String verificationStatus
});




}
/// @nodoc
class __$OrganizationSummaryCopyWithImpl<$Res>
    implements _$OrganizationSummaryCopyWith<$Res> {
  __$OrganizationSummaryCopyWithImpl(this._self, this._then);

  final _OrganizationSummary _self;
  final $Res Function(_OrganizationSummary) _then;

/// Create a copy of OrganizationSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? verificationStatus = null,}) {
  return _then(_OrganizationSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AdminRef {

 String get id; String get fullName;
/// Create a copy of AdminRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminRefCopyWith<AdminRef> get copyWith => _$AdminRefCopyWithImpl<AdminRef>(this as AdminRef, _$identity);

  /// Serializes this AdminRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminRef&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName);

@override
String toString() {
  return 'AdminRef(id: $id, fullName: $fullName)';
}


}

/// @nodoc
abstract mixin class $AdminRefCopyWith<$Res>  {
  factory $AdminRefCopyWith(AdminRef value, $Res Function(AdminRef) _then) = _$AdminRefCopyWithImpl;
@useResult
$Res call({
 String id, String fullName
});




}
/// @nodoc
class _$AdminRefCopyWithImpl<$Res>
    implements $AdminRefCopyWith<$Res> {
  _$AdminRefCopyWithImpl(this._self, this._then);

  final AdminRef _self;
  final $Res Function(AdminRef) _then;

/// Create a copy of AdminRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminRef].
extension AdminRefPatterns on AdminRef {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminRef() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminRef value)  $default,){
final _that = this;
switch (_that) {
case _AdminRef():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminRef value)?  $default,){
final _that = this;
switch (_that) {
case _AdminRef() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminRef() when $default != null:
return $default(_that.id,_that.fullName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName)  $default,) {final _that = this;
switch (_that) {
case _AdminRef():
return $default(_that.id,_that.fullName);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName)?  $default,) {final _that = this;
switch (_that) {
case _AdminRef() when $default != null:
return $default(_that.id,_that.fullName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminRef implements AdminRef {
  const _AdminRef({required this.id, required this.fullName});
  factory _AdminRef.fromJson(Map<String, dynamic> json) => _$AdminRefFromJson(json);

@override final  String id;
@override final  String fullName;

/// Create a copy of AdminRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminRefCopyWith<_AdminRef> get copyWith => __$AdminRefCopyWithImpl<_AdminRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminRef&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName);

@override
String toString() {
  return 'AdminRef(id: $id, fullName: $fullName)';
}


}

/// @nodoc
abstract mixin class _$AdminRefCopyWith<$Res> implements $AdminRefCopyWith<$Res> {
  factory _$AdminRefCopyWith(_AdminRef value, $Res Function(_AdminRef) _then) = __$AdminRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName
});




}
/// @nodoc
class __$AdminRefCopyWithImpl<$Res>
    implements _$AdminRefCopyWith<$Res> {
  __$AdminRefCopyWithImpl(this._self, this._then);

  final _AdminRef _self;
  final $Res Function(_AdminRef) _then;

/// Create a copy of AdminRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,}) {
  return _then(_AdminRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RecordCounts {

 int get bookedConsultations; int get contracts;
/// Create a copy of RecordCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordCountsCopyWith<RecordCounts> get copyWith => _$RecordCountsCopyWithImpl<RecordCounts>(this as RecordCounts, _$identity);

  /// Serializes this RecordCounts to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordCounts&&(identical(other.bookedConsultations, bookedConsultations) || other.bookedConsultations == bookedConsultations)&&(identical(other.contracts, contracts) || other.contracts == contracts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookedConsultations,contracts);

@override
String toString() {
  return 'RecordCounts(bookedConsultations: $bookedConsultations, contracts: $contracts)';
}


}

/// @nodoc
abstract mixin class $RecordCountsCopyWith<$Res>  {
  factory $RecordCountsCopyWith(RecordCounts value, $Res Function(RecordCounts) _then) = _$RecordCountsCopyWithImpl;
@useResult
$Res call({
 int bookedConsultations, int contracts
});




}
/// @nodoc
class _$RecordCountsCopyWithImpl<$Res>
    implements $RecordCountsCopyWith<$Res> {
  _$RecordCountsCopyWithImpl(this._self, this._then);

  final RecordCounts _self;
  final $Res Function(RecordCounts) _then;

/// Create a copy of RecordCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookedConsultations = null,Object? contracts = null,}) {
  return _then(_self.copyWith(
bookedConsultations: null == bookedConsultations ? _self.bookedConsultations : bookedConsultations // ignore: cast_nullable_to_non_nullable
as int,contracts: null == contracts ? _self.contracts : contracts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordCounts].
extension RecordCountsPatterns on RecordCounts {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordCounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordCounts() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordCounts value)  $default,){
final _that = this;
switch (_that) {
case _RecordCounts():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordCounts value)?  $default,){
final _that = this;
switch (_that) {
case _RecordCounts() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bookedConsultations,  int contracts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordCounts() when $default != null:
return $default(_that.bookedConsultations,_that.contracts);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bookedConsultations,  int contracts)  $default,) {final _that = this;
switch (_that) {
case _RecordCounts():
return $default(_that.bookedConsultations,_that.contracts);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bookedConsultations,  int contracts)?  $default,) {final _that = this;
switch (_that) {
case _RecordCounts() when $default != null:
return $default(_that.bookedConsultations,_that.contracts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecordCounts implements RecordCounts {
  const _RecordCounts({this.bookedConsultations = 0, this.contracts = 0});
  factory _RecordCounts.fromJson(Map<String, dynamic> json) => _$RecordCountsFromJson(json);

@override@JsonKey() final  int bookedConsultations;
@override@JsonKey() final  int contracts;

/// Create a copy of RecordCounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordCountsCopyWith<_RecordCounts> get copyWith => __$RecordCountsCopyWithImpl<_RecordCounts>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecordCountsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordCounts&&(identical(other.bookedConsultations, bookedConsultations) || other.bookedConsultations == bookedConsultations)&&(identical(other.contracts, contracts) || other.contracts == contracts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookedConsultations,contracts);

@override
String toString() {
  return 'RecordCounts(bookedConsultations: $bookedConsultations, contracts: $contracts)';
}


}

/// @nodoc
abstract mixin class _$RecordCountsCopyWith<$Res> implements $RecordCountsCopyWith<$Res> {
  factory _$RecordCountsCopyWith(_RecordCounts value, $Res Function(_RecordCounts) _then) = __$RecordCountsCopyWithImpl;
@override @useResult
$Res call({
 int bookedConsultations, int contracts
});




}
/// @nodoc
class __$RecordCountsCopyWithImpl<$Res>
    implements _$RecordCountsCopyWith<$Res> {
  __$RecordCountsCopyWithImpl(this._self, this._then);

  final _RecordCounts _self;
  final $Res Function(_RecordCounts) _then;

/// Create a copy of RecordCounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookedConsultations = null,Object? contracts = null,}) {
  return _then(_RecordCounts(
bookedConsultations: null == bookedConsultations ? _self.bookedConsultations : bookedConsultations // ignore: cast_nullable_to_non_nullable
as int,contracts: null == contracts ? _self.contracts : contracts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$UserDetail {

 String get id; String get fullName; String get email; String get role; String get status; DateTime get createdAt; bool get twoFactorEnabled; List<SessionInfo> get sessions; List<OrganizationSummary> get ownedOrganizations;@JsonKey(name: '_count') RecordCounts get counts; String? get phone; DateTime? get phoneVerifiedAt; DateTime? get lastLoginAt; DateTime? get deletedAt; DateTime? get suspendedAt; String? get suspendedReason; DateTime? get termsAcceptedAt; String? get termsVersion; LawyerSummary? get lawyerProfile; AdminRef? get suspendedBy;
/// Create a copy of UserDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDetailCopyWith<UserDetail> get copyWith => _$UserDetailCopyWithImpl<UserDetail>(this as UserDetail, _$identity);

  /// Serializes this UserDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.twoFactorEnabled, twoFactorEnabled) || other.twoFactorEnabled == twoFactorEnabled)&&const DeepCollectionEquality().equals(other.sessions, sessions)&&const DeepCollectionEquality().equals(other.ownedOrganizations, ownedOrganizations)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.phoneVerifiedAt, phoneVerifiedAt) || other.phoneVerifiedAt == phoneVerifiedAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.suspendedAt, suspendedAt) || other.suspendedAt == suspendedAt)&&(identical(other.suspendedReason, suspendedReason) || other.suspendedReason == suspendedReason)&&(identical(other.termsAcceptedAt, termsAcceptedAt) || other.termsAcceptedAt == termsAcceptedAt)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion)&&(identical(other.lawyerProfile, lawyerProfile) || other.lawyerProfile == lawyerProfile)&&(identical(other.suspendedBy, suspendedBy) || other.suspendedBy == suspendedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,fullName,email,role,status,createdAt,twoFactorEnabled,const DeepCollectionEquality().hash(sessions),const DeepCollectionEquality().hash(ownedOrganizations),counts,phone,phoneVerifiedAt,lastLoginAt,deletedAt,suspendedAt,suspendedReason,termsAcceptedAt,termsVersion,lawyerProfile,suspendedBy]);

@override
String toString() {
  return 'UserDetail(id: $id, fullName: $fullName, email: $email, role: $role, status: $status, createdAt: $createdAt, twoFactorEnabled: $twoFactorEnabled, sessions: $sessions, ownedOrganizations: $ownedOrganizations, counts: $counts, phone: $phone, phoneVerifiedAt: $phoneVerifiedAt, lastLoginAt: $lastLoginAt, deletedAt: $deletedAt, suspendedAt: $suspendedAt, suspendedReason: $suspendedReason, termsAcceptedAt: $termsAcceptedAt, termsVersion: $termsVersion, lawyerProfile: $lawyerProfile, suspendedBy: $suspendedBy)';
}


}

/// @nodoc
abstract mixin class $UserDetailCopyWith<$Res>  {
  factory $UserDetailCopyWith(UserDetail value, $Res Function(UserDetail) _then) = _$UserDetailCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String email, String role, String status, DateTime createdAt, bool twoFactorEnabled, List<SessionInfo> sessions, List<OrganizationSummary> ownedOrganizations,@JsonKey(name: '_count') RecordCounts counts, String? phone, DateTime? phoneVerifiedAt, DateTime? lastLoginAt, DateTime? deletedAt, DateTime? suspendedAt, String? suspendedReason, DateTime? termsAcceptedAt, String? termsVersion, LawyerSummary? lawyerProfile, AdminRef? suspendedBy
});


$RecordCountsCopyWith<$Res> get counts;$LawyerSummaryCopyWith<$Res>? get lawyerProfile;$AdminRefCopyWith<$Res>? get suspendedBy;

}
/// @nodoc
class _$UserDetailCopyWithImpl<$Res>
    implements $UserDetailCopyWith<$Res> {
  _$UserDetailCopyWithImpl(this._self, this._then);

  final UserDetail _self;
  final $Res Function(UserDetail) _then;

/// Create a copy of UserDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? role = null,Object? status = null,Object? createdAt = null,Object? twoFactorEnabled = null,Object? sessions = null,Object? ownedOrganizations = null,Object? counts = null,Object? phone = freezed,Object? phoneVerifiedAt = freezed,Object? lastLoginAt = freezed,Object? deletedAt = freezed,Object? suspendedAt = freezed,Object? suspendedReason = freezed,Object? termsAcceptedAt = freezed,Object? termsVersion = freezed,Object? lawyerProfile = freezed,Object? suspendedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,twoFactorEnabled: null == twoFactorEnabled ? _self.twoFactorEnabled : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
as bool,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<SessionInfo>,ownedOrganizations: null == ownedOrganizations ? _self.ownedOrganizations : ownedOrganizations // ignore: cast_nullable_to_non_nullable
as List<OrganizationSummary>,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as RecordCounts,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,phoneVerifiedAt: freezed == phoneVerifiedAt ? _self.phoneVerifiedAt : phoneVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,suspendedAt: freezed == suspendedAt ? _self.suspendedAt : suspendedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,suspendedReason: freezed == suspendedReason ? _self.suspendedReason : suspendedReason // ignore: cast_nullable_to_non_nullable
as String?,termsAcceptedAt: freezed == termsAcceptedAt ? _self.termsAcceptedAt : termsAcceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,termsVersion: freezed == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String?,lawyerProfile: freezed == lawyerProfile ? _self.lawyerProfile : lawyerProfile // ignore: cast_nullable_to_non_nullable
as LawyerSummary?,suspendedBy: freezed == suspendedBy ? _self.suspendedBy : suspendedBy // ignore: cast_nullable_to_non_nullable
as AdminRef?,
  ));
}
/// Create a copy of UserDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecordCountsCopyWith<$Res> get counts {
  
  return $RecordCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}/// Create a copy of UserDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LawyerSummaryCopyWith<$Res>? get lawyerProfile {
    if (_self.lawyerProfile == null) {
    return null;
  }

  return $LawyerSummaryCopyWith<$Res>(_self.lawyerProfile!, (value) {
    return _then(_self.copyWith(lawyerProfile: value));
  });
}/// Create a copy of UserDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminRefCopyWith<$Res>? get suspendedBy {
    if (_self.suspendedBy == null) {
    return null;
  }

  return $AdminRefCopyWith<$Res>(_self.suspendedBy!, (value) {
    return _then(_self.copyWith(suspendedBy: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserDetail].
extension UserDetailPatterns on UserDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDetail value)  $default,){
final _that = this;
switch (_that) {
case _UserDetail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDetail value)?  $default,){
final _that = this;
switch (_that) {
case _UserDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String email,  String role,  String status,  DateTime createdAt,  bool twoFactorEnabled,  List<SessionInfo> sessions,  List<OrganizationSummary> ownedOrganizations, @JsonKey(name: '_count')  RecordCounts counts,  String? phone,  DateTime? phoneVerifiedAt,  DateTime? lastLoginAt,  DateTime? deletedAt,  DateTime? suspendedAt,  String? suspendedReason,  DateTime? termsAcceptedAt,  String? termsVersion,  LawyerSummary? lawyerProfile,  AdminRef? suspendedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDetail() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.role,_that.status,_that.createdAt,_that.twoFactorEnabled,_that.sessions,_that.ownedOrganizations,_that.counts,_that.phone,_that.phoneVerifiedAt,_that.lastLoginAt,_that.deletedAt,_that.suspendedAt,_that.suspendedReason,_that.termsAcceptedAt,_that.termsVersion,_that.lawyerProfile,_that.suspendedBy);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String email,  String role,  String status,  DateTime createdAt,  bool twoFactorEnabled,  List<SessionInfo> sessions,  List<OrganizationSummary> ownedOrganizations, @JsonKey(name: '_count')  RecordCounts counts,  String? phone,  DateTime? phoneVerifiedAt,  DateTime? lastLoginAt,  DateTime? deletedAt,  DateTime? suspendedAt,  String? suspendedReason,  DateTime? termsAcceptedAt,  String? termsVersion,  LawyerSummary? lawyerProfile,  AdminRef? suspendedBy)  $default,) {final _that = this;
switch (_that) {
case _UserDetail():
return $default(_that.id,_that.fullName,_that.email,_that.role,_that.status,_that.createdAt,_that.twoFactorEnabled,_that.sessions,_that.ownedOrganizations,_that.counts,_that.phone,_that.phoneVerifiedAt,_that.lastLoginAt,_that.deletedAt,_that.suspendedAt,_that.suspendedReason,_that.termsAcceptedAt,_that.termsVersion,_that.lawyerProfile,_that.suspendedBy);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String email,  String role,  String status,  DateTime createdAt,  bool twoFactorEnabled,  List<SessionInfo> sessions,  List<OrganizationSummary> ownedOrganizations, @JsonKey(name: '_count')  RecordCounts counts,  String? phone,  DateTime? phoneVerifiedAt,  DateTime? lastLoginAt,  DateTime? deletedAt,  DateTime? suspendedAt,  String? suspendedReason,  DateTime? termsAcceptedAt,  String? termsVersion,  LawyerSummary? lawyerProfile,  AdminRef? suspendedBy)?  $default,) {final _that = this;
switch (_that) {
case _UserDetail() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.role,_that.status,_that.createdAt,_that.twoFactorEnabled,_that.sessions,_that.ownedOrganizations,_that.counts,_that.phone,_that.phoneVerifiedAt,_that.lastLoginAt,_that.deletedAt,_that.suspendedAt,_that.suspendedReason,_that.termsAcceptedAt,_that.termsVersion,_that.lawyerProfile,_that.suspendedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDetail extends UserDetail {
  const _UserDetail({required this.id, required this.fullName, required this.email, required this.role, required this.status, required this.createdAt, this.twoFactorEnabled = false, final  List<SessionInfo> sessions = const <SessionInfo>[], final  List<OrganizationSummary> ownedOrganizations = const <OrganizationSummary>[], @JsonKey(name: '_count') this.counts = const RecordCounts(), this.phone, this.phoneVerifiedAt, this.lastLoginAt, this.deletedAt, this.suspendedAt, this.suspendedReason, this.termsAcceptedAt, this.termsVersion, this.lawyerProfile, this.suspendedBy}): _sessions = sessions,_ownedOrganizations = ownedOrganizations,super._();
  factory _UserDetail.fromJson(Map<String, dynamic> json) => _$UserDetailFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String email;
@override final  String role;
@override final  String status;
@override final  DateTime createdAt;
@override@JsonKey() final  bool twoFactorEnabled;
 final  List<SessionInfo> _sessions;
@override@JsonKey() List<SessionInfo> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

 final  List<OrganizationSummary> _ownedOrganizations;
@override@JsonKey() List<OrganizationSummary> get ownedOrganizations {
  if (_ownedOrganizations is EqualUnmodifiableListView) return _ownedOrganizations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownedOrganizations);
}

@override@JsonKey(name: '_count') final  RecordCounts counts;
@override final  String? phone;
@override final  DateTime? phoneVerifiedAt;
@override final  DateTime? lastLoginAt;
@override final  DateTime? deletedAt;
@override final  DateTime? suspendedAt;
@override final  String? suspendedReason;
@override final  DateTime? termsAcceptedAt;
@override final  String? termsVersion;
@override final  LawyerSummary? lawyerProfile;
@override final  AdminRef? suspendedBy;

/// Create a copy of UserDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDetailCopyWith<_UserDetail> get copyWith => __$UserDetailCopyWithImpl<_UserDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.twoFactorEnabled, twoFactorEnabled) || other.twoFactorEnabled == twoFactorEnabled)&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&const DeepCollectionEquality().equals(other._ownedOrganizations, _ownedOrganizations)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.phoneVerifiedAt, phoneVerifiedAt) || other.phoneVerifiedAt == phoneVerifiedAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.suspendedAt, suspendedAt) || other.suspendedAt == suspendedAt)&&(identical(other.suspendedReason, suspendedReason) || other.suspendedReason == suspendedReason)&&(identical(other.termsAcceptedAt, termsAcceptedAt) || other.termsAcceptedAt == termsAcceptedAt)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion)&&(identical(other.lawyerProfile, lawyerProfile) || other.lawyerProfile == lawyerProfile)&&(identical(other.suspendedBy, suspendedBy) || other.suspendedBy == suspendedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,fullName,email,role,status,createdAt,twoFactorEnabled,const DeepCollectionEquality().hash(_sessions),const DeepCollectionEquality().hash(_ownedOrganizations),counts,phone,phoneVerifiedAt,lastLoginAt,deletedAt,suspendedAt,suspendedReason,termsAcceptedAt,termsVersion,lawyerProfile,suspendedBy]);

@override
String toString() {
  return 'UserDetail(id: $id, fullName: $fullName, email: $email, role: $role, status: $status, createdAt: $createdAt, twoFactorEnabled: $twoFactorEnabled, sessions: $sessions, ownedOrganizations: $ownedOrganizations, counts: $counts, phone: $phone, phoneVerifiedAt: $phoneVerifiedAt, lastLoginAt: $lastLoginAt, deletedAt: $deletedAt, suspendedAt: $suspendedAt, suspendedReason: $suspendedReason, termsAcceptedAt: $termsAcceptedAt, termsVersion: $termsVersion, lawyerProfile: $lawyerProfile, suspendedBy: $suspendedBy)';
}


}

/// @nodoc
abstract mixin class _$UserDetailCopyWith<$Res> implements $UserDetailCopyWith<$Res> {
  factory _$UserDetailCopyWith(_UserDetail value, $Res Function(_UserDetail) _then) = __$UserDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String email, String role, String status, DateTime createdAt, bool twoFactorEnabled, List<SessionInfo> sessions, List<OrganizationSummary> ownedOrganizations,@JsonKey(name: '_count') RecordCounts counts, String? phone, DateTime? phoneVerifiedAt, DateTime? lastLoginAt, DateTime? deletedAt, DateTime? suspendedAt, String? suspendedReason, DateTime? termsAcceptedAt, String? termsVersion, LawyerSummary? lawyerProfile, AdminRef? suspendedBy
});


@override $RecordCountsCopyWith<$Res> get counts;@override $LawyerSummaryCopyWith<$Res>? get lawyerProfile;@override $AdminRefCopyWith<$Res>? get suspendedBy;

}
/// @nodoc
class __$UserDetailCopyWithImpl<$Res>
    implements _$UserDetailCopyWith<$Res> {
  __$UserDetailCopyWithImpl(this._self, this._then);

  final _UserDetail _self;
  final $Res Function(_UserDetail) _then;

/// Create a copy of UserDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? role = null,Object? status = null,Object? createdAt = null,Object? twoFactorEnabled = null,Object? sessions = null,Object? ownedOrganizations = null,Object? counts = null,Object? phone = freezed,Object? phoneVerifiedAt = freezed,Object? lastLoginAt = freezed,Object? deletedAt = freezed,Object? suspendedAt = freezed,Object? suspendedReason = freezed,Object? termsAcceptedAt = freezed,Object? termsVersion = freezed,Object? lawyerProfile = freezed,Object? suspendedBy = freezed,}) {
  return _then(_UserDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,twoFactorEnabled: null == twoFactorEnabled ? _self.twoFactorEnabled : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
as bool,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<SessionInfo>,ownedOrganizations: null == ownedOrganizations ? _self._ownedOrganizations : ownedOrganizations // ignore: cast_nullable_to_non_nullable
as List<OrganizationSummary>,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as RecordCounts,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,phoneVerifiedAt: freezed == phoneVerifiedAt ? _self.phoneVerifiedAt : phoneVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,suspendedAt: freezed == suspendedAt ? _self.suspendedAt : suspendedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,suspendedReason: freezed == suspendedReason ? _self.suspendedReason : suspendedReason // ignore: cast_nullable_to_non_nullable
as String?,termsAcceptedAt: freezed == termsAcceptedAt ? _self.termsAcceptedAt : termsAcceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,termsVersion: freezed == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String?,lawyerProfile: freezed == lawyerProfile ? _self.lawyerProfile : lawyerProfile // ignore: cast_nullable_to_non_nullable
as LawyerSummary?,suspendedBy: freezed == suspendedBy ? _self.suspendedBy : suspendedBy // ignore: cast_nullable_to_non_nullable
as AdminRef?,
  ));
}

/// Create a copy of UserDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecordCountsCopyWith<$Res> get counts {
  
  return $RecordCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}/// Create a copy of UserDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LawyerSummaryCopyWith<$Res>? get lawyerProfile {
    if (_self.lawyerProfile == null) {
    return null;
  }

  return $LawyerSummaryCopyWith<$Res>(_self.lawyerProfile!, (value) {
    return _then(_self.copyWith(lawyerProfile: value));
  });
}/// Create a copy of UserDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminRefCopyWith<$Res>? get suspendedBy {
    if (_self.suspendedBy == null) {
    return null;
  }

  return $AdminRefCopyWith<$Res>(_self.suspendedBy!, (value) {
    return _then(_self.copyWith(suspendedBy: value));
  });
}
}


/// @nodoc
mixin _$BulkResult {

 List<String> get succeeded; List<BulkSkip> get skipped;
/// Create a copy of BulkResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BulkResultCopyWith<BulkResult> get copyWith => _$BulkResultCopyWithImpl<BulkResult>(this as BulkResult, _$identity);

  /// Serializes this BulkResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BulkResult&&const DeepCollectionEquality().equals(other.succeeded, succeeded)&&const DeepCollectionEquality().equals(other.skipped, skipped));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(succeeded),const DeepCollectionEquality().hash(skipped));

@override
String toString() {
  return 'BulkResult(succeeded: $succeeded, skipped: $skipped)';
}


}

/// @nodoc
abstract mixin class $BulkResultCopyWith<$Res>  {
  factory $BulkResultCopyWith(BulkResult value, $Res Function(BulkResult) _then) = _$BulkResultCopyWithImpl;
@useResult
$Res call({
 List<String> succeeded, List<BulkSkip> skipped
});




}
/// @nodoc
class _$BulkResultCopyWithImpl<$Res>
    implements $BulkResultCopyWith<$Res> {
  _$BulkResultCopyWithImpl(this._self, this._then);

  final BulkResult _self;
  final $Res Function(BulkResult) _then;

/// Create a copy of BulkResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? succeeded = null,Object? skipped = null,}) {
  return _then(_self.copyWith(
succeeded: null == succeeded ? _self.succeeded : succeeded // ignore: cast_nullable_to_non_nullable
as List<String>,skipped: null == skipped ? _self.skipped : skipped // ignore: cast_nullable_to_non_nullable
as List<BulkSkip>,
  ));
}

}


/// Adds pattern-matching-related methods to [BulkResult].
extension BulkResultPatterns on BulkResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BulkResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BulkResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BulkResult value)  $default,){
final _that = this;
switch (_that) {
case _BulkResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BulkResult value)?  $default,){
final _that = this;
switch (_that) {
case _BulkResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> succeeded,  List<BulkSkip> skipped)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BulkResult() when $default != null:
return $default(_that.succeeded,_that.skipped);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> succeeded,  List<BulkSkip> skipped)  $default,) {final _that = this;
switch (_that) {
case _BulkResult():
return $default(_that.succeeded,_that.skipped);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> succeeded,  List<BulkSkip> skipped)?  $default,) {final _that = this;
switch (_that) {
case _BulkResult() when $default != null:
return $default(_that.succeeded,_that.skipped);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BulkResult implements BulkResult {
  const _BulkResult({required final  List<String> succeeded, required final  List<BulkSkip> skipped}): _succeeded = succeeded,_skipped = skipped;
  factory _BulkResult.fromJson(Map<String, dynamic> json) => _$BulkResultFromJson(json);

 final  List<String> _succeeded;
@override List<String> get succeeded {
  if (_succeeded is EqualUnmodifiableListView) return _succeeded;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_succeeded);
}

 final  List<BulkSkip> _skipped;
@override List<BulkSkip> get skipped {
  if (_skipped is EqualUnmodifiableListView) return _skipped;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skipped);
}


/// Create a copy of BulkResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BulkResultCopyWith<_BulkResult> get copyWith => __$BulkResultCopyWithImpl<_BulkResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BulkResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BulkResult&&const DeepCollectionEquality().equals(other._succeeded, _succeeded)&&const DeepCollectionEquality().equals(other._skipped, _skipped));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_succeeded),const DeepCollectionEquality().hash(_skipped));

@override
String toString() {
  return 'BulkResult(succeeded: $succeeded, skipped: $skipped)';
}


}

/// @nodoc
abstract mixin class _$BulkResultCopyWith<$Res> implements $BulkResultCopyWith<$Res> {
  factory _$BulkResultCopyWith(_BulkResult value, $Res Function(_BulkResult) _then) = __$BulkResultCopyWithImpl;
@override @useResult
$Res call({
 List<String> succeeded, List<BulkSkip> skipped
});




}
/// @nodoc
class __$BulkResultCopyWithImpl<$Res>
    implements _$BulkResultCopyWith<$Res> {
  __$BulkResultCopyWithImpl(this._self, this._then);

  final _BulkResult _self;
  final $Res Function(_BulkResult) _then;

/// Create a copy of BulkResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? succeeded = null,Object? skipped = null,}) {
  return _then(_BulkResult(
succeeded: null == succeeded ? _self._succeeded : succeeded // ignore: cast_nullable_to_non_nullable
as List<String>,skipped: null == skipped ? _self._skipped : skipped // ignore: cast_nullable_to_non_nullable
as List<BulkSkip>,
  ));
}


}


/// @nodoc
mixin _$BulkSkip {

 String get id; String get reason;
/// Create a copy of BulkSkip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BulkSkipCopyWith<BulkSkip> get copyWith => _$BulkSkipCopyWithImpl<BulkSkip>(this as BulkSkip, _$identity);

  /// Serializes this BulkSkip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BulkSkip&&(identical(other.id, id) || other.id == id)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reason);

@override
String toString() {
  return 'BulkSkip(id: $id, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $BulkSkipCopyWith<$Res>  {
  factory $BulkSkipCopyWith(BulkSkip value, $Res Function(BulkSkip) _then) = _$BulkSkipCopyWithImpl;
@useResult
$Res call({
 String id, String reason
});




}
/// @nodoc
class _$BulkSkipCopyWithImpl<$Res>
    implements $BulkSkipCopyWith<$Res> {
  _$BulkSkipCopyWithImpl(this._self, this._then);

  final BulkSkip _self;
  final $Res Function(BulkSkip) _then;

/// Create a copy of BulkSkip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reason = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BulkSkip].
extension BulkSkipPatterns on BulkSkip {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BulkSkip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BulkSkip() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BulkSkip value)  $default,){
final _that = this;
switch (_that) {
case _BulkSkip():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BulkSkip value)?  $default,){
final _that = this;
switch (_that) {
case _BulkSkip() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BulkSkip() when $default != null:
return $default(_that.id,_that.reason);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reason)  $default,) {final _that = this;
switch (_that) {
case _BulkSkip():
return $default(_that.id,_that.reason);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reason)?  $default,) {final _that = this;
switch (_that) {
case _BulkSkip() when $default != null:
return $default(_that.id,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BulkSkip implements BulkSkip {
  const _BulkSkip({required this.id, required this.reason});
  factory _BulkSkip.fromJson(Map<String, dynamic> json) => _$BulkSkipFromJson(json);

@override final  String id;
@override final  String reason;

/// Create a copy of BulkSkip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BulkSkipCopyWith<_BulkSkip> get copyWith => __$BulkSkipCopyWithImpl<_BulkSkip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BulkSkipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BulkSkip&&(identical(other.id, id) || other.id == id)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reason);

@override
String toString() {
  return 'BulkSkip(id: $id, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$BulkSkipCopyWith<$Res> implements $BulkSkipCopyWith<$Res> {
  factory _$BulkSkipCopyWith(_BulkSkip value, $Res Function(_BulkSkip) _then) = __$BulkSkipCopyWithImpl;
@override @useResult
$Res call({
 String id, String reason
});




}
/// @nodoc
class __$BulkSkipCopyWithImpl<$Res>
    implements _$BulkSkipCopyWith<$Res> {
  __$BulkSkipCopyWithImpl(this._self, this._then);

  final _BulkSkip _self;
  final $Res Function(_BulkSkip) _then;

/// Create a copy of BulkSkip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reason = null,}) {
  return _then(_BulkSkip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
