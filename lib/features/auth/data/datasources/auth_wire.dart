import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_session.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';

/// Pure translation between the auth REST wire format and the domain
/// entities. Kept out of [AuthRemoteDataSourceImpl] so the HTTP code stays
/// about transport and this stays about shape. Every parser fails loudly
/// (throws) on a missing/mistyped field rather than silently substituting.
class AuthWire {
  const AuthWire._();

  // --- requests ------------------------------------------------------------

  static Map<String, dynamic> registerBody(RegisterRequest request) {
    final typeFields = switch (request) {
      IndividualRegisterRequest(:final fullName) => {'accountType': 'individual', 'fullName': fullName},
      CompanyRegisterRequest(:final companyName, :final commercialRegistrationNumber) => {
        'accountType': 'company',
        'companyName': companyName,
        'commercialRegistrationNumber': commercialRegistrationNumber,
      },
      LawyerRegisterRequest(:final fullName, :final barLicenseNumber, :final mainSpecialty) => {
        'accountType': 'lawyer',
        'fullName': fullName,
        'barLicenseNumber': barLicenseNumber,
        'mainSpecialty': mainSpecialty,
      },
    };
    return {
      ...typeFields,
      'phone': request.phone,
      'email': request.email,
      'password': request.password,
      'acceptTerms': request.acceptTerms,
      'termsVersion': request.termsVersion,
    };
  }

  // --- responses ---------------------------------------------------------

  static Map<String, dynamic> data(Object? body) {
    return (body as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  static List<dynamic> dataList(Object? body) {
    return (body as Map<String, dynamic>)['data'] as List<dynamic>;
  }

  static AuthUser user(Map<String, dynamic> userJson) {
    return AuthUser(
      id: userJson['id'] as String,
      fullName: userJson['fullName'] as String,
      email: userJson['email'] as String,
      phone: userJson['phone'] as String?,
      role: UserRoleWire.fromWire(userJson['role'] as String),
      phoneVerified: userJson['phoneVerified'] as bool,
    );
  }

  static AuthTokens tokens(Map<String, dynamic> tokensJson) {
    return AuthTokens(accessToken: tokensJson['accessToken'] as String, refreshToken: tokensJson['refreshToken'] as String);
  }

  static ({AuthUser user, AuthTokens tokens}) session(Object? body) {
    final data = AuthWire.data(body);
    return (user: user(data['user'] as Map<String, dynamic>), tokens: tokens(data['tokens'] as Map<String, dynamic>));
  }

  static AuthSession sessionSummary(Map<String, dynamic> json) {
    return AuthSession(
      id: json['id'] as String,
      deviceLabel: json['deviceLabel'] as String?,
      ipAddress: json['ipAddress'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] == null ? null : DateTime.parse(json['lastUsedAt'] as String),
      isCurrent: json['current'] as bool? ?? false,
    );
  }
}
