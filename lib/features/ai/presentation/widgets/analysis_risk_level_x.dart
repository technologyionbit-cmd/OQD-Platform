import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/analysis_risk_level.dart';

extension AnalysisRiskLevelX on AnalysisRiskLevel {
  String label(AppLocalizations l10n) {
    return switch (this) {
      AnalysisRiskLevel.low => l10n.analysisRiskLow,
      AnalysisRiskLevel.medium => l10n.analysisRiskMedium,
      AnalysisRiskLevel.high => l10n.analysisRiskHigh,
    };
  }

  AppStatusTone get tone {
    return switch (this) {
      AnalysisRiskLevel.low => AppStatusTone.success,
      AnalysisRiskLevel.medium => AppStatusTone.warning,
      AnalysisRiskLevel.high => AppStatusTone.error,
    };
  }
}
