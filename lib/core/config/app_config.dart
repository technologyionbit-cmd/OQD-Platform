import 'package:flutter/foundation.dart';

/// Single runtime configuration for the app. There is one build — no
/// dev/staging/production flavors. [apiBaseUrl] defaults to the local
/// backend and can be overridden at compile time without touching code:
///
/// ```
/// flutter run --dart-define=API_BASE_URL=https://api.aqd.example.com/v1
/// ```
class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.enableNetworkLogging});

  factory AppConfig.resolve() {
    const defined = String.fromEnvironment('API_BASE_URL');
    return AppConfig(
      apiBaseUrl: defined.isNotEmpty ? defined : _defaultApiBaseUrl,
      enableNetworkLogging: !kReleaseMode,
    );
  }

  /// Production NestJS backend on the VPS. Override via
  /// `--dart-define=API_BASE_URL=...` for local dev against
  /// `backend/` (`npm run dev`) or a LAN address on a physical device.
  static const _defaultApiBaseUrl = 'https://oqdjo.com/v1';

  final String apiBaseUrl;
  final bool enableNetworkLogging;
}
