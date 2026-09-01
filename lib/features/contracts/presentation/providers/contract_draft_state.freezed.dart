// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contract_draft_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContractDraftState {

 ContractTemplate? get template; Map<String, String> get fieldValues; Map<String, String> get errors;/// Set only when editing an already-saved draft — `save`/`generate`
/// then update that contract instead of creating a new one.
 String? get editingContractId;
/// Create a copy of ContractDraftState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContractDraftStateCopyWith<ContractDraftState> get copyWith => _$ContractDraftStateCopyWithImpl<ContractDraftState>(this as ContractDraftState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContractDraftState&&(identical(other.template, template) || other.template == template)&&const DeepCollectionEquality().equals(other.fieldValues, fieldValues)&&const DeepCollectionEquality().equals(other.errors, errors)&&(identical(other.editingContractId, editingContractId) || other.editingContractId == editingContractId));
}


@override
int get hashCode => Object.hash(runtimeType,template,const DeepCollectionEquality().hash(fieldValues),const DeepCollectionEquality().hash(errors),editingContractId);

@override
String toString() {
  return 'ContractDraftState(template: $template, fieldValues: $fieldValues, errors: $errors, editingContractId: $editingContractId)';
}


}

/// @nodoc
abstract mixin class $ContractDraftStateCopyWith<$Res>  {
  factory $ContractDraftStateCopyWith(ContractDraftState value, $Res Function(ContractDraftState) _then) = _$ContractDraftStateCopyWithImpl;
@useResult
$Res call({
 ContractTemplate? template, Map<String, String> fieldValues, Map<String, String> errors, String? editingContractId
});


$ContractTemplateCopyWith<$Res>? get template;

}
/// @nodoc
class _$ContractDraftStateCopyWithImpl<$Res>
    implements $ContractDraftStateCopyWith<$Res> {
  _$ContractDraftStateCopyWithImpl(this._self, this._then);

  final ContractDraftState _self;
  final $Res Function(ContractDraftState) _then;

/// Create a copy of ContractDraftState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? template = freezed,Object? fieldValues = null,Object? errors = null,Object? editingContractId = freezed,}) {
  return _then(_self.copyWith(
template: freezed == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as ContractTemplate?,fieldValues: null == fieldValues ? _self.fieldValues : fieldValues // ignore: cast_nullable_to_non_nullable
as Map<String, String>,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,editingContractId: freezed == editingContractId ? _self.editingContractId : editingContractId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ContractDraftState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContractTemplateCopyWith<$Res>? get template {
    if (_self.template == null) {
    return null;
  }

  return $ContractTemplateCopyWith<$Res>(_self.template!, (value) {
    return _then(_self.copyWith(template: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContractDraftState].
extension ContractDraftStatePatterns on ContractDraftState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContractDraftState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContractDraftState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContractDraftState value)  $default,){
final _that = this;
switch (_that) {
case _ContractDraftState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContractDraftState value)?  $default,){
final _that = this;
switch (_that) {
case _ContractDraftState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContractTemplate? template,  Map<String, String> fieldValues,  Map<String, String> errors,  String? editingContractId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContractDraftState() when $default != null:
return $default(_that.template,_that.fieldValues,_that.errors,_that.editingContractId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContractTemplate? template,  Map<String, String> fieldValues,  Map<String, String> errors,  String? editingContractId)  $default,) {final _that = this;
switch (_that) {
case _ContractDraftState():
return $default(_that.template,_that.fieldValues,_that.errors,_that.editingContractId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContractTemplate? template,  Map<String, String> fieldValues,  Map<String, String> errors,  String? editingContractId)?  $default,) {final _that = this;
switch (_that) {
case _ContractDraftState() when $default != null:
return $default(_that.template,_that.fieldValues,_that.errors,_that.editingContractId);case _:
  return null;

}
}

}

/// @nodoc


class _ContractDraftState implements ContractDraftState {
  const _ContractDraftState({this.template, final  Map<String, String> fieldValues = const <String, String>{}, final  Map<String, String> errors = const <String, String>{}, this.editingContractId}): _fieldValues = fieldValues,_errors = errors;
  

@override final  ContractTemplate? template;
 final  Map<String, String> _fieldValues;
@override@JsonKey() Map<String, String> get fieldValues {
  if (_fieldValues is EqualUnmodifiableMapView) return _fieldValues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldValues);
}

 final  Map<String, String> _errors;
@override@JsonKey() Map<String, String> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}

/// Set only when editing an already-saved draft — `save`/`generate`
/// then update that contract instead of creating a new one.
@override final  String? editingContractId;

/// Create a copy of ContractDraftState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContractDraftStateCopyWith<_ContractDraftState> get copyWith => __$ContractDraftStateCopyWithImpl<_ContractDraftState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContractDraftState&&(identical(other.template, template) || other.template == template)&&const DeepCollectionEquality().equals(other._fieldValues, _fieldValues)&&const DeepCollectionEquality().equals(other._errors, _errors)&&(identical(other.editingContractId, editingContractId) || other.editingContractId == editingContractId));
}


@override
int get hashCode => Object.hash(runtimeType,template,const DeepCollectionEquality().hash(_fieldValues),const DeepCollectionEquality().hash(_errors),editingContractId);

@override
String toString() {
  return 'ContractDraftState(template: $template, fieldValues: $fieldValues, errors: $errors, editingContractId: $editingContractId)';
}


}

/// @nodoc
abstract mixin class _$ContractDraftStateCopyWith<$Res> implements $ContractDraftStateCopyWith<$Res> {
  factory _$ContractDraftStateCopyWith(_ContractDraftState value, $Res Function(_ContractDraftState) _then) = __$ContractDraftStateCopyWithImpl;
@override @useResult
$Res call({
 ContractTemplate? template, Map<String, String> fieldValues, Map<String, String> errors, String? editingContractId
});


@override $ContractTemplateCopyWith<$Res>? get template;

}
/// @nodoc
class __$ContractDraftStateCopyWithImpl<$Res>
    implements _$ContractDraftStateCopyWith<$Res> {
  __$ContractDraftStateCopyWithImpl(this._self, this._then);

  final _ContractDraftState _self;
  final $Res Function(_ContractDraftState) _then;

/// Create a copy of ContractDraftState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? template = freezed,Object? fieldValues = null,Object? errors = null,Object? editingContractId = freezed,}) {
  return _then(_ContractDraftState(
template: freezed == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as ContractTemplate?,fieldValues: null == fieldValues ? _self._fieldValues : fieldValues // ignore: cast_nullable_to_non_nullable
as Map<String, String>,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,editingContractId: freezed == editingContractId ? _self.editingContractId : editingContractId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ContractDraftState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContractTemplateCopyWith<$Res>? get template {
    if (_self.template == null) {
    return null;
  }

  return $ContractTemplateCopyWith<$Res>(_self.template!, (value) {
    return _then(_self.copyWith(template: value));
  });
}
}

// dart format on
