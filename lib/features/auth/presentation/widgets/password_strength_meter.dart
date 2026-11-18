import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';

enum PasswordStrength { weak, good, strong }

/// Feedback only — the server's rules (see `newPasswordError`) stay the gate.
/// Weak = breaks a required rule, good = meets them, strong = meets them with
/// extra length or variety.
PasswordStrength passwordStrengthOf(String password) {
  final meetsRules =
      Validators.isPasswordLongEnough(password) &&
      Validators.isPasswordWithinByteLimit(password) &&
      Validators.hasLetterAndDigit(password);
  if (!meetsRules) return PasswordStrength.weak;
  final mixedCase =
      RegExp('[a-z]').hasMatch(password) && RegExp('[A-Z]').hasMatch(password);
  final hasSymbol = RegExp(r'[^A-Za-z0-9\s]').hasMatch(password);
  final long = password.length >= 12;
  final extras = [long, mixedCase, hasSymbol].where((e) => e).length;
  return extras >= 2 ? PasswordStrength.strong : PasswordStrength.good;
}

/// Three segments and a word that fill as the user types. Renders nothing
/// while the field is empty, so it never competes with the rules hint.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final text = controller.text;
        if (text.isEmpty) return const SizedBox.shrink();

        final l10n = AppLocalizations.of(context)!;
        final strength = passwordStrengthOf(text);
        final (label, color, filled) = switch (strength) {
          PasswordStrength.weak => (
            l10n.authPasswordStrengthWeak,
            AppColors.error,
            1,
          ),
          PasswordStrength.good => (
            l10n.authPasswordStrengthGood,
            AppColors.secondary,
            2,
          ),
          PasswordStrength.strong => (
            l10n.authPasswordStrengthStrong,
            AppColors.success,
            3,
          ),
        };
        final track = Theme.of(context).colorScheme.surfaceContainerHighest;

        return Semantics(
          liveRegion: true,
          label: label,
          excludeSemantics: true,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      height: 4,
                      decoration: BoxDecoration(
                        color: i < filled ? color : track,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (i < 2) const SizedBox(width: AppSpacing.xxs),
                ],
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: color),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
