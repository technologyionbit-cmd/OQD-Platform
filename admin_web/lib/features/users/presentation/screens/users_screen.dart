import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/routing/route_paths.dart';
import 'package:aqd_admin/core/utils/file_saver.dart';
import 'package:aqd_admin/core/utils/formatters.dart';
import 'package:aqd_admin/core/widgets/admin_data_table.dart';
import 'package:aqd_admin/core/widgets/confirm_dialog.dart';
import 'package:aqd_admin/core/widgets/page_header.dart';
import 'package:aqd_admin/core/widgets/reason_dialog.dart';
import 'package:aqd_admin/core/widgets/snacks.dart';
import 'package:aqd_admin/core/widgets/status_chip.dart';
import 'package:aqd_admin/features/users/domain/managed_user.dart';
import 'package:aqd_admin/features/users/presentation/providers/users_providers.dart';
import 'package:aqd_admin/features/users/presentation/widgets/user_labels.dart';
import 'package:aqd_admin/features/users/presentation/widgets/users_filters.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  bool _exporting = false;

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(context, title: l10n.exportConfirmTitle, message: l10n.exportConfirmBody, confirmLabel: l10n.exportCsv);
    if (!confirmed || !mounted) return;
    setState(() => _exporting = true);
    try {
      final bytes = await ref.read(usersRepositoryProvider).exportCsv(ref.read(usersQueryProvider));
      await ref.read(fileSaverProvider)('users.csv', bytes, 'text/csv');
      if (mounted) showSuccessSnack(context, l10n.exportDone);
    } on Object catch (error) {
      if (mounted) showFailureSnack(context, error);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _bulk(String action) async {
    final l10n = AppLocalizations.of(context);
    final ids = ref.read(selectedUsersProvider).toList();
    String? reason;
    if (action == 'suspend') {
      reason = await showReasonDialog(context, title: l10n.suspendTitle, message: l10n.bulkSuspendBody(ids.length), confirmLabel: l10n.bulkSuspend);
      if (reason == null) return;
    } else {
      final confirmed = await showConfirmDialog(
        context,
        title: action == 'activate' ? l10n.activateTitle : l10n.revokeTitle,
        message: action == 'activate' ? l10n.bulkActivateBody(ids.length) : l10n.bulkRevokeBody(ids.length),
      );
      if (!confirmed) return;
    }
    if (!mounted) return;
    try {
      final result = await ref.read(usersRepositoryProvider).bulk(action: action, ids: ids, reason: reason);
      ref.read(selectedUsersProvider.notifier).clear();
      ref.invalidate(usersPageProvider);
      if (mounted) showSuccessSnack(context, l10n.bulkResult(result.succeeded.length, result.skipped.length));
    } on Object catch (error) {
      if (mounted) showFailureSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(usersQueryProvider);
    final controller = ref.read(usersQueryProvider.notifier);
    final page = ref.watch(usersPageProvider);
    final selected = ref.watch(selectedUsersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: l10n.navUsers,
          subtitle: l10n.usersSubtitle,
          actions: [
            OutlinedButton.icon(
              onPressed: _exporting ? null : _export,
              icon: _exporting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.download_outlined),
              label: Text(l10n.exportCsv),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: AdminDataTable<ManagedUser>(
              columns: [
                AdminColumn(label: l10n.colName, sortKey: 'fullName', cell: (u) => _NameCell(user: u)),
                AdminColumn(label: l10n.colEmail, sortKey: 'email', cell: (u) => Text(u.email)),
                AdminColumn(label: l10n.colPhone, cell: (u) => Text(u.phone ?? '-', textDirection: TextDirection.ltr)),
                AdminColumn(label: l10n.colRole, cell: (u) => Text(roleLabel(l10n, u.role))),
                AdminColumn(
                  label: l10n.colStatus,
                  cell: (u) => u.isRemoved
                      ? StatusChip(label: l10n.statusRemoved, tone: StatusTone.error)
                      : StatusChip(label: statusLabel(l10n, u.status), tone: statusTone(u.status)),
                ),
                AdminColumn(label: l10n.colLastLogin, sortKey: 'lastLoginAt', cell: (u) => Text(u.lastLoginAt == null ? l10n.never : formatDateTime(context, u.lastLoginAt))),
                AdminColumn(label: l10n.colCreated, sortKey: 'createdAt', cell: (u) => Text(formatDate(context, u.createdAt))),
              ],
              rows: page.value?.items ?? const [],
              page: query.page,
              limit: query.limit,
              total: page.value?.total ?? 0,
              isLoading: page.isLoading,
              error: page.hasError ? page.error : null,
              onRetry: () => ref.invalidate(usersPageProvider),
              sortKey: query.sort,
              ascending: query.ascending,
              onSort: controller.sortBy,
              onPageChanged: controller.setPage,
              onLimitChanged: controller.setLimit,
              filters: const UsersFilters(),
              idOf: (u) => u.id,
              selectedIds: selected,
              onSelectionChanged: ref.read(selectedUsersProvider.notifier).set,
              bulkActions: [
                FilledButton.tonalIcon(onPressed: () => _bulk('suspend'), icon: const Icon(Icons.block, size: 18), label: Text(l10n.bulkSuspend)),
                FilledButton.tonalIcon(onPressed: () => _bulk('activate'), icon: const Icon(Icons.check_circle_outline, size: 18), label: Text(l10n.bulkActivate)),
                FilledButton.tonalIcon(onPressed: () => _bulk('revokeSessions'), icon: const Icon(Icons.logout, size: 18), label: Text(l10n.bulkRevoke)),
              ],
              onRowTap: (u) => context.go('${RoutePaths.users}/${u.id}'),
            ),
          ),
        ),
      ],
    );
  }
}

class _NameCell extends StatelessWidget {
  const _NameCell({required this.user});

  final ManagedUser user;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Text(
        user.fullName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.w600, decoration: user.isRemoved ? TextDecoration.lineThrough : null),
      ),
    );
  }
}
