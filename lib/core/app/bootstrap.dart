import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/app.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';
import 'package:aqd_ionbit/core/utils/app_logger.dart';

/// The one composition root. Resolves the runtime [AppConfig] and async
/// [SharedPreferences], then boots the widget tree inside a guarded zone.
Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final sharedPreferences = await SharedPreferences.getInstance();

      FlutterError.onError = (details) {
        AppLogger.error('Uncaught Flutter error', error: details.exception, stackTrace: details.stack);
      };

      runApp(
        ProviderScope(
          overrides: [
            appPreferencesProvider.overrideWithValue(AppPreferences(sharedPreferences)),
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
