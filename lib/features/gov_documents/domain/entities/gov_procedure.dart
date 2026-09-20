/// Fixed, app-known taxonomy — mirrors [ContractCategory]: a real
/// government-integration backend would send this, but the set is small
/// and app-known enough to model as an enum and localize via l10n.
enum GovProcedureType { companyRegistration, propertyRegistration, contractNotarization, lawsuitFiling }

/// Whether the procedure can be completed through a direct online
/// integration (mock only — no real government API) or is informational
/// only, matching the reference's two badge styles.
enum GovProcedureAccessType { directLink, guide }

class GovRequiredDocument {
  const GovRequiredDocument({required this.id, required this.title});
  final String id;
  final String title;
}

class GovProcedureStep {
  const GovProcedureStep({required this.order, required this.title, required this.description});
  final int order;
  final String title;
  final String description;
}

/// One government-documents catalog entry — required-document names and
/// step descriptions are backend-owned catalog content (localized
/// server-side per docs/backend/01-domain-model.md §10), not l10n keys;
/// the procedure's own identity/category *is* l10n-driven
/// (see `GovProcedureTypeX`), since — like [ContractCategory] — it's a
/// small fixed taxonomy rather than free-form content.
class GovProcedure {
  const GovProcedure({
    required this.id,
    required this.type,
    required this.durationLabel,
    required this.accessType,
    required this.requiredDocuments,
    required this.steps,
  });

  /// Backend row id — needed to address `/v1/gov-procedures/{id}/progress`.
  /// `type` remains the stable identity used throughout the UI/routing.
  final String id;
  final GovProcedureType type;
  final String durationLabel;
  final GovProcedureAccessType accessType;
  final List<GovRequiredDocument> requiredDocuments;
  final List<GovProcedureStep> steps;
}

/// Per-procedure progress — which required documents the user has marked
/// ready, and whether they've tapped "Start Procedure". Persisted
/// server-side per user+procedure (docs/backend/01-domain-model.md §10
/// `UserGovProcedureProgress`).
class GovProcedureProgress {
  const GovProcedureProgress({this.checkedDocumentIds = const {}, this.started = false});

  final Set<String> checkedDocumentIds;
  final bool started;

  GovProcedureProgress copyWith({Set<String>? checkedDocumentIds, bool? started}) {
    return GovProcedureProgress(checkedDocumentIds: checkedDocumentIds ?? this.checkedDocumentIds, started: started ?? this.started);
  }
}
