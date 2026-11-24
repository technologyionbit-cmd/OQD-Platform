import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/widgets/status_chip.dart';

/// Words and colours for the values the API sends as plain strings.

String roleLabel(AppLocalizations l10n, String role) => switch (role) {
      'client' => l10n.roleClient,
      'lawyer' => l10n.roleLawyer,
      'company' => l10n.roleCompany,
      'admin' => l10n.roleAdmin,
      _ => role,
    };

String statusLabel(AppLocalizations l10n, String status) => switch (status) {
      'active' => l10n.statusActive,
      'suspended' => l10n.statusSuspended,
      'banned' => l10n.statusBanned,
      'pendingDeletion' => l10n.statusPendingDeletion,
      _ => status,
    };

StatusTone statusTone(String status) => switch (status) {
      'active' => StatusTone.success,
      'suspended' => StatusTone.warning,
      'banned' => StatusTone.error,
      _ => StatusTone.neutral,
    };

String verificationLabel(AppLocalizations l10n, String status) => switch (status) {
      'unverified' => l10n.verUnverified,
      'pending' => l10n.verPending,
      'verified' => l10n.verVerified,
      'rejected' => l10n.verRejected,
      _ => status,
    };

StatusTone verificationTone(String status) => switch (status) {
      'verified' => StatusTone.success,
      'pending' => StatusTone.warning,
      'rejected' => StatusTone.error,
      _ => StatusTone.neutral,
    };
