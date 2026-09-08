// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consultation_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConsultationMessage {

 String get id; String get text; DateTime get sentAt; bool get isFromLawyer;
/// Create a copy of ConsultationMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsultationMessageCopyWith<ConsultationMessage> get copyWith => _$ConsultationMessageCopyWithImpl<ConsultationMessage>(this as ConsultationMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsultationMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.isFromLawyer, isFromLawyer) || other.isFromLawyer == isFromLawyer));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,sentAt,isFromLawyer);

@override
String toString() {
  return 'ConsultationMessage(id: $id, text: $text, sentAt: $sentAt, isFromLawyer: $isFromLawyer)';
}


}

/// @nodoc
abstract mixin class $ConsultationMessageCopyWith<$Res>  {
  factory $ConsultationMessageCopyWith(ConsultationMessage value, $Res Function(ConsultationMessage) _then) = _$ConsultationMessageCopyWithImpl;
@useResult
$Res call({
 String id, String text, DateTime sentAt, bool isFromLawyer
});




}
/// @nodoc
class _$ConsultationMessageCopyWithImpl<$Res>
    implements $ConsultationMessageCopyWith<$Res> {
  _$ConsultationMessageCopyWithImpl(this._self, this._then);

  final ConsultationMessage _self;
  final $Res Function(ConsultationMessage) _then;

/// Create a copy of ConsultationMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? sentAt = null,Object? isFromLawyer = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,isFromLawyer: null == isFromLawyer ? _self.isFromLawyer : isFromLawyer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsultationMessage].
extension ConsultationMessagePatterns on ConsultationMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsultationMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsultationMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsultationMessage value)  $default,){
final _that = this;
switch (_that) {
case _ConsultationMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsultationMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ConsultationMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  DateTime sentAt,  bool isFromLawyer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsultationMessage() when $default != null:
return $default(_that.id,_that.text,_that.sentAt,_that.isFromLawyer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  DateTime sentAt,  bool isFromLawyer)  $default,) {final _that = this;
switch (_that) {
case _ConsultationMessage():
return $default(_that.id,_that.text,_that.sentAt,_that.isFromLawyer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  DateTime sentAt,  bool isFromLawyer)?  $default,) {final _that = this;
switch (_that) {
case _ConsultationMessage() when $default != null:
return $default(_that.id,_that.text,_that.sentAt,_that.isFromLawyer);case _:
  return null;

}
}

}

/// @nodoc


class _ConsultationMessage implements ConsultationMessage {
  const _ConsultationMessage({required this.id, required this.text, required this.sentAt, required this.isFromLawyer});
  

@override final  String id;
@override final  String text;
@override final  DateTime sentAt;
@override final  bool isFromLawyer;

/// Create a copy of ConsultationMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsultationMessageCopyWith<_ConsultationMessage> get copyWith => __$ConsultationMessageCopyWithImpl<_ConsultationMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsultationMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.isFromLawyer, isFromLawyer) || other.isFromLawyer == isFromLawyer));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,sentAt,isFromLawyer);

@override
String toString() {
  return 'ConsultationMessage(id: $id, text: $text, sentAt: $sentAt, isFromLawyer: $isFromLawyer)';
}


}

/// @nodoc
abstract mixin class _$ConsultationMessageCopyWith<$Res> implements $ConsultationMessageCopyWith<$Res> {
  factory _$ConsultationMessageCopyWith(_ConsultationMessage value, $Res Function(_ConsultationMessage) _then) = __$ConsultationMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, DateTime sentAt, bool isFromLawyer
});




}
/// @nodoc
class __$ConsultationMessageCopyWithImpl<$Res>
    implements _$ConsultationMessageCopyWith<$Res> {
  __$ConsultationMessageCopyWithImpl(this._self, this._then);

  final _ConsultationMessage _self;
  final $Res Function(_ConsultationMessage) _then;

/// Create a copy of ConsultationMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? sentAt = null,Object? isFromLawyer = null,}) {
  return _then(_ConsultationMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,isFromLawyer: null == isFromLawyer ? _self.isFromLawyer : isFromLawyer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
