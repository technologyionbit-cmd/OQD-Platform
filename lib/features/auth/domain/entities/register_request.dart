import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request.freezed.dart';

/// One variant per account type — the registration form's fields genuinely
/// differ per type (bar license vs. commercial registration vs. none), so a
/// union is the honest model here rather than one struct with a pile of
/// nullable fields.
///
/// Every variant carries the terms acceptance: [acceptTerms] must be true
/// (the user ticked the box) and [termsVersion] names the terms they saw
/// (`AppConfig.termsVersion`). The server stores both.
@freezed
sealed class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest.individual({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required bool acceptTerms,
    required String termsVersion,
  }) = IndividualRegisterRequest;

  const factory RegisterRequest.company({
    required String companyName,
    required String commercialRegistrationNumber,
    required String email,
    required String phone,
    required String password,
    required bool acceptTerms,
    required String termsVersion,
  }) = CompanyRegisterRequest;

  const factory RegisterRequest.lawyer({
    required String fullName,
    required String barLicenseNumber,
    required String mainSpecialty,
    required String email,
    required String phone,
    required String password,
    required bool acceptTerms,
    required String termsVersion,
  }) = LawyerRegisterRequest;
}
