import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/widgets/app_shell.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/email_verification_banner.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/lawyer_schedule_screen.dart';
import 'package:aqd_ionbit/features/lawyer_dashboard/presentation/screens/lawyer_clients_screen.dart';
import 'package:aqd_ionbit/features/lawyer_dashboard/presentation/screens/lawyer_dashboard_screen.dart';
import 'package:aqd_ionbit/features/lawyer_dashboard/presentation/screens/lawyer_earnings_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/account_screen.dart';

/// The lawyer's 5-tab shell: Dashboard, Schedule, Clients, Earnings,
/// Profile — a genuinely different destination set from the client shell
/// (per the screenshots), reusing the same [AppShell] chrome.
StatefulShellRoute lawyerShellRoute() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      final l10n = AppLocalizations.of(context)!;
      return AppShell(
        navigationShell: navigationShell,
        banner: const EmailVerificationBanner(),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.space_dashboard_outlined),
            selectedIcon: const Icon(Icons.space_dashboard),
            label: l10n.navLawyerDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: l10n.navSchedule,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l10n.navClients,
          ),
          NavigationDestination(
            icon: const Icon(Icons.payments_outlined),
            selectedIcon: const Icon(Icons.payments),
            label: l10n.navEarnings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navMyProfile,
          ),
        ],
      );
    },
    branches: [
      StatefulShellBranch(
        routes: [GoRoute(path: RoutePaths.lawyerDashboard, builder: (context, state) => const LawyerDashboardScreen())],
      ),
      StatefulShellBranch(
        routes: [GoRoute(path: RoutePaths.lawyerSchedule, builder: (context, state) => const LawyerScheduleScreen())],
      ),
      StatefulShellBranch(
        routes: [GoRoute(path: RoutePaths.lawyerClients, builder: (context, state) => const LawyerClientsScreen())],
      ),
      StatefulShellBranch(
        routes: [GoRoute(path: RoutePaths.lawyerEarnings, builder: (context, state) => const LawyerEarningsScreen())],
      ),
      StatefulShellBranch(routes: [GoRoute(path: RoutePaths.lawyerProfile, builder: (context, state) => const AccountScreen())]),
    ],
  );
}
