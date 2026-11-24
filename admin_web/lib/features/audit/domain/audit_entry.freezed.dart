// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuditActor {

 String get id; String get fullName; String get email;
/// Create a copy of AuditActor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditActorCopyWith<AuditActor> get copyWith => _$AuditActorCopyWithImpl<AuditActor>(this as AuditActor, _$identity);

  /// Serializes this AuditActor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditActor&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email);

@override
String toString() {
  return 'AuditActor(id: $id, fullName: $fullName, email: $email)';
}


}

/// @nodoc
abstract mixin class $AuditActorCopyWith<$Res>  {
  factory $AuditActorCopyWith(AuditActor value, $Res Function(AuditActor) _then) = _$AuditActorCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String email
});




}
/// @nodoc
class _$AuditActorCopyWithImpl<$Res>
    implements $AuditActorCopyWith<$Res> {
  _$AuditActorCopyWithImpl(this._self, this._then);

  final AuditActor _self;
  final $Res Function(AuditActor) _then;

/// Create a copy of AuditActor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? email = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditActor].
extension AuditActorPatterns on AuditActor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditActor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditActor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditActor value)  $default,){
final _that = this;
switch (_that) {
case _AuditActor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditActor value)?  $default,){
final _that = this;
switch (_that) {
case _AuditActor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditActor() when $default != null:
return $default(_that.id,_that.fullName,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String email)  $default,) {final _that = this;
switch (_that) {
case _AuditActor():
return $default(_that.id,_that.fullName,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String email)?  $default,) {final _that = this;
switch (_that) {
case _AuditActor() when $default != null:
return $default(_that.id,_that.fullName,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditActor implements AuditActor {
  const _AuditActor({required this.id, required this.fullName, required this.email});
  factory _AuditActor.fromJson(Map<String, dynamic> json) => _$AuditActorFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String email;

/// Create a copy of AuditActor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditActorCopyWith<_AuditActor> get copyWith => __$AuditActorCopyWithImpl<_AuditActor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditActorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditActor&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email);

@override
String toString() {
  return 'AuditActor(id: $id, fullName: $fullName, email: $email)';
}


}

/// @nodoc
abstract mixin class _$AuditActorCopyWith<$Res> implements $AuditActorCopyWith<$Res> {
  factory _$AuditActorCopyWith(_AuditActor value, $Res Function(_AuditActor) _then) = __$AuditActorCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String email
});




}
/// @nodoc
class __$AuditActorCopyWithImpl<$Res>
    implements _$AuditActorCopyWith<$Res> {
  __$AuditActorCopyWithImpl(this._self, this._then);

  final _AuditActor _self;
  final $Res Function(_AuditActor) _then;

/// Create a copy of AuditActor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? email = null,}) {
  return _then(_AuditActor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AuditEntry {

 String get id; String get action; String get method; String get path; int get statusCode; DateTime get createdAt; String? get entityType; String? get entityId; String? get ipAddress; AuditActor? get actor;
/// Create a copy of AuditEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditEntryCopyWith<AuditEntry> get copyWith => _$AuditEntryCopyWithImpl<AuditEntry>(this as AuditEntry, _$identity);

  /// Serializes this AuditEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.method, method) || other.method == method)&&(identical(other.path, path) || other.path == path)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.actor, actor) || other.actor == actor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,method,path,statusCode,createdAt,entityType,entityId,ipAddress,actor);

@override
String toString() {
  return 'AuditEntry(id: $id, action: $action, method: $method, path: $path, statusCode: $statusCode, createdAt: $createdAt, entityType: $entityType, entityId: $entityId, ipAddress: $ipAddress, actor: $actor)';
}


}

/// @nodoc
abstract mixin class $AuditEntryCopyWith<$Res>  {
  factory $AuditEntryCopyWith(AuditEntry value, $Res Function(AuditEntry) _then) = _$AuditEntryCopyWithImpl;
@useResult
$Res call({
 String id, String action, String method, String path, int statusCode, DateTime createdAt, String? entityType, String? entityId, String? ipAddress, AuditActor? actor
});


$AuditActorCopyWith<$Res>? get actor;

}
/// @nodoc
class _$AuditEntryCopyWithImpl<$Res>
    implements $AuditEntryCopyWith<$Res> {
  _$AuditEntryCopyWithImpl(this._self, this._then);

  final AuditEntry _self;
  final $Res Function(AuditEntry) _then;

/// Create a copy of AuditEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? action = null,Object? method = null,Object? path = null,Object? statusCode = null,Object? createdAt = null,Object? entityType = freezed,Object? entityId = freezed,Object? ipAddress = freezed,Object? actor = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,entityType: freezed == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String?,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as AuditActor?,
  ));
}
/// Create a copy of AuditEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuditActorCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $AuditActorCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuditEntry].
extension AuditEntryPatterns on AuditEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditEntry value)  $default,){
final _that = this;
switch (_that) {
case _AuditEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AuditEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String action,  String method,  String path,  int statusCode,  DateTime createdAt,  String? entityType,  String? entityId,  String? ipAddress,  AuditActor? actor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditEntry() when $default != null:
return $default(_that.id,_that.action,_that.method,_that.path,_that.statusCode,_that.createdAt,_that.entityType,_that.entityId,_that.ipAddress,_that.actor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String action,  String method,  String path,  int statusCode,  DateTime createdAt,  String? entityType,  String? entityId,  String? ipAddress,  AuditActor? actor)  $default,) {final _that = this;
switch (_that) {
case _AuditEntry():
return $default(_that.id,_that.action,_that.method,_that.path,_that.statusCode,_that.createdAt,_that.entityType,_that.entityId,_that.ipAddress,_that.actor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String action,  String method,  String path,  int statusCode,  DateTime createdAt,  String? entityType,  String? entityId,  String? ipAddress,  AuditActor? actor)?  $default,) {final _that = this;
switch (_that) {
case _AuditEntry() when $default != null:
return $default(_that.id,_that.action,_that.method,_that.path,_that.statusCode,_that.createdAt,_that.entityType,_that.entityId,_that.ipAddress,_that.actor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditEntry extends AuditEntry {
  const _AuditEntry({required this.id, required this.action, required this.method, required this.path, required this.statusCode, required this.createdAt, this.entityType, this.entityId, this.ipAddress, this.actor}): super._();
  factory _AuditEntry.fromJson(Map<String, dynamic> json) => _$AuditEntryFromJson(json);

@override final  String id;
@override final  String action;
@override final  String method;
@override final  String path;
@override final  int statusCode;
@override final  DateTime createdAt;
@override final  String? entityType;
@override final  String? entityId;
@override final  String? ipAddress;
@override final  AuditActor? actor;

/// Create a copy of AuditEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditEntryCopyWith<_AuditEntry> get copyWith => __$AuditEntryCopyWithImpl<_AuditEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.method, method) || other.method == method)&&(identical(other.path, path) || other.path == path)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.actor, actor) || other.actor == actor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,method,path,statusCode,createdAt,entityType,entityId,ipAddress,actor);

@override
String toString() {
  return 'AuditEntry(id: $id, action: $action, method: $method, path: $path, statusCode: $statusCode, createdAt: $createdAt, entityType: $entityType, entityId: $entityId, ipAddress: $ipAddress, actor: $actor)';
}


}

/// @nodoc
abstract mixin class _$AuditEntryCopyWith<$Res> implements $AuditEntryCopyWith<$Res> {
  factory _$AuditEntryCopyWith(_AuditEntry value, $Res Function(_AuditEntry) _then) = __$AuditEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String action, String method, String path, int statusCode, DateTime createdAt, String? entityType, String? entityId, String? ipAddress, AuditActor? actor
});


@override $AuditActorCopyWith<$Res>? get actor;

}
/// @nodoc
class __$AuditEntryCopyWithImpl<$Res>
    implements _$AuditEntryCopyWith<$Res> {
  __$AuditEntryCopyWithImpl(this._self, this._then);

  final _AuditEntry _self;
  final $Res Function(_AuditEntry) _then;

/// Create a copy of AuditEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? action = null,Object? method = null,Object? path = null,Object? statusCode = null,Object? createdAt = null,Object? entityType = freezed,Object? entityId = freezed,Object? ipAddress = freezed,Object? actor = freezed,}) {
  return _then(_AuditEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,entityType: freezed == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String?,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as AuditActor?,
  ));
}

/// Create a copy of AuditEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuditActorCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $AuditActorCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}
}


/// @nodoc
mixin _$AuditDetail {

 String get id; String get action; String get method; String get path; int get statusCode; DateTime get createdAt; String? get entityType; String? get entityId; String? get ipAddress; String? get userAgent; AuditActor? get actor; Object? get before; Object? get after; Object? get meta;
/// Create a copy of AuditDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditDetailCopyWith<AuditDetail> get copyWith => _$AuditDetailCopyWithImpl<AuditDetail>(this as AuditDetail, _$identity);

  /// Serializes this AuditDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.method, method) || other.method == method)&&(identical(other.path, path) || other.path == path)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.actor, actor) || other.actor == actor)&&const DeepCollectionEquality().equals(other.before, before)&&const DeepCollectionEquality().equals(other.after, after)&&const DeepCollectionEquality().equals(other.meta, meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,method,path,statusCode,createdAt,entityType,entityId,ipAddress,userAgent,actor,const DeepCollectionEquality().hash(before),const DeepCollectionEquality().hash(after),const DeepCollectionEquality().hash(meta));

@override
String toString() {
  return 'AuditDetail(id: $id, action: $action, method: $method, path: $path, statusCode: $statusCode, createdAt: $createdAt, entityType: $entityType, entityId: $entityId, ipAddress: $ipAddress, userAgent: $userAgent, actor: $actor, before: $before, after: $after, meta: $meta)';
}


}

/// @nodoc
abstract mixin class $AuditDetailCopyWith<$Res>  {
  factory $AuditDetailCopyWith(AuditDetail value, $Res Function(AuditDetail) _then) = _$AuditDetailCopyWithImpl;
@useResult
$Res call({
 String id, String action, String method, String path, int statusCode, DateTime createdAt, String? entityType, String? entityId, String? ipAddress, String? userAgent, AuditActor? actor, Object? before, Object? after, Object? meta
});


$AuditActorCopyWith<$Res>? get actor;

}
/// @nodoc
class _$AuditDetailCopyWithImpl<$Res>
    implements $AuditDetailCopyWith<$Res> {
  _$AuditDetailCopyWithImpl(this._self, this._then);

  final AuditDetail _self;
  final $Res Function(AuditDetail) _then;

/// Create a copy of AuditDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? action = null,Object? method = null,Object? path = null,Object? statusCode = null,Object? createdAt = null,Object? entityType = freezed,Object? entityId = freezed,Object? ipAddress = freezed,Object? userAgent = freezed,Object? actor = freezed,Object? before = freezed,Object? after = freezed,Object? meta = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,entityType: freezed == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String?,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as AuditActor?,before: freezed == before ? _self.before : before ,after: freezed == after ? _self.after : after ,meta: freezed == meta ? _self.meta : meta ,
  ));
}
/// Create a copy of AuditDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuditActorCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $AuditActorCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuditDetail].
extension AuditDetailPatterns on AuditDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditDetail value)  $default,){
final _that = this;
switch (_that) {
case _AuditDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditDetail value)?  $default,){
final _that = this;
switch (_that) {
case _AuditDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String action,  String method,  String path,  int statusCode,  DateTime createdAt,  String? entityType,  String? entityId,  String? ipAddress,  String? userAgent,  AuditActor? actor,  Object? before,  Object? after,  Object? meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditDetail() when $default != null:
return $default(_that.id,_that.action,_that.method,_that.path,_that.statusCode,_that.createdAt,_that.entityType,_that.entityId,_that.ipAddress,_that.userAgent,_that.actor,_that.before,_that.after,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String action,  String method,  String path,  int statusCode,  DateTime createdAt,  String? entityType,  String? entityId,  String? ipAddress,  String? userAgent,  AuditActor? actor,  Object? before,  Object? after,  Object? meta)  $default,) {final _that = this;
switch (_that) {
case _AuditDetail():
return $default(_that.id,_that.action,_that.method,_that.path,_that.statusCode,_that.createdAt,_that.entityType,_that.entityId,_that.ipAddress,_that.userAgent,_that.actor,_that.before,_that.after,_that.meta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String action,  String method,  String path,  int statusCode,  DateTime createdAt,  String? entityType,  String? entityId,  String? ipAddress,  String? userAgent,  AuditActor? actor,  Object? before,  Object? after,  Object? meta)?  $default,) {final _that = this;
switch (_that) {
case _AuditDetail() when $default != null:
return $default(_that.id,_that.action,_that.method,_that.path,_that.statusCode,_that.createdAt,_that.entityType,_that.entityId,_that.ipAddress,_that.userAgent,_that.actor,_that.before,_that.after,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditDetail implements AuditDetail {
  const _AuditDetail({required this.id, required this.action, required this.method, required this.path, required this.statusCode, required this.createdAt, this.entityType, this.entityId, this.ipAddress, this.userAgent, this.actor, this.before, this.after, this.meta});
  factory _AuditDetail.fromJson(Map<String, dynamic> json) => _$AuditDetailFromJson(json);

@override final  String id;
@override final  String action;
@override final  String method;
@override final  String path;
@override final  int statusCode;
@override final  DateTime createdAt;
@override final  String? entityType;
@override final  String? entityId;
@override final  String? ipAddress;
@override final  String? userAgent;
@override final  AuditActor? actor;
@override final  Object? before;
@override final  Object? after;
@override final  Object? meta;

/// Create a copy of AuditDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditDetailCopyWith<_AuditDetail> get copyWith => __$AuditDetailCopyWithImpl<_AuditDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.method, method) || other.method == method)&&(identical(other.path, path) || other.path == path)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.actor, actor) || other.actor == actor)&&const DeepCollectionEquality().equals(other.before, before)&&const DeepCollectionEquality().equals(other.after, after)&&const DeepCollectionEquality().equals(other.meta, meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,method,path,statusCode,createdAt,entityType,entityId,ipAddress,userAgent,actor,const DeepCollectionEquality().hash(before),const DeepCollectionEquality().hash(after),const DeepCollectionEquality().hash(meta));

@override
String toString() {
  return 'AuditDetail(id: $id, action: $action, method: $method, path: $path, statusCode: $statusCode, createdAt: $createdAt, entityType: $entityType, entityId: $entityId, ipAddress: $ipAddress, userAgent: $userAgent, actor: $actor, before: $before, after: $after, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$AuditDetailCopyWith<$Res> implements $AuditDetailCopyWith<$Res> {
  factory _$AuditDetailCopyWith(_AuditDetail value, $Res Function(_AuditDetail) _then) = __$AuditDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String action, String method, String path, int statusCode, DateTime createdAt, String? entityType, String? entityId, String? ipAddress, String? userAgent, AuditActor? actor, Object? before, Object? after, Object? meta
});


@override $AuditActorCopyWith<$Res>? get actor;

}
/// @nodoc
class __$AuditDetailCopyWithImpl<$Res>
    implements _$AuditDetailCopyWith<$Res> {
  __$AuditDetailCopyWithImpl(this._self, this._then);

  final _AuditDetail _self;
  final $Res Function(_AuditDetail) _then;

/// Create a copy of AuditDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? action = null,Object? method = null,Object? path = null,Object? statusCode = null,Object? createdAt = null,Object? entityType = freezed,Object? entityId = freezed,Object? ipAddress = freezed,Object? userAgent = freezed,Object? actor = freezed,Object? before = freezed,Object? after = freezed,Object? meta = freezed,}) {
  return _then(_AuditDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,entityType: freezed == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String?,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as AuditActor?,before: freezed == before ? _self.before : before ,after: freezed == after ? _self.after : after ,meta: freezed == meta ? _self.meta : meta ,
  ));
}

/// Create a copy of AuditDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuditActorCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $AuditActorCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}
}

// dart format on
