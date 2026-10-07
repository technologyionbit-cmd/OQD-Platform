// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegisterRequest {

 String get phone; String get email; String get password; bool get acceptTerms; String get termsVersion;
/// Create a copy of RegisterRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterRequestCopyWith<RegisterRequest> get copyWith => _$RegisterRequestCopyWithImpl<RegisterRequest>(this as RegisterRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterRequest&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.acceptTerms, acceptTerms) || other.acceptTerms == acceptTerms)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion));
}


@override
int get hashCode => Object.hash(runtimeType,phone,email,password,acceptTerms,termsVersion);

@override
String toString() {
  return 'RegisterRequest(phone: $phone, email: $email, password: $password, acceptTerms: $acceptTerms, termsVersion: $termsVersion)';
}


}

/// @nodoc
abstract mixin class $RegisterRequestCopyWith<$Res>  {
  factory $RegisterRequestCopyWith(RegisterRequest value, $Res Function(RegisterRequest) _then) = _$RegisterRequestCopyWithImpl;
@useResult
$Res call({
 String phone, String email, String password, bool acceptTerms, String termsVersion
});




}
/// @nodoc
class _$RegisterRequestCopyWithImpl<$Res>
    implements $RegisterRequestCopyWith<$Res> {
  _$RegisterRequestCopyWithImpl(this._self, this._then);

  final RegisterRequest _self;
  final $Res Function(RegisterRequest) _then;

/// Create a copy of RegisterRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phone = null,Object? email = null,Object? password = null,Object? acceptTerms = null,Object? termsVersion = null,}) {
  return _then(_self.copyWith(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,acceptTerms: null == acceptTerms ? _self.acceptTerms : acceptTerms // ignore: cast_nullable_to_non_nullable
as bool,termsVersion: null == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterRequest].
extension RegisterRequestPatterns on RegisterRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( IndividualRegisterRequest value)?  individual,TResult Function( CompanyRegisterRequest value)?  company,TResult Function( LawyerRegisterRequest value)?  lawyer,required TResult orElse(),}){
final _that = this;
switch (_that) {
case IndividualRegisterRequest() when individual != null:
return individual(_that);case CompanyRegisterRequest() when company != null:
return company(_that);case LawyerRegisterRequest() when lawyer != null:
return lawyer(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( IndividualRegisterRequest value)  individual,required TResult Function( CompanyRegisterRequest value)  company,required TResult Function( LawyerRegisterRequest value)  lawyer,}){
final _that = this;
switch (_that) {
case IndividualRegisterRequest():
return individual(_that);case CompanyRegisterRequest():
return company(_that);case LawyerRegisterRequest():
return lawyer(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( IndividualRegisterRequest value)?  individual,TResult? Function( CompanyRegisterRequest value)?  company,TResult? Function( LawyerRegisterRequest value)?  lawyer,}){
final _that = this;
switch (_that) {
case IndividualRegisterRequest() when individual != null:
return individual(_that);case CompanyRegisterRequest() when company != null:
return company(_that);case LawyerRegisterRequest() when lawyer != null:
return lawyer(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String fullName,  String phone,  String email,  String password,  bool acceptTerms,  String termsVersion)?  individual,TResult Function( String companyName,  String commercialRegistrationNumber,  String email,  String phone,  String password,  bool acceptTerms,  String termsVersion)?  company,TResult Function( String fullName,  String barLicenseNumber,  String mainSpecialty,  String email,  String phone,  String password,  bool acceptTerms,  String termsVersion)?  lawyer,required TResult orElse(),}) {final _that = this;
switch (_that) {
case IndividualRegisterRequest() when individual != null:
return individual(_that.fullName,_that.phone,_that.email,_that.password,_that.acceptTerms,_that.termsVersion);case CompanyRegisterRequest() when company != null:
return company(_that.companyName,_that.commercialRegistrationNumber,_that.email,_that.phone,_that.password,_that.acceptTerms,_that.termsVersion);case LawyerRegisterRequest() when lawyer != null:
return lawyer(_that.fullName,_that.barLicenseNumber,_that.mainSpecialty,_that.email,_that.phone,_that.password,_that.acceptTerms,_that.termsVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String fullName,  String phone,  String email,  String password,  bool acceptTerms,  String termsVersion)  individual,required TResult Function( String companyName,  String commercialRegistrationNumber,  String email,  String phone,  String password,  bool acceptTerms,  String termsVersion)  company,required TResult Function( String fullName,  String barLicenseNumber,  String mainSpecialty,  String email,  String phone,  String password,  bool acceptTerms,  String termsVersion)  lawyer,}) {final _that = this;
switch (_that) {
case IndividualRegisterRequest():
return individual(_that.fullName,_that.phone,_that.email,_that.password,_that.acceptTerms,_that.termsVersion);case CompanyRegisterRequest():
return company(_that.companyName,_that.commercialRegistrationNumber,_that.email,_that.phone,_that.password,_that.acceptTerms,_that.termsVersion);case LawyerRegisterRequest():
return lawyer(_that.fullName,_that.barLicenseNumber,_that.mainSpecialty,_that.email,_that.phone,_that.password,_that.acceptTerms,_that.termsVersion);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String fullName,  String phone,  String email,  String password,  bool acceptTerms,  String termsVersion)?  individual,TResult? Function( String companyName,  String commercialRegistrationNumber,  String email,  String phone,  String password,  bool acceptTerms,  String termsVersion)?  company,TResult? Function( String fullName,  String barLicenseNumber,  String mainSpecialty,  String email,  String phone,  String password,  bool acceptTerms,  String termsVersion)?  lawyer,}) {final _that = this;
switch (_that) {
case IndividualRegisterRequest() when individual != null:
return individual(_that.fullName,_that.phone,_that.email,_that.password,_that.acceptTerms,_that.termsVersion);case CompanyRegisterRequest() when company != null:
return company(_that.companyName,_that.commercialRegistrationNumber,_that.email,_that.phone,_that.password,_that.acceptTerms,_that.termsVersion);case LawyerRegisterRequest() when lawyer != null:
return lawyer(_that.fullName,_that.barLicenseNumber,_that.mainSpecialty,_that.email,_that.phone,_that.password,_that.acceptTerms,_that.termsVersion);case _:
  return null;

}
}

}

/// @nodoc


class IndividualRegisterRequest implements RegisterRequest {
  const IndividualRegisterRequest({required this.fullName, required this.phone, required this.email, required this.password, required this.acceptTerms, required this.termsVersion});
  

 final  String fullName;
@override final  String phone;
@override final  String email;
@override final  String password;
@override final  bool acceptTerms;
@override final  String termsVersion;

/// Create a copy of RegisterRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IndividualRegisterRequestCopyWith<IndividualRegisterRequest> get copyWith => _$IndividualRegisterRequestCopyWithImpl<IndividualRegisterRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IndividualRegisterRequest&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.acceptTerms, acceptTerms) || other.acceptTerms == acceptTerms)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion));
}


@override
int get hashCode => Object.hash(runtimeType,fullName,phone,email,password,acceptTerms,termsVersion);

@override
String toString() {
  return 'RegisterRequest.individual(fullName: $fullName, phone: $phone, email: $email, password: $password, acceptTerms: $acceptTerms, termsVersion: $termsVersion)';
}


}

/// @nodoc
abstract mixin class $IndividualRegisterRequestCopyWith<$Res> implements $RegisterRequestCopyWith<$Res> {
  factory $IndividualRegisterRequestCopyWith(IndividualRegisterRequest value, $Res Function(IndividualRegisterRequest) _then) = _$IndividualRegisterRequestCopyWithImpl;
@override @useResult
$Res call({
 String fullName, String phone, String email, String password, bool acceptTerms, String termsVersion
});




}
/// @nodoc
class _$IndividualRegisterRequestCopyWithImpl<$Res>
    implements $IndividualRegisterRequestCopyWith<$Res> {
  _$IndividualRegisterRequestCopyWithImpl(this._self, this._then);

  final IndividualRegisterRequest _self;
  final $Res Function(IndividualRegisterRequest) _then;

/// Create a copy of RegisterRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? phone = null,Object? email = null,Object? password = null,Object? acceptTerms = null,Object? termsVersion = null,}) {
  return _then(IndividualRegisterRequest(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,acceptTerms: null == acceptTerms ? _self.acceptTerms : acceptTerms // ignore: cast_nullable_to_non_nullable
as bool,termsVersion: null == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CompanyRegisterRequest implements RegisterRequest {
  const CompanyRegisterRequest({required this.companyName, required this.commercialRegistrationNumber, required this.email, required this.phone, required this.password, required this.acceptTerms, required this.termsVersion});
  

 final  String companyName;
 final  String commercialRegistrationNumber;
@override final  String email;
@override final  String phone;
@override final  String password;
@override final  bool acceptTerms;
@override final  String termsVersion;

/// Create a copy of RegisterRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyRegisterRequestCopyWith<CompanyRegisterRequest> get copyWith => _$CompanyRegisterRequestCopyWithImpl<CompanyRegisterRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanyRegisterRequest&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.commercialRegistrationNumber, commercialRegistrationNumber) || other.commercialRegistrationNumber == commercialRegistrationNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.password, password) || other.password == password)&&(identical(other.acceptTerms, acceptTerms) || other.acceptTerms == acceptTerms)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion));
}


@override
int get hashCode => Object.hash(runtimeType,companyName,commercialRegistrationNumber,email,phone,password,acceptTerms,termsVersion);

@override
String toString() {
  return 'RegisterRequest.company(companyName: $companyName, commercialRegistrationNumber: $commercialRegistrationNumber, email: $email, phone: $phone, password: $password, acceptTerms: $acceptTerms, termsVersion: $termsVersion)';
}


}

/// @nodoc
abstract mixin class $CompanyRegisterRequestCopyWith<$Res> implements $RegisterRequestCopyWith<$Res> {
  factory $CompanyRegisterRequestCopyWith(CompanyRegisterRequest value, $Res Function(CompanyRegisterRequest) _then) = _$CompanyRegisterRequestCopyWithImpl;
@override @useResult
$Res call({
 String companyName, String commercialRegistrationNumber, String email, String phone, String password, bool acceptTerms, String termsVersion
});




}
/// @nodoc
class _$CompanyRegisterRequestCopyWithImpl<$Res>
    implements $CompanyRegisterRequestCopyWith<$Res> {
  _$CompanyRegisterRequestCopyWithImpl(this._self, this._then);

  final CompanyRegisterRequest _self;
  final $Res Function(CompanyRegisterRequest) _then;

/// Create a copy of RegisterRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? companyName = null,Object? commercialRegistrationNumber = null,Object? email = null,Object? phone = null,Object? password = null,Object? acceptTerms = null,Object? termsVersion = null,}) {
  return _then(CompanyRegisterRequest(
companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,commercialRegistrationNumber: null == commercialRegistrationNumber ? _self.commercialRegistrationNumber : commercialRegistrationNumber // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,acceptTerms: null == acceptTerms ? _self.acceptTerms : acceptTerms // ignore: cast_nullable_to_non_nullable
as bool,termsVersion: null == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LawyerRegisterRequest implements RegisterRequest {
  const LawyerRegisterRequest({required this.fullName, required this.barLicenseNumber, required this.mainSpecialty, required this.email, required this.phone, required this.password, required this.acceptTerms, required this.termsVersion});
  

 final  String fullName;
 final  String barLicenseNumber;
 final  String mainSpecialty;
@override final  String email;
@override final  String phone;
@override final  String password;
@override final  bool acceptTerms;
@override final  String termsVersion;

/// Create a copy of RegisterRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LawyerRegisterRequestCopyWith<LawyerRegisterRequest> get copyWith => _$LawyerRegisterRequestCopyWithImpl<LawyerRegisterRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LawyerRegisterRequest&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.barLicenseNumber, barLicenseNumber) || other.barLicenseNumber == barLicenseNumber)&&(identical(other.mainSpecialty, mainSpecialty) || other.mainSpecialty == mainSpecialty)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.password, password) || other.password == password)&&(identical(other.acceptTerms, acceptTerms) || other.acceptTerms == acceptTerms)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion));
}


@override
int get hashCode => Object.hash(runtimeType,fullName,barLicenseNumber,mainSpecialty,email,phone,password,acceptTerms,termsVersion);

@override
String toString() {
  return 'RegisterRequest.lawyer(fullName: $fullName, barLicenseNumber: $barLicenseNumber, mainSpecialty: $mainSpecialty, email: $email, phone: $phone, password: $password, acceptTerms: $acceptTerms, termsVersion: $termsVersion)';
}


}

/// @nodoc
abstract mixin class $LawyerRegisterRequestCopyWith<$Res> implements $RegisterRequestCopyWith<$Res> {
  factory $LawyerRegisterRequestCopyWith(LawyerRegisterRequest value, $Res Function(LawyerRegisterRequest) _then) = _$LawyerRegisterRequestCopyWithImpl;
@override @useResult
$Res call({
 String fullName, String barLicenseNumber, String mainSpecialty, String email, String phone, String password, bool acceptTerms, String termsVersion
});




}
/// @nodoc
class _$LawyerRegisterRequestCopyWithImpl<$Res>
    implements $LawyerRegisterRequestCopyWith<$Res> {
  _$LawyerRegisterRequestCopyWithImpl(this._self, this._then);

  final LawyerRegisterRequest _self;
  final $Res Function(LawyerRegisterRequest) _then;

/// Create a copy of RegisterRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? barLicenseNumber = null,Object? mainSpecialty = null,Object? email = null,Object? phone = null,Object? password = null,Object? acceptTerms = null,Object? termsVersion = null,}) {
  return _then(LawyerRegisterRequest(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,barLicenseNumber: null == barLicenseNumber ? _self.barLicenseNumber : barLicenseNumber // ignore: cast_nullable_to_non_nullable
as String,mainSpecialty: null == mainSpecialty ? _self.mainSpecialty : mainSpecialty // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,acceptTerms: null == acceptTerms ? _self.acceptTerms : acceptTerms // ignore: cast_nullable_to_non_nullable
as bool,termsVersion: null == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
