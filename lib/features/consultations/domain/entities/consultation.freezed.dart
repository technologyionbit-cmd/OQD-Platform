// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consultation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Consultation {

 String get id; String get lawyerId; String get lawyerName; String get clientName; ConsultationType get type; ConsultationStatus get status; DateTime get scheduledAt; DateTime get createdAt; double get price; String get notes; List<ConsultationMessage> get messages;
/// Create a copy of Consultation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsultationCopyWith<Consultation> get copyWith => _$ConsultationCopyWithImpl<Consultation>(this as Consultation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Consultation&&(identical(other.id, id) || other.id == id)&&(identical(other.lawyerId, lawyerId) || other.lawyerId == lawyerId)&&(identical(other.lawyerName, lawyerName) || other.lawyerName == lawyerName)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.price, price) || other.price == price)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.messages, messages));
}


@override
int get hashCode => Object.hash(runtimeType,id,lawyerId,lawyerName,clientName,type,status,scheduledAt,createdAt,price,notes,const DeepCollectionEquality().hash(messages));

@override
String toString() {
  return 'Consultation(id: $id, lawyerId: $lawyerId, lawyerName: $lawyerName, clientName: $clientName, type: $type, status: $status, scheduledAt: $scheduledAt, createdAt: $createdAt, price: $price, notes: $notes, messages: $messages)';
}


}

/// @nodoc
abstract mixin class $ConsultationCopyWith<$Res>  {
  factory $ConsultationCopyWith(Consultation value, $Res Function(Consultation) _then) = _$ConsultationCopyWithImpl;
@useResult
$Res call({
 String id, String lawyerId, String lawyerName, String clientName, ConsultationType type, ConsultationStatus status, DateTime scheduledAt, DateTime createdAt, double price, String notes, List<ConsultationMessage> messages
});




}
/// @nodoc
class _$ConsultationCopyWithImpl<$Res>
    implements $ConsultationCopyWith<$Res> {
  _$ConsultationCopyWithImpl(this._self, this._then);

  final Consultation _self;
  final $Res Function(Consultation) _then;

/// Create a copy of Consultation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lawyerId = null,Object? lawyerName = null,Object? clientName = null,Object? type = null,Object? status = null,Object? scheduledAt = null,Object? createdAt = null,Object? price = null,Object? notes = null,Object? messages = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lawyerId: null == lawyerId ? _self.lawyerId : lawyerId // ignore: cast_nullable_to_non_nullable
as String,lawyerName: null == lawyerName ? _self.lawyerName : lawyerName // ignore: cast_nullable_to_non_nullable
as String,clientName: null == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConsultationType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConsultationStatus,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ConsultationMessage>,
  ));
}

}


/// Adds pattern-matching-related methods to [Consultation].
extension ConsultationPatterns on Consultation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Consultation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Consultation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Consultation value)  $default,){
final _that = this;
switch (_that) {
case _Consultation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Consultation value)?  $default,){
final _that = this;
switch (_that) {
case _Consultation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String lawyerId,  String lawyerName,  String clientName,  ConsultationType type,  ConsultationStatus status,  DateTime scheduledAt,  DateTime createdAt,  double price,  String notes,  List<ConsultationMessage> messages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Consultation() when $default != null:
return $default(_that.id,_that.lawyerId,_that.lawyerName,_that.clientName,_that.type,_that.status,_that.scheduledAt,_that.createdAt,_that.price,_that.notes,_that.messages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String lawyerId,  String lawyerName,  String clientName,  ConsultationType type,  ConsultationStatus status,  DateTime scheduledAt,  DateTime createdAt,  double price,  String notes,  List<ConsultationMessage> messages)  $default,) {final _that = this;
switch (_that) {
case _Consultation():
return $default(_that.id,_that.lawyerId,_that.lawyerName,_that.clientName,_that.type,_that.status,_that.scheduledAt,_that.createdAt,_that.price,_that.notes,_that.messages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String lawyerId,  String lawyerName,  String clientName,  ConsultationType type,  ConsultationStatus status,  DateTime scheduledAt,  DateTime createdAt,  double price,  String notes,  List<ConsultationMessage> messages)?  $default,) {final _that = this;
switch (_that) {
case _Consultation() when $default != null:
return $default(_that.id,_that.lawyerId,_that.lawyerName,_that.clientName,_that.type,_that.status,_that.scheduledAt,_that.createdAt,_that.price,_that.notes,_that.messages);case _:
  return null;

}
}

}

/// @nodoc


class _Consultation implements Consultation {
  const _Consultation({required this.id, required this.lawyerId, required this.lawyerName, required this.clientName, required this.type, required this.status, required this.scheduledAt, required this.createdAt, required this.price, this.notes = '', final  List<ConsultationMessage> messages = const <ConsultationMessage>[]}): _messages = messages;
  

@override final  String id;
@override final  String lawyerId;
@override final  String lawyerName;
@override final  String clientName;
@override final  ConsultationType type;
@override final  ConsultationStatus status;
@override final  DateTime scheduledAt;
@override final  DateTime createdAt;
@override final  double price;
@override@JsonKey() final  String notes;
 final  List<ConsultationMessage> _messages;
@override@JsonKey() List<ConsultationMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of Consultation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsultationCopyWith<_Consultation> get copyWith => __$ConsultationCopyWithImpl<_Consultation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Consultation&&(identical(other.id, id) || other.id == id)&&(identical(other.lawyerId, lawyerId) || other.lawyerId == lawyerId)&&(identical(other.lawyerName, lawyerName) || other.lawyerName == lawyerName)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.price, price) || other.price == price)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._messages, _messages));
}


@override
int get hashCode => Object.hash(runtimeType,id,lawyerId,lawyerName,clientName,type,status,scheduledAt,createdAt,price,notes,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'Consultation(id: $id, lawyerId: $lawyerId, lawyerName: $lawyerName, clientName: $clientName, type: $type, status: $status, scheduledAt: $scheduledAt, createdAt: $createdAt, price: $price, notes: $notes, messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$ConsultationCopyWith<$Res> implements $ConsultationCopyWith<$Res> {
  factory _$ConsultationCopyWith(_Consultation value, $Res Function(_Consultation) _then) = __$ConsultationCopyWithImpl;
@override @useResult
$Res call({
 String id, String lawyerId, String lawyerName, String clientName, ConsultationType type, ConsultationStatus status, DateTime scheduledAt, DateTime createdAt, double price, String notes, List<ConsultationMessage> messages
});




}
/// @nodoc
class __$ConsultationCopyWithImpl<$Res>
    implements _$ConsultationCopyWith<$Res> {
  __$ConsultationCopyWithImpl(this._self, this._then);

  final _Consultation _self;
  final $Res Function(_Consultation) _then;

/// Create a copy of Consultation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lawyerId = null,Object? lawyerName = null,Object? clientName = null,Object? type = null,Object? status = null,Object? scheduledAt = null,Object? createdAt = null,Object? price = null,Object? notes = null,Object? messages = null,}) {
  return _then(_Consultation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lawyerId: null == lawyerId ? _self.lawyerId : lawyerId // ignore: cast_nullable_to_non_nullable
as String,lawyerName: null == lawyerName ? _self.lawyerName : lawyerName // ignore: cast_nullable_to_non_nullable
as String,clientName: null == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConsultationType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConsultationStatus,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ConsultationMessage>,
  ));
}


}

// dart format on
