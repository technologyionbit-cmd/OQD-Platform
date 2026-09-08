import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/ai/domain/entities/analysis_risk_level.dart';

part 'analysis_clause.freezed.dart';

@freezed
abstract class AnalysisClause with _$AnalysisClause {
  const factory AnalysisClause({
    required String id,
    required String title,
    required String content,
    required AnalysisRiskLevel riskLevel,
    required String recommendation,
  }) = _AnalysisClause;
}
