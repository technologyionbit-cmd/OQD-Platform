/// The events the server notifies about — mirrors the backend's
/// `NotificationType` enum. The app builds each notification's text from
/// its type and params, so it always shows in the current language.
enum NotificationType {
  /// A client asked a lawyer for a consultation (sent to the lawyer).
  consultationRequested,
  consultationAccepted,
  consultationRejected,
  consultationCancelled,
  consultationCompleted,
  consultationRescheduled,
  /// An admin approved the lawyer's verification (sent to the lawyer).
  lawyerVerificationApproved,
  /// An admin rejected it; `params['reason']` says why.
  lawyerVerificationRejected,
}
