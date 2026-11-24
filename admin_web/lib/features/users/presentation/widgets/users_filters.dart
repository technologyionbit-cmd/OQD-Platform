import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/widgets/filter_widgets.dart';
import 'package:aqd_admin/features/users/presentation/providers/users_providers.dart';
import 'package:aqd_admin/features/users/presentation/widgets/user_labels.dart';

/// Search + filters above the users table.
class UsersFilters extends ConsumerWidget {
  const UsersFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(usersQueryProvider);
    final controller = ref.read(usersQueryProvider.notifier);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 320,
          child: DebouncedSearchField(
            // Rebuilt when filters are cleared, so the box empties too.
            key: ValueKey('search-${query.hasFilters}-${query.search.isEmpty}'),
            initialValue: query.search,
            hint: l10n.searchUsersHint,
            onChanged: controller.setSearch,
          ),
        ),
        FilterDropdown<String>(
          label: l10n.filterRole,
          value: query.role,
          options: {
            'client': l10n.roleClient,
            'lawyer': l10n.roleLawyer,
            'company': l10n.roleCompany,
            'admin': l10n.roleAdmin,
          },
          onChanged: controller.setRole,
        ),
        FilterDropdown<String>(
          label: l10n.filterStatus,
          value: query.status,
          options: {
            for (final status in ['active', 'suspended', 'banned', 'pendingDeletion']) status: statusLabel(l10n, status),
          },
          onChanged: controller.setStatus,
        ),
        SizedBox(
          width: 190,
          child: DropdownButtonFormField<String>(
            initialValue: query.deleted,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.filterDeleted),
            items: [
              DropdownMenuItem(value: 'exclude', child: Text(l10n.deletedHide)),
              DropdownMenuItem(value: 'only', child: Text(l10n.deletedOnly)),
              DropdownMenuItem(value: 'include', child: Text(l10n.deletedInclude)),
            ],
            onChanged: (value) {
              if (value != null) controller.setDeleted(value);
            },
          ),
        ),
        DateFilterButton(label: l10n.dateFrom, value: query.createdFrom, onChanged: controller.setFrom),
        DateFilterButton(label: l10n.dateTo, value: query.createdTo, onChanged: controller.setTo),
        if (query.hasFilters) TextButton.icon(onPressed: controller.clearFilters, icon: const Icon(Icons.filter_alt_off_outlined, size: 18), label: Text(l10n.clearFilters)),
      ],
    );
  }
}
