import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_bottom_sheet.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/core/widgets/section_header.dart';

class _MockSession {
  _MockSession({required this.device, required this.isCurrent});
  final String device;
  bool isCurrent;
}

/// Account → Security & Privacy — fully mock (password change, 2FA and
/// biometric toggles, active-session list) since there's no real auth
/// backend to enforce any of this against; every control still updates
/// visible UI state rather than being a decorative dead button.
class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = false;
  final List<_MockSession> _sessions = [
    _MockSession(device: 'iPhone 15 Pro — Amman', isCurrent: true),
    _MockSession(device: 'Chrome — Windows', isCurrent: false),
  ];

  Future<void> _changePassword() async {
    final l10n = AppLocalizations.of(context)!;
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? error;

    final saved = await showAppBottomSheet<bool>(
      context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
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
                AppTextField(controller: confirmController, label: l10n.securityConfirmPasswordLabel, obscureText: true),
                if (error != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(error!, style: TextStyle(color: sheetContext.statusColors.error.foreground)),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: l10n.commonSave,
                  onPressed: () {
                    if (!Validators.isRequired(currentController.text) ||
                        !Validators.isRequired(newController.text) ||
                        !Validators.isPasswordLongEnough(newController.text)) {
                      setSheetState(() => error = l10n.validationRequired);
                      return;
                    }
                    if (newController.text != confirmController.text) {
                      setSheetState(() => error = l10n.securityPasswordMismatch);
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
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.securityPasswordUpdatedMessage)));
    }
  }

  void _endSession(_MockSession session) {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _sessions.remove(session));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.securitySessionEndedMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                    subtitle: Text(l10n.securityTwoFactorSubtitle),
                    value: _twoFactorEnabled,
                    onChanged: (value) => setState(() => _twoFactorEnabled = value),
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
            for (final session in _sessions) ...[
              AppCard(
                child: Row(
                  children: [
                    Icon(session.isCurrent ? Icons.smartphone : Icons.laptop_mac_outlined, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.device, style: Theme.of(context).textTheme.titleSmall),
                          Text(l10n.securitySessionLocationJordan, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    if (!session.isCurrent)
                      TextButton(
                        onPressed: () => _endSession(session),
                        child: Text(l10n.securityEndSession, style: TextStyle(color: context.statusColors.error.foreground)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}
