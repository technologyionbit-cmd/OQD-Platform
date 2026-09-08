import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_bottom_sheet.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/confirmation_dialog.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/ai_conversation.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/ai_message.dart';
import 'package:aqd_ionbit/features/ai/presentation/providers/ai_conversations_controller.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_category.dart';
import 'package:aqd_ionbit/features/contracts/presentation/widgets/contract_category_x.dart';
import 'package:aqd_ionbit/features/messages/presentation/utils/mock_file_attachment.dart';

/// Local-only stages for the in-chat "create a contract" mini-flow. This is
/// a presentation-layer overlay on top of the real chat (its prompts/cards
/// aren't persisted `AiMessage`s) — see the class doc below for why.
enum _WizardStage { none, selectType, askParty1, askParty2, askSubject, askValue, draftReady, sent }

/// A message that only exists for the duration of the in-chat contract
/// wizard — rendered inline with the real conversation, but not persisted
/// through `AiConversationsController` (the mock backend's `AiMessage` has
/// no slot for structured content, and adding one would mean touching a
/// freezed entity + its generated code for a purely front-end demo flow).
class _WizardMessage {
  const _WizardMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}

/// The client's AI tab *is* the chat — matches the reference (no separate
/// "AI home" landing page). Fresh, it shows a welcome bubble plus the three
/// reference quick-action chips; past conversations are one tap away via
/// the history icon instead of a whole separate screen. [initialConversationId]/
/// [initialMessage] still let another screen (analysis results, a resumed
/// conversation) open straight into a specific thread.
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key, this.initialConversationId, this.initialMessage});

  final String? initialConversationId;
  final String? initialMessage;

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  String? _conversationId;
  bool _isSending = false;
  bool _hasError = false;
  String? _lastFailedText;

  _WizardStage _wizard = _WizardStage.none;
  ContractCategory? _wizardCategory;
  String? _party1, _party2, _subject, _value;
  final List<_WizardMessage> _wizardMessages = [];

  @override
  void initState() {
    super.initState();
    _conversationId = widget.initialConversationId;
    final initialMessage = widget.initialMessage;
    if (initialMessage != null && initialMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(initialMessage));
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _inputController.clear();
    setState(() {
      _isSending = true;
      _hasError = false;
      _lastFailedText = null;
    });

    final result = await ref.read(aiConversationsControllerProvider.notifier).sendMessage(text: text, conversationId: _conversationId);
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isSending = false;
        _hasError = true;
        _lastFailedText = text;
      }),
      (conversation) => setState(() {
        _isSending = false;
        _conversationId = conversation.id;
      }),
    );
    _scrollToBottom();
  }

  Future<void> _attachMockFile() async {
    final id = _conversationId;
    final messageCount = id != null ? (ref.read(aiConversationByIdProvider(id))?.messages.length ?? 0) : 0;
    final file = pickMockFileAttachment(consultationId: id ?? 'new-ai-chat', messageCountSoFar: messageCount);
    await _send('📎 ${file.fileName}');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  Future<void> _clearConversation() async {
    final l10n = AppLocalizations.of(context)!;
    final id = _conversationId;
    if (id == null) return;
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.aiClearConversationTitle,
      message: l10n.aiClearConversationMessage,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    await ref.read(aiConversationsControllerProvider.notifier).clearConversation(id);
  }

  void _newConversation() {
    setState(() {
      _conversationId = null;
      _hasError = false;
      _lastFailedText = null;
      _resetWizard();
    });
  }

  void _resetWizard() {
    _wizard = _WizardStage.none;
    _wizardCategory = null;
    _party1 = _party2 = _subject = _value = null;
    _wizardMessages.clear();
  }

  Future<void> _openConversation(String id) async {
    Navigator.of(context).pop();
    setState(() {
      _conversationId = id;
      _resetWizard();
    });
  }

  Future<void> _showHistory() async {
    final l10n = AppLocalizations.of(context)!;
    final conversations = ref.read(aiConversationsControllerProvider).value ?? const <AiConversation>[];
    await showAppBottomSheet<void>(
      context,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.aiRecentConversationsTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            if (conversations.isEmpty)
              EmptyState(icon: Icons.chat_bubble_outline, message: l10n.aiNoConversationsMessage)
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: conversations.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return AppCard(
                      onTap: () => _openConversation(conversation.id),
                      child: Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(conversation.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  // --- Contract wizard -----------------------------------------------

  Future<void> _startContractWizard() async {
    setState(() {
      _resetWizard();
      _wizard = _WizardStage.selectType;
    });
    await _send(AppLocalizations.of(context)!.aiQuickActionCreateContract);
    if (!mounted) return;
    setState(() => _wizardMessages.add(_WizardMessage(text: AppLocalizations.of(context)!.aiContractWizardIntro, isUser: false)));
    _scrollToBottom();
  }

  void _pickContractType(ContractCategory category) {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _wizardCategory = category;
      _wizardMessages.add(_WizardMessage(text: category.label(l10n), isUser: true));
      _wizardMessages.add(_WizardMessage(text: l10n.aiContractWizardAskParty1, isUser: false));
      _wizard = _WizardStage.askParty1;
    });
    _scrollToBottom();
  }

  void _submitWizardAnswer(String text) {
    if (text.trim().isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _wizardMessages.add(_WizardMessage(text: text.trim(), isUser: true));
      switch (_wizard) {
        case _WizardStage.askParty1:
          _party1 = text.trim();
          _wizardMessages.add(_WizardMessage(text: l10n.aiContractWizardAskParty2, isUser: false));
          _wizard = _WizardStage.askParty2;
        case _WizardStage.askParty2:
          _party2 = text.trim();
          _wizardMessages.add(_WizardMessage(text: l10n.aiContractWizardAskSubject, isUser: false));
          _wizard = _WizardStage.askSubject;
        case _WizardStage.askSubject:
          _subject = text.trim();
          _wizardMessages.add(_WizardMessage(text: l10n.aiContractWizardAskValue, isUser: false));
          _wizard = _WizardStage.askValue;
        case _WizardStage.askValue:
          _value = text.trim();
          _wizard = _WizardStage.draftReady;
        case _WizardStage.none:
        case _WizardStage.selectType:
        case _WizardStage.draftReady:
        case _WizardStage.sent:
          break;
      }
    });
    _inputController.clear();
    _scrollToBottom();
  }

  void _sendSignatureRequest() {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _wizard = _WizardStage.sent);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.aiContractWizardSentMessage)));
  }

  void _saveDraftToVault() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.aiContractWizardSavedMessage)));
  }

  bool get _isCollectingWizardAnswer => const {
    _WizardStage.askParty1,
    _WizardStage.askParty2,
    _WizardStage.askSubject,
    _WizardStage.askValue,
  }.contains(_wizard);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final conversationId = _conversationId;
    final conversation = conversationId != null ? ref.watch(aiConversationByIdProvider(conversationId)) : null;
    final messages = conversation?.messages ?? const <AiMessage>[];
    final isFresh = messages.isEmpty && _wizard == _WizardStage.none;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconBadge(
              icon: Icons.smart_toy_outlined,
              size: 36,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              iconColor: AppColors.primary,
              iconSize: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.aiChatTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: context.statusColors.success.foreground, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          l10n.aiStatusAvailable,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.history), tooltip: l10n.aiRecentConversationsTitle, onPressed: _showHistory),
          IconButton(icon: const Icon(Icons.add_comment_outlined), tooltip: l10n.aiNewConversation, onPressed: _newConversation),
          if (conversationId != null)
            IconButton(icon: const Icon(Icons.delete_outline), tooltip: l10n.aiClearConversationTitle, onPressed: _clearConversation),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(color: context.statusColors.warning.background, borderRadius: AppRadii.mdRadius),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.secondary, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: Text(l10n.aiDisclaimer, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.secondary))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  if (isFresh) ...[
                    _ChatBubble(message: AiMessage(id: 'welcome', text: l10n.aiWelcomeMessage, isFromUser: false, sentAt: DateTime.now())),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        ActionChip(avatar: const Icon(Icons.description_outlined, size: 16), label: Text(l10n.aiQuickActionCreateContract), onPressed: _startContractWizard),
                        ActionChip(
                          avatar: const Icon(Icons.people_outline, size: 16),
                          label: Text(l10n.aiQuickActionHrIssue),
                          onPressed: () => _send(l10n.aiQuickActionHrIssue),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.menu_book_outlined, size: 16),
                          label: Text(l10n.aiQuickActionExplainClause),
                          onPressed: () => _send(l10n.aiQuickActionExplainClause),
                        ),
                      ],
                    ),
                  ],
                  for (final message in messages) _ChatBubble(message: message),
                  for (final wizardMessage in _wizardMessages)
                    _ChatBubble(message: AiMessage(id: 'w', text: wizardMessage.text, isFromUser: wizardMessage.isUser, sentAt: DateTime.now())),
                  if (_wizard == _WizardStage.selectType) _ContractTypeGrid(onSelect: _pickContractType),
                  if (_wizard == _WizardStage.draftReady || _wizard == _WizardStage.sent)
                    _ContractDraftCard(
                      category: _wizardCategory!,
                      party1: _party1!,
                      party2: _party2!,
                      subject: _subject!,
                      value: _value!,
                      isSent: _wizard == _WizardStage.sent,
                      onSendSignature: _sendSignatureRequest,
                      onSaveVault: _saveDraftToVault,
                    ),
                  if (_isSending) const _TypingIndicator(),
                  if (_hasError)
                    _ErrorBubble(
                      message: l10n.errorGeneric,
                      onRetry: () {
                        final text = _lastFailedText;
                        if (text != null) _send(text);
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _isSending ? null : _attachMockFile,
                    tooltip: l10n.commonUpload,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(hintText: _isCollectingWizardAnswer ? l10n.aiContractWizardInputHint : l10n.aiChatInputHint),
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: _isSending
                          ? null
                          : _isCollectingWizardAnswer
                          ? _submitWizardAnswer
                          : _send,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filled(
                    onPressed: _isSending
                        ? null
                        : () => _isCollectingWizardAnswer ? _submitWizardAnswer(_inputController.text) : _send(_inputController.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractTypeGrid extends StatelessWidget {
  const _ContractTypeGrid({required this.onSelect});

  final ValueChanged<ContractCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.sm),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.xs,
        crossAxisSpacing: AppSpacing.xs,
        childAspectRatio: 2.2,
        children: [
          for (final category in ContractCategory.values)
            AppCard(
              onTap: () => onSelect(category),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category.icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: Text(category.label(l10n), maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ContractDraftCard extends StatelessWidget {
  const _ContractDraftCard({
    required this.category,
    required this.party1,
    required this.party2,
    required this.subject,
    required this.value,
    required this.isSent,
    required this.onSendSignature,
    required this.onSaveVault,
  });

  final ContractCategory category;
  final String party1;
  final String party2;
  final String subject;
  final String value;
  final bool isSent;
  final VoidCallback onSendSignature;
  final VoidCallback onSaveVault;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.sm),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(category.icon, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(l10n.aiContractWizardDraftTitle(category.label(l10n)), style: Theme.of(context).textTheme.titleSmall),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
              decoration: BoxDecoration(
                color: isSent ? context.statusColors.info.background : context.statusColors.neutral.background,
                borderRadius: AppRadii.smRadius,
              ),
              child: Text(
                isSent ? l10n.aiContractWizardStatusSent : l10n.aiContractWizardStatusDraft,
                style: TextStyle(
                  color: isSent ? context.statusColors.info.foreground : context.statusColors.neutral.foreground,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DraftRow(label: l10n.aiContractWizardPartyA, value: party1),
            _DraftRow(label: l10n.aiContractWizardPartyB, value: party2),
            _DraftRow(label: l10n.aiContractWizardSubjectLabel, value: subject),
            _DraftRow(label: l10n.aiContractWizardValueLabel, value: value),
            if (!isSent) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(label: l10n.aiContractWizardSendSignature, variant: AppButtonVariant.success, onPressed: onSendSignature),
              const SizedBox(height: AppSpacing.xs),
              AppButton(label: l10n.aiContractWizardSaveVault, variant: AppButtonVariant.outlined, onPressed: onSaveVault),
            ],
          ],
        ),
      ),
    );
  }
}

class _DraftRow extends StatelessWidget {
  const _DraftRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(value, textAlign: TextAlign.end, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final AiMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isFromUser;
    return Align(
      alignment: isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: AppRadii.mdRadius,
        ),
        child: Text(message.text, style: TextStyle(color: isUser ? AppColors.onPrimary : AppColors.textPrimary)),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: AppRadii.mdRadius),
        child: const SizedBox(
          width: 24,
          height: 12,
          child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
      ),
    );
  }
}

class _ErrorBubble extends StatelessWidget {
  const _ErrorBubble({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(color: context.statusColors.error.background, borderRadius: AppRadii.mdRadius),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: context.statusColors.error.foreground, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Text(message, style: TextStyle(color: context.statusColors.error.foreground)),
            TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
          ],
        ),
      ),
    );
  }
}
