import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/utils/time_ago.dart' show formatTimeAgo;
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_bottom_sheet.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/section_header.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_session.dart';
import 'package:aqd_ionbit/features/profile/presentation/providers/active_sessions_controller.dart';

/// Account → Security & Privacy. Change-password and the active-session
/// list are wired to the real `/auth/*` API. 2FA has no backend yet so its
/// toggle is shown disabled; biometric unlock stays a local device
/// preference.
class SecurityPrivacyScreen extends ConsumerStatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  ConsumerState<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends ConsumerState<SecurityPrivacyScreen> {
  bool _biometricEnabled = false;
  bool _revokingOthers = false;

  Future<void> _changePassword() async {
    final l10n = AppLocalizations.of(context)!;
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    final saved = await showAppBottomSheet<bool>(
      context,
      builder: (sheetContext) {
        String? error;
        var submitting = false;

        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> submit() async {
              if (!Validators.isRequired(currentController.text) ||
                  !Validators.isPasswordLongEnough(newController.text)) {
                setSheetState(() => error = l10n.validationRequired);
                return;
              }
              if (newController.text != confirmController.text) {
                setSheetState(() => error = l10n.securityPasswordMismatch);
                return;
              }

              setSheetState(() {
                submitting = true;
                error = null;
              });
              final result = await ref.read(authRepositoryProvider).changePassword(
                    currentPassword: currentController.text,
                    newPassword: newController.text,
                  );
              if (!sheetContext.mounted) return;

              switch (result) {
                case Success():
                  Navigator.of(sheetContext).pop(true);
                case ResultFailure(:final failure):
                  setSheetState(() {
                    submitting = false;
                    error = _failureMessage(failure, l10n);
                  });
              }
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.securityChangePasswordTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                AppTextField(controller: currentController, label: l10n.securityCurrentPasswordLabel, obscureText: true),
                const SizedBox(height: AppSpacing.md),
                AppTextField(controller: newController, label: l10n.securityNewPasswordLabel, obscureText: true),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: confirmController,
                  label: l10n.securityConfirmPasswordLabel,
                  obscureText: true,
                  onSubmitted: (_) => submit(),
                ),
                if (error != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(error!, style: TextStyle(color: sheetContext.statusColors.error.foreground)),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(label: l10n.commonSave, isLoading: submitting, onPressed: submit),
              ],
            );
          },
        );
      },
    );

    if (saved == true && mounted) {
      // Changing the password revokes every other session server-side.
      ref.invalidate(activeSessionsControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.securityPasswordUpdatedMessage)));
    }
  }

  Future<void> _endSession(AuthSession session) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await ref.read(activeSessionsControllerProvider.notifier).revoke(session.id);
    if (!mounted) return;
    _showResultSnack(result, l10n, l10n.securitySessionEndedMessage);
  }

  Future<void> _endOtherSessions() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _revokingOthers = true);
    final result = await ref.read(activeSessionsControllerProvider.notifier).revokeOthers();
    if (!mounted) return;
    setState(() => _revokingOthers = false);
    _showResultSnack(result, l10n, l10n.securitySessionEndedMessage);
  }

  void _showResultSnack(Result<void> result, AppLocalizations l10n, String successMessage) {
    final message = result.fold((failure) => _failureMessage(failure, l10n), (_) => successMessage);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _failureMessage(Failure failure, AppLocalizations l10n) {
    return switch (failure) {
      ValidationFailure(:final fieldErrors) when fieldErrors.isNotEmpty => fieldErrors.values.first.first,
      Failure(:final message?) => message,
      NetworkFailure() => l10n.errorNetwork,
      TimeoutFailure() => l10n.errorTimeout,
      _ => l10n.errorGeneric,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sessions = ref.watch(activeSessionsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.securityPrivacyTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(l10n.securityChangePasswordTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: _changePassword,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.verified_user_outlined),
                    title: Text(l10n.securityTwoFactorTitle),
                    subtitle: Text(l10n.securityTwoFactorUnavailable),
                    value: false,
                    onChanged: null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint),
                    title: Text(l10n.securityBiometricTitle),
                    subtitle: Text(l10n.securityBiometricSubtitle),
                    value: _biometricEnabled,
                    onChanged: (value) => setState(() => _biometricEnabled = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: l10n.securityActiveSessionsTitle),
            const SizedBox(height: AppSpacing.sm),
            switch (sessions) {
              AsyncData(:final value) => _SessionList(
                sessions: value,
                revokingOthers: _revokingOthers,
                onEnd: _endSession,
                onEndOthers: _endOtherSessions,
              ),
              AsyncError() => ErrorView(
                message: l10n.securitySessionsError,
                onRetry: () => ref.read(activeSessionsControllerProvider.notifier).refresh(),
              ),
              _ => const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xl), child: LoadingView()),
            },
          ],
        ),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({
    required this.sessions,
    required this.revokingOthers,
    required this.onEnd,
    required this.onEndOthers,
  });

  final List<AuthSession> sessions;
  final bool revokingOthers;
  final void Function(AuthSession) onEnd;
  final VoidCallback onEndOthers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasOthers = sessions.any((session) => !session.isCurrent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final session in sessions) ...[
          AppCard(
            child: Row(
              children: [
                Icon(session.isCurrent ? Icons.smartphone : Icons.devices_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.isCurrent ? l10n.securityThisDevice : (session.deviceLabel ?? l10n.securityUnknownDevice),
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        [
                          if (session.ipAddress != null) session.ipAddress!,
                          formatTimeAgo(session.lastUsedAt ?? session.createdAt, l10n),
                        ].join(' · '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (!session.isCurrent)
                  TextButton(
                    onPressed: () => onEnd(session),
                    child: Text(l10n.securityEndSession, style: TextStyle(color: context.statusColors.error.foreground)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (hasOthers) ...[
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: l10n.securityEndAllOtherSessions,
            variant: AppButtonVariant.destructive,
            isLoading: revokingOthers,
            onPressed: onEndOthers,
          ),
        ],
      ],
    );
  }
}
