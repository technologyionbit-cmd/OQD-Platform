// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contract_field.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContractField {

 String get id; String get label; ContractFieldType get type; bool get isRequired; List<String> get options; String? get hint;
/// Create a copy of ContractField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContractFieldCopyWith<ContractField> get copyWith => _$ContractFieldCopyWithImpl<ContractField>(this as ContractField, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContractField&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.type, type) || other.type == type)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&const DeepCollectionEquality().equals(other.options, options)&&(identical(other.hint, hint) || other.hint == hint));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,type,isRequired,const DeepCollectionEquality().hash(options),hint);

@override
String toString() {
  return 'ContractField(id: $id, label: $label, type: $type, isRequired: $isRequired, options: $options, hint: $hint)';
}


}

/// @nodoc
abstract mixin class $ContractFieldCopyWith<$Res>  {
  factory $ContractFieldCopyWith(ContractField value, $Res Function(ContractField) _then) = _$ContractFieldCopyWithImpl;
@useResult
$Res call({
 String id, String label, ContractFieldType type, bool isRequired, List<String> options, String? hint
});




}
/// @nodoc
class _$ContractFieldCopyWithImpl<$Res>
    implements $ContractFieldCopyWith<$Res> {
  _$ContractFieldCopyWithImpl(this._self, this._then);

  final ContractField _self;
  final $Res Function(ContractField) _then;

/// Create a copy of ContractField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? type = null,Object? isRequired = null,Object? options = null,Object? hint = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContractFieldType,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<String>,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContractField].
extension ContractFieldPatterns on ContractField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContractField value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContractField() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContractField value)  $default,){
final _that = this;
switch (_that) {
case _ContractField():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContractField value)?  $default,){
final _that = this;
switch (_that) {
case _ContractField() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  ContractFieldType type,  bool isRequired,  List<String> options,  String? hint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContractField() when $default != null:
return $default(_that.id,_that.label,_that.type,_that.isRequired,_that.options,_that.hint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  ContractFieldType type,  bool isRequired,  List<String> options,  String? hint)  $default,) {final _that = this;
switch (_that) {
case _ContractField():
return $default(_that.id,_that.label,_that.type,_that.isRequired,_that.options,_that.hint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  ContractFieldType type,  bool isRequired,  List<String> options,  String? hint)?  $default,) {final _that = this;
switch (_that) {
case _ContractField() when $default != null:
return $default(_that.id,_that.label,_that.type,_that.isRequired,_that.options,_that.hint);case _:
  return null;

}
}

}

/// @nodoc


class _ContractField implements ContractField {
  const _ContractField({required this.id, required this.label, required this.type, required this.isRequired, final  List<String> options = const <String>[], this.hint}): _options = options;
  

@override final  String id;
@override final  String label;
@override final  ContractFieldType type;
@override final  bool isRequired;
 final  List<String> _options;
@override@JsonKey() List<String> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

@override final  String? hint;

/// Create a copy of ContractField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContractFieldCopyWith<_ContractField> get copyWith => __$ContractFieldCopyWithImpl<_ContractField>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContractField&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.type, type) || other.type == type)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.hint, hint) || other.hint == hint));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,type,isRequired,const DeepCollectionEquality().hash(_options),hint);

@override
String toString() {
  return 'ContractField(id: $id, label: $label, type: $type, isRequired: $isRequired, options: $options, hint: $hint)';
}


}

/// @nodoc
abstract mixin class _$ContractFieldCopyWith<$Res> implements $ContractFieldCopyWith<$Res> {
  factory _$ContractFieldCopyWith(_ContractField value, $Res Function(_ContractField) _then) = __$ContractFieldCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, ContractFieldType type, bool isRequired, List<String> options, String? hint
});




}
/// @nodoc
class __$ContractFieldCopyWithImpl<$Res>
    implements _$ContractFieldCopyWith<$Res> {
  __$ContractFieldCopyWithImpl(this._self, this._then);

  final _ContractField _self;
  final $Res Function(_ContractField) _then;

/// Create a copy of ContractField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? type = null,Object? isRequired = null,Object? options = null,Object? hint = freezed,}) {
  return _then(_ContractField(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContractFieldType,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<String>,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
