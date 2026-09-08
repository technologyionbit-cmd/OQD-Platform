import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_metrics.freezed.dart';

/// Live call metrics/controls tracked for the duration of a session. No
/// real audio/video is involved in the mock runtime — [isMuted],
/// [isCameraOn], and [isSpeakerOn] are just toggled local state that a
/// real WebRTC/Agora/Twilio implementation would later back with actual
/// media-track control.
@freezed
abstract class CallMetrics with _$CallMetrics {
  const factory CallMetrics({
    @Default(0) int durationSeconds,
    @Default(false) bool isMuted,
    @Default(true) bool isCameraOn,
    @Default(true) bool isSpeakerOn,
  }) = _CallMetrics;
}
