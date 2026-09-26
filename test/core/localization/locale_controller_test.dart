import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/core/localization/locale_controller.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';

void main() {
  group('resolveDeviceLocale', () {
    test('uses the device language when the app supports it', () {
      expect(LocaleController.resolveDeviceLocale(const [Locale('en', 'US')]), const Locale('en'));
      expect(LocaleController.resolveDeviceLocale(const [Locale('ar', 'JO')]), const Locale('ar'));
    });

    test('takes the first supported language in the device preference order', () {
      expect(LocaleController.resolveDeviceLocale(const [Locale('fr'), Locale('en'), Locale('ar')]), const Locale('en'));
    });

    test('falls back to Arabic when no device language is supported', () {
      expect(LocaleController.resolveDeviceLocale(const [Locale('fr'), Locale('de')]), const Locale('ar'));
      expect(LocaleController.resolveDeviceLocale(const []), const Locale('ar'));
    });
  });

  group('LocaleController', () {
    Future<ProviderContainer> containerWith({required Map<String, Object> prefs, required List<Locale> device}) async {
      SharedPreferences.setMockInitialValues(prefs);
      final preferences = AppPreferences(await SharedPreferences.getInstance());
      final container = ProviderContainer(
        overrides: [
          appPreferencesProvider.overrideWithValue(preferences),
          deviceLocalesProvider.overrideWithValue(device),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('follows the device until the user picks a language', () async {
      final container = await containerWith(prefs: {}, device: const [Locale('en')]);
      expect(container.read(localeControllerProvider), const Locale('en'));
    });

    test('a saved choice wins over the device language', () async {
      final container = await containerWith(prefs: {'prefs.locale': 'ar'}, device: const [Locale('en')]);
      expect(container.read(localeControllerProvider), const Locale('ar'));
    });

    test('toggle switches language and persists the choice', () async {
      final container = await containerWith(prefs: {}, device: const [Locale('ar')]);

      await container.read(localeControllerProvider.notifier).toggle();

      expect(container.read(localeControllerProvider), const Locale('en'));
      expect(container.read(appPreferencesProvider).localeCode, 'en');
    });
  });
}
