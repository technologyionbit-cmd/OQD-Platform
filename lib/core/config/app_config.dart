import 'package:flutter/foundation.dart';

/// Single runtime configuration for the app. There are no flavors.
/// [apiBaseUrl] defaults to the deployed backend in every build mode and can
/// be overridden at compile time without touching code, e.g. to run against a
/// local `backend/` (`npm run dev`):
///
/// ```
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/v1
/// ```
///
/// The terms and privacy pages are overridable the same way
/// (`TERMS_URL`, `PRIVACY_URL`).
class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.enableNetworkLogging, this.termsUrl = _defaultTermsUrl, this.privacyUrl = _defaultPrivacyUrl});

  factory AppConfig.resolve() {
    const defined = String.fromEnvironment('API_BASE_URL');
    const terms = String.fromEnvironment('TERMS_URL');
    const privacy = String.fromEnvironment('PRIVACY_URL');
    return AppConfig(
      apiBaseUrl: defined.isNotEmpty ? defined : _defaultApiBaseUrl,
      enableNetworkLogging: !kReleaseMode,
      termsUrl: terms.isNotEmpty ? terms : _defaultTermsUrl,
      privacyUrl: privacy.isNotEmpty ? privacy : _defaultPrivacyUrl,
    );
  }

  /// The deployed NestJS backend on the VPS. For a local backend use
  /// `--dart-define=API_BASE_URL=...`: `http://10.0.2.2:3000/v1` from the
  /// Android emulator, `http://localhost:3000/v1` from the iOS simulator or
  /// desktop, the computer's LAN address from a physical device.
  static const _defaultApiBaseUrl = 'https://oqdjo.com/v1';

  // Placeholders until the published pages exist.
  static const _defaultTermsUrl = 'https://oqdjo.com/terms';
  static const _defaultPrivacyUrl = 'https://oqdjo.com/privacy';

  /// The terms/privacy version the register screen shows and the user
  /// accepts. Must equal the backend's TERMS_VERSION — bump both together
  /// when the published terms change.
  static const termsVersion = '2026-09-28';

  final String apiBaseUrl;
  final bool enableNetworkLogging;
  final String termsUrl;
  final String privacyUrl;
}
