/// Replaces the old pair of independent booleans on [LawyerProfile]
/// (`isVerified`/`hasPendingVerification`), which allowed illegal
/// combinations (e.g. both `true`) and had no terminal `rejected` state.
/// Mirrors the backend's `LawyerVerificationStatus` enum exactly
/// (docs/backend/01-domain-model.md §3).
enum VerificationStatus { unverified, pending, verified, rejected }
