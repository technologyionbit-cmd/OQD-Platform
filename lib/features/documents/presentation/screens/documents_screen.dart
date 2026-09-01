import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document_source_type.dart';
import 'package:aqd_ionbit/features/documents/presentation/providers/documents_controller.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final documentsState = ref.watch(documentsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navDocuments)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.sm),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(hintText: l10n.documentsSearchHint, prefixIcon: const Icon(Icons.search)),
              ),
            ),
            Expanded(
              child: switch (documentsState) {
                AsyncData(value: final documents) => Builder(
                  builder: (context) {
                    final filtered = documents.where((d) => d.title.toLowerCase().contains(_query.toLowerCase())).toList();
                    if (filtered.isEmpty) {
                      return EmptyState(
                        icon: Icons.folder_open_outlined,
                        title: l10n.documentsEmptyTitle,
                        message: l10n.documentsEmptyMessage,
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => ref.read(documentsControllerProvider.notifier).refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) => _DocumentCard(document: filtered[index]),
                      ),
                    );
                  },
                ),
                AsyncError() => ErrorView(
                  message: l10n.errorGeneric,
                  onRetry: () => ref.read(documentsControllerProvider.notifier).refresh(),
                ),
                _ => const LoadingView(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document});

  final Document document;

  @override
  Widget build(BuildContext context) {
    final canOpen = document.contractId != null;
    return AppCard(
      onTap: canOpen ? () => context.push(RoutePaths.clientContractDetails(document.contractId!)) : null,
      child: Row(
        children: [
          IconBadge(
            icon: document.sourceType == DocumentSourceType.generatedContract ? Icons.description_outlined : Icons.upload_file_outlined,
            size: 44,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(document.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${document.sizeLabel} · ${DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(document.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (canOpen) const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
