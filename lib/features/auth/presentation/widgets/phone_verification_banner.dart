import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/phone_verification_prompt.dart';

/// Strip under every role's screens while the signed-in user's phone is
/// unverified: says what is locked and opens the code screen. Renders
/// nothing once the phone is verified.
class PhoneVerificationBanner extends ConsumerWidget {
  const PhoneVerificationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    if (user == null || user.phoneVerified) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final colors = context.statusColors.warning;

    return Material(
      color: colors.background,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
        child: Row(
          children: [
            Icon(Icons.sms_outlined, size: 20, color: colors.foreground),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l10n.phoneVerificationBannerMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.foreground),
              ),
            ),
            TextButton(
              // The router sees the prompt and opens the code screen.
              onPressed: () => ref.read(phoneVerificationPromptProvider.notifier).show(),
              child: Text(l10n.phoneVerificationBannerAction),
            ),
          ],
        ),
      ),
    );
  }
}
