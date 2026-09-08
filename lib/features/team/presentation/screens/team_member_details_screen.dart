import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/app_dropdown.dart';
import 'package:aqd_ionbit/core/widgets/confirmation_dialog.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/features/team/domain/entities/team_member_role.dart';
import 'package:aqd_ionbit/features/team/presentation/providers/team_controller.dart';
import 'package:aqd_ionbit/features/team/presentation/widgets/team_member_role_x.dart';

class TeamMemberDetailsScreen extends ConsumerStatefulWidget {
  const TeamMemberDetailsScreen({super.key, required this.memberId});

  final String memberId;

  @override
  ConsumerState<TeamMemberDetailsScreen> createState() => _TeamMemberDetailsScreenState();
}

class _TeamMemberDetailsScreenState extends ConsumerState<TeamMemberDetailsScreen> {
  bool _isUpdatingRole = false;

  Future<void> _changeRole(TeamMemberRole role) async {
    setState(() => _isUpdatingRole = true);
    await ref.read(teamControllerProvider.notifier).updateMemberRole(id: widget.memberId, role: role);
    if (!mounted) return;
    setState(() => _isUpdatingRole = false);
  }

  Future<void> _remove() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.teamRemoveConfirmTitle,
      message: l10n.teamRemoveConfirmMessage,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    await ref.read(teamControllerProvider.notifier).removeMember(widget.memberId);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final member = ref.watch(teamMemberByIdProvider(widget.memberId));

    if (member == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navTeam)),
        body: EmptyState(icon: Icons.person_off_outlined, message: l10n.errorGeneric),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(member.fullName)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Row(
              children: [
                const IconBadge(icon: Icons.person_outline, size: 56),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.fullName, style: Theme.of(context).textTheme.titleLarge),
                      Text(member.email, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.teamJoinedOn(DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(member.joinedAt))),
                  const SizedBox(height: AppSpacing.md),
                  AppDropdown<TeamMemberRole>(
                    label: l10n.teamRoleLabel,
                    value: member.role,
                    items: TeamMemberRole.values,
                    itemLabel: (r) => r.label(l10n),
                    onChanged: (role) {
                      if (!_isUpdatingRole && role != null) _changeRole(role);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: l10n.teamRemoveMember, variant: AppButtonVariant.destructive, onPressed: _remove),
          ],
        ),
      ),
    );
  }
}
