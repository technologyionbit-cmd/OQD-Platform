import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive local preferences only (locale, theme mode, onboarding
/// flags). Tokens and anything sensitive belong in [TokenManager] /
/// [SecureStorageService] instead — never here.
class AppPreferences {
  AppPreferences(this._prefs);

  static const _localeKey = 'prefs.locale';
  static const _themeModeKey = 'prefs.theme_mode';
  static const _onboardingSeenKey = 'prefs.onboarding_seen';
  static const _notificationsEnabledKey = 'prefs.notifications_enabled';
  static const _installInitializedKey = 'prefs.install_initialized';

  final SharedPreferences _prefs;

  /// Set once on first launch — see [FreshInstallGuard].
  bool get isInstallInitialized => _prefs.getBool(_installInitializedKey) ?? false;
  Future<void> markInstallInitialized() => _prefs.setBool(_installInitializedKey, true);

  String? get localeCode => _prefs.getString(_localeKey);
  Future<void> setLocaleCode(String code) => _prefs.setString(_localeKey, code);

  String? get themeMode => _prefs.getString(_themeModeKey);
  Future<void> setThemeMode(String mode) => _prefs.setString(_themeModeKey, mode);

  bool get hasSeenOnboarding => _prefs.getBool(_onboardingSeenKey) ?? false;
  Future<void> setOnboardingSeen(bool seen) => _prefs.setBool(_onboardingSeenKey, seen);

  bool get notificationsEnabled => _prefs.getBool(_notificationsEnabledKey) ?? true;
  Future<void> setNotificationsEnabled(bool enabled) => _prefs.setBool(_notificationsEnabledKey, enabled);
}
