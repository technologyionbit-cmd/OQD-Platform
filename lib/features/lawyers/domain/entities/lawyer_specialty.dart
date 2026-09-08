/// Fixed, app-known taxonomy — mirrors [ContractCategory]: a real backend
/// would send lawyer specialties too, but the set is small and app-known
/// enough to model as an enum and localize via l10n rather than free text.
enum LawyerSpecialty { commercial, personalStatus, criminal, labor, realEstate, corporate, intellectualProperty, general }
