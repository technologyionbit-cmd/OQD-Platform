import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/team/domain/entities/team_member_role.dart';

extension TeamMemberRoleX on TeamMemberRole {
  String label(AppLocalizations l10n) {
    return switch (this) {
      TeamMemberRole.admin => l10n.teamRoleAdmin,
      TeamMemberRole.manager => l10n.teamRoleManager,
      TeamMemberRole.member => l10n.teamRoleMember,
    };
  }

  AppStatusTone get tone {
    return switch (this) {
      TeamMemberRole.admin => AppStatusTone.info,
      TeamMemberRole.manager => AppStatusTone.warning,
      TeamMemberRole.member => AppStatusTone.neutral,
    };
  }
}
