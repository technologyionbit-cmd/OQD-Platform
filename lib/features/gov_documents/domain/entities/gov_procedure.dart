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
/// step descriptions are mock catalog content (hardcoded Arabic, same
/// convention as `ContractsMockDataSource`'s template field labels), not
/// l10n keys; the procedure's own identity/category *is* l10n-driven
/// (see `GovProcedureTypeX`), since — like [ContractCategory] — it's a
/// small fixed taxonomy rather than free-form content.
class GovProcedure {
  const GovProcedure({
    required this.type,
    required this.durationLabel,
    required this.accessType,
    required this.requiredDocuments,
    required this.steps,
  });

  final GovProcedureType type;
  final String durationLabel;
  final GovProcedureAccessType accessType;
  final List<GovRequiredDocument> requiredDocuments;
  final List<GovProcedureStep> steps;
}
