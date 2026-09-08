/// Full lifecycle of a booked consultation, spanning both the booking
/// stage and the live-session stage so any screen watching a
/// [Consultation]'s status can tell where it is end-to-end:
///
/// - Booking stage: [pendingApproval] (client picked a slot, lawyer hasn't
///   responded) resolves to [confirmed] or [declined]; [confirmed] can
///   still be [cancelled] by either side before the session starts.
/// - Live-session stage (driven by the `consultation_room` feature's own
///   runtime, mirrored here for list/badge display): [waiting] (join
///   window open) → [ready] (both sides can start) → [connecting]
///   (voice/video only) → [active] → [ended].
/// - Terminal outcomes: [ended] resolves to [completed]; a session can
///   also end as [missed] (nobody joined within the grace period) or
///   [failed] (connection could not be established/maintained).
enum ConsultationStatus {
  pendingApproval,
  confirmed,
  waiting,
  ready,
  connecting,
  active,
  ended,
  completed,
  cancelled,
  declined,
  missed,
  failed,
}

/// Valid forward transitions for [ConsultationStatus], enforced by
/// [ConsultationStatusX.canTransitionTo]/[ConsultationStatusX.transitionTo]
/// so nothing in the app can push a consultation into a state its current
/// state can't reach.
const Map<ConsultationStatus, Set<ConsultationStatus>> _kConsultationTransitions = {
  ConsultationStatus.pendingApproval: {ConsultationStatus.confirmed, ConsultationStatus.declined, ConsultationStatus.cancelled},
  ConsultationStatus.confirmed: {ConsultationStatus.waiting, ConsultationStatus.cancelled},
  ConsultationStatus.waiting: {ConsultationStatus.ready, ConsultationStatus.cancelled},
  ConsultationStatus.ready: {ConsultationStatus.connecting, ConsultationStatus.active, ConsultationStatus.missed, ConsultationStatus.cancelled},
  ConsultationStatus.connecting: {ConsultationStatus.active, ConsultationStatus.failed},
  ConsultationStatus.active: {ConsultationStatus.ended, ConsultationStatus.failed},
  ConsultationStatus.ended: {ConsultationStatus.completed},
  ConsultationStatus.completed: {},
  ConsultationStatus.cancelled: {},
  ConsultationStatus.declined: {},
  ConsultationStatus.missed: {},
  ConsultationStatus.failed: {},
};

extension ConsultationStatusX on ConsultationStatus {
  /// Whether moving from this status directly to [target] is a legal
  /// lifecycle transition.
  bool canTransitionTo(ConsultationStatus target) => _kConsultationTransitions[this]?.contains(target) ?? false;

  /// Whether a live session (voice/video call, or a fresh written-chat
  /// join) can ever be entered while a [Consultation] is in this status —
  /// [pendingApproval] hasn't been approved yet, and every other value here
  /// is a terminal outcome with nothing left to join. `confirmed` (still
  /// waiting to start) and the in-progress values (`waiting`/`ready`/
  /// `connecting`/`active`) are the only ones where entering makes sense.
  ///
  /// This is the single source of truth `ConsultationWaitingScreen` and the
  /// three live-session screens (`ChatRoomScreen`, `VoiceCallScreen`,
  /// `VideoCallScreen`) all gate on — without it, reaching one of those
  /// screens directly (a stale deep link, a browser back/forward on web, or
  /// simply re-pushing an old route) would auto-join purely off session
  /// timing, bypassing the booking-level status entirely. [completed] is
  /// the one exception a caller may still want to special-case: a
  /// completed *written* consultation still has a real transcript worth
  /// showing read-only, even though there's no live session left to join.
  bool get blocksLiveSession => switch (this) {
    ConsultationStatus.confirmed ||
    ConsultationStatus.waiting ||
    ConsultationStatus.ready ||
    ConsultationStatus.connecting ||
    ConsultationStatus.active => false,
    ConsultationStatus.pendingApproval ||
    ConsultationStatus.ended ||
    ConsultationStatus.completed ||
    ConsultationStatus.cancelled ||
    ConsultationStatus.declined ||
    ConsultationStatus.missed ||
    ConsultationStatus.failed => true,
  };

  /// Returns [target] if the transition is legal, otherwise throws a
  /// [StateError] — use [canTransitionTo] first when an invalid transition
  /// should be handled gracefully instead of throwing.
  ConsultationStatus transitionTo(ConsultationStatus target) {
    if (!canTransitionTo(target)) {
      throw StateError('Invalid consultation status transition: $this -> $target');
    }
    return target;
  }
}
