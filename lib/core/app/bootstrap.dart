import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/app.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/providers/provider_retry.dart';
import 'package:aqd_ionbit/core/security/fresh_install_guard.dart';
import 'package:aqd_ionbit/core/security/secure_storage_service.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';
import 'package:aqd_ionbit/core/utils/app_logger.dart';

/// The one composition root. Resolves the runtime [AppConfig] and async
/// [SharedPreferences], then boots the widget tree inside a guarded zone.
Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        AppLogger.error('Uncaught Flutter error', error: details.exception, stackTrace: details.stack);
      };
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        AppLogger.error('Uncaught platform error', error: error, stackTrace: stackTrace);
        return true;
      };

      final preferences = AppPreferences(await SharedPreferences.getInstance());
      final secureStorage = SecureStorageService();
      await FreshInstallGuard(preferences: preferences, secureStorage: secureStorage).run();

      runApp(
        ProviderScope(
          retry: providerRetry,
          overrides: [
            appPreferencesProvider.overrideWithValue(preferences),
            secureStorageServiceProvider.overrideWithValue(secureStorage),
          ],
          child: const AqdApp(),
        ),
      );
    },
    (error, stackTrace) {
      AppLogger.error('Uncaught async error', error: error, stackTrace: stackTrace);
    },
  );
}
