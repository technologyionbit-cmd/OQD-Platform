// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CallMetrics {

 int get durationSeconds; bool get isMuted; bool get isCameraOn; bool get isSpeakerOn;
/// Create a copy of CallMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallMetricsCopyWith<CallMetrics> get copyWith => _$CallMetricsCopyWithImpl<CallMetrics>(this as CallMetrics, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallMetrics&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isCameraOn, isCameraOn) || other.isCameraOn == isCameraOn)&&(identical(other.isSpeakerOn, isSpeakerOn) || other.isSpeakerOn == isSpeakerOn));
}


@override
int get hashCode => Object.hash(runtimeType,durationSeconds,isMuted,isCameraOn,isSpeakerOn);

@override
String toString() {
  return 'CallMetrics(durationSeconds: $durationSeconds, isMuted: $isMuted, isCameraOn: $isCameraOn, isSpeakerOn: $isSpeakerOn)';
}


}

/// @nodoc
abstract mixin class $CallMetricsCopyWith<$Res>  {
  factory $CallMetricsCopyWith(CallMetrics value, $Res Function(CallMetrics) _then) = _$CallMetricsCopyWithImpl;
@useResult
$Res call({
 int durationSeconds, bool isMuted, bool isCameraOn, bool isSpeakerOn
});




}
/// @nodoc
class _$CallMetricsCopyWithImpl<$Res>
    implements $CallMetricsCopyWith<$Res> {
  _$CallMetricsCopyWithImpl(this._self, this._then);

  final CallMetrics _self;
  final $Res Function(CallMetrics) _then;

/// Create a copy of CallMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? durationSeconds = null,Object? isMuted = null,Object? isCameraOn = null,Object? isSpeakerOn = null,}) {
  return _then(_self.copyWith(
durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isCameraOn: null == isCameraOn ? _self.isCameraOn : isCameraOn // ignore: cast_nullable_to_non_nullable
as bool,isSpeakerOn: null == isSpeakerOn ? _self.isSpeakerOn : isSpeakerOn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CallMetrics].
extension CallMetricsPatterns on CallMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallMetrics value)  $default,){
final _that = this;
switch (_that) {
case _CallMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _CallMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int durationSeconds,  bool isMuted,  bool isCameraOn,  bool isSpeakerOn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallMetrics() when $default != null:
return $default(_that.durationSeconds,_that.isMuted,_that.isCameraOn,_that.isSpeakerOn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int durationSeconds,  bool isMuted,  bool isCameraOn,  bool isSpeakerOn)  $default,) {final _that = this;
switch (_that) {
case _CallMetrics():
return $default(_that.durationSeconds,_that.isMuted,_that.isCameraOn,_that.isSpeakerOn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int durationSeconds,  bool isMuted,  bool isCameraOn,  bool isSpeakerOn)?  $default,) {final _that = this;
switch (_that) {
case _CallMetrics() when $default != null:
return $default(_that.durationSeconds,_that.isMuted,_that.isCameraOn,_that.isSpeakerOn);case _:
  return null;

}
}

}

/// @nodoc


class _CallMetrics implements CallMetrics {
  const _CallMetrics({this.durationSeconds = 0, this.isMuted = false, this.isCameraOn = true, this.isSpeakerOn = true});
  

@override@JsonKey() final  int durationSeconds;
@override@JsonKey() final  bool isMuted;
@override@JsonKey() final  bool isCameraOn;
@override@JsonKey() final  bool isSpeakerOn;

/// Create a copy of CallMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallMetricsCopyWith<_CallMetrics> get copyWith => __$CallMetricsCopyWithImpl<_CallMetrics>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallMetrics&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isCameraOn, isCameraOn) || other.isCameraOn == isCameraOn)&&(identical(other.isSpeakerOn, isSpeakerOn) || other.isSpeakerOn == isSpeakerOn));
}


@override
int get hashCode => Object.hash(runtimeType,durationSeconds,isMuted,isCameraOn,isSpeakerOn);

@override
String toString() {
  return 'CallMetrics(durationSeconds: $durationSeconds, isMuted: $isMuted, isCameraOn: $isCameraOn, isSpeakerOn: $isSpeakerOn)';
}


}

/// @nodoc
abstract mixin class _$CallMetricsCopyWith<$Res> implements $CallMetricsCopyWith<$Res> {
  factory _$CallMetricsCopyWith(_CallMetrics value, $Res Function(_CallMetrics) _then) = __$CallMetricsCopyWithImpl;
@override @useResult
$Res call({
 int durationSeconds, bool isMuted, bool isCameraOn, bool isSpeakerOn
});




}
/// @nodoc
class __$CallMetricsCopyWithImpl<$Res>
    implements _$CallMetricsCopyWith<$Res> {
  __$CallMetricsCopyWithImpl(this._self, this._then);

  final _CallMetrics _self;
  final $Res Function(_CallMetrics) _then;

/// Create a copy of CallMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? durationSeconds = null,Object? isMuted = null,Object? isCameraOn = null,Object? isSpeakerOn = null,}) {
  return _then(_CallMetrics(
durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isCameraOn: null == isCameraOn ? _self.isCameraOn : isCameraOn // ignore: cast_nullable_to_non_nullable
as bool,isSpeakerOn: null == isSpeakerOn ? _self.isSpeakerOn : isSpeakerOn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
