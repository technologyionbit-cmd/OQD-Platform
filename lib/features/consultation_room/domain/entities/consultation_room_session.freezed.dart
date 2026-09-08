// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consultation_room_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConsultationRoomSession {

 String get consultationId; ConsultationType get type; SessionState get state; CallMetrics get metrics; int get reconnectAttempts;
/// Create a copy of ConsultationRoomSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsultationRoomSessionCopyWith<ConsultationRoomSession> get copyWith => _$ConsultationRoomSessionCopyWithImpl<ConsultationRoomSession>(this as ConsultationRoomSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsultationRoomSession&&(identical(other.consultationId, consultationId) || other.consultationId == consultationId)&&(identical(other.type, type) || other.type == type)&&(identical(other.state, state) || other.state == state)&&(identical(other.metrics, metrics) || other.metrics == metrics)&&(identical(other.reconnectAttempts, reconnectAttempts) || other.reconnectAttempts == reconnectAttempts));
}


@override
int get hashCode => Object.hash(runtimeType,consultationId,type,state,metrics,reconnectAttempts);

@override
String toString() {
  return 'ConsultationRoomSession(consultationId: $consultationId, type: $type, state: $state, metrics: $metrics, reconnectAttempts: $reconnectAttempts)';
}


}

/// @nodoc
abstract mixin class $ConsultationRoomSessionCopyWith<$Res>  {
  factory $ConsultationRoomSessionCopyWith(ConsultationRoomSession value, $Res Function(ConsultationRoomSession) _then) = _$ConsultationRoomSessionCopyWithImpl;
@useResult
$Res call({
 String consultationId, ConsultationType type, SessionState state, CallMetrics metrics, int reconnectAttempts
});


$CallMetricsCopyWith<$Res> get metrics;

}
/// @nodoc
class _$ConsultationRoomSessionCopyWithImpl<$Res>
    implements $ConsultationRoomSessionCopyWith<$Res> {
  _$ConsultationRoomSessionCopyWithImpl(this._self, this._then);

  final ConsultationRoomSession _self;
  final $Res Function(ConsultationRoomSession) _then;

/// Create a copy of ConsultationRoomSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? consultationId = null,Object? type = null,Object? state = null,Object? metrics = null,Object? reconnectAttempts = null,}) {
  return _then(_self.copyWith(
consultationId: null == consultationId ? _self.consultationId : consultationId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConsultationType,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as SessionState,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as CallMetrics,reconnectAttempts: null == reconnectAttempts ? _self.reconnectAttempts : reconnectAttempts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ConsultationRoomSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CallMetricsCopyWith<$Res> get metrics {
  
  return $CallMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConsultationRoomSession].
extension ConsultationRoomSessionPatterns on ConsultationRoomSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsultationRoomSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsultationRoomSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsultationRoomSession value)  $default,){
final _that = this;
switch (_that) {
case _ConsultationRoomSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsultationRoomSession value)?  $default,){
final _that = this;
switch (_that) {
case _ConsultationRoomSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String consultationId,  ConsultationType type,  SessionState state,  CallMetrics metrics,  int reconnectAttempts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsultationRoomSession() when $default != null:
return $default(_that.consultationId,_that.type,_that.state,_that.metrics,_that.reconnectAttempts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String consultationId,  ConsultationType type,  SessionState state,  CallMetrics metrics,  int reconnectAttempts)  $default,) {final _that = this;
switch (_that) {
case _ConsultationRoomSession():
return $default(_that.consultationId,_that.type,_that.state,_that.metrics,_that.reconnectAttempts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String consultationId,  ConsultationType type,  SessionState state,  CallMetrics metrics,  int reconnectAttempts)?  $default,) {final _that = this;
switch (_that) {
case _ConsultationRoomSession() when $default != null:
return $default(_that.consultationId,_that.type,_that.state,_that.metrics,_that.reconnectAttempts);case _:
  return null;

}
}

}

/// @nodoc


class _ConsultationRoomSession implements ConsultationRoomSession {
  const _ConsultationRoomSession({required this.consultationId, required this.type, required this.state, this.metrics = const CallMetrics(), this.reconnectAttempts = 0});
  

@override final  String consultationId;
@override final  ConsultationType type;
@override final  SessionState state;
@override@JsonKey() final  CallMetrics metrics;
@override@JsonKey() final  int reconnectAttempts;

/// Create a copy of ConsultationRoomSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsultationRoomSessionCopyWith<_ConsultationRoomSession> get copyWith => __$ConsultationRoomSessionCopyWithImpl<_ConsultationRoomSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsultationRoomSession&&(identical(other.consultationId, consultationId) || other.consultationId == consultationId)&&(identical(other.type, type) || other.type == type)&&(identical(other.state, state) || other.state == state)&&(identical(other.metrics, metrics) || other.metrics == metrics)&&(identical(other.reconnectAttempts, reconnectAttempts) || other.reconnectAttempts == reconnectAttempts));
}


@override
int get hashCode => Object.hash(runtimeType,consultationId,type,state,metrics,reconnectAttempts);

@override
String toString() {
  return 'ConsultationRoomSession(consultationId: $consultationId, type: $type, state: $state, metrics: $metrics, reconnectAttempts: $reconnectAttempts)';
}


}

/// @nodoc
abstract mixin class _$ConsultationRoomSessionCopyWith<$Res> implements $ConsultationRoomSessionCopyWith<$Res> {
  factory _$ConsultationRoomSessionCopyWith(_ConsultationRoomSession value, $Res Function(_ConsultationRoomSession) _then) = __$ConsultationRoomSessionCopyWithImpl;
@override @useResult
$Res call({
 String consultationId, ConsultationType type, SessionState state, CallMetrics metrics, int reconnectAttempts
});


@override $CallMetricsCopyWith<$Res> get metrics;

}
/// @nodoc
class __$ConsultationRoomSessionCopyWithImpl<$Res>
    implements _$ConsultationRoomSessionCopyWith<$Res> {
  __$ConsultationRoomSessionCopyWithImpl(this._self, this._then);

  final _ConsultationRoomSession _self;
  final $Res Function(_ConsultationRoomSession) _then;

/// Create a copy of ConsultationRoomSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? consultationId = null,Object? type = null,Object? state = null,Object? metrics = null,Object? reconnectAttempts = null,}) {
  return _then(_ConsultationRoomSession(
consultationId: null == consultationId ? _self.consultationId : consultationId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConsultationType,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as SessionState,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as CallMetrics,reconnectAttempts: null == reconnectAttempts ? _self.reconnectAttempts : reconnectAttempts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ConsultationRoomSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CallMetricsCopyWith<$Res> get metrics {
  
  return $CallMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}
}

// dart format on
