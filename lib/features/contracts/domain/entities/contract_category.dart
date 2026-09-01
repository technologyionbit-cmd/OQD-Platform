/// Fixed, app-known taxonomy — not arbitrary API content, so (unlike
/// template titles/field labels) this is safe to model as a Dart enum and
/// localize via l10n the same way [UserRole] is.
enum ContractCategory { employment, sale, rental, partnership, nda, serviceAgreement, other }
