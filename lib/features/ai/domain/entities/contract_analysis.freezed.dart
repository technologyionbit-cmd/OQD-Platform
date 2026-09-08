// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contract_analysis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContractAnalysis {

 String get id; String get documentTitle; DateTime get createdAt; AnalysisRiskLevel get overallRisk; String get summary; List<AnalysisClause> get clauses;/// The document/contract this analysis was run on, when it came from
/// the client's own vault rather than a freshly "uploaded" mock file.
 String? get sourceDocumentId;
/// Create a copy of ContractAnalysis
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContractAnalysisCopyWith<ContractAnalysis> get copyWith => _$ContractAnalysisCopyWithImpl<ContractAnalysis>(this as ContractAnalysis, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContractAnalysis&&(identical(other.id, id) || other.id == id)&&(identical(other.documentTitle, documentTitle) || other.documentTitle == documentTitle)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.overallRisk, overallRisk) || other.overallRisk == overallRisk)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.clauses, clauses)&&(identical(other.sourceDocumentId, sourceDocumentId) || other.sourceDocumentId == sourceDocumentId));
}


@override
int get hashCode => Object.hash(runtimeType,id,documentTitle,createdAt,overallRisk,summary,const DeepCollectionEquality().hash(clauses),sourceDocumentId);

@override
String toString() {
  return 'ContractAnalysis(id: $id, documentTitle: $documentTitle, createdAt: $createdAt, overallRisk: $overallRisk, summary: $summary, clauses: $clauses, sourceDocumentId: $sourceDocumentId)';
}


}

/// @nodoc
abstract mixin class $ContractAnalysisCopyWith<$Res>  {
  factory $ContractAnalysisCopyWith(ContractAnalysis value, $Res Function(ContractAnalysis) _then) = _$ContractAnalysisCopyWithImpl;
@useResult
$Res call({
 String id, String documentTitle, DateTime createdAt, AnalysisRiskLevel overallRisk, String summary, List<AnalysisClause> clauses, String? sourceDocumentId
});




}
/// @nodoc
class _$ContractAnalysisCopyWithImpl<$Res>
    implements $ContractAnalysisCopyWith<$Res> {
  _$ContractAnalysisCopyWithImpl(this._self, this._then);

  final ContractAnalysis _self;
  final $Res Function(ContractAnalysis) _then;

/// Create a copy of ContractAnalysis
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? documentTitle = null,Object? createdAt = null,Object? overallRisk = null,Object? summary = null,Object? clauses = null,Object? sourceDocumentId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentTitle: null == documentTitle ? _self.documentTitle : documentTitle // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,overallRisk: null == overallRisk ? _self.overallRisk : overallRisk // ignore: cast_nullable_to_non_nullable
as AnalysisRiskLevel,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,clauses: null == clauses ? _self.clauses : clauses // ignore: cast_nullable_to_non_nullable
as List<AnalysisClause>,sourceDocumentId: freezed == sourceDocumentId ? _self.sourceDocumentId : sourceDocumentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContractAnalysis].
extension ContractAnalysisPatterns on ContractAnalysis {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContractAnalysis value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContractAnalysis() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContractAnalysis value)  $default,){
final _that = this;
switch (_that) {
case _ContractAnalysis():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContractAnalysis value)?  $default,){
final _that = this;
switch (_that) {
case _ContractAnalysis() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String documentTitle,  DateTime createdAt,  AnalysisRiskLevel overallRisk,  String summary,  List<AnalysisClause> clauses,  String? sourceDocumentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContractAnalysis() when $default != null:
return $default(_that.id,_that.documentTitle,_that.createdAt,_that.overallRisk,_that.summary,_that.clauses,_that.sourceDocumentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String documentTitle,  DateTime createdAt,  AnalysisRiskLevel overallRisk,  String summary,  List<AnalysisClause> clauses,  String? sourceDocumentId)  $default,) {final _that = this;
switch (_that) {
case _ContractAnalysis():
return $default(_that.id,_that.documentTitle,_that.createdAt,_that.overallRisk,_that.summary,_that.clauses,_that.sourceDocumentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String documentTitle,  DateTime createdAt,  AnalysisRiskLevel overallRisk,  String summary,  List<AnalysisClause> clauses,  String? sourceDocumentId)?  $default,) {final _that = this;
switch (_that) {
case _ContractAnalysis() when $default != null:
return $default(_that.id,_that.documentTitle,_that.createdAt,_that.overallRisk,_that.summary,_that.clauses,_that.sourceDocumentId);case _:
  return null;

}
}

}

/// @nodoc


class _ContractAnalysis implements ContractAnalysis {
  const _ContractAnalysis({required this.id, required this.documentTitle, required this.createdAt, required this.overallRisk, required this.summary, required final  List<AnalysisClause> clauses, this.sourceDocumentId}): _clauses = clauses;
  

@override final  String id;
@override final  String documentTitle;
@override final  DateTime createdAt;
@override final  AnalysisRiskLevel overallRisk;
@override final  String summary;
 final  List<AnalysisClause> _clauses;
@override List<AnalysisClause> get clauses {
  if (_clauses is EqualUnmodifiableListView) return _clauses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clauses);
}

/// The document/contract this analysis was run on, when it came from
/// the client's own vault rather than a freshly "uploaded" mock file.
@override final  String? sourceDocumentId;

/// Create a copy of ContractAnalysis
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContractAnalysisCopyWith<_ContractAnalysis> get copyWith => __$ContractAnalysisCopyWithImpl<_ContractAnalysis>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContractAnalysis&&(identical(other.id, id) || other.id == id)&&(identical(other.documentTitle, documentTitle) || other.documentTitle == documentTitle)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.overallRisk, overallRisk) || other.overallRisk == overallRisk)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._clauses, _clauses)&&(identical(other.sourceDocumentId, sourceDocumentId) || other.sourceDocumentId == sourceDocumentId));
}


@override
int get hashCode => Object.hash(runtimeType,id,documentTitle,createdAt,overallRisk,summary,const DeepCollectionEquality().hash(_clauses),sourceDocumentId);

@override
String toString() {
  return 'ContractAnalysis(id: $id, documentTitle: $documentTitle, createdAt: $createdAt, overallRisk: $overallRisk, summary: $summary, clauses: $clauses, sourceDocumentId: $sourceDocumentId)';
}


}

/// @nodoc
abstract mixin class _$ContractAnalysisCopyWith<$Res> implements $ContractAnalysisCopyWith<$Res> {
  factory _$ContractAnalysisCopyWith(_ContractAnalysis value, $Res Function(_ContractAnalysis) _then) = __$ContractAnalysisCopyWithImpl;
@override @useResult
$Res call({
 String id, String documentTitle, DateTime createdAt, AnalysisRiskLevel overallRisk, String summary, List<AnalysisClause> clauses, String? sourceDocumentId
});




}
/// @nodoc
class __$ContractAnalysisCopyWithImpl<$Res>
    implements _$ContractAnalysisCopyWith<$Res> {
  __$ContractAnalysisCopyWithImpl(this._self, this._then);

  final _ContractAnalysis _self;
  final $Res Function(_ContractAnalysis) _then;

/// Create a copy of ContractAnalysis
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? documentTitle = null,Object? createdAt = null,Object? overallRisk = null,Object? summary = null,Object? clauses = null,Object? sourceDocumentId = freezed,}) {
  return _then(_ContractAnalysis(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentTitle: null == documentTitle ? _self.documentTitle : documentTitle // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,overallRisk: null == overallRisk ? _self.overallRisk : overallRisk // ignore: cast_nullable_to_non_nullable
as AnalysisRiskLevel,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,clauses: null == clauses ? _self._clauses : clauses // ignore: cast_nullable_to_non_nullable
as List<AnalysisClause>,sourceDocumentId: freezed == sourceDocumentId ? _self.sourceDocumentId : sourceDocumentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
