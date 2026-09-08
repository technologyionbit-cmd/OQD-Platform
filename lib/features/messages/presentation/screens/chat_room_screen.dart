import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_bottom_sheet.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/confirmation_dialog.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
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
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/consultation_type_x.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message_type.dart';
import 'package:aqd_ionbit/features/messages/presentation/providers/chat_controller.dart';
import 'package:aqd_ionbit/features/messages/presentation/providers/chat_state.dart';
import 'package:aqd_ionbit/features/messages/presentation/providers/local_image_cache.dart';
import 'package:aqd_ionbit/features/messages/presentation/utils/mock_file_attachment.dart';
import 'package:aqd_ionbit/features/messages/presentation/utils/mock_lawyer_reply.dart';
import 'package:aqd_ionbit/features/messages/presentation/widgets/chat_composer.dart';
import 'package:aqd_ionbit/features/messages/presentation/widgets/chat_day_divider.dart';
import 'package:aqd_ionbit/features/messages/presentation/widgets/chat_lobby_view.dart';
import 'package:aqd_ionbit/features/messages/presentation/widgets/chat_message_bubble.dart';
import 'package:aqd_ionbit/features/messages/presentation/widgets/chat_typing_indicator.dart';

/// The live Written Chat screen — one implementation shared by client and
/// lawyer (and company, read-only-ish the same way `ConsultationDetailsScreen`
/// is), keyed by [consultationId]. Drives `SessionController` for the
/// waiting/ready/active/ended lifecycle (written consultations go straight
/// `ready -> active`, see `ConsultationRoomMockDataSource.connect`) and
/// `ChatController` for the transcript itself.
class ChatRoomScreen extends ConsumerWidget {
  const ChatRoomScreen({super.key, required this.consultationId, this.routeBase = RoutePaths.clientBase});

  final String consultationId;
  final String routeBase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Same pattern as ConsultationDetailsScreen: the controller is the
    // source of truth for the whole list, watched once so a cold deep link
    // still resolves.
    final consultationsState = ref.watch(consultationsControllerProvider);
    final consultation = ref.watch(consultationByIdProvider(consultationId));

    if (consultation == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.consultationDetailsTitle)),
        body: switch (consultationsState) {
          AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(consultationsControllerProvider.notifier).refresh()),
          AsyncData() => EmptyState(icon: Icons.error_outline, message: l10n.chatInvalidConsultationMessage),
          _ => const LoadingView(),
        },
      );
    }

    return _ChatRoomBody(consultation: consultation, routeBase: routeBase);
  }
}

class _ChatRoomBody extends ConsumerStatefulWidget {
  const _ChatRoomBody({required this.consultation, required this.routeBase});

  final Consultation consultation;
  final String routeBase;

  @override
  ConsumerState<_ChatRoomBody> createState() => _ChatRoomBodyState();
}

class _ChatRoomBodyState extends ConsumerState<_ChatRoomBody> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  Timer? _typingStartTimer;
  Timer? _typingEndTimer;
  Timer? _tickTimer;

  bool _joinRequested = false;
  bool _connectRequested = false;
  bool _autoEndTriggered = false;
  bool _hasMarkedRead = false;
  bool _hasScrolledInitially = false;

  SessionControllerArgs get _sessionArg => (consultationId: widget.consultation.id, type: widget.consultation.type);

  @override
  void dispose() {
    _typingStartTimer?.cancel();
    _typingEndTimer?.cancel();
    _tickTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Session lifecycle -------------------------------------------------

  // The accumulated duration lives on `SessionController`/`CallMetrics`
  // (see `incrementDuration`), same as VoiceCallScreen/VideoCallScreen —
  // not local `State`, so it survives this widget being disposed/rebuilt.
  // The `Timer` that ticks it forward once a second stays owned by this
  // widget (cancelled reliably in `dispose()`).
  void _syncSession(ConsultationRoomSession session) {
    if (session.state == SessionState.waiting &&
        !_joinRequested &&
        ConsultationRoomTiming.isWithinJoinWindow(widget.consultation.scheduledAt, DateTime.now())) {
      _joinRequested = true;
      Future.microtask(() => ref.read(sessionControllerProvider(_sessionArg).notifier).join());
    } else if (session.state == SessionState.ready && !_connectRequested) {
      _connectRequested = true;
      // Written consultations skip `connecting` entirely at the repository
      // level — this call resolves straight to `active`.
      Future.microtask(() => ref.read(sessionControllerProvider(_sessionArg).notifier).connect());
    } else if (session.state == SessionState.active) {
      _resumeTicking();
      if (_remaining(session.metrics.durationSeconds) <= Duration.zero && !_autoEndTriggered) {
        _autoEndTriggered = true;
        Future.microtask(_endSession);
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

  Future<void> _endSession() async {
    _typingStartTimer?.cancel();
    _typingEndTimer?.cancel();
    _tickTimer?.cancel();
    await ref.read(sessionControllerProvider(_sessionArg).notifier).end();
    if (!mounted) return;
    // Best-effort: keep the booking-level status roughly in sync for the
    // consultations list/details screens, without introducing a second
    // status machine — see Consultation.status doc. Failure here (e.g. the
    // booking was already completed) is harmless to ignore: the live
    // session state above is already the source of truth for this screen.
    await ref.read(consultationsControllerProvider.notifier).complete(widget.consultation.id);
  }

  Future<void> _confirmEnd(AppLocalizations l10n) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.chatEndConfirmTitle,
      message: l10n.chatEndConfirmMessage,
      confirmLabel: l10n.commonConfirm,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    await _endSession();
  }

  // --- Sending -------------------------------------------------------------

  Future<void> _sendText(AppLocalizations l10n, String senderId, UserRole role) async {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    _textController.clear();
    await _submitText(l10n, text, senderId, role);
  }

  Future<void> _submitText(AppLocalizations l10n, String text, String senderId, UserRole role) async {
    final sessionState = ref.read(sessionControllerProvider(_sessionArg)).value?.state;
    if (sessionState != SessionState.active) return;

    final notifier = ref.read(chatControllerProvider(widget.consultation.id).notifier);
    final result = await notifier.sendText(senderId: senderId, senderRole: role, text: text);
    if (!mounted) return;
    result.fold(
      (failure) => _showSendFailedSnackbar(l10n, () => _submitText(l10n, text, senderId, role)),
      (message) {
        _scrollToBottom();
        if (role == UserRole.client) _scheduleMockLawyerReply(l10n, message.text);
      },
    );
  }

  Future<void> _pickImage(AppLocalizations l10n, String senderId, UserRole role) async {
    final sessionState = ref.read(sessionControllerProvider(_sessionArg)).value?.state;
    if (sessionState != SessionState.active) return;

    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null || !mounted) return; // user cancelled — not an error
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      final confirmed = await _showImagePreviewSheet(bytes, l10n);
      if (confirmed != true || !mounted) return;

      final reference = 'mock-image://${DateTime.now().microsecondsSinceEpoch}';
      ref.read(localImageCacheProvider).put(reference, bytes);
      final notifier = ref.read(chatControllerProvider(widget.consultation.id).notifier);
      final result = await notifier.sendImage(senderId: senderId, senderRole: role, attachmentUrl: reference);
      if (!mounted) return;
      result.fold(
        (failure) => _showSendFailedSnackbar(l10n, () => _pickImage(l10n, senderId, role)),
        (_) => _scrollToBottom(),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chatImagePickError)));
    }
  }

  Future<bool?> _showImagePreviewSheet(Uint8List bytes, AppLocalizations l10n) {
    return showAppBottomSheet<bool>(
      context,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(borderRadius: AppRadii.mdRadius, child: Image.memory(bytes, height: 220, fit: BoxFit.contain)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l10n.commonCancel,
                    variant: AppButtonVariant.outlined,
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: AppButton(label: l10n.chatSendAttachment, onPressed: () => Navigator.of(sheetContext).pop(true))),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _attachMockFile(AppLocalizations l10n, String senderId, UserRole role, int messageCountSoFar) async {
    final sessionState = ref.read(sessionControllerProvider(_sessionArg)).value?.state;
    if (sessionState != SessionState.active) return;

    final file = pickMockFileAttachment(consultationId: widget.consultation.id, messageCountSoFar: messageCountSoFar);
    final notifier = ref.read(chatControllerProvider(widget.consultation.id).notifier);
    final result = await notifier.sendFile(senderId: senderId, senderRole: role, fileName: file.fileName, attachmentUrl: file.encode());
    if (!mounted) return;
    result.fold((failure) => _showSendFailedSnackbar(l10n, () => _attachMockFile(l10n, senderId, role, messageCountSoFar)), (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chatAttachedFileSnackbar(file.fileName))));
      _scrollToBottom();
    });
  }

  void _showSendFailedSnackbar(AppLocalizations l10n, VoidCallback onRetry) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.chatSendFailedMessage), action: SnackBarAction(label: l10n.commonRetry, onPressed: onRetry)));
  }

  // --- Mock lawyer reply simulation ---------------------------------------
  //
  // All Timer work for this simulation is owned by this State object (not
  // the riverpod controller) precisely so it is guaranteed to be cancelled
  // in dispose() below, and so it can never fire once the screen is gone.

  void _scheduleMockLawyerReply(AppLocalizations l10n, String triggerText) {
    final sessionState = ref.read(sessionControllerProvider(_sessionArg)).value?.state;
    if (sessionState != SessionState.active) return;

    final timing = mockReplyTiming(consultationId: widget.consultation.id, triggerText: triggerText);
    _typingStartTimer?.cancel();
    _typingEndTimer?.cancel();
    final chatNotifier = ref.read(chatControllerProvider(widget.consultation.id).notifier);

    _typingStartTimer = Timer(timing.beforeTyping, () {
      if (!mounted || ref.read(sessionControllerProvider(_sessionArg)).value?.state != SessionState.active) return;
      chatNotifier.setLawyerTyping(true);

      _typingEndTimer = Timer(timing.typingVisible, () {
        if (!mounted) return;
        if (ref.read(sessionControllerProvider(_sessionArg)).value?.state != SessionState.active) {
          chatNotifier.setLawyerTyping(false);
          return;
        }
        final replyL10n = AppLocalizations.of(context)!;
        final replyText = pickMockLawyerReply(replyL10n, consultationId: widget.consultation.id, triggerText: triggerText);
        final reply = Message(
          id: 'mock_reply_${DateTime.now().microsecondsSinceEpoch}',
          consultationId: widget.consultation.id,
          senderId: kDemoLawyerUserId,
          senderRole: UserRole.lawyer,
          type: MessageType.text,
          text: replyText,
          sentAt: DateTime.now(),
        );
        chatNotifier.appendLawyerReply(reply);
        _scrollToBottom();
      });
    });
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(target, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final consultation = widget.consultation;
    final currentUser = ref.watch(authControllerProvider).value;
    final isLawyerView = currentUser?.role == UserRole.lawyer;
    final myRole = currentUser?.role == UserRole.lawyer ? UserRole.lawyer : UserRole.client;
    final mySenderId = currentUser?.id ?? (isLawyerView ? kDemoLawyerUserId : kDemoClientUserId);
    final otherPartyName = isLawyerView ? consultation.clientName : consultation.lawyerName;

    // A completed written consultation has no live session left to join —
    // go straight to its read-only transcript instead of asking
    // SessionController for a session, which would default to a fresh
    // `waiting` state and render the pre-consultation lobby (a "starts at
    // <a time already in the past>" countdown makes no sense for something
    // that already happened).
    if (consultation.status == ConsultationStatus.completed) {
      return Scaffold(
        appBar: _buildAppBar(l10n, otherPartyName, consultation, isLawyerView: isLawyerView, sessionState: null, durationSeconds: 0),
        body: _buildChat(l10n, isLawyerView, myRole, mySenderId, ended: true, durationSeconds: 0),
      );
    }

    // Any other status a live session can never be entered for (pending
    // approval, cancelled, declined, missed, failed, or already fully
    // ended) — reachable via a stale deep link, browser back/forward on
    // web, or a re-pushed old route — must not auto-join either.
    if (consultation.status.blocksLiveSession) {
      return Scaffold(
        appBar: _buildAppBar(l10n, otherPartyName, consultation, isLawyerView: isLawyerView, sessionState: null, durationSeconds: 0),
        body: _buildUnavailable(l10n),
      );
    }

    final sessionAsync = ref.watch(sessionControllerProvider(_sessionArg));
    sessionAsync.whenData(_syncSession);

    return Scaffold(
      appBar: _buildAppBar(
        l10n,
        otherPartyName,
        consultation,
        isLawyerView: isLawyerView,
        sessionState: sessionAsync.value?.state,
        durationSeconds: sessionAsync.value?.metrics.durationSeconds ?? 0,
      ),
      body: switch (sessionAsync) {
        AsyncData(value: final session) => _buildForSession(l10n, session, isLawyerView, myRole, mySenderId),
        AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.invalidate(sessionControllerProvider(_sessionArg))),
        _ => const LoadingView(),
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    AppLocalizations l10n,
    String otherPartyName,
    Consultation consultation, {
    required bool isLawyerView,
    required SessionState? sessionState,
    required int durationSeconds,
  }) {
    // The counterpart's role isn't implicit from the name alone — a chat
    // participant should always be able to tell at a glance whether they're
    // talking to the lawyer or the client.
    final otherPartyRole = isLawyerView ? l10n.accountRoleClient : l10n.accountRoleLawyer;
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const IconBadge(icon: Icons.person_outline, size: 36),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge,
                    children: [
                      TextSpan(text: otherPartyName),
                      TextSpan(
                        text: ' · $otherPartyRole',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  consultation.type.label(l10n),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (sessionState == SessionState.active)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
            // FittedBox rather than a bare Text: at very narrow widths (see
            // the 320px responsive check) the AppBar's actions row doesn't
            // otherwise shrink fixed-width children, and this label can
            // otherwise push the overflow menu button off-screen.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 96),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(l10n.chatTimeRemaining(_formatRemaining(_remaining(durationSeconds)))),
              ),
            ),
          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'details') {
              context.push(RoutePaths.consultationDetailsFor(widget.routeBase, consultation.id));
            } else if (value == 'end') {
              _confirmEnd(l10n);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'details', child: Text(l10n.chatViewDetails)),
            if (sessionState == SessionState.active) PopupMenuItem(value: 'end', child: Text(l10n.consultationEnd)),
          ],
        ),
      ],
    );
  }

  Widget _buildUnavailable(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmptyState(icon: Icons.forum_outlined, message: l10n.consultationRoomUnavailableMessage),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.chatViewDetails,
              variant: AppButtonVariant.outlined,
              onPressed: () => context.push(RoutePaths.consultationDetailsFor(widget.routeBase, widget.consultation.id)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForSession(AppLocalizations l10n, ConsultationRoomSession session, bool isLawyerView, UserRole myRole, String mySenderId) {
    switch (session.state) {
      case SessionState.waiting:
        if (!ConsultationRoomTiming.isWithinJoinWindow(widget.consultation.scheduledAt, DateTime.now())) {
          return ChatLobbyView(consultation: widget.consultation, isLawyerView: isLawyerView);
        }
        return const LoadingView();
      case SessionState.ready:
      case SessionState.connecting:
        // Written consultations never actually sit in `connecting` (see
        // `ConsultationRoomMockDataSource.connect`) — this is just the brief
        // async gap while `join`/`connect` round-trip.
        return const LoadingView();
      case SessionState.active:
        return _buildChat(l10n, isLawyerView, myRole, mySenderId, ended: false, durationSeconds: session.metrics.durationSeconds);
      case SessionState.ended:
        return _buildChat(l10n, isLawyerView, myRole, mySenderId, ended: true, durationSeconds: session.metrics.durationSeconds);
      case SessionState.failed:
        return ErrorView(
          message: l10n.errorGeneric,
          onRetry: () => ref.read(sessionControllerProvider(_sessionArg).notifier).connect(),
        );
    }
  }

  Widget _buildChat(
    AppLocalizations l10n,
    bool isLawyerView,
    UserRole myRole,
    String mySenderId, {
    required bool ended,
    required int durationSeconds,
  }) {
    final chatAsync = ref.watch(chatControllerProvider(widget.consultation.id));
    return switch (chatAsync) {
      AsyncData(value: final chatState) => _buildChatData(l10n, chatState, isLawyerView, myRole, mySenderId, ended, durationSeconds),
      AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.invalidate(chatControllerProvider(widget.consultation.id))),
      _ => const LoadingView(),
    };
  }

  Widget _buildChatData(
    AppLocalizations l10n,
    ChatState chatState,
    bool isLawyerView,
    UserRole myRole,
    String mySenderId,
    bool ended,
    int durationSeconds,
  ) {
    if (!_hasMarkedRead) {
      _hasMarkedRead = true;
      Future.microtask(() => ref.read(chatControllerProvider(widget.consultation.id).notifier).markRead(myRole));
    }
    if (!_hasScrolledInitially && chatState.messages.isNotEmpty) {
      _hasScrolledInitially = true;
      _scrollToBottom(animate: false);
    }

    // Chat for a voice/video consultation shares this same session with the
    // call screen it was opened from (they watch the identical
    // `sessionControllerProvider` key) — a still-`active` session for a
    // non-written type means the call is genuinely still live underneath
    // this pushed route, so offer a clear way back to it instead of leaving
    // the user to guess whether opening chat ended the call.
    final showReturnToCall = !ended && widget.consultation.type != ConsultationType.written;

    final remaining = _remaining(durationSeconds);
    final warning = ended
        ? null
        : remaining <= ConsultationRoomTiming.finalWarningThreshold
        ? l10n.chatFinalWarning
        : remaining <= ConsultationRoomTiming.firstWarningThreshold
        ? l10n.chatFirstWarning
        : null;

    return Column(
      children: [
        if (warning != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            color: remaining <= ConsultationRoomTiming.finalWarningThreshold
                ? context.statusColors.error.background
                : context.statusColors.warning.background,
            child: Row(
              children: [
                Icon(
                  Icons.access_time_filled,
                  size: 16,
                  color: remaining <= ConsultationRoomTiming.finalWarningThreshold
                      ? context.statusColors.error.foreground
                      : context.statusColors.warning.foreground,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    warning,
                    style: TextStyle(
                      color: remaining <= ConsultationRoomTiming.finalWarningThreshold
                          ? context.statusColors.error.foreground
                          : context.statusColors.warning.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (ended)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            color: AppColors.surfaceVariant,
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(l10n.chatEndedBannerMessage, style: Theme.of(context).textTheme.bodySmall)),
              ],
            ),
          ),
        Expanded(child: _buildMessageList(l10n, chatState, isLawyerView, ended)),
        if (showReturnToCall)
          SafeArea(
            top: false,
            bottom: false,
            child: InkWell(
              onTap: () => context.pop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                color: AppColors.primary.withAlpha(0x1A),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, size: 16, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        l10n.chatReturnToCallAction,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (!ended)
          ChatComposer(
            controller: _textController,
            enabled: true,
            isSending: chatState.isSending,
            onSend: () => _sendText(l10n, mySenderId, myRole),
            onPickImage: () => _pickImage(l10n, mySenderId, myRole),
            onAttachFile: () => _attachMockFile(l10n, mySenderId, myRole, chatState.messages.length),
          )
        else
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                l10n.chatEndedBannerMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageList(AppLocalizations l10n, ChatState chatState, bool isLawyerView, bool ended) {
    if (chatState.messages.isEmpty && !chatState.isLawyerTyping) {
      return EmptyState(icon: Icons.forum_outlined, title: l10n.chatEmptyTitle, message: l10n.chatEmptyMessage);
    }

    final viewerRole = isLawyerView ? UserRole.lawyer : UserRole.client;
    final items = <Widget>[];
    DateTime? lastDay;
    for (final message in chatState.messages) {
      final day = DateTime(message.sentAt.year, message.sentAt.month, message.sentAt.day);
      if (lastDay == null || day != lastDay) {
        items.add(ChatDayDivider(date: day));
        lastDay = day;
      }
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: ChatMessageBubble(key: ValueKey(message.id), message: message, isMine: message.senderRole == viewerRole),
        ),
      );
    }
    if (chatState.isLawyerTyping && !ended) {
      items.add(const Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.md), child: ChatTypingIndicator()));
    }

    return ListView(controller: _scrollController, padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm), children: items);
  }

  String _formatRemaining(Duration remaining) {
    final minutes = remaining.inMinutes.clamp(0, 99);
    final seconds = remaining.inSeconds.remainder(60).clamp(0, 59);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
