import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/widgets/app_shell.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/phone_verification_banner.dart';
import 'package:aqd_ionbit/features/company/presentation/screens/company_home_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contracts_list_screen.dart';
import 'package:aqd_ionbit/features/documents/presentation/screens/documents_screen.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/screens/lawyers_list_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/account_screen.dart';

/// The company's 5-tab shell: Home, Contracts, Lawyers, Documents, Account.
/// Contracts/Lawyers/Documents mount the exact same screens the client
/// uses (via each screen's `routeBase` param) — a company is, in this
/// mock backend, just another account that creates contracts and books
/// lawyers, so duplicating those features per role would only create two
/// versions to keep in sync for no real behavioral difference.
StatefulShellRoute companyShellRoute() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      final l10n = AppLocalizations.of(context)!;
      return AppShell(
        navigationShell: navigationShell,
        banner: const PhoneVerificationBanner(),
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
        routes: [
          GoRoute(path: RoutePaths.companyContracts, builder: (context, state) => const ContractsListScreen(routeBase: RoutePaths.companyBase)),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(path: RoutePaths.companyLawyers, builder: (context, state) => const LawyersListScreen(routeBase: RoutePaths.companyBase)),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(path: RoutePaths.companyDocuments, builder: (context, state) => const DocumentsScreen(routeBase: RoutePaths.companyBase)),
        ],
      ),
      StatefulShellBranch(routes: [GoRoute(path: RoutePaths.companyAccount, builder: (context, state) => const AccountScreen())]),
    ],
  );
}
