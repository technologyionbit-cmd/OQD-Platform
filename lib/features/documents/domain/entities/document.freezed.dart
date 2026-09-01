// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Document {

 String get id; String get title; DocumentSourceType get sourceType; DateTime get createdAt; String get sizeLabel;/// Set when this document is a generated contract — lets the vault
/// open the real contract details screen instead of faking a preview.
 String? get contractId;
/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentCopyWith<Document> get copyWith => _$DocumentCopyWithImpl<Document>(this as Document, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Document&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sizeLabel, sizeLabel) || other.sizeLabel == sizeLabel)&&(identical(other.contractId, contractId) || other.contractId == contractId));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,sourceType,createdAt,sizeLabel,contractId);

@override
String toString() {
  return 'Document(id: $id, title: $title, sourceType: $sourceType, createdAt: $createdAt, sizeLabel: $sizeLabel, contractId: $contractId)';
}


}

/// @nodoc
abstract mixin class $DocumentCopyWith<$Res>  {
  factory $DocumentCopyWith(Document value, $Res Function(Document) _then) = _$DocumentCopyWithImpl;
@useResult
$Res call({
 String id, String title, DocumentSourceType sourceType, DateTime createdAt, String sizeLabel, String? contractId
});




}
/// @nodoc
class _$DocumentCopyWithImpl<$Res>
    implements $DocumentCopyWith<$Res> {
  _$DocumentCopyWithImpl(this._self, this._then);

  final Document _self;
  final $Res Function(Document) _then;

/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? sourceType = null,Object? createdAt = null,Object? sizeLabel = null,Object? contractId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as DocumentSourceType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sizeLabel: null == sizeLabel ? _self.sizeLabel : sizeLabel // ignore: cast_nullable_to_non_nullable
as String,contractId: freezed == contractId ? _self.contractId : contractId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Document].
extension DocumentPatterns on Document {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Document value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Document() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Document value)  $default,){
final _that = this;
switch (_that) {
case _Document():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Document value)?  $default,){
final _that = this;
switch (_that) {
case _Document() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  DocumentSourceType sourceType,  DateTime createdAt,  String sizeLabel,  String? contractId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Document() when $default != null:
return $default(_that.id,_that.title,_that.sourceType,_that.createdAt,_that.sizeLabel,_that.contractId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  DocumentSourceType sourceType,  DateTime createdAt,  String sizeLabel,  String? contractId)  $default,) {final _that = this;
switch (_that) {
case _Document():
return $default(_that.id,_that.title,_that.sourceType,_that.createdAt,_that.sizeLabel,_that.contractId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  DocumentSourceType sourceType,  DateTime createdAt,  String sizeLabel,  String? contractId)?  $default,) {final _that = this;
switch (_that) {
case _Document() when $default != null:
return $default(_that.id,_that.title,_that.sourceType,_that.createdAt,_that.sizeLabel,_that.contractId);case _:
  return null;

}
}

}

/// @nodoc


class _Document implements Document {
  const _Document({required this.id, required this.title, required this.sourceType, required this.createdAt, required this.sizeLabel, this.contractId});
  

@override final  String id;
@override final  String title;
@override final  DocumentSourceType sourceType;
@override final  DateTime createdAt;
@override final  String sizeLabel;
/// Set when this document is a generated contract — lets the vault
/// open the real contract details screen instead of faking a preview.
@override final  String? contractId;

/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentCopyWith<_Document> get copyWith => __$DocumentCopyWithImpl<_Document>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Document&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sizeLabel, sizeLabel) || other.sizeLabel == sizeLabel)&&(identical(other.contractId, contractId) || other.contractId == contractId));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,sourceType,createdAt,sizeLabel,contractId);

@override
String toString() {
  return 'Document(id: $id, title: $title, sourceType: $sourceType, createdAt: $createdAt, sizeLabel: $sizeLabel, contractId: $contractId)';
}


}

/// @nodoc
abstract mixin class _$DocumentCopyWith<$Res> implements $DocumentCopyWith<$Res> {
  factory _$DocumentCopyWith(_Document value, $Res Function(_Document) _then) = __$DocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DocumentSourceType sourceType, DateTime createdAt, String sizeLabel, String? contractId
});




}
/// @nodoc
class __$DocumentCopyWithImpl<$Res>
    implements _$DocumentCopyWith<$Res> {
  __$DocumentCopyWithImpl(this._self, this._then);

  final _Document _self;
  final $Res Function(_Document) _then;

/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? sourceType = null,Object? createdAt = null,Object? sizeLabel = null,Object? contractId = freezed,}) {
  return _then(_Document(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as DocumentSourceType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sizeLabel: null == sizeLabel ? _self.sizeLabel : sizeLabel // ignore: cast_nullable_to_non_nullable
as String,contractId: freezed == contractId ? _self.contractId : contractId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
