import 'package:aqd_ionbit/core/security/secure_storage_service.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';
import 'package:aqd_ionbit/core/utils/app_logger.dart';

/// iOS keeps Keychain items after the app is deleted, so without this a
/// reinstall would silently resume the previous owner's session.
/// `SharedPreferences` *is* wiped on uninstall, so an empty preferences
/// store next to a populated Keychain means "fresh install": the leftover
/// secrets are dropped before anything reads them.
class FreshInstallGuard {
  const FreshInstallGuard({required AppPreferences preferences, required SecureStorageService secureStorage})
    : _preferences = preferences,
      _secureStorage = secureStorage;

  final AppPreferences _preferences;
  final SecureStorageService _secureStorage;

  Future<void> run() async {
    if (_preferences.isInstallInitialized) return;

    // Installs that predate this guard already have preferences (the
    // onboarding flag) — they are upgrades, not reinstalls, so their
    // session is kept.
    if (!_preferences.hasSeenOnboarding) {
      try {
        await _secureStorage.deleteAll().timeout(const Duration(seconds: 5));
      } catch (e, stackTrace) {
        AppLogger.error('Failed to clear secure storage on fresh install', error: e, stackTrace: stackTrace);
      }
    }
    await _preferences.markInstallInitialized();
  }
}
