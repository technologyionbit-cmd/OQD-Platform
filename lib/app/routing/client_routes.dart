import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/app/routing/placeholder_route.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/widgets/app_shell.dart';
import 'package:aqd_ionbit/features/documents/presentation/screens/documents_screen.dart';
import 'package:aqd_ionbit/features/home/presentation/screens/client_home_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/account_screen.dart';

/// The client's 5-tab shell: Home, AI, Documents, Lawyers, Account — order
/// matches the reference screenshots (built in logical 1..N order; RTL
/// mirroring of the bottom bar is Flutter's job, not this file's).
StatefulShellRoute clientShellRoute() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      final l10n = AppLocalizations.of(context)!;
      return AppShell(
        navigationShell: navigationShell,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l10n.navHome),
          NavigationDestination(icon: const Icon(Icons.smart_toy_outlined), selectedIcon: const Icon(Icons.smart_toy), label: l10n.navAi),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: l10n.navDocuments,
          ),
          NavigationDestination(icon: const Icon(Icons.gavel_outlined), selectedIcon: const Icon(Icons.gavel), label: l10n.navLawyers),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navAccount,
          ),
        ],
      );
    },
    branches: [
      StatefulShellBranch(routes: [GoRoute(path: RoutePaths.clientHome, builder: (context, state) => const ClientHomeScreen())]),
      StatefulShellBranch(
        routes: [placeholderRoute(path: RoutePaths.clientAi, title: (l10n) => l10n.navAi, icon: Icons.smart_toy_outlined)],
      ),
      StatefulShellBranch(
        routes: [GoRoute(path: RoutePaths.clientDocuments, builder: (context, state) => const DocumentsScreen())],
      ),
      StatefulShellBranch(
        routes: [placeholderRoute(path: RoutePaths.clientLawyers, title: (l10n) => l10n.navLawyers, icon: Icons.gavel_outlined)],
      ),
      StatefulShellBranch(routes: [GoRoute(path: RoutePaths.clientAccount, builder: (context, state) => const AccountScreen())]),
    ],
  );
}
