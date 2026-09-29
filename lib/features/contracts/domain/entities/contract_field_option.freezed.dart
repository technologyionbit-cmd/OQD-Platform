// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contract_field_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContractFieldOption {

 String get value; String get label;
/// Create a copy of ContractFieldOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContractFieldOptionCopyWith<ContractFieldOption> get copyWith => _$ContractFieldOptionCopyWithImpl<ContractFieldOption>(this as ContractFieldOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContractFieldOption&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,value,label);

@override
String toString() {
  return 'ContractFieldOption(value: $value, label: $label)';
}


}

/// @nodoc
abstract mixin class $ContractFieldOptionCopyWith<$Res>  {
  factory $ContractFieldOptionCopyWith(ContractFieldOption value, $Res Function(ContractFieldOption) _then) = _$ContractFieldOptionCopyWithImpl;
@useResult
$Res call({
 String value, String label
});




}
/// @nodoc
class _$ContractFieldOptionCopyWithImpl<$Res>
    implements $ContractFieldOptionCopyWith<$Res> {
  _$ContractFieldOptionCopyWithImpl(this._self, this._then);

  final ContractFieldOption _self;
  final $Res Function(ContractFieldOption) _then;

/// Create a copy of ContractFieldOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? label = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ContractFieldOption].
extension ContractFieldOptionPatterns on ContractFieldOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContractFieldOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContractFieldOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContractFieldOption value)  $default,){
final _that = this;
switch (_that) {
case _ContractFieldOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContractFieldOption value)?  $default,){
final _that = this;
switch (_that) {
case _ContractFieldOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContractFieldOption() when $default != null:
return $default(_that.value,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String label)  $default,) {final _that = this;
switch (_that) {
case _ContractFieldOption():
return $default(_that.value,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String label)?  $default,) {final _that = this;
switch (_that) {
case _ContractFieldOption() when $default != null:
return $default(_that.value,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _ContractFieldOption implements ContractFieldOption {
  const _ContractFieldOption({required this.value, required this.label});
  

@override final  String value;
@override final  String label;

/// Create a copy of ContractFieldOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContractFieldOptionCopyWith<_ContractFieldOption> get copyWith => __$ContractFieldOptionCopyWithImpl<_ContractFieldOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContractFieldOption&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,value,label);

@override
String toString() {
  return 'ContractFieldOption(value: $value, label: $label)';
}


}

/// @nodoc
abstract mixin class _$ContractFieldOptionCopyWith<$Res> implements $ContractFieldOptionCopyWith<$Res> {
  factory _$ContractFieldOptionCopyWith(_ContractFieldOption value, $Res Function(_ContractFieldOption) _then) = __$ContractFieldOptionCopyWithImpl;
@override @useResult
$Res call({
 String value, String label
});




}
/// @nodoc
class __$ContractFieldOptionCopyWithImpl<$Res>
    implements _$ContractFieldOptionCopyWith<$Res> {
  __$ContractFieldOptionCopyWithImpl(this._self, this._then);

  final _ContractFieldOption _self;
  final $Res Function(_ContractFieldOption) _then;

/// Create a copy of ContractFieldOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? label = null,}) {
  return _then(_ContractFieldOption(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
