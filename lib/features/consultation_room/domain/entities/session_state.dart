/// The live-session runtime's own state machine — narrower than
/// [ConsultationStatus] (which also covers the booking stage), this is
/// what the `consultation_room` feature's controller/repository actually
/// drive while a session is being joined/connected/run.
///
/// [waiting] → [ready] → [connecting] (voice/video only) → [active] →
/// [ended], with [failed] reachable from [connecting] or [active] when a
/// connection attempt or an already-active call breaks down.
enum SessionState { waiting, ready, connecting, active, ended, failed }
