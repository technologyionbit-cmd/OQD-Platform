/// Holds the short-lived access token **in memory only**. It is never put in
/// localStorage/sessionStorage: a page reload drops it, and the app gets a
/// new one from the httpOnly refresh cookie (`/admin-auth/refresh`).
class SessionStore {
  String? _accessToken;

  String? get accessToken => _accessToken;

  // ignore: use_setters_to_change_properties
  void setAccessToken(String? token) => _accessToken = token;

  void clear() => _accessToken = null;
}
