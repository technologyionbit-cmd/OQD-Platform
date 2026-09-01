// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contract_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContractTemplate {

 String get id; ContractCategory get category; String get title; List<ContractField> get fields;
/// Create a copy of ContractTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContractTemplateCopyWith<ContractTemplate> get copyWith => _$ContractTemplateCopyWithImpl<ContractTemplate>(this as ContractTemplate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContractTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.fields, fields));
}


@override
int get hashCode => Object.hash(runtimeType,id,category,title,const DeepCollectionEquality().hash(fields));

@override
String toString() {
  return 'ContractTemplate(id: $id, category: $category, title: $title, fields: $fields)';
}


}

/// @nodoc
abstract mixin class $ContractTemplateCopyWith<$Res>  {
  factory $ContractTemplateCopyWith(ContractTemplate value, $Res Function(ContractTemplate) _then) = _$ContractTemplateCopyWithImpl;
@useResult
$Res call({
 String id, ContractCategory category, String title, List<ContractField> fields
});




}
/// @nodoc
class _$ContractTemplateCopyWithImpl<$Res>
    implements $ContractTemplateCopyWith<$Res> {
  _$ContractTemplateCopyWithImpl(this._self, this._then);

  final ContractTemplate _self;
  final $Res Function(ContractTemplate) _then;

/// Create a copy of ContractTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category = null,Object? title = null,Object? fields = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ContractCategory,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<ContractField>,
  ));
}

}


/// Adds pattern-matching-related methods to [ContractTemplate].
extension ContractTemplatePatterns on ContractTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContractTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContractTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContractTemplate value)  $default,){
final _that = this;
switch (_that) {
case _ContractTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContractTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _ContractTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ContractCategory category,  String title,  List<ContractField> fields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContractTemplate() when $default != null:
return $default(_that.id,_that.category,_that.title,_that.fields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ContractCategory category,  String title,  List<ContractField> fields)  $default,) {final _that = this;
switch (_that) {
case _ContractTemplate():
return $default(_that.id,_that.category,_that.title,_that.fields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ContractCategory category,  String title,  List<ContractField> fields)?  $default,) {final _that = this;
switch (_that) {
case _ContractTemplate() when $default != null:
return $default(_that.id,_that.category,_that.title,_that.fields);case _:
  return null;

}
}

}

/// @nodoc


class _ContractTemplate implements ContractTemplate {
  const _ContractTemplate({required this.id, required this.category, required this.title, required final  List<ContractField> fields}): _fields = fields;
  

@override final  String id;
@override final  ContractCategory category;
@override final  String title;
 final  List<ContractField> _fields;
@override List<ContractField> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}


/// Create a copy of ContractTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContractTemplateCopyWith<_ContractTemplate> get copyWith => __$ContractTemplateCopyWithImpl<_ContractTemplate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContractTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._fields, _fields));
}


@override
int get hashCode => Object.hash(runtimeType,id,category,title,const DeepCollectionEquality().hash(_fields));

@override
String toString() {
  return 'ContractTemplate(id: $id, category: $category, title: $title, fields: $fields)';
}


}

/// @nodoc
abstract mixin class _$ContractTemplateCopyWith<$Res> implements $ContractTemplateCopyWith<$Res> {
  factory _$ContractTemplateCopyWith(_ContractTemplate value, $Res Function(_ContractTemplate) _then) = __$ContractTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, ContractCategory category, String title, List<ContractField> fields
});




}
/// @nodoc
class __$ContractTemplateCopyWithImpl<$Res>
    implements _$ContractTemplateCopyWith<$Res> {
  __$ContractTemplateCopyWithImpl(this._self, this._then);

  final _ContractTemplate _self;
  final $Res Function(_ContractTemplate) _then;

/// Create a copy of ContractTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category = null,Object? title = null,Object? fields = null,}) {
  return _then(_ContractTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ContractCategory,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<ContractField>,
  ));
}


}

// dart format on
