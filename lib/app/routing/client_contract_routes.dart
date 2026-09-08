import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/ai/presentation/screens/ai_analysis_select_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_details_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_form_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_preview_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_type_selection_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contracts_list_screen.dart';
import 'package:aqd_ionbit/features/notifications/presentation/screens/notifications_screen.dart';

/// Pushed full-screen on top of the client shell (no bottom nav mid-flow)
/// — separate from `client_routes.dart`'s shell/tabs so that file stays
/// about the 5 tabs and this one is just the contracts sub-flow (plus
/// notifications/analyze, which hang off the same "pushed on top of the
/// shell" pattern).
List<RouteBase> clientContractRoutes() {
  return [
    GoRoute(path: RoutePaths.clientNotifications, builder: (context, state) => const NotificationsScreen()),
    GoRoute(path: RoutePaths.clientContracts, builder: (context, state) => const ContractsListScreen()),
    GoRoute(path: RoutePaths.clientContractsAnalyze, builder: (context, state) => const AiAnalysisSelectScreen()),
    GoRoute(path: RoutePaths.clientContractsNew, builder: (context, state) => const ContractTypeSelectionScreen()),
    GoRoute(path: RoutePaths.clientContractsNewForm, builder: (context, state) => const ContractFormScreen()),
    GoRoute(path: RoutePaths.clientContractsNewPreview, builder: (context, state) => const ContractPreviewScreen()),
    GoRoute(
      path: RoutePaths.clientContractDetailsPattern,
      builder: (context, state) => ContractDetailsScreen(contractId: state.pathParameters['id']!),
    ),
  ];
}
