/// Drives UX only (which shell/nav the app shows). The backend remains the
/// sole authority on what a given role is actually allowed to do — this
/// enum must never be treated as an authorization mechanism.
enum UserRole { client, lawyer, company }

extension UserRoleWire on UserRole {
  /// The string the backend uses for this role (`client`/`lawyer`/`company`).
  String get wireValue => name;

  /// Parses a backend role string. Throws on an unknown value rather than
  /// silently defaulting — an unrecognised role is a contract mismatch.
  static UserRole fromWire(String value) => UserRole.values.byName(value.trim());

  /// Like [fromWire] but returns null for a role this app has no shell for
  /// (the backend also has `admin`, which is served by the admin API only).
  static UserRole? tryFromWire(String value) {
    final trimmed = value.trim();
    for (final role in UserRole.values) {
      if (role.name == trimmed) return role;
    }
    return null;
  }
}
