import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/consultation_room_timing.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/session_state.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/providers/session_controller.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultation_by_id_provider.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultations_controller.dart';
import 'package:aqd_ionbit/features/consultations/presentation/widgets/consultation_status_x.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/consultation_type_x.dart';

/// The common pre-session lobby shared by Written Chat, Voice Call, and
/// Video Call — one implementation (keyed by [consultationId], role-aware
/// via `authControllerProvider`) instead of a bespoke waiting screen per
/// communication type. It calculates its own state purely from
/// [Consultation.status] and [Consultation.scheduledAt]/[ConsultationRoomTiming]
/// (never from `SessionState`, which is the live-session runtime's own
/// concern — see `SessionController`); the only place it touches
/// `sessionControllerProvider` is to drive `join()` (and, for written,
/// `connect()` too) once the user presses Join, then hands off to
/// `ChatRoomScreen`, `VoiceCallScreen`, or `VideoCallScreen`.
class ConsultationWaitingScreen extends ConsumerWidget {
  const ConsultationWaitingScreen({super.key, required this.consultationId, this.routeBase = RoutePaths.clientBase});

  final String consultationId;
  final String routeBase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Source of truth is the controller's whole list — watched once so a
    // cold deep link still resolves, matching ConsultationDetailsScreen /
    // ChatRoomScreen.
    final consultationsState = ref.watch(consultationsControllerProvider);
    final consultation = ref.watch(consultationByIdProvider(consultationId));

    if (consultation == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.consultationRoomTitle)),
        body: switch (consultationsState) {
          AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(consultationsControllerProvider.notifier).refresh()),
          AsyncData() => EmptyState(icon: Icons.error_outline, message: l10n.chatInvalidConsultationMessage),
          _ => const LoadingView(),
        },
      );
    }

    return _ConsultationWaitingBody(consultation: consultation, routeBase: routeBase);
  }
}

enum _LobbyPhase { unavailable, tooEarly, joinWindow, missed }

class _ConsultationWaitingBody extends ConsumerStatefulWidget {
  const _ConsultationWaitingBody({required this.consultation, required this.routeBase});

  final Consultation consultation;
  final String routeBase;

  @override
  ConsumerState<_ConsultationWaitingBody> createState() => _ConsultationWaitingBodyState();
}

class _ConsultationWaitingBodyState extends ConsumerState<_ConsultationWaitingBody> {
  Timer? _tickTimer;
  bool _isJoining = false;
  bool _missedMarkRequested = false;

  SessionControllerArgs get _sessionArg => (consultationId: widget.consultation.id, type: widget.consultation.type);

  _LobbyPhase get _phase {
    final consultation = widget.consultation;
    // Checked ahead of the general `blocksLiveSession` fallback so that once
    // `_markMissedIfNeeded` below has persisted the `missed` status, this
    // still renders the specific "Consultation missed" messaging instead of
    // falling through to the generic "unavailable" one.
    if (consultation.status == ConsultationStatus.missed) return _LobbyPhase.missed;
    if (consultation.status.blocksLiveSession) return _LobbyPhase.unavailable;
    final now = DateTime.now();
    if (ConsultationRoomTiming.isPastGracePeriod(consultation.scheduledAt, now)) return _LobbyPhase.missed;
    if (ConsultationRoomTiming.isWithinJoinWindow(consultation.scheduledAt, now)) return _LobbyPhase.joinWindow;
    return _LobbyPhase.tooEarly;
  }

  /// Persists the wall-clock-computed `missed` phase into the booking-level
  /// status the first time it's observed, so it survives into consultation
  /// history/list screens instead of only ever existing as this lobby's own
  /// display — mirrors the `_joinRequested`-style "fire once" guards the
  /// live-session screens use for their own best-effort status syncs.
  void _markMissedIfNeeded() {
    if (_missedMarkRequested) return;
    if (_phase != _LobbyPhase.missed) return;
    if (widget.consultation.status == ConsultationStatus.missed) return;
    _missedMarkRequested = true;
    Future.microtask(() => ref.read(consultationsControllerProvider.notifier).markMissed(widget.consultation.id));
  }

  @override
  void initState() {
    super.initState();
    // Warm up the session provider ahead of a Join press (its `getSession`
    // fetch has simulated latency) without driving any lifecycle from here.
    ref.read(sessionControllerProvider(_sessionArg));
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleJoin(AppLocalizations l10n) async {
    final consultation = widget.consultation;

    setState(() => _isJoining = true);
    try {
      await ref.read(sessionControllerProvider(_sessionArg).future);
    } catch (_) {
      // Failure surfaces below via the join()/connect() calls themselves.
    }
    if (!mounted) return;

    final notifier = ref.read(sessionControllerProvider(_sessionArg).notifier);
    var result = await notifier.join();

    if (consultation.type == ConsultationType.voice || consultation.type == ConsultationType.video) {
      // Voice/video both pass through `connecting` — that transition (and
      // its failure/retry handling) belongs to VoiceCallScreen/VideoCallScreen
      // themselves, so the lobby only needs `join()` (waiting -> ready) to
      // succeed before handing off.
      if (!mounted) return;
      setState(() => _isJoining = false);
      if (result.isSuccess) {
        final destination = consultation.type == ConsultationType.voice
            ? RoutePaths.voiceCallFor(widget.routeBase, consultation.id)
            : RoutePaths.videoCallFor(widget.routeBase, consultation.id);
        context.pushReplacement(destination);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.consultationRoomJoinFailedMessage)));
      }
      return;
    }

    if (mounted && result.isSuccess) {
      result = await notifier.connect();
    }
    if (!mounted) return;
    setState(() => _isJoining = false);

    if (result.valueOrNull?.state == SessionState.active) {
      context.pushReplacement(RoutePaths.chatRoomFor(widget.routeBase, consultation.id));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.consultationRoomJoinFailedMessage)));
    }
  }

  void _viewDetails() {
    context.push(RoutePaths.consultationDetailsFor(widget.routeBase, widget.consultation.id));
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.consultationDetailsFor(widget.routeBase, widget.consultation.id));
    }
  }

  String _countdownLabel(AppLocalizations l10n, Duration remaining) {
    if (remaining.inDays >= 1) return l10n.consultationRoomCountdownDays(remaining.inDays);
    if (remaining.inHours >= 1) return l10n.consultationRoomCountdownHours(remaining.inHours);
    return l10n.consultationRoomCountdownMinutes(remaining.inMinutes.clamp(1, 59));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final consultation = widget.consultation;
    _markMissedIfNeeded();
    final role = ref.watch(authControllerProvider).value?.role;
    final isLawyerView = role == UserRole.lawyer;
    final otherPartyName = isLawyerView ? consultation.clientName : consultation.lawyerName;
    final timeLabel = DateFormat.jm(locale).format(consultation.scheduledAt);
    final dateLabel = DateFormat.yMMMd(locale).format(consultation.scheduledAt);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.consultationRoomTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const IconBadge(icon: Icons.person_outline, size: 56),
                    const SizedBox(height: AppSpacing.md),
                    Text(otherPartyName, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(consultation.type.icon, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: AppSpacing.xxs),
                        Flexible(
                          child: Text(
                            consultation.type.label(l10n),
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    Text(dateLabel, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      timeLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildPhaseContent(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseContent(BuildContext context, AppLocalizations l10n) {
    return switch (_phase) {
      _LobbyPhase.unavailable => _buildUnavailable(context, l10n),
      _LobbyPhase.tooEarly => _buildTooEarly(context, l10n),
      _LobbyPhase.joinWindow => _buildJoinWindow(context, l10n),
      _LobbyPhase.missed => _buildMissed(context, l10n),
    };
  }

  Widget _buildUnavailable(BuildContext context, AppLocalizations l10n) {
    final status = widget.consultation.status;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusBadge(label: status.label(l10n), tone: status.tone),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.consultationRoomUnavailableMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSecondaryActions(l10n),
      ],
    );
  }

  Widget _buildTooEarly(BuildContext context, AppLocalizations l10n) {
    final untilJoinWindow = widget.consultation.scheduledAt.subtract(ConsultationRoomTiming.joinWindow).difference(DateTime.now());
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.consultationRoomTooEarlyTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.consultationRoomTooEarlyMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        if (untilJoinWindow > Duration.zero) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.consultationRoomStartsIn(_countdownLabel(l10n, untilJoinWindow)),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _buildSecondaryActions(l10n),
      ],
    );
  }

  Widget _buildJoinWindow(BuildContext context, AppLocalizations l10n) {
    final untilScheduled = widget.consultation.scheduledAt.difference(DateTime.now());
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.consultationRoomReadyTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: context.statusColors.success.foreground, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.consultationRoomReadyMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        if (untilScheduled > Duration.zero) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.consultationRoomStartsIn(_countdownLabel(l10n, untilScheduled)),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: l10n.consultationRoomJoinAction,
          icon: widget.consultation.type.icon,
          isLoading: _isJoining,
          onPressed: _isJoining ? null : () => _handleJoin(l10n),
        ),
      ],
    );
  }

  Widget _buildMissed(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.consultationRoomMissedTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: context.statusColors.error.foreground, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.consultationRoomMissedMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSecondaryActions(l10n),
      ],
    );
  }

  Widget _buildSecondaryActions(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(label: l10n.chatViewDetails, variant: AppButtonVariant.outlined, onPressed: _viewDetails),
        const SizedBox(height: AppSpacing.sm),
        AppButton(label: l10n.consultationRoomBackAction, variant: AppButtonVariant.text, onPressed: _back),
      ],
    );
  }
}
