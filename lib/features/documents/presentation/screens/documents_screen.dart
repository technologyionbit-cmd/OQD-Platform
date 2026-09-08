import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_bottom_sheet.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/app_chip.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/core/widgets/confirmation_dialog.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/contract_analysis.dart';
import 'package:aqd_ionbit/features/ai/presentation/providers/ai_analyses_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contracts_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/widgets/contract_status_x.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document_source_type.dart';
import 'package:aqd_ionbit/features/documents/presentation/providers/documents_controller.dart';

enum _VaultFilter { all, documents, aiReports, contracts }

/// The "digital vault" — matches the reference's filter-tab list (all /
/// plain documents / AI analysis reports / generated contracts) by merging
/// two already-existing mock datasets (`documentsControllerProvider` and,
/// client-role only, `aiAnalysesControllerProvider`) into one feed, rather
/// than inventing a third mock source for what the reference shows as a
/// single unified list.
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key, this.routeBase = RoutePaths.clientBase});

  final String routeBase;

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _VaultFilter _filter = _VaultFilter.all;

  bool get _includesAiReports => widget.routeBase == RoutePaths.clientBase;

  // A lawyer only ever gets read access to a client's documents — see
  // lawyer_extra_routes.dart's doc comment — so upload/rename/delete must
  // not be offered here.
  bool get _canManage => widget.routeBase != RoutePaths.lawyerBase;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final title = await showAppBottomSheet<String>(
      context,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.documentsUploadTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.documentsUploadHint, style: Theme.of(sheetContext).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.md),
            AppTextField(controller: titleController, label: l10n.documentsUploadLabel),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.commonUpload,
              onPressed: () => Navigator.of(sheetContext).pop(titleController.text.trim()),
            ),
          ],
        );
      },
    );
    if (title == null || title.isEmpty || !mounted) return;
    final result = await ref.read(documentsControllerProvider.notifier).upload(title);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.documentsUploadedMessage))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final documentsState = ref.watch(documentsControllerProvider);
    final analysesState = _includesAiReports ? ref.watch(aiAnalysesControllerProvider) : const AsyncValue<List<ContractAnalysis>>.data([]);
    final isLoading = documentsState is AsyncLoading || analysesState is AsyncLoading;
    final hasError = documentsState is AsyncError || analysesState is AsyncError;
    final documents = documentsState.value ?? const <Document>[];
    final analyses = analysesState.value ?? const <ContractAnalysis>[];
    final totalCount = documents.length + analyses.length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navDocuments)),
      floatingActionButton: _canManage
          ? FloatingActionButton(onPressed: _upload, tooltip: l10n.documentsUploadTitle, child: const Icon(Icons.add))
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xs),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(hintText: l10n.documentsSearchHint, prefixIcon: const Icon(Icons.search)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(l10n.vaultSavedFilesCount(totalCount), style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  AppChip(label: l10n.contractsFilterAll, selected: _filter == _VaultFilter.all, onTap: () => setState(() => _filter = _VaultFilter.all)),
                  const SizedBox(width: AppSpacing.xs),
                  AppChip(
                    label: l10n.vaultFilterDocuments,
                    selected: _filter == _VaultFilter.documents,
                    onTap: () => setState(() => _filter = _VaultFilter.documents),
                  ),
                  if (_includesAiReports) ...[
                    const SizedBox(width: AppSpacing.xs),
                    AppChip(
                      label: l10n.vaultFilterAiReports,
                      selected: _filter == _VaultFilter.aiReports,
                      onTap: () => setState(() => _filter = _VaultFilter.aiReports),
                    ),
                  ],
                  const SizedBox(width: AppSpacing.xs),
                  AppChip(
                    label: l10n.vaultFilterContracts,
                    selected: _filter == _VaultFilter.contracts,
                    onTap: () => setState(() => _filter = _VaultFilter.contracts),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: isLoading
                  ? const LoadingView()
                  : hasError
                  ? ErrorView(
                      message: l10n.errorGeneric,
                      onRetry: () {
                        ref.read(documentsControllerProvider.notifier).refresh();
                        if (_includesAiReports) ref.read(aiAnalysesControllerProvider.notifier).refresh();
                      },
                    )
                  : Builder(
                      builder: (context) {
                        final query = _query.trim().toLowerCase();
                        final filteredDocuments = documents.where((d) {
                          final matchesFilter = switch (_filter) {
                            _VaultFilter.all => true,
                            _VaultFilter.documents => d.sourceType == DocumentSourceType.uploaded,
                            _VaultFilter.contracts => d.sourceType == DocumentSourceType.generatedContract,
                            _VaultFilter.aiReports => false,
                          };
                          return matchesFilter && d.title.toLowerCase().contains(query);
                        }).toList();
                        final filteredAnalyses = (_includesAiReports && (_filter == _VaultFilter.all || _filter == _VaultFilter.aiReports))
                            ? analyses.where((a) => a.documentTitle.toLowerCase().contains(query)).toList()
                            : const <ContractAnalysis>[];

                        if (filteredDocuments.isEmpty && filteredAnalyses.isEmpty) {
                          return query.isNotEmpty
                              ? EmptyState(
                                  icon: Icons.search_off_outlined,
                                  title: l10n.documentsSearchEmptyTitle,
                                  message: l10n.documentsSearchEmptyMessage,
                                )
                              : EmptyState(icon: Icons.folder_open_outlined, title: l10n.documentsEmptyTitle, message: l10n.documentsEmptyMessage);
                        }

                        final items = [
                          ...filteredAnalyses.map((a) => (analysis: a, document: null as Document?)),
                          ...filteredDocuments.map((d) => (analysis: null as ContractAnalysis?, document: d)),
                        ]..sort((a, b) {
                          final dateA = a.analysis?.createdAt ?? a.document!.createdAt;
                          final dateB = b.analysis?.createdAt ?? b.document!.createdAt;
                          return dateB.compareTo(dateA);
                        });

                        return RefreshIndicator(
                          onRefresh: () async {
                            await ref.read(documentsControllerProvider.notifier).refresh();
                            if (_includesAiReports) await ref.read(aiAnalysesControllerProvider.notifier).refresh();
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xs, AppSpacing.xl, AppSpacing.xl),
                            itemCount: items.length,
                            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              if (item.analysis != null) return _AnalysisCard(analysis: item.analysis!);
                              return _DocumentCard(document: item.document!, routeBase: widget.routeBase, canManage: _canManage);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.analysis});

  final ContractAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      onTap: () => context.push(RoutePaths.clientAiAnalysisResult(analysis.id)),
      child: Row(
        children: [
          IconBadge(icon: Icons.analytics_outlined, size: 44, backgroundColor: context.statusColors.info.background, iconColor: context.statusColors.info.foreground),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(analysis.documentTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(analysis.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(label: l10n.vaultAiReportBadge, tone: AppStatusTone.info),
        ],
      ),
    );
  }
}

class _DocumentCard extends ConsumerWidget {
  const _DocumentCard({required this.document, required this.routeBase, required this.canManage});

  final Document document;
  final String routeBase;
  final bool canManage;

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: document.title);
    final newTitle = await showAppBottomSheet<String>(
      context,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.documentsRenameTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            AppTextField(controller: controller, label: l10n.documentsUploadLabel),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: l10n.commonSave, onPressed: () => Navigator.of(sheetContext).pop(controller.text.trim())),
          ],
        );
      },
    );
    if (newTitle == null || newTitle.isEmpty || newTitle == document.title || !context.mounted) return;
    await ref.read(documentsControllerProvider.notifier).rename(id: document.id, newTitle: newTitle);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.documentsDeleteConfirmTitle,
      message: l10n.documentsDeleteConfirmMessage,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final result = await ref.read(documentsControllerProvider.notifier).delete(document.id);
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.documentsDeletedMessage))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final canOpen = document.contractId != null;
    // Only a generated-contract document has a real contract behind it to
    // show a rich status badge for — a plain uploaded file has no such
    // status in this mock model, matching the original simpler card.
    final linkedContract = canOpen
        ? ref.watch(contractsControllerProvider).value?.where((c) => c.id == document.contractId).firstOrNull
        : null;

    return AppCard(
      onTap: canOpen ? () => context.push(RoutePaths.contractDetailsFor(routeBase, document.contractId!)) : null,
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
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (linkedContract != null) ...[
            Flexible(child: StatusBadge(label: linkedContract.status.label(l10n), tone: linkedContract.status.tone)),
            const SizedBox(width: AppSpacing.xs),
          ],
          if (canManage)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
              onSelected: (value) {
                if (value == 'rename') _rename(context, ref);
                if (value == 'delete') _delete(context, ref);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'rename', child: Text(l10n.commonRename)),
                PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete)),
              ],
            ),
          if (canOpen)
            Icon(
              Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}
