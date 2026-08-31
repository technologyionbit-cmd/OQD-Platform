import 'package:aqd_ionbit/core/security/secure_storage_service.dart';
import 'package:aqd_ionbit/core/utils/app_logger.dart';

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

/// Single source of truth for the current session's tokens.
///
/// Holds them in memory for fast access from [AuthInterceptor] on every
/// request, and mirrors them into secure storage so the session survives an
/// app restart. Never logs a token — see [AppLogger].
class TokenManager {
  TokenManager(this._secureStorage);

  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';

  final SecureStorageService _secureStorage;

  AuthTokens? _cached;

  /// A secure-storage read failure (corrupt keychain entry, first-run
  /// platform-channel hiccup, etc.) is treated the same as "no session
  /// found" rather than crashing app startup — either way the user just
  /// lands on the login screen. Bounded with a timeout too: some platform
  /// secure-storage backends can hang rather than error (observed on the
  /// Windows target with no host window), and a hung read must not freeze
  /// the splash screen forever.
  Future<AuthTokens?> loadFromStorage() async {
    try {
      final access = await _secureStorage.read(_accessTokenKey).timeout(const Duration(seconds: 5));
      final refresh = await _secureStorage.read(_refreshTokenKey).timeout(const Duration(seconds: 5));
      if (access == null || refresh == null) {
        _cached = null;
        return null;
      }
      _cached = AuthTokens(accessToken: access, refreshToken: refresh);
      return _cached;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to read session from secure storage', error: e, stackTrace: stackTrace);
      _cached = null;
      return null;
    }
  }

  AuthTokens? get current => _cached;

  Future<void> save(AuthTokens tokens) async {
    _cached = tokens;
    await _secureStorage.write(_accessTokenKey, tokens.accessToken);
    await _secureStorage.write(_refreshTokenKey, tokens.refreshToken);
  }

  Future<void> clear() async {
    _cached = null;
    await _secureStorage.delete(_accessTokenKey);
    await _secureStorage.delete(_refreshTokenKey);
  }
}
