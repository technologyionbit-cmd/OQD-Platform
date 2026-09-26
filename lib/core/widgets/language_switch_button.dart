import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/localization/locale_controller.dart';

/// Compact "English" / "العربية" switch for screens reachable before
/// sign-in (onboarding, login) — the only way for someone who doesn't read
/// the current language to change it. Shows the language it switches *to*,
/// written in that language, as is conventional.
class LanguageSwitchButton extends ConsumerWidget {
  const LanguageSwitchButton({super.key, this.foregroundColor});

  /// Defaults to the theme's; pass a light color on dark headers.
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeControllerProvider).languageCode == 'ar';

    return Semantics(
      button: true,
      label: AppLocalizations.of(context)!.commonChangeLanguage,
      excludeSemantics: true,
      child: TextButton.icon(
        onPressed: () => ref.read(localeControllerProvider.notifier).toggle(),
        style: TextButton.styleFrom(foregroundColor: foregroundColor),
        icon: const Icon(Icons.language_rounded, size: 18),
        label: Text(isArabic ? 'English' : 'العربية'),
      ),
    );
  }
}
