import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/localization/locale_controller.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/core/widgets/info_card.dart';
import 'package:aqd_admin/core/widgets/page_header.dart';
import 'package:aqd_admin/features/auth/presentation/providers/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authControllerProvider).value;
    final locale = ref.watch(localeProvider);
    final config = ref.watch(appConfigProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(title: l10n.navSettings),
        Expanded(
          child: SingleChildScrollView(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InfoCard(
                      title: l10n.settingsAccount,
                      children: [
                        InfoRow(label: l10n.colName, text: user?.fullName),
                        InfoRow(label: l10n.colEmail, text: user?.email),
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: OutlinedButton.icon(onPressed: () => ref.read(authControllerProvider.notifier).logout(), icon: const Icon(Icons.logout, size: 18), label: Text(l10n.signOut)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InfoCard(
                      title: l10n.settingsPreferences,
                      children: [
                        InfoRow(
                          label: l10n.language,
                          child: SegmentedButton<String>(
                            showSelectedIcon: false,
                            segments: [
                              ButtonSegment(value: 'ar', label: Text(l10n.settingsLanguageArabic)),
                              ButtonSegment(value: 'en', label: Text(l10n.switchToEnglish)),
                            ],
                            selected: {locale.languageCode},
                            onSelectionChanged: (s) => ref.read(localeProvider.notifier).setLocale(Locale(s.first)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InfoCard(title: l10n.settingsSystem, children: [InfoRow(label: l10n.settingsApi, text: config.apiBaseUrl)]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
