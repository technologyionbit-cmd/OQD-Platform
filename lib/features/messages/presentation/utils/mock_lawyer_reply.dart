import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';

/// Picks one of several realistic, generic legal-consultation-style canned
/// replies — deterministic (seeded off the consultation ID and the
/// triggering message text, never `Random()`) so manual QA and widget
/// tests see the exact same reply on every run for the same input.
String pickMockLawyerReply(AppLocalizations l10n, {required String consultationId, required String triggerText}) {
  final pool = [
    l10n.chatMockReply1,
    l10n.chatMockReply2,
    l10n.chatMockReply3,
    l10n.chatMockReply4,
    l10n.chatMockReply5,
    l10n.chatMockReply6,
  ];
  final seed = (consultationId + triggerText).hashCode.abs();
  return pool[seed % pool.length];
}

/// How long to wait before showing the typing indicator (1-3s) and how
/// long to keep it visible once the reply is ready to insert (1-2s) —
/// seeded the same deterministic way as [pickMockLawyerReply] so the whole
/// simulated exchange is reproducible.
({Duration beforeTyping, Duration typingVisible}) mockReplyTiming({required String consultationId, required String triggerText}) {
  final seed = (consultationId + triggerText).hashCode.abs();
  return (beforeTyping: Duration(milliseconds: 1000 + seed % 2000), typingVisible: Duration(milliseconds: 1000 + (seed ~/ 7) % 1000));
}
