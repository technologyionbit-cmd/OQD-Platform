import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/home_greeting_header.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';

/// The lawyer's landing tab. Phase 5 is navigation-only — the real
/// dashboard (today's earnings/clients/consultations stats, pending
/// bookings, schedule) is lawyer feature work for a later phase.
class LawyerDashboardScreen extends ConsumerWidget {
  const LawyerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      body: Column(
        children: [
          HomeGreetingHeader(
            greeting: user != null ? l10n.homeWelcome(user.fullName) : l10n.navLawyerDashboard,
            icon: Icons.gavel_outlined,
          ),
          Expanded(child: EmptyState(icon: Icons.space_dashboard_outlined, message: l10n.placeholderComingSoonMessage)),
        ],
      ),
    );
  }
}
