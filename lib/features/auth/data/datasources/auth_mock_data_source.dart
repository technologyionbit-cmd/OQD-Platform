import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
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
  Future<void> logout(String accessToken) async {
    await _simulateLatency();
    _sessionsByAccessToken.remove(accessToken);
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await _simulateLatency();
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
