import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/features/messages/presentation/providers/local_image_cache.dart';

/// Full-screen, pinch-to-zoom viewer opened by tapping an image message.
/// Seeded demo image messages (`mock://images/...`) have no real bytes
/// behind them, so this falls back to a clear "preview unavailable" state
/// instead of a broken image — never a silent no-op.
class ChatImageViewerScreen extends ConsumerWidget {
  const ChatImageViewerScreen({super.key, required this.attachmentUrl});

  final String? attachmentUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final bytes = ref.watch(localImageCacheProvider).get(attachmentUrl);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: AppColors.onPrimary, title: Text(l10n.chatImagePreviewTitle)),
      body: Center(
        child: bytes != null
            ? InteractiveViewer(child: Image.memory(bytes))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.image_outlined, color: Colors.white54, size: 96),
                  const SizedBox(height: 12),
                  Text(l10n.chatImageUnavailableMock, style: const TextStyle(color: Colors.white70)),
                ],
              ),
      ),
    );
  }
}

void showChatImageViewer(BuildContext context, String? attachmentUrl) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => ChatImageViewerScreen(attachmentUrl: attachmentUrl), fullscreenDialog: true));
}
