import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_bottom_sheet.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/app_dropdown.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/team/domain/entities/team_member_role.dart';
import 'package:aqd_ionbit/features/team/presentation/providers/team_controller.dart';
import 'package:aqd_ionbit/features/team/presentation/widgets/team_member_role_x.dart';

class TeamListScreen extends ConsumerStatefulWidget {
  const TeamListScreen({super.key});

  @override
  ConsumerState<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends ConsumerState<TeamListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addMember() async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    var role = TeamMemberRole.member;
    final errors = <String, String?>{};

    final added = await showAppBottomSheet<bool>(
      context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.teamAddMemberTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                AppTextField(controller: nameController, label: l10n.authFullName, errorText: errors['name']),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: emailController,
                  label: l10n.authEmailLabel,
                  keyboardType: TextInputType.emailAddress,
                  errorText: errors['email'],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppDropdown<TeamMemberRole>(
                  label: l10n.teamRoleLabel,
                  value: role,
                  items: TeamMemberRole.values,
                  itemLabel: (r) => r.label(l10n),
                  onChanged: (value) => setSheetState(() => role = value ?? role),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: l10n.teamAddMemberAction,
                  onPressed: () {
                    final nameError = Validators.isRequired(nameController.text) ? null : l10n.validationRequired;
                    final emailError = Validators.isValidEmail(emailController.text) ? null : l10n.validationInvalidEmail;
                    if (nameError != null || emailError != null) {
                      setSheetState(() {
                        errors['name'] = nameError;
                        errors['email'] = emailError;
                      });
                      return;
                    }
                    Navigator.of(sheetContext).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (added != true || !mounted) return;
    final result = await ref
        .read(teamControllerProvider.notifier)
        .addMember(fullName: nameController.text.trim(), email: emailController.text.trim(), role: role);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.teamMemberAddedMessage))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final teamState = ref.watch(teamControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTeam)),
      floatingActionButton: FloatingActionButton(onPressed: _addMember, tooltip: l10n.teamAddMemberTitle, child: const Icon(Icons.person_add_outlined)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.sm),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(hintText: l10n.teamSearchHint, prefixIcon: const Icon(Icons.search)),
              ),
            ),
            Expanded(
              child: switch (teamState) {
                AsyncData(value: final members) => Builder(
                  builder: (context) {
                    final filtered = members.where((m) => m.fullName.toLowerCase().contains(_query.toLowerCase())).toList();
                    if (filtered.isEmpty) {
                      return EmptyState(icon: Icons.groups_outlined, title: l10n.teamEmptyTitle, message: l10n.teamEmptyMessage);
                    }
                    return RefreshIndicator(
                      onRefresh: () => ref.read(teamControllerProvider.notifier).refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final member = filtered[index];
                          return AppCard(
                            onTap: () => context.push(RoutePaths.companyTeamMemberDetails(member.id)),
                            child: Row(
                              children: [
                                const IconBadge(icon: Icons.person_outline, size: 44),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(member.fullName, style: Theme.of(context).textTheme.titleSmall),
                                      Text(
                                        member.email,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(label: member.role.label(l10n), tone: member.role.tone),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(teamControllerProvider.notifier).refresh()),
                _ => const LoadingView(),
              },
            ),
          ],
        ),
      ),
    );
  }
}
