import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/config/feature_flags.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/widgets/app_shell.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/phone_verification_banner.dart';
import 'package:aqd_ionbit/features/ai/presentation/screens/ai_chat_screen.dart';
import 'package:aqd_ionbit/features/documents/presentation/screens/documents_screen.dart';
import 'package:aqd_ionbit/features/home/presentation/screens/client_home_screen.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/screens/lawyers_list_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/account_screen.dart';

/// The client's shell: Home, AI, Documents, Lawyers, Account — order
/// matches the reference screenshots (built in logical 1..N order; RTL
/// mirroring of the bottom bar is Flutter's job, not this file's). The AI
/// and Documents tabs run on made-up data, so they only exist while
/// [showPreviewTabs] is on (see [FeatureFlags]).
StatefulShellRoute clientShellRoute({bool showPreviewTabs = FeatureFlags.previewFeatures}) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      final l10n = AppLocalizations.of(context)!;
      // Guests may browse Home and Lawyers; every other tab asks them to
      // sign in first.
      final lawyersIndex = showPreviewTabs ? 3 : 1;
      return Consumer(
        builder:
            (context, ref, _) => AppShell(
              navigationShell: navigationShell,
              banner: const PhoneVerificationBanner(),
              canSelect: (index) {
                if (ref.read(authControllerProvider).value != null || index == 0 || index == lawyersIndex) return true;
                context.push(RoutePaths.loginRequired);
                return false;
              },
              destinations: [
                NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l10n.navHome),
                if (showPreviewTabs) ...[
                  NavigationDestination(icon: const Icon(Icons.smart_toy_outlined), selectedIcon: const Icon(Icons.smart_toy), label: l10n.navAi),
                  NavigationDestination(icon: const Icon(Icons.folder_outlined), selectedIcon: const Icon(Icons.folder), label: l10n.navDocuments),
                ],
                NavigationDestination(icon: const Icon(Icons.gavel_outlined), selectedIcon: const Icon(Icons.gavel), label: l10n.navLawyers),
                NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: l10n.navAccount),
              ],
            ),
      );
    },
    branches: [
      StatefulShellBranch(routes: [GoRoute(path: RoutePaths.clientHome, builder: (context, state) => const ClientHomeScreen())]),
      if (showPreviewTabs) ...[
        StatefulShellBranch(routes: [GoRoute(path: RoutePaths.clientAi, builder: (context, state) => const AiChatScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: RoutePaths.clientDocuments, builder: (context, state) => const DocumentsScreen())]),
      ],
      StatefulShellBranch(routes: [GoRoute(path: RoutePaths.clientLawyers, builder: (context, state) => const LawyersListScreen())]),
      StatefulShellBranch(routes: [GoRoute(path: RoutePaths.clientAccount, builder: (context, state) => const AccountScreen())]),
    ],
  );
}
