import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/config/app_config.dart';
import 'package:aqd_ionbit/core/network/auth_session_ports.dart';
import 'package:aqd_ionbit/core/network/dio_client.dart';
import 'package:aqd_ionbit/core/security/secure_storage_service.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';

/// Runtime configuration. [AppConfig.resolve] needs nothing from
/// `bootstrap()` (it reads compile-time `--dart-define`s and the build
/// mode), so this has a real default; tests may still override it.
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.resolve());

/// [AppPreferences] wraps an async `SharedPreferences.getInstance()` that
/// can only be resolved once `bootstrap()` has awaited it, so this is
/// overridden in `ProviderScope(overrides: [...])` at app start (see
/// `core/app/bootstrap.dart`). Reading it before that override is a
/// programmer error, so it throws loudly instead of silently defaulting.
final appPreferencesProvider = Provider<AppPreferences>((ref) {
  throw UnimplementedError('appPreferencesProvider must be overridden in bootstrap()');
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) => SecureStorageService());

final tokenManagerProvider = Provider<TokenManager>((ref) => TokenManager(ref.watch(secureStorageServiceProvider)));

final tokenRefresherProvider = Provider<TokenRefresher>((ref) => TokenRefresher());

final sessionExpiredNotifierProvider = Provider<SessionExpiredNotifier>((ref) => SessionExpiredNotifier());

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    appConfig: ref.watch(appConfigProvider),
    tokenManager: ref.watch(tokenManagerProvider),
    onSessionExpired: () => ref.read(sessionExpiredNotifierProvider).notify(),
    onRefreshToken: ref.watch(tokenRefresherProvider).call,
  );
});

final dioProvider = Provider((ref) => ref.watch(dioClientProvider).dio);
