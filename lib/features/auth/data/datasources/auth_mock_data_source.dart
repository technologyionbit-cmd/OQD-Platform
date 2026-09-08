import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';

/// Temporary, isolated stand-in for the real backend (no Aqd API contract
/// is available to the frontend yet — see `docs`/PR description). Lives
/// entirely behind [AuthRemoteDataSource]; nothing outside `data/` knows
/// this class exists. Demo credentials below are for local development only.
///
/// Demo accounts (password for all: `Password123`):
///  - client@aqd.test  (UserRole.client)
///  - lawyer@aqd.test  (UserRole.lawyer)
///  - company@aqd.test (UserRole.company)
class AuthMockDataSource implements AuthRemoteDataSource {
  final Map<String, _MockAccount> _accounts = {
    'client@aqd.test': _MockAccount(
      password: 'Password123',
      user: const AuthUser(id: 'u_client_1', fullName: 'أحمد العتيبي', email: 'client@aqd.test', role: UserRole.client),
    ),
    'lawyer@aqd.test': _MockAccount(
      password: 'Password123',
      user: const AuthUser(id: 'u_lawyer_1', fullName: 'سارة المطيري', email: 'lawyer@aqd.test', role: UserRole.lawyer),
    ),
    'company@aqd.test': _MockAccount(
      password: 'Password123',
      user: const AuthUser(
        id: 'u_company_1',
        fullName: 'شركة الرواد القانونية',
        email: 'company@aqd.test',
        role: UserRole.company,
      ),
    ),
  };

  final Map<String, AuthUser> _sessionsByAccessToken = {};
  final Map<String, String> _accessTokenByRefreshToken = {};

  @override
  Future<({AuthUser user, AuthTokens tokens})> login({required String email, required String password}) async {
    await _simulateLatency();
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const UnauthorizedFailure();
    }
    final tokens = _issueSession(account.user);
    return (user: account.user, tokens: tokens);
  }

  @override
  Future<({AuthUser user, AuthTokens tokens})> register(RegisterRequest request) async {
    await _simulateLatency();

    final (email, fullName, role) = switch (request) {
      IndividualRegisterRequest(:final email, :final fullName) => (email, fullName, UserRole.client),
      CompanyRegisterRequest(:final email, :final companyName) => (email, companyName, UserRole.company),
      LawyerRegisterRequest(:final email, :final fullName) => (email, fullName, UserRole.lawyer),
    };
    final password = switch (request) {
      IndividualRegisterRequest(:final password) => password,
      CompanyRegisterRequest(:final password) => password,
      LawyerRegisterRequest(:final password) => password,
    };

    final normalizedEmail = email.trim().toLowerCase();
    if (_accounts.containsKey(normalizedEmail)) {
      throw const ValidationFailure(fieldErrors: {
        'email': ['هذا البريد الإلكتروني مسجل بالفعل'],
      });
    }

    final user = AuthUser(id: 'u_${DateTime.now().microsecondsSinceEpoch}', fullName: fullName, email: normalizedEmail, role: role);
    _accounts[normalizedEmail] = _MockAccount(password: password, user: user);

    final tokens = _issueSession(user);
    return (user: user, tokens: tokens);
  }

  @override
  Future<AuthTokens> refreshToken(String refreshToken) async {
    await _simulateLatency();
    final oldAccessToken = _accessTokenByRefreshToken.remove(refreshToken);
    final user = oldAccessToken == null ? null : _sessionsByAccessToken.remove(oldAccessToken);
    if (user == null) throw const UnauthorizedFailure();
    return _issueSession(user);
  }

  @override
  Future<AuthUser> currentUser(String accessToken) async {
    await _simulateLatency();
    final user = _sessionsByAccessToken[accessToken];
    if (user == null) throw const UnauthorizedFailure();
    return user;
  }

  @override
  Future<AuthUser> updateProfile({required String accessToken, required String fullName, required String email}) async {
    await _simulateLatency();
    final existing = _sessionsByAccessToken[accessToken];
    if (existing == null) throw const UnauthorizedFailure();

    final normalizedEmail = email.trim().toLowerCase();
    final updated = AuthUser(id: existing.id, fullName: fullName, email: normalizedEmail, role: existing.role);

    // Keep the accounts map keyed by the current email, moving the entry
    // if the email itself changed.
    final oldEmailKey = _accounts.entries.where((e) => e.value.user.id == existing.id).map((e) => e.key).firstOrNull;
    if (oldEmailKey != null) {
      final account = _accounts.remove(oldEmailKey)!;
      _accounts[normalizedEmail] = _MockAccount(password: account.password, user: updated);
    }
    _sessionsByAccessToken[accessToken] = updated;
    return updated;
  }

  @override
  Future<void> logout(String accessToken) async {
    await _simulateLatency();
    _sessionsByAccessToken.remove(accessToken);
  }

  @override
  Future<void> requestOtp({required String destination}) async {
    await _simulateLatency();
  }

  @override
  Future<bool> verifyOtp({required String destination, required String code}) async {
    await _simulateLatency();
    return code == '1234';
  }

  @override
  Future<void> resetPassword({required String destination, required String code, required String newPassword}) async {
    await _simulateLatency();
    if (code != '1234') throw const UnauthorizedFailure();

    final account = _accounts[destination.trim().toLowerCase()];
    if (account != null) {
      _accounts[destination.trim().toLowerCase()] = _MockAccount(password: newPassword, user: account.user);
    }
    // Unknown destination (e.g. a phone number, not one of the demo emails)
    // still succeeds — a real backend looks the account up by verified
    // phone/email, which this mock has no equivalent index for.
  }

  AuthTokens _issueSession(AuthUser user) {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final tokens = AuthTokens(accessToken: 'mock-access-${user.id}-$stamp', refreshToken: 'mock-refresh-${user.id}-$stamp');
    _sessionsByAccessToken[tokens.accessToken] = user;
    _accessTokenByRefreshToken[tokens.refreshToken] = tokens.accessToken;
    return tokens;
  }

  Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 600));
}

class _MockAccount {
  const _MockAccount({required this.password, required this.user});
  final String password;
  final AuthUser user;
}
