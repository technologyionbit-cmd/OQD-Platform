import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/app/routing/placeholder_route.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/widgets/app_shell.dart';
import 'package:aqd_ionbit/features/company/presentation/screens/company_home_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/account_screen.dart';

/// The company's 5-tab shell: Home, Contracts, Lawyers, Documents, Account.
/// No distinct company UI appears in the reference screenshots (companies
/// there show up as a lawyer's *client*, not as their own app experience),
/// so this mirrors the client shell's structure/visual language rather
/// than inventing a new one — only the Contracts tab (in place of client's
/// AI tab) reflects a real product difference from the brief.
StatefulShellRoute companyShellRoute() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      final l10n = AppLocalizations.of(context)!;
      return AppShell(
        navigationShell: navigationShell,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l10n.navHome),
          NavigationDestination(
            icon: const Icon(Icons.description_outlined),
            selectedIcon: const Icon(Icons.description),
            label: l10n.navContracts,
          ),
          NavigationDestination(icon: const Icon(Icons.gavel_outlined), selectedIcon: const Icon(Icons.gavel), label: l10n.navLawyers),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: l10n.navDocuments,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navAccount,
          ),
        ],
      );
    },
    branches: [
      StatefulShellBranch(routes: [GoRoute(path: RoutePaths.companyHome, builder: (context, state) => const CompanyHomeScreen())]),
      StatefulShellBranch(
        routes: [placeholderRoute(path: RoutePaths.companyContracts, title: (l10n) => l10n.navContracts, icon: Icons.description_outlined)],
      ),
      StatefulShellBranch(
        routes: [placeholderRoute(path: RoutePaths.companyLawyers, title: (l10n) => l10n.navLawyers, icon: Icons.gavel_outlined)],
      ),
      StatefulShellBranch(
        routes: [placeholderRoute(path: RoutePaths.companyDocuments, title: (l10n) => l10n.navDocuments, icon: Icons.folder_outlined)],
      ),
      StatefulShellBranch(routes: [GoRoute(path: RoutePaths.companyAccount, builder: (context, state) => const AccountScreen())]),
    ],
  );
}
