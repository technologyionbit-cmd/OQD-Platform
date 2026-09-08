import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/section_header.dart';
import 'package:aqd_ionbit/features/ai/presentation/providers/ai_analyses_controller.dart';
import 'package:aqd_ionbit/features/documents/presentation/providers/documents_controller.dart';

/// Step 1 of contract analysis — pick an existing vault document, or type
/// a title to represent a freshly "uploaded" mock document (there's no
/// real file picker/OCR pipeline in this phase, see this feature's scope
/// note). Either path hands off to [analyzeDocument] and shows the
/// "Analyzing..." state inline before navigating to the result.
class AiAnalysisSelectScreen extends ConsumerStatefulWidget {
  const AiAnalysisSelectScreen({super.key});

  @override
  ConsumerState<AiAnalysisSelectScreen> createState() => _AiAnalysisSelectScreenState();
}

class _AiAnalysisSelectScreenState extends ConsumerState<AiAnalysisSelectScreen> {
  final _titleController = TextEditingController();
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _analyze({required String title, String? sourceDocumentId}) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isAnalyzing = true);
    final result = await ref
        .read(aiAnalysesControllerProvider.notifier)
        .analyzeDocument(documentTitle: title, sourceDocumentId: sourceDocumentId);
    if (!mounted) return;
    setState(() => _isAnalyzing = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric))),
      (analysis) => context.pushReplacement(RoutePaths.clientAiAnalysisResult(analysis.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final documentsState = ref.watch(documentsControllerProvider);

    if (_isAnalyzing) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.serviceAnalyzeContract)),
        body: LoadingView(message: l10n.analysisAnalyzingMessage),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.serviceAnalyzeContract)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text(l10n.analysisUploadTitle, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            AppTextField(
              controller: _titleController,
              label: l10n.analysisUploadLabel,
              hintText: l10n.analysisUploadHint,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.analysisAnalyzeButton,
              icon: Icons.upload_file_outlined,
              variant: AppButtonVariant.outlined,
              onPressed: _titleController.text.trim().isEmpty ? null : () => _analyze(title: _titleController.text.trim()),
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(title: l10n.analysisSelectFromVaultTitle),
            const SizedBox(height: AppSpacing.sm),
            switch (documentsState) {
              AsyncData(value: final documents) when documents.isEmpty => EmptyState(
                icon: Icons.folder_open_outlined,
                message: l10n.documentsEmptyMessage,
              ),
              AsyncData(value: final documents) => Column(
                children: [
                  for (final document in documents) ...[
                    AppCard(
                      onTap: () => _analyze(title: document.title, sourceDocumentId: document.id),
                      child: Row(
                        children: [
                          const IconBadge(icon: Icons.description_outlined, size: 40),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(document.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
              AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(documentsControllerProvider.notifier).refresh()),
              _ => const LoadingView(),
            },
          ],
        ),
      ),
    );
  }
}
