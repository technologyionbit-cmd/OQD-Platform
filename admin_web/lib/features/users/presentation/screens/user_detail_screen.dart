import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/routing/route_paths.dart';
import 'package:aqd_admin/core/utils/formatters.dart';
import 'package:aqd_admin/core/widgets/confirm_dialog.dart';
import 'package:aqd_admin/core/widgets/info_card.dart';
import 'package:aqd_admin/core/widgets/reason_dialog.dart';
import 'package:aqd_admin/core/widgets/snacks.dart';
import 'package:aqd_admin/core/widgets/state_views.dart';
import 'package:aqd_admin/core/widgets/status_chip.dart';
import 'package:aqd_admin/features/users/domain/managed_user.dart';
import 'package:aqd_admin/features/users/presentation/providers/users_providers.dart';
import 'package:aqd_admin/features/users/presentation/widgets/user_labels.dart';

class UserDetailScreen extends ConsumerWidget {
  const UserDetailScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(userDetailProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => context.go(RoutePaths.users),
            icon: const Icon(Icons.arrow_back),
            label: Text(l10n.backToList),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: detail.when(
            loading: () => const LoadingView(),
            error: (error, _) => ErrorView(error: error, onRetry: () => ref.invalidate(userDetailProvider(userId))),
            data: (user) => SingleChildScrollView(child: _DetailBody(user: user)),
          ),
        ),
      ],
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.user});

  final UserDetail user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final left = [
      _AccountCard(user: user),
      const SizedBox(height: 16),
      _RelatedCard(user: user),
    ];
    final right = [
      _ActionsCard(user: user),
      const SizedBox(height: 16),
      _SessionsCard(user: user),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(user.fullName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            if (user.isRemoved) StatusChip(label: l10n.statusRemoved, tone: StatusTone.error) else StatusChip(label: statusLabel(l10n, user.status), tone: statusTone(user.status)),
            StatusChip(label: roleLabel(l10n, user.role), tone: StatusTone.info),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 1000) {
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [...right, const SizedBox(height: 16), ...left]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: left)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: right)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user});

  final UserDetail user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InfoCard(
      title: l10n.sectionAccount,
      children: [
        InfoRow(label: l10n.colEmail, text: user.email),
        InfoRow(label: l10n.colPhone, child: SelectableText(user.phone ?? '-', textDirection: TextDirection.ltr)),
        InfoRow(label: l10n.fieldPhoneVerified, text: user.phoneVerifiedAt == null ? l10n.no : l10n.yes),
        InfoRow(label: l10n.colCreated, text: formatDateTime(context, user.createdAt)),
        InfoRow(label: l10n.colLastLogin, text: user.lastLoginAt == null ? l10n.never : formatDateTime(context, user.lastLoginAt)),
        InfoRow(label: l10n.fieldTerms, text: user.termsVersion == null ? '-' : '${user.termsVersion} (${formatDate(context, user.termsAcceptedAt)})'),
        if (user.suspendedAt != null) ...[
          const Divider(height: 24),
          InfoRow(label: l10n.fieldSuspendedAt, text: formatDateTime(context, user.suspendedAt)),
          InfoRow(label: l10n.fieldSuspendReason, text: user.suspendedReason),
          InfoRow(label: l10n.fieldSuspendedBy, text: user.suspendedBy?.fullName),
        ],
        if (user.isRemoved) ...[
          const Divider(height: 24),
          InfoRow(label: l10n.fieldDeletedAt, text: formatDateTime(context, user.deletedAt)),
        ],
      ],
    );
  }
}

class _RelatedCard extends StatelessWidget {
  const _RelatedCard({required this.user});

  final UserDetail user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lawyer = user.lawyerProfile;
    return InfoCard(
      title: l10n.sectionRelated,
      children: [
        InfoRow(label: l10n.fieldConsultations, text: '${user.counts.bookedConsultations}'),
        InfoRow(label: l10n.fieldContracts, text: '${user.counts.contracts}'),
        if (lawyer != null) ...[
          InfoRow(
            label: l10n.fieldLawyerStatus,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: StatusChip(label: verificationLabel(l10n, lawyer.verificationStatus), tone: verificationTone(lawyer.verificationStatus)),
            ),
          ),
          InfoRow(label: l10n.fieldRating, text: '${lawyer.rating.toStringAsFixed(2)} (${lawyer.reviewsCount})'),
        ],
        if (user.ownedOrganizations.isNotEmpty)
          InfoRow(label: l10n.fieldOrganizations, text: user.ownedOrganizations.map((o) => o.name).join('، ')),
      ],
    );
  }
}

class _SessionsCard extends StatelessWidget {
  const _SessionsCard({required this.user});

  final UserDetail user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return InfoCard(
      title: '${l10n.sectionSessions} (${user.sessions.length})',
      children: [
        if (user.sessions.isEmpty) Text(l10n.noSessions, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        for (final session in user.sessions)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.deviceLabel ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${session.ipAddress ?? '-'}  ·  ${l10n.sessionLastUsed}: ${formatDateTime(context, session.lastUsedAt ?? session.createdAt)}',
                  style: theme.textTheme.bodySmall,
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActionsCard extends ConsumerWidget {
  const _ActionsCard({required this.user});

  final UserDetail user;

  /// Runs [action], refreshes the detail and the list, and says how it went.
  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
      ref
        ..invalidate(userDetailProvider(user.id))
        ..invalidate(usersPageProvider);
      if (context.mounted) showSuccessSnack(context, l10n.actionDone);
    } on Object catch (error) {
      if (context.mounted) showFailureSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(usersRepositoryProvider);
    final scheme = Theme.of(context).colorScheme;

    Widget button(String label, IconData icon, VoidCallback onPressed, {bool danger = false}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18, color: danger ? scheme.error : null),
          label: Text(label, style: TextStyle(color: danger ? scheme.error : null)),
          style: OutlinedButton.styleFrom(alignment: AlignmentDirectional.centerStart, side: danger ? BorderSide(color: scheme.error) : null),
        ),
      );
    }

    final actions = <Widget>[];
    if (user.isAdmin) {
      actions.add(Text(l10n.adminProtected));
    } else if (user.isRemoved) {
      actions.add(button(l10n.restoreAction, Icons.restore_from_trash_outlined, () async {
        final ok = await showConfirmDialog(context, title: l10n.restoreTitle, message: l10n.restoreBody);
        if (ok && context.mounted) await _run(context, ref, () => repo.restore(user.id));
      }));
    } else {
      if (user.isSuspended) {
        actions.add(button(l10n.activateAction, Icons.check_circle_outline, () async {
          final ok = await showConfirmDialog(context, title: l10n.activateTitle, message: l10n.activateBody);
          if (ok && context.mounted) await _run(context, ref, () => repo.activate(user.id));
        }));
      } else if (user.status == 'active') {
        actions.add(button(l10n.suspendAction, Icons.block, () async {
          final reason = await showReasonDialog(context, title: l10n.suspendTitle, message: l10n.suspendBody, confirmLabel: l10n.suspendAction);
          if (reason != null && context.mounted) await _run(context, ref, () => repo.suspend(user.id, reason: reason));
        }));
      }
      if (user.status == 'active' && user.phone != null) {
        actions.add(button(l10n.resetPasswordAction, Icons.password_outlined, () async {
          final ok = await showConfirmDialog(context, title: l10n.resetTitle, message: l10n.resetBody);
          if (ok && context.mounted) await _run(context, ref, () => repo.resetPassword(user.id));
        }));
      }
      if (user.sessions.isNotEmpty) {
        actions.add(button(l10n.revokeAction, Icons.logout, () async {
          final ok = await showConfirmDialog(context, title: l10n.revokeTitle, message: l10n.revokeBody);
          if (ok && context.mounted) await _run(context, ref, () => repo.revokeSessions(user.id));
        }));
      }
      actions.add(button(l10n.deleteAction, Icons.delete_outline, () async {
        final reason = await showReasonDialog(context, title: l10n.deleteTitle, message: l10n.deleteBody, confirmLabel: l10n.deleteAction);
        if (reason == null || !context.mounted) return;
        final confirmed = await showConfirmDialog(
          context,
          title: l10n.deleteTitle,
          message: l10n.deleteBody,
          confirmLabel: l10n.deleteAction,
          destructive: true,
          confirmWord: l10n.deleteConfirmWord,
        );
        if (confirmed && context.mounted) await _run(context, ref, () => repo.softDelete(user.id, reason: reason));
      }, danger: true));
    }

    return InfoCard(
      title: l10n.sectionActions,
      children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: actions)],
    );
  }
}
