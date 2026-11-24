/// Runtime configuration for the admin app. Override at build time, e.g.
/// against a local backend:
///
/// ```
/// flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/v1
/// ```
class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  factory AppConfig.resolve() {
    const defined = String.fromEnvironment('API_BASE_URL');
    return AppConfig(apiBaseUrl: defined.isNotEmpty ? defined : _defaultApiBaseUrl);
  }

  /// The deployed NestJS backend. The refresh cookie is scoped to this host
  /// (`/v1/admin-auth`), and the admin app lives on a sibling subdomain, so
  /// the browser treats the two as same-site.
  static const _defaultApiBaseUrl = 'https://oqdjo.com/v1';

  final String apiBaseUrl;
}
