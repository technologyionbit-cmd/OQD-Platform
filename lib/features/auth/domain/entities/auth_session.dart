import 'package:flutter/foundation.dart';

/// One active sign-in for the current user, as shown on the
/// "Active Sessions" list in Security & Privacy. Backed by a `refresh_token`
/// row server-side.
///
/// Plain immutable class rather than `freezed` — the field set is tiny and
/// this keeps the auth feature buildable without a codegen step.
@immutable
class AuthSession {
  const AuthSession({
    required this.id,
    required this.createdAt,
    required this.isCurrent,
    this.deviceLabel,
    this.ipAddress,
    this.lastUsedAt,
  });

  final String id;
  final String? deviceLabel;
  final String? ipAddress;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  /// Whether this is the session the app is currently signed in with — the
  /// UI must not offer to revoke it (use "sign out" instead).
  final bool isCurrent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSession &&
          other.id == id &&
          other.deviceLabel == deviceLabel &&
          other.ipAddress == ipAddress &&
          other.createdAt == createdAt &&
          other.lastUsedAt == lastUsedAt &&
          other.isCurrent == isCurrent;

  @override
  int get hashCode => Object.hash(id, deviceLabel, ipAddress, createdAt, lastUsedAt, isCurrent);
}
