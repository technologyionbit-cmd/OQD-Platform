/// Fixed, app-known taxonomy of notification events — mirrors how
/// [ContractCategory]/[ContractStatus] are modeled as enums rather than
/// arbitrary backend strings, since the app itself decides when each of
/// these fires (contract generated, booking accepted, ...).
enum NotificationType {
  contractCreated,
  contractUpdated,
  contractReady,
  contractRequiresAction,
  consultationBooked,
  consultationAccepted,
  consultationRejected,
  consultationCancelled,
  consultationCompleted,
  consultationReminder,
  newMessage,
  documentUploaded,
  aiAnalysisCompleted,
}
