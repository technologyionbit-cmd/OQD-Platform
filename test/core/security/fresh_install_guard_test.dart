import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/core/security/fresh_install_guard.dart';
import 'package:aqd_ionbit/core/security/secure_storage_service.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';

class _MockSecureStorage extends Mock implements SecureStorageService {}

void main() {
  late _MockSecureStorage secureStorage;

  setUp(() {
    secureStorage = _MockSecureStorage();
    when(() => secureStorage.deleteAll()).thenAnswer((_) async {});
  });

  Future<AppPreferences> preferences(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return AppPreferences(await SharedPreferences.getInstance());
  }

  test('wipes leftover secure storage on a fresh install and marks it initialized', () async {
    final prefs = await preferences({});

    await FreshInstallGuard(preferences: prefs, secureStorage: secureStorage).run();

    verify(() => secureStorage.deleteAll()).called(1);
    expect(prefs.isInstallInitialized, isTrue);
  });

  test('never wipes again once initialized', () async {
    final prefs = await preferences({'prefs.install_initialized': true});

    await FreshInstallGuard(preferences: prefs, secureStorage: secureStorage).run();

    verifyNever(() => secureStorage.deleteAll());
  });

  test('keeps the session of an install that predates the guard', () async {
    final prefs = await preferences({'prefs.onboarding_seen': true});

    await FreshInstallGuard(preferences: prefs, secureStorage: secureStorage).run();

    verifyNever(() => secureStorage.deleteAll());
    expect(prefs.isInstallInitialized, isTrue);
  });

  test('still completes when secure storage fails', () async {
    when(() => secureStorage.deleteAll()).thenThrow(Exception('keychain unavailable'));
    final prefs = await preferences({});

    await FreshInstallGuard(preferences: prefs, secureStorage: secureStorage).run();

    expect(prefs.isInstallInitialized, isTrue);
  });
}
