import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message_type.dart';
import 'package:aqd_ionbit/features/messages/presentation/providers/local_image_cache.dart';
import 'package:aqd_ionbit/features/messages/presentation/utils/message_timestamp.dart';
import 'package:aqd_ionbit/features/messages/presentation/utils/mock_file_attachment.dart';
import 'package:aqd_ionbit/features/messages/presentation/widgets/chat_image_viewer.dart';

/// One chat bubble — text, image, or mock file. [isMine] is relative to
/// whoever is viewing (mirrors `_MessageBubble` in
/// `ConsultationDetailsScreen`'s older thread), so the same widget renders
/// correctly for both the client's and the lawyer's screen. Tapping the
/// timestamp toggles it between the smart relative/clock-time default and
/// the full absolute date+time.
class ChatMessageBubble extends ConsumerStatefulWidget {
  const ChatMessageBubble({super.key, required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  ConsumerState<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends ConsumerState<ChatMessageBubble> {
  bool _showAbsoluteTimestamp = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final message = widget.message;
    final isMine = widget.isMine;
    final bubbleColor = isMine ? AppColors.primary : AppColors.surfaceVariant;
    final textColor = isMine ? AppColors.onPrimary : AppColors.textPrimary;

    return Align(
      alignment: isMine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(color: bubbleColor, borderRadius: AppRadii.mdRadius),
              child: _buildContent(context, l10n, textColor),
            ),
            GestureDetector(
              onTap: () => setState(() => _showAbsoluteTimestamp = !_showAbsoluteTimestamp),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: AppSpacing.xxs, end: AppSpacing.xxs, bottom: AppSpacing.xxs),
                child: Text(
                  formatMessageTimestamp(message.sentAt, l10n: l10n, locale: locale, absolute: _showAbsoluteTimestamp),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, Color textColor) {
    final message = widget.message;
    switch (message.type) {
      case MessageType.text:
        return Text(message.text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor));

      case MessageType.image:
        final bytes = ref.watch(localImageCacheProvider).get(message.attachmentUrl);
        return GestureDetector(
          onTap: () => showChatImageViewer(context, message.attachmentUrl),
          child: ClipRRect(
            borderRadius: AppRadii.smRadius,
            child: bytes != null
                ? Image.memory(bytes, width: 180, height: 180, fit: BoxFit.cover)
                : Container(
                    width: 180,
                    height: 180,
                    color: textColor.withValues(alpha: 0.08),
                    alignment: Alignment.center,
                    child: Icon(Icons.image_outlined, size: 48, color: textColor.withValues(alpha: 0.6)),
                  ),
          ),
        );

      case MessageType.file:
        final file = MockFileAttachment.tryDecode(message.attachmentUrl);
        final fileName = file?.fileName ?? message.text;
        return InkWell(
          borderRadius: AppRadii.smRadius,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chatFileDownloadedMock(fileName)))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insert_drive_file_outlined, color: textColor),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: textColor),
                    ),
                    if (file != null && file.sizeLabel.isNotEmpty)
                      Text(
                        file.sizeLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor.withValues(alpha: 0.8)),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.download_outlined, color: textColor, size: 18),
            ],
          ),
        );
    }
  }
}
