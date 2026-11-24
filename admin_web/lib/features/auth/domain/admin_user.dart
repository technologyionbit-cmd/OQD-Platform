import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_user.freezed.dart';
part 'admin_user.g.dart';

/// The signed-in staff member, as returned by `/admin-auth/*`.
@freezed
abstract class AdminUser with _$AdminUser {
  const factory AdminUser({
    required String id,
    required String fullName,
    required String email,
    required String role,
    String? phone,

    /// Full access sees everything and manages other admins. Otherwise
    /// [permissions] lists `<module>.view` / `<module>.manage`.
    @Default(false) bool fullAccess,
    @Default(<String>[]) List<String> permissions,
  }) = _AdminUser;

  const AdminUser._();

  factory AdminUser.fromJson(Map<String, dynamic> json) => _$AdminUserFromJson(json);

  bool get isAdmin => role == 'admin';

  /// May this admin open [module]? With [manage] the question is whether
  /// they may change things there, not just look. The server enforces the
  /// same rule; this only decides what the app shows.
  bool can(String module, {bool manage = false}) {
    if (fullAccess) return true;
    if (permissions.contains('$module.manage')) return true;
    return !manage && permissions.contains('$module.view');
  }

  /// First letter(s) for the avatar.
  String get initials {
    String first(String word) => String.fromCharCode(word.runes.first);
    final parts = fullName.trim().split(RegExp(r'\s+')).where((String p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return first(parts.first);
    return '${first(parts.first)}${first(parts.last)}';
  }
}
