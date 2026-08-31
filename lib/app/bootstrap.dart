import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/app/app.dart';
import 'package:aqd_ionbit/core/config/env_config.dart';
import 'package:aqd_ionbit/core/config/environment.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';
import 'package:aqd_ionbit/core/utils/app_logger.dart';

/// Single composition root for all three flavors — each `main_<env>.dart`
/// only differs in which [Environment] it passes here.
Future<void> bootstrap(Environment environment) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final envConfig = EnvConfig.forEnvironment(environment);
      final sharedPreferences = await SharedPreferences.getInstance();

      FlutterError.onError = (details) {
        AppLogger.error('Uncaught Flutter error', error: details.exception, stackTrace: details.stack);
      };

      runApp(
        ProviderScope(
          overrides: [
            envConfigProvider.overrideWithValue(envConfig),
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
