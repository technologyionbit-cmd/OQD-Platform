import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/home_greeting_header.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';

/// The company's landing tab. Phase 5 is navigation-only — the real
/// dashboard (company-wide contracts, team activity) is company feature
/// work for a later phase.
class CompanyHomeScreen extends ConsumerWidget {
  const CompanyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      body: Column(
        children: [
          HomeGreetingHeader(greeting: user != null ? l10n.homeWelcome(user.fullName) : l10n.navHome, icon: Icons.apartment_outlined),
          Expanded(child: EmptyState(icon: Icons.dashboard_customize_outlined, message: l10n.placeholderComingSoonMessage)),
        ],
      ),
    );
  }
}
