/// Wall-clock constants governing the live-session lifecycle. Pure
/// foundation only — nothing here builds UI; screens in a later phase will
/// use these to decide when to show a join button, a countdown warning, or
/// a "missed" state.
abstract final class ConsultationRoomTiming {
  /// How long before the scheduled time either side may join the room.
  static const joinWindow = Duration(minutes: 15);

  /// How long after the scheduled time a session can still be joined —
  /// past this, the `consultations` lifecycle moves the booking to
  /// `ConsultationStatus.missed` instead.
  static const gracePeriod = Duration(minutes: 10);

  /// Hard cap on how long an active session may run.
  static const maxSessionDuration = Duration(minutes: 60);

  /// Remaining-time threshold for the first "wrapping up soon" warning.
  static const firstWarningThreshold = Duration(minutes: 5);

  /// Remaining-time threshold for the final warning before the session
  /// auto-ends.
  static const finalWarningThreshold = Duration(minutes: 1);

  /// Maximum number of automatic reconnection attempts after a dropped
  /// connection before giving up and surfacing [SessionState.failed].
  static const maxReconnectionAttempts = 3;

  /// Delay between successive reconnection attempts.
  static const reconnectionInterval = Duration(seconds: 10);

  /// Whether [now] falls within the window either side may join —
  /// [joinWindow] before [scheduledAt] through [gracePeriod] after it.
  static bool isWithinJoinWindow(DateTime scheduledAt, DateTime now) {
    return !now.isBefore(scheduledAt.subtract(joinWindow)) && now.isBefore(scheduledAt.add(gracePeriod));
  }

  /// Whether [now] is past the grace period, i.e. the join window for
  /// [scheduledAt] has closed and nobody joined.
  static bool isPastGracePeriod(DateTime scheduledAt, DateTime now) => !now.isBefore(scheduledAt.add(gracePeriod));
}
