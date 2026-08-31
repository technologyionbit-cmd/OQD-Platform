import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/config/env_config.dart';
import 'package:aqd_ionbit/core/network/auth_session_ports.dart';
import 'package:aqd_ionbit/core/network/dio_client.dart';
import 'package:aqd_ionbit/core/security/secure_storage_service.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';

/// [EnvConfig] and [AppPreferences] depend on values only known once
/// `bootstrap()` resolves them (env is a compile-time selection, prefs
/// wraps an async `SharedPreferences.getInstance()`) — both are overridden
/// in `ProviderScope(overrides: [...])` at app start (see `app/bootstrap.dart`).
/// Reading either before that override is a programmer error, so they throw
/// loudly instead of silently falling back to a default.
final envConfigProvider = Provider<EnvConfig>((ref) {
  throw UnimplementedError('envConfigProvider must be overridden in bootstrap()');
});

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  throw UnimplementedError('appPreferencesProvider must be overridden in bootstrap()');
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) => SecureStorageService());

final tokenManagerProvider = Provider<TokenManager>((ref) => TokenManager(ref.watch(secureStorageServiceProvider)));

final tokenRefresherProvider = Provider<TokenRefresher>((ref) => TokenRefresher());

final sessionExpiredNotifierProvider = Provider<SessionExpiredNotifier>((ref) => SessionExpiredNotifier());

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    envConfig: ref.watch(envConfigProvider),
    tokenManager: ref.watch(tokenManagerProvider),
    onSessionExpired: () => ref.read(sessionExpiredNotifierProvider).notify(),
    onRefreshToken: ref.watch(tokenRefresherProvider).call,
  );
});

final dioProvider = Provider((ref) => ref.watch(dioClientProvider).dio);
