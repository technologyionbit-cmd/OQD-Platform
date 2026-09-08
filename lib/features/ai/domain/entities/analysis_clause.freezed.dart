// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analysis_clause.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnalysisClause {

 String get id; String get title; String get content; AnalysisRiskLevel get riskLevel; String get recommendation;
/// Create a copy of AnalysisClause
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalysisClauseCopyWith<AnalysisClause> get copyWith => _$AnalysisClauseCopyWithImpl<AnalysisClause>(this as AnalysisClause, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalysisClause&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.riskLevel, riskLevel) || other.riskLevel == riskLevel)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,content,riskLevel,recommendation);

@override
String toString() {
  return 'AnalysisClause(id: $id, title: $title, content: $content, riskLevel: $riskLevel, recommendation: $recommendation)';
}


}

/// @nodoc
abstract mixin class $AnalysisClauseCopyWith<$Res>  {
  factory $AnalysisClauseCopyWith(AnalysisClause value, $Res Function(AnalysisClause) _then) = _$AnalysisClauseCopyWithImpl;
@useResult
$Res call({
 String id, String title, String content, AnalysisRiskLevel riskLevel, String recommendation
});




}
/// @nodoc
class _$AnalysisClauseCopyWithImpl<$Res>
    implements $AnalysisClauseCopyWith<$Res> {
  _$AnalysisClauseCopyWithImpl(this._self, this._then);

  final AnalysisClause _self;
  final $Res Function(AnalysisClause) _then;

/// Create a copy of AnalysisClause
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? content = null,Object? riskLevel = null,Object? recommendation = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,riskLevel: null == riskLevel ? _self.riskLevel : riskLevel // ignore: cast_nullable_to_non_nullable
as AnalysisRiskLevel,recommendation: null == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalysisClause].
extension AnalysisClausePatterns on AnalysisClause {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalysisClause value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalysisClause() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalysisClause value)  $default,){
final _that = this;
switch (_that) {
case _AnalysisClause():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalysisClause value)?  $default,){
final _that = this;
switch (_that) {
case _AnalysisClause() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String content,  AnalysisRiskLevel riskLevel,  String recommendation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalysisClause() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.riskLevel,_that.recommendation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String content,  AnalysisRiskLevel riskLevel,  String recommendation)  $default,) {final _that = this;
switch (_that) {
case _AnalysisClause():
return $default(_that.id,_that.title,_that.content,_that.riskLevel,_that.recommendation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String content,  AnalysisRiskLevel riskLevel,  String recommendation)?  $default,) {final _that = this;
switch (_that) {
case _AnalysisClause() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.riskLevel,_that.recommendation);case _:
  return null;

}
}

}

/// @nodoc


class _AnalysisClause implements AnalysisClause {
  const _AnalysisClause({required this.id, required this.title, required this.content, required this.riskLevel, required this.recommendation});
  

@override final  String id;
@override final  String title;
@override final  String content;
@override final  AnalysisRiskLevel riskLevel;
@override final  String recommendation;

/// Create a copy of AnalysisClause
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalysisClauseCopyWith<_AnalysisClause> get copyWith => __$AnalysisClauseCopyWithImpl<_AnalysisClause>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalysisClause&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.riskLevel, riskLevel) || other.riskLevel == riskLevel)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,content,riskLevel,recommendation);

@override
String toString() {
  return 'AnalysisClause(id: $id, title: $title, content: $content, riskLevel: $riskLevel, recommendation: $recommendation)';
}


}

/// @nodoc
abstract mixin class _$AnalysisClauseCopyWith<$Res> implements $AnalysisClauseCopyWith<$Res> {
  factory _$AnalysisClauseCopyWith(_AnalysisClause value, $Res Function(_AnalysisClause) _then) = __$AnalysisClauseCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String content, AnalysisRiskLevel riskLevel, String recommendation
});




}
/// @nodoc
class __$AnalysisClauseCopyWithImpl<$Res>
    implements _$AnalysisClauseCopyWith<$Res> {
  __$AnalysisClauseCopyWithImpl(this._self, this._then);

  final _AnalysisClause _self;
  final $Res Function(_AnalysisClause) _then;

/// Create a copy of AnalysisClause
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? content = null,Object? riskLevel = null,Object? recommendation = null,}) {
  return _then(_AnalysisClause(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,riskLevel: null == riskLevel ? _self.riskLevel : riskLevel // ignore: cast_nullable_to_non_nullable
as AnalysisRiskLevel,recommendation: null == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
