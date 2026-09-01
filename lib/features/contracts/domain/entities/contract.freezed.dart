// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contract.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Contract {

 String get id; String get title; ContractCategory get category; ContractStatus get status; DateTime get createdAt; DateTime get updatedAt; List<String> get parties; Map<String, String> get fieldValues; String get templateId; String get generatedContent;
/// Create a copy of Contract
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContractCopyWith<Contract> get copyWith => _$ContractCopyWithImpl<Contract>(this as Contract, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Contract&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.parties, parties)&&const DeepCollectionEquality().equals(other.fieldValues, fieldValues)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.generatedContent, generatedContent) || other.generatedContent == generatedContent));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,category,status,createdAt,updatedAt,const DeepCollectionEquality().hash(parties),const DeepCollectionEquality().hash(fieldValues),templateId,generatedContent);

@override
String toString() {
  return 'Contract(id: $id, title: $title, category: $category, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, parties: $parties, fieldValues: $fieldValues, templateId: $templateId, generatedContent: $generatedContent)';
}


}

/// @nodoc
abstract mixin class $ContractCopyWith<$Res>  {
  factory $ContractCopyWith(Contract value, $Res Function(Contract) _then) = _$ContractCopyWithImpl;
@useResult
$Res call({
 String id, String title, ContractCategory category, ContractStatus status, DateTime createdAt, DateTime updatedAt, List<String> parties, Map<String, String> fieldValues, String templateId, String generatedContent
});




}
/// @nodoc
class _$ContractCopyWithImpl<$Res>
    implements $ContractCopyWith<$Res> {
  _$ContractCopyWithImpl(this._self, this._then);

  final Contract _self;
  final $Res Function(Contract) _then;

/// Create a copy of Contract
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? category = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? parties = null,Object? fieldValues = null,Object? templateId = null,Object? generatedContent = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ContractCategory,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContractStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,parties: null == parties ? _self.parties : parties // ignore: cast_nullable_to_non_nullable
as List<String>,fieldValues: null == fieldValues ? _self.fieldValues : fieldValues // ignore: cast_nullable_to_non_nullable
as Map<String, String>,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,generatedContent: null == generatedContent ? _self.generatedContent : generatedContent // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Contract].
extension ContractPatterns on Contract {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Contract value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Contract() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Contract value)  $default,){
final _that = this;
switch (_that) {
case _Contract():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Contract value)?  $default,){
final _that = this;
switch (_that) {
case _Contract() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  ContractCategory category,  ContractStatus status,  DateTime createdAt,  DateTime updatedAt,  List<String> parties,  Map<String, String> fieldValues,  String templateId,  String generatedContent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Contract() when $default != null:
return $default(_that.id,_that.title,_that.category,_that.status,_that.createdAt,_that.updatedAt,_that.parties,_that.fieldValues,_that.templateId,_that.generatedContent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  ContractCategory category,  ContractStatus status,  DateTime createdAt,  DateTime updatedAt,  List<String> parties,  Map<String, String> fieldValues,  String templateId,  String generatedContent)  $default,) {final _that = this;
switch (_that) {
case _Contract():
return $default(_that.id,_that.title,_that.category,_that.status,_that.createdAt,_that.updatedAt,_that.parties,_that.fieldValues,_that.templateId,_that.generatedContent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  ContractCategory category,  ContractStatus status,  DateTime createdAt,  DateTime updatedAt,  List<String> parties,  Map<String, String> fieldValues,  String templateId,  String generatedContent)?  $default,) {final _that = this;
switch (_that) {
case _Contract() when $default != null:
return $default(_that.id,_that.title,_that.category,_that.status,_that.createdAt,_that.updatedAt,_that.parties,_that.fieldValues,_that.templateId,_that.generatedContent);case _:
  return null;

}
}

}

/// @nodoc


class _Contract implements Contract {
  const _Contract({required this.id, required this.title, required this.category, required this.status, required this.createdAt, required this.updatedAt, required final  List<String> parties, required final  Map<String, String> fieldValues, required this.templateId, required this.generatedContent}): _parties = parties,_fieldValues = fieldValues;
  

@override final  String id;
@override final  String title;
@override final  ContractCategory category;
@override final  ContractStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<String> _parties;
@override List<String> get parties {
  if (_parties is EqualUnmodifiableListView) return _parties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parties);
}

 final  Map<String, String> _fieldValues;
@override Map<String, String> get fieldValues {
  if (_fieldValues is EqualUnmodifiableMapView) return _fieldValues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldValues);
}

@override final  String templateId;
@override final  String generatedContent;

/// Create a copy of Contract
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContractCopyWith<_Contract> get copyWith => __$ContractCopyWithImpl<_Contract>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Contract&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._parties, _parties)&&const DeepCollectionEquality().equals(other._fieldValues, _fieldValues)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.generatedContent, generatedContent) || other.generatedContent == generatedContent));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,category,status,createdAt,updatedAt,const DeepCollectionEquality().hash(_parties),const DeepCollectionEquality().hash(_fieldValues),templateId,generatedContent);

@override
String toString() {
  return 'Contract(id: $id, title: $title, category: $category, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, parties: $parties, fieldValues: $fieldValues, templateId: $templateId, generatedContent: $generatedContent)';
}


}

/// @nodoc
abstract mixin class _$ContractCopyWith<$Res> implements $ContractCopyWith<$Res> {
  factory _$ContractCopyWith(_Contract value, $Res Function(_Contract) _then) = __$ContractCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, ContractCategory category, ContractStatus status, DateTime createdAt, DateTime updatedAt, List<String> parties, Map<String, String> fieldValues, String templateId, String generatedContent
});




}
/// @nodoc
class __$ContractCopyWithImpl<$Res>
    implements _$ContractCopyWith<$Res> {
  __$ContractCopyWithImpl(this._self, this._then);

  final _Contract _self;
  final $Res Function(_Contract) _then;

/// Create a copy of Contract
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? category = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? parties = null,Object? fieldValues = null,Object? templateId = null,Object? generatedContent = null,}) {
  return _then(_Contract(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ContractCategory,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContractStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,parties: null == parties ? _self._parties : parties // ignore: cast_nullable_to_non_nullable
as List<String>,fieldValues: null == fieldValues ? _self._fieldValues : fieldValues // ignore: cast_nullable_to_non_nullable
as Map<String, String>,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,generatedContent: null == generatedContent ? _self.generatedContent : generatedContent // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
