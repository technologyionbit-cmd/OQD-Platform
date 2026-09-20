// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lawyer_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LawyerProfile {

 String get id; String get fullName; List<LawyerSpecialty> get specialties; String get bio; int get yearsOfExperience; double get rating; int get reviewsCount; List<ConsultationType> get consultationTypes; Map<ConsultationType, double> get pricing; VerificationStatus get verificationStatus;
/// Create a copy of LawyerProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LawyerProfileCopyWith<LawyerProfile> get copyWith => _$LawyerProfileCopyWithImpl<LawyerProfile>(this as LawyerProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LawyerProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&const DeepCollectionEquality().equals(other.specialties, specialties)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.yearsOfExperience, yearsOfExperience) || other.yearsOfExperience == yearsOfExperience)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewsCount, reviewsCount) || other.reviewsCount == reviewsCount)&&const DeepCollectionEquality().equals(other.consultationTypes, consultationTypes)&&const DeepCollectionEquality().equals(other.pricing, pricing)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}


@override
int get hashCode => Object.hash(runtimeType,id,fullName,const DeepCollectionEquality().hash(specialties),bio,yearsOfExperience,rating,reviewsCount,const DeepCollectionEquality().hash(consultationTypes),const DeepCollectionEquality().hash(pricing),verificationStatus);

@override
String toString() {
  return 'LawyerProfile(id: $id, fullName: $fullName, specialties: $specialties, bio: $bio, yearsOfExperience: $yearsOfExperience, rating: $rating, reviewsCount: $reviewsCount, consultationTypes: $consultationTypes, pricing: $pricing, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class $LawyerProfileCopyWith<$Res>  {
  factory $LawyerProfileCopyWith(LawyerProfile value, $Res Function(LawyerProfile) _then) = _$LawyerProfileCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, List<LawyerSpecialty> specialties, String bio, int yearsOfExperience, double rating, int reviewsCount, List<ConsultationType> consultationTypes, Map<ConsultationType, double> pricing, VerificationStatus verificationStatus
});




}
/// @nodoc
class _$LawyerProfileCopyWithImpl<$Res>
    implements $LawyerProfileCopyWith<$Res> {
  _$LawyerProfileCopyWithImpl(this._self, this._then);

  final LawyerProfile _self;
  final $Res Function(LawyerProfile) _then;

/// Create a copy of LawyerProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? specialties = null,Object? bio = null,Object? yearsOfExperience = null,Object? rating = null,Object? reviewsCount = null,Object? consultationTypes = null,Object? pricing = null,Object? verificationStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,specialties: null == specialties ? _self.specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<LawyerSpecialty>,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,yearsOfExperience: null == yearsOfExperience ? _self.yearsOfExperience : yearsOfExperience // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewsCount: null == reviewsCount ? _self.reviewsCount : reviewsCount // ignore: cast_nullable_to_non_nullable
as int,consultationTypes: null == consultationTypes ? _self.consultationTypes : consultationTypes // ignore: cast_nullable_to_non_nullable
as List<ConsultationType>,pricing: null == pricing ? _self.pricing : pricing // ignore: cast_nullable_to_non_nullable
as Map<ConsultationType, double>,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [LawyerProfile].
extension LawyerProfilePatterns on LawyerProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LawyerProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LawyerProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LawyerProfile value)  $default,){
final _that = this;
switch (_that) {
case _LawyerProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LawyerProfile value)?  $default,){
final _that = this;
switch (_that) {
case _LawyerProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  List<LawyerSpecialty> specialties,  String bio,  int yearsOfExperience,  double rating,  int reviewsCount,  List<ConsultationType> consultationTypes,  Map<ConsultationType, double> pricing,  VerificationStatus verificationStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LawyerProfile() when $default != null:
return $default(_that.id,_that.fullName,_that.specialties,_that.bio,_that.yearsOfExperience,_that.rating,_that.reviewsCount,_that.consultationTypes,_that.pricing,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  List<LawyerSpecialty> specialties,  String bio,  int yearsOfExperience,  double rating,  int reviewsCount,  List<ConsultationType> consultationTypes,  Map<ConsultationType, double> pricing,  VerificationStatus verificationStatus)  $default,) {final _that = this;
switch (_that) {
case _LawyerProfile():
return $default(_that.id,_that.fullName,_that.specialties,_that.bio,_that.yearsOfExperience,_that.rating,_that.reviewsCount,_that.consultationTypes,_that.pricing,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  List<LawyerSpecialty> specialties,  String bio,  int yearsOfExperience,  double rating,  int reviewsCount,  List<ConsultationType> consultationTypes,  Map<ConsultationType, double> pricing,  VerificationStatus verificationStatus)?  $default,) {final _that = this;
switch (_that) {
case _LawyerProfile() when $default != null:
return $default(_that.id,_that.fullName,_that.specialties,_that.bio,_that.yearsOfExperience,_that.rating,_that.reviewsCount,_that.consultationTypes,_that.pricing,_that.verificationStatus);case _:
  return null;

}
}

}

/// @nodoc


class _LawyerProfile implements LawyerProfile {
  const _LawyerProfile({required this.id, required this.fullName, required final  List<LawyerSpecialty> specialties, required this.bio, required this.yearsOfExperience, required this.rating, required this.reviewsCount, required final  List<ConsultationType> consultationTypes, required final  Map<ConsultationType, double> pricing, this.verificationStatus = VerificationStatus.verified}): _specialties = specialties,_consultationTypes = consultationTypes,_pricing = pricing;
  

@override final  String id;
@override final  String fullName;
 final  List<LawyerSpecialty> _specialties;
@override List<LawyerSpecialty> get specialties {
  if (_specialties is EqualUnmodifiableListView) return _specialties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specialties);
}

@override final  String bio;
@override final  int yearsOfExperience;
@override final  double rating;
@override final  int reviewsCount;
 final  List<ConsultationType> _consultationTypes;
@override List<ConsultationType> get consultationTypes {
  if (_consultationTypes is EqualUnmodifiableListView) return _consultationTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_consultationTypes);
}

 final  Map<ConsultationType, double> _pricing;
@override Map<ConsultationType, double> get pricing {
  if (_pricing is EqualUnmodifiableMapView) return _pricing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_pricing);
}

@override@JsonKey() final  VerificationStatus verificationStatus;

/// Create a copy of LawyerProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LawyerProfileCopyWith<_LawyerProfile> get copyWith => __$LawyerProfileCopyWithImpl<_LawyerProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LawyerProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&const DeepCollectionEquality().equals(other._specialties, _specialties)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.yearsOfExperience, yearsOfExperience) || other.yearsOfExperience == yearsOfExperience)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewsCount, reviewsCount) || other.reviewsCount == reviewsCount)&&const DeepCollectionEquality().equals(other._consultationTypes, _consultationTypes)&&const DeepCollectionEquality().equals(other._pricing, _pricing)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}


@override
int get hashCode => Object.hash(runtimeType,id,fullName,const DeepCollectionEquality().hash(_specialties),bio,yearsOfExperience,rating,reviewsCount,const DeepCollectionEquality().hash(_consultationTypes),const DeepCollectionEquality().hash(_pricing),verificationStatus);

@override
String toString() {
  return 'LawyerProfile(id: $id, fullName: $fullName, specialties: $specialties, bio: $bio, yearsOfExperience: $yearsOfExperience, rating: $rating, reviewsCount: $reviewsCount, consultationTypes: $consultationTypes, pricing: $pricing, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class _$LawyerProfileCopyWith<$Res> implements $LawyerProfileCopyWith<$Res> {
  factory _$LawyerProfileCopyWith(_LawyerProfile value, $Res Function(_LawyerProfile) _then) = __$LawyerProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, List<LawyerSpecialty> specialties, String bio, int yearsOfExperience, double rating, int reviewsCount, List<ConsultationType> consultationTypes, Map<ConsultationType, double> pricing, VerificationStatus verificationStatus
});




}
/// @nodoc
class __$LawyerProfileCopyWithImpl<$Res>
    implements _$LawyerProfileCopyWith<$Res> {
  __$LawyerProfileCopyWithImpl(this._self, this._then);

  final _LawyerProfile _self;
  final $Res Function(_LawyerProfile) _then;

/// Create a copy of LawyerProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? specialties = null,Object? bio = null,Object? yearsOfExperience = null,Object? rating = null,Object? reviewsCount = null,Object? consultationTypes = null,Object? pricing = null,Object? verificationStatus = null,}) {
  return _then(_LawyerProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,specialties: null == specialties ? _self._specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<LawyerSpecialty>,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,yearsOfExperience: null == yearsOfExperience ? _self.yearsOfExperience : yearsOfExperience // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewsCount: null == reviewsCount ? _self.reviewsCount : reviewsCount // ignore: cast_nullable_to_non_nullable
as int,consultationTypes: null == consultationTypes ? _self._consultationTypes : consultationTypes // ignore: cast_nullable_to_non_nullable
as List<ConsultationType>,pricing: null == pricing ? _self._pricing : pricing // ignore: cast_nullable_to_non_nullable
as Map<ConsultationType, double>,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,
  ));
}


}

// dart format on
