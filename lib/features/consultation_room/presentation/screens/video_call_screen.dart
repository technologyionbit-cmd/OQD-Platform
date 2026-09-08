import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/confirmation_dialog.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/consultation_room_session.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/consultation_room_timing.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/session_state.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/providers/session_controller.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultation_by_id_provider.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultations_controller.dart';

/// The mock video-call screen — reached from `ConsultationWaitingScreen`
/// once a `ConsultationType.video` session has been joined. Drives the same
/// `sessionControllerProvider`/`SessionState` machine `VoiceCallScreen`/
/// `ChatRoomScreen` use (`waiting -> ready -> connecting -> active ->
/// ended`, with `failed` reachable from `connecting` or `active`) — no
/// bespoke call state machine lives here, only presentation, the
/// reconnect/timer bookkeeping that state machine doesn't itself own, and
/// UI-only mock camera bookkeeping (switch-camera facing, draggable local
/// preview position) that never needs to survive this screen.
class VideoCallScreen extends ConsumerWidget {
  const VideoCallScreen({super.key, required this.consultationId, this.routeBase = RoutePaths.clientBase});

  final String consultationId;
  final String routeBase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Same pattern as VoiceCallScreen/ChatRoomScreen: the controller is the
    // source of truth for the whole list, watched once so a cold deep link
    // still resolves.
    final consultationsState = ref.watch(consultationsControllerProvider);
    final consultation = ref.watch(consultationByIdProvider(consultationId));

    if (consultation == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.consultationTypeVideo)),
        body: switch (consultationsState) {
          AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(consultationsControllerProvider.notifier).refresh()),
          AsyncData() => EmptyState(icon: Icons.error_outline, message: l10n.chatInvalidConsultationMessage),
          _ => const LoadingView(),
        },
      );
    }

    return _VideoCallBody(consultation: consultation, routeBase: routeBase);
  }
}

class _VideoCallBody extends ConsumerStatefulWidget {
  const _VideoCallBody({required this.consultation, required this.routeBase});

  final Consultation consultation;
  final String routeBase;

  @override
  ConsumerState<_VideoCallBody> createState() => _VideoCallBodyState();
}

class _VideoCallBodyState extends ConsumerState<_VideoCallBody> {
  Timer? _tickTimer;
  Timer? _reconnectTimer;

  // Frozen at first build rather than read live off `widget.consultation` —
  // see VoiceCallScreen's identical field for why: ending the call flips
  // the booking-level status to `completed` (one of the blocked statuses)
  // via `_endSession`'s best-effort sync, which must not retroactively hide
  // this same screen's own "ended" summary.
  late final bool _blockedAtEntry = widget.consultation.status.blocksLiveSession;

  bool _joinRequested = false;
  bool _connectRequested = false;
  bool _autoEndTriggered = false;
  bool _endedAutomatically = false;
  bool _markedFailed = false;

  // Presentation-only mock camera bookkeeping — never touches
  // SessionState/CallMetrics, which only track on/off (owned by the
  // session controller). Which lens is "active" is purely cosmetic here.
  bool _isFrontCamera = true;

  SessionControllerArgs get _sessionArg => (consultationId: widget.consultation.id, type: widget.consultation.type);

  @override
  void dispose() {
    _tickTimer?.cancel();
    _reconnectTimer?.cancel();
    super.dispose();
  }

  // --- Session lifecycle -------------------------------------------------

  // The accumulated duration lives on `SessionController`/`CallMetrics`
  // (see `incrementDuration`), not local `State` — it survives this widget
  // being disposed/rebuilt. The `Timer` that ticks it forward once a second
  // stays owned by this widget (cancelled reliably in `dispose()`) and just
  // calls into the controller each tick, matching the pattern the original
  // local-elapsed-time implementation used.
  void _syncSession(ConsultationRoomSession session) {
    if (session.state == SessionState.waiting &&
        !_joinRequested &&
        ConsultationRoomTiming.isWithinJoinWindow(widget.consultation.scheduledAt, DateTime.now())) {
      _joinRequested = true;
      Future.microtask(() => ref.read(sessionControllerProvider(_sessionArg).notifier).join());
    } else if (session.state == SessionState.ready && !_connectRequested) {
      _connectRequested = true;
      Future.microtask(() => ref.read(sessionControllerProvider(_sessionArg).notifier).connect());
    } else if (session.state == SessionState.active) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      _resumeTicking();
      if (_remaining(session.metrics.durationSeconds) <= Duration.zero && !_autoEndTriggered) {
        _autoEndTriggered = true;
        Future.microtask(() => _endSession(automatic: true));
      }
    } else if (session.state == SessionState.failed) {
      _pauseTicking();
      _scheduleReconnect(session);
      // Keep the booking-level status in sync once reconnection is
      // exhausted, matching `_endSession`'s best-effort sync on a normal
      // end — otherwise a call that never recovers stays `confirmed`
      // forever in consultation lists/history.
      if (session.reconnectAttempts >= ConsultationRoomTiming.maxReconnectionAttempts && !_markedFailed) {
        _markedFailed = true;
        Future.microtask(() => ref.read(consultationsControllerProvider.notifier).markFailed(widget.consultation.id));
      }
    } else {
      _pauseTicking();
    }
  }

  void _resumeTicking() {
    if (_tickTimer != null) return;
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      ref.read(sessionControllerProvider(_sessionArg).notifier).incrementDuration();
    });
  }

  void _pauseTicking() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  Duration _remaining(int durationSeconds) {
    final remaining = ConsultationRoomTiming.maxSessionDuration - Duration(seconds: durationSeconds);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void _scheduleReconnect(ConsultationRoomSession session) {
    if (session.reconnectAttempts >= ConsultationRoomTiming.maxReconnectionAttempts) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      return;
    }
    if (_reconnectTimer != null) return;
    _reconnectTimer = Timer(ConsultationRoomTiming.reconnectionInterval, () {
      _reconnectTimer = null;
      if (!mounted) return;
      ref.read(sessionControllerProvider(_sessionArg).notifier).retryConnection();
    });
  }

  void _retryNow() {
    final session = ref.read(sessionControllerProvider(_sessionArg)).value;
    if (session == null || session.reconnectAttempts >= ConsultationRoomTiming.maxReconnectionAttempts) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    ref.read(sessionControllerProvider(_sessionArg).notifier).retryConnection();
  }

  Future<void> _endSession({bool automatic = false}) async {
    _tickTimer?.cancel();
    _reconnectTimer?.cancel();
    _endedAutomatically = automatic;
    await ref.read(sessionControllerProvider(_sessionArg).notifier).end();
    if (!mounted) return;
    // Best-effort, matching VoiceCallScreen/ChatRoomScreen: keep the
    // booking-level status roughly in sync without introducing a second
    // status machine.
    await ref.read(consultationsControllerProvider.notifier).complete(widget.consultation.id);
  }

  Future<void> _confirmEnd(AppLocalizations l10n) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.voiceCallEndConfirmTitle,
      message: l10n.voiceCallEndConfirmMessage,
      confirmLabel: l10n.voiceCallEndCallAction,
      cancelLabel: l10n.voiceCallKeepCallAction,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    await _endSession();
  }

  Future<void> _toggleMute() => ref.read(sessionControllerProvider(_sessionArg).notifier).toggleMute();

  Future<void> _toggleCamera() => ref.read(sessionControllerProvider(_sessionArg).notifier).toggleCamera();

  Future<void> _toggleSpeaker() => ref.read(sessionControllerProvider(_sessionArg).notifier).toggleSpeaker();

  void _switchCamera(AppLocalizations l10n) {
    setState(() => _isFrontCamera = !_isFrontCamera);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isFrontCamera ? l10n.videoCallSwitchedToFrontCamera : l10n.videoCallSwitchedToBackCamera)),
    );
  }

  void _openDetails() {
    context.push(RoutePaths.consultationDetailsFor(widget.routeBase, widget.consultation.id));
  }

  void _openChat() {
    context.push(RoutePaths.chatRoomFor(widget.routeBase, widget.consultation.id));
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.consultationDetailsFor(widget.routeBase, widget.consultation.id));
    }
  }

  Future<void> _handleBackPress(AppLocalizations l10n, SessionState state) async {
    if (state == SessionState.active) {
      await _confirmEnd(l10n);
      return;
    }
    _back();
  }

  String _formatElapsed(Duration elapsed) {
    final minutes = elapsed.inMinutes.clamp(0, 99);
    final seconds = elapsed.inSeconds.remainder(60).clamp(0, 59);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = ref.watch(authControllerProvider).value;
    final isLawyerView = currentUser?.role == UserRole.lawyer;

    // A stale deep link, a browser back/forward on web, or simply
    // re-pushing an old route could otherwise land here for a consultation
    // that was cancelled/declined/missed/completed etc. since it was last
    // open — bail out before ever touching sessionControllerProvider (no
    // auto-join/connect side effect) rather than relying solely on
    // ConsultationWaitingScreen's own gate upstream.
    if (_blockedAtEntry) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.consultationTypeVideo)),
        body: _buildUnavailable(l10n, isLawyerView),
      );
    }

    final sessionAsync = ref.watch(sessionControllerProvider(_sessionArg));
    sessionAsync.whenData(_syncSession);
    final sessionState = sessionAsync.value?.state;

    return PopScope(
      // See VoiceCallScreen's identical guard: the AppBar's own back button
      // already routes an active call through the end-confirmation dialog
      // — the system back gesture/button must too, or it silently exits a
      // still-`active` mock session with no confirmation at all.
      canPop: sessionState != SessionState.active,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress(l10n, sessionState ?? SessionState.waiting);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.consultationTypeVideo),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: l10n.consultationRoomBackAction,
            onPressed: () => _handleBackPress(l10n, sessionState ?? SessionState.waiting),
          ),
          actions: [
            if (kDebugMode && sessionState == SessionState.active)
              IconButton(
                icon: const Icon(Icons.bug_report_outlined),
                tooltip: l10n.consultationRoomSimulateConnectionLossAction,
                onPressed: () => ref.read(sessionControllerProvider(_sessionArg).notifier).reportConnectionLost(),
              ),
            if (sessionState != SessionState.ended) ...[
              IconButton(icon: const Icon(Icons.chat_bubble_outline), tooltip: l10n.videoCallChatAction, onPressed: _openChat),
              IconButton(icon: const Icon(Icons.info_outline), tooltip: l10n.chatViewDetails, onPressed: _openDetails),
            ],
          ],
        ),
        body: switch (sessionAsync) {
          AsyncData(value: final session) => _buildForSession(l10n, session, isLawyerView),
          AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.invalidate(sessionControllerProvider(_sessionArg))),
          _ => const LoadingView(),
        },
      ),
    );
  }

  Widget _buildForSession(AppLocalizations l10n, ConsultationRoomSession session, bool isLawyerView) {
    switch (session.state) {
      case SessionState.waiting:
      case SessionState.ready:
      case SessionState.connecting:
        return _buildConnecting(l10n, isLawyerView);
      case SessionState.active:
        return _buildCallStage(l10n, isLawyerView, session, reconnecting: false);
      case SessionState.failed:
        if (session.reconnectAttempts >= ConsultationRoomTiming.maxReconnectionAttempts) {
          return _buildUnavailable(l10n, isLawyerView);
        }
        return _buildCallStage(l10n, isLawyerView, session, reconnecting: true);
      case SessionState.ended:
        return _buildEnded(l10n, isLawyerView, session);
    }
  }

  String _otherPartyName(bool isLawyerView) => isLawyerView ? widget.consultation.clientName : widget.consultation.lawyerName;

  Widget _buildConnecting(AppLocalizations l10n, bool isLawyerView) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconBadge(icon: Icons.person_outline, size: 96, iconSize: 44),
            const SizedBox(height: AppSpacing.lg),
            Text(_otherPartyName(isLawyerView), style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l10n.videoCallLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.voiceCallConnectingLabel, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildCallStage(AppLocalizations l10n, bool isLawyerView, ConsultationRoomSession session, {required bool reconnecting}) {
    final elapsed = Duration(seconds: session.metrics.durationSeconds);
    final remaining = _remaining(session.metrics.durationSeconds);
    final isFinalWarning = remaining <= ConsultationRoomTiming.finalWarningThreshold;
    final warning = reconnecting
        ? null
        : isFinalWarning
        ? l10n.chatFinalWarning
        : remaining <= ConsultationRoomTiming.firstWarningThreshold
        ? l10n.chatFirstWarning
        : null;

    return Column(
      children: [
        if (reconnecting)
          _Banner(
            icon: Icons.wifi_off,
            color: context.statusColors.error.foreground,
            background: context.statusColors.error.background,
            lines: [
              l10n.voiceCallConnectionLostBanner,
              '${l10n.voiceCallStatusReconnecting} ${l10n.voiceCallReconnectingAttempt(session.reconnectAttempts + 1, ConsultationRoomTiming.maxReconnectionAttempts)}',
            ],
          )
        else if (warning != null)
          _Banner(
            icon: Icons.access_time_filled,
            color: isFinalWarning ? context.statusColors.error.foreground : context.statusColors.warning.foreground,
            background: isFinalWarning ? context.statusColors.error.background : context.statusColors.warning.background,
            lines: [warning],
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                key: const Key('videoCallRemoteArea'),
                children: [
                  Semantics(
                    label: l10n.videoCallRemoteVideoLabel,
                    child: _RemoteVideoArea(
                      name: _otherPartyName(isLawyerView),
                      typeLabel: l10n.videoCallLabel,
                      duration: _formatElapsed(elapsed),
                      statusLabel: reconnecting ? l10n.voiceCallStatusReconnecting : l10n.voiceCallStatusConnected,
                      reconnecting: reconnecting,
                      onRetryNow: reconnecting ? _retryNow : null,
                      retryLabel: l10n.voiceCallRetryNowAction,
                    ),
                  ),
                  _DraggableLocalPreview(
                    bounds: constraints.biggest,
                    isCameraOn: session.metrics.isCameraOn,
                    cameraOffLabel: l10n.videoCallCameraOffPlaceholder,
                    semanticLabel: l10n.videoCallLocalVideoLabel,
                  ),
                ],
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _VideoControlButton(
                  icon: session.metrics.isMuted ? Icons.mic_off : Icons.mic_none_outlined,
                  isActive: session.metrics.isMuted,
                  label: session.metrics.isMuted ? l10n.voiceCallUnmuteAction : l10n.voiceCallMuteAction,
                  onPressed: reconnecting ? null : _toggleMute,
                ),
                _VideoControlButton(
                  icon: session.metrics.isCameraOn ? Icons.videocam_outlined : Icons.videocam_off_outlined,
                  isActive: session.metrics.isCameraOn,
                  label: session.metrics.isCameraOn ? l10n.videoCallCameraOffAction : l10n.videoCallCameraOnAction,
                  onPressed: reconnecting ? null : _toggleCamera,
                ),
                _VideoControlButton(
                  icon: session.metrics.isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                  isActive: session.metrics.isSpeakerOn,
                  label: session.metrics.isSpeakerOn ? l10n.voiceCallSpeakerOffAction : l10n.voiceCallSpeakerOnAction,
                  onPressed: reconnecting ? null : _toggleSpeaker,
                ),
                _VideoControlButton(
                  icon: Icons.cameraswitch_outlined,
                  isActive: false,
                  label: l10n.videoCallSwitchCameraAction,
                  onPressed: (reconnecting || !session.metrics.isCameraOn) ? null : () => _switchCamera(l10n),
                ),
                _VideoControlButton(
                  icon: Icons.call_end,
                  isActive: false,
                  isDestructive: true,
                  label: l10n.voiceCallEndCallAction,
                  onPressed: () => _confirmEnd(l10n),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnavailable(AppLocalizations l10n, bool isLawyerView) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBadge(
              icon: Icons.videocam_off_outlined,
              size: 72,
              backgroundColor: context.statusColors.error.background,
              iconColor: context.statusColors.error.foreground,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.voiceCallUnavailableTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: context.statusColors.error.foreground, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.voiceCallUnavailableMessage(_otherPartyName(isLawyerView)),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: l10n.chatViewDetails, variant: AppButtonVariant.outlined, onPressed: _openDetails),
            const SizedBox(height: AppSpacing.sm),
            AppButton(label: l10n.consultationRoomBackAction, variant: AppButtonVariant.text, onPressed: _back),
          ],
        ),
      ),
    );
  }

  Widget _buildEnded(AppLocalizations l10n, bool isLawyerView, ConsultationRoomSession session) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconBadge(icon: Icons.call_end, size: 72, backgroundColor: AppColors.surfaceVariant, iconColor: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.voiceCallEndedTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _otherPartyName(isLawyerView),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _endedAutomatically ? l10n.voiceCallAutoEndedMessage : l10n.videoCallEndedMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.chatDurationLabel(_formatElapsed(Duration(seconds: session.metrics.durationSeconds))),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: l10n.voiceCallDoneAction, onPressed: _back),
          ],
        ),
      ),
    );
  }
}

/// A dismiss-free, full-width status strip shown above the call content —
/// used both for the "connection lost / reconnecting" state and for the
/// approaching-timeout warnings, matching VoiceCallScreen/ChatRoomScreen's
/// banner treatment so every live-session screen reads as one system.
class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.color, required this.background, required this.lines});

  final IconData icon;
  final Color color;
  final Color background;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      color: background,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final line in lines) Text(line, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The full-bleed "remote video" placeholder — a dark canvas standing in for
/// a real video track, with the remote participant's avatar/name/status
/// centered over it. No camera/media API is ever touched here.
class _RemoteVideoArea extends StatelessWidget {
  const _RemoteVideoArea({
    required this.name,
    required this.typeLabel,
    required this.duration,
    required this.statusLabel,
    required this.reconnecting,
    required this.onRetryNow,
    required this.retryLabel,
  });

  final String name;
  final String typeLabel;
  final String duration;
  final String statusLabel;
  final bool reconnecting;
  final VoidCallback? onRetryNow;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.navyDarkest,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconBadge(
                icon: Icons.person_outline,
                size: 120,
                iconSize: 56,
                backgroundColor: AppColors.onPrimary.withAlpha(0x3D),
                iconColor: AppColors.onPrimary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.onPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(typeLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary.withAlpha(0xB3))),
              const SizedBox(height: AppSpacing.xl),
              Text(
                duration,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.onPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              StatusBadge(label: statusLabel, tone: reconnecting ? AppStatusTone.warning : AppStatusTone.success),
              if (onRetryNow != null) ...[
                const SizedBox(height: AppSpacing.lg),
                AppButton(label: retryLabel, variant: AppButtonVariant.outlined, onPressed: onRetryNow),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

const _localPreviewWidth = 90.0;
const _localPreviewHeight = 140.0;

/// The small floating "local camera preview" card — draggable within the
/// remote video area's bounds, purely presentation-side state (position
/// resets on rebuild of this widget, which is fine: this is a mock, not a
/// persisted layout preference). Falls back to a fixed top-end position if
/// [bounds] is too small to usefully drag within.
class _DraggableLocalPreview extends StatefulWidget {
  const _DraggableLocalPreview({required this.bounds, required this.isCameraOn, required this.cameraOffLabel, required this.semanticLabel});

  final Size bounds;
  final bool isCameraOn;
  final String cameraOffLabel;
  final String semanticLabel;

  @override
  State<_DraggableLocalPreview> createState() => _DraggableLocalPreviewState();
}

class _DraggableLocalPreviewState extends State<_DraggableLocalPreview> {
  Offset? _offset;

  Offset _clamped(Offset offset) {
    final maxX = (widget.bounds.width - _localPreviewWidth).clamp(0.0, double.infinity);
    final maxY = (widget.bounds.height - _localPreviewHeight).clamp(0.0, double.infinity);
    return Offset(offset.dx.clamp(0.0, maxX), offset.dy.clamp(0.0, maxY));
  }

  @override
  Widget build(BuildContext context) {
    final defaultOffset = Offset((widget.bounds.width - _localPreviewWidth - AppSpacing.md).clamp(0.0, double.infinity), AppSpacing.md);
    final offset = _clamped(_offset ?? defaultOffset);

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() => _offset = _clamped(offset + details.delta)),
        child: Semantics(
          label: widget.semanticLabel,
          child: Container(
            key: const Key('videoCallLocalPreview'),
            width: _localPreviewWidth,
            height: _localPreviewHeight,
            decoration: BoxDecoration(
              color: AppColors.navyLight,
              borderRadius: AppRadii.mdRadius,
              border: Border.all(color: AppColors.onPrimary.withAlpha(0x3D)),
              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 2))],
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.isCameraOn
                ? Center(child: Icon(Icons.person, color: AppColors.onPrimary.withAlpha(0xB3), size: 40))
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxs),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam_off_outlined, color: AppColors.onPrimary.withAlpha(0xB3), size: 24),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            widget.cameraOffLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.onPrimary.withAlpha(0xB3), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// An icon-only, tooltip-labeled circular call-control button. Video has
/// five controls (Mute/Camera/Speaker/Switch camera/End call) rather than
/// VoiceCallScreen's two, so — to stay usable down to a 320px-wide screen —
/// the visible caption VoiceCallScreen's `_CallToggleButton` shows beneath
/// each button is dropped here in favor of a tooltip carrying the same
/// label, which doubles as the button's semantic label for accessibility.
class _VideoControlButton extends StatelessWidget {
  const _VideoControlButton({required this.icon, required this.isActive, required this.label, required this.onPressed, this.isDestructive = false});

  final IconData icon;
  final bool isActive;
  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    if (isDestructive) {
      return IconButton.filled(
        onPressed: onPressed,
        tooltip: label,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: context.statusColors.error.foreground,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(48, 48),
        ),
      );
    }
    if (isActive) {
      return IconButton.filled(
        onPressed: onPressed,
        tooltip: label,
        icon: Icon(icon),
        style: IconButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, minimumSize: const Size(48, 48)),
      );
    }
    return IconButton.filledTonal(onPressed: onPressed, tooltip: label, icon: Icon(icon), style: IconButton.styleFrom(minimumSize: const Size(48, 48)));
  }
}
