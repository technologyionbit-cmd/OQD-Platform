import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/app/routing/placeholder_route.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_details_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_form_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_preview_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_type_selection_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contracts_list_screen.dart';

/// Pushed full-screen on top of the client shell (no bottom nav mid-flow)
/// — separate from `client_routes.dart`'s shell/tabs so that file stays
/// about the 5 tabs and this one is just the contracts sub-flow. Screens
/// are swapped in incrementally as each is built; until then they're a
/// real, isolated placeholder rather than a dead link.
List<RouteBase> clientContractRoutes() {
  return [
    placeholderRoute(
      path: RoutePaths.clientNotifications,
      title: (l10n) => l10n.clientNotificationsTitle,
      icon: Icons.notifications_outlined,
    ),
    GoRoute(path: RoutePaths.clientContracts, builder: (context, state) => const ContractsListScreen()),
    placeholderRoute(
      path: RoutePaths.clientContractsAnalyze,
      title: (l10n) => l10n.serviceAnalyzeContract,
      icon: Icons.search_outlined,
    ),
    GoRoute(path: RoutePaths.clientContractsNew, builder: (context, state) => const ContractTypeSelectionScreen()),
    GoRoute(path: RoutePaths.clientContractsNewForm, builder: (context, state) => const ContractFormScreen()),
    GoRoute(path: RoutePaths.clientContractsNewPreview, builder: (context, state) => const ContractPreviewScreen()),
    GoRoute(
      path: RoutePaths.clientContractDetailsPattern,
      builder: (context, state) => ContractDetailsScreen(contractId: state.pathParameters['id']!),
    ),
  ];
}
