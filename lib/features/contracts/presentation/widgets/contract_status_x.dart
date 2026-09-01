import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_status.dart';

/// Localized label + [StatusBadge] tone for each status — defined once so
/// the list, details, and preview screens never duplicate this mapping.
extension ContractStatusX on ContractStatus {
  String label(AppLocalizations l10n) {
    return switch (this) {
      ContractStatus.draft => l10n.contractStatusDraft,
      ContractStatus.pendingSignature => l10n.contractStatusPendingSignature,
      ContractStatus.signed => l10n.contractStatusSigned,
      ContractStatus.completed => l10n.contractStatusCompleted,
      ContractStatus.cancelled => l10n.contractStatusCancelled,
    };
  }

  AppStatusTone get tone {
    return switch (this) {
      ContractStatus.draft => AppStatusTone.neutral,
      ContractStatus.pendingSignature => AppStatusTone.warning,
      ContractStatus.signed => AppStatusTone.info,
      ContractStatus.completed => AppStatusTone.success,
      ContractStatus.cancelled => AppStatusTone.error,
    };
  }
}
