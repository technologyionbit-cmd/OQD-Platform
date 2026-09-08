import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/ai/domain/entities/analysis_clause.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/analysis_risk_level.dart';

part 'contract_analysis.freezed.dart';

@freezed
abstract class ContractAnalysis with _$ContractAnalysis {
  const factory ContractAnalysis({
    required String id,
    required String documentTitle,
    required DateTime createdAt,
    required AnalysisRiskLevel overallRisk,
    required String summary,
    required List<AnalysisClause> clauses,
    /// The document/contract this analysis was run on, when it came from
    /// the client's own vault rather than a freshly "uploaded" mock file.
    String? sourceDocumentId,
  }) = _ContractAnalysis;
}
