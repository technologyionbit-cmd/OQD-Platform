import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/routing/routes/account_extra_routes.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/screens/consultation_waiting_screen.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/screens/voice_call_screen.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/screens/video_call_screen.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/consultation_details_screen.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/consultations_list_screen.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/lawyer_requests_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_details_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contracts_list_screen.dart';
import 'package:aqd_ionbit/features/documents/presentation/screens/documents_screen.dart';
import 'package:aqd_ionbit/features/lawyer_dashboard/presentation/screens/lawyer_client_details_screen.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/screens/lawyer_profile_edit_screen.dart';
import 'package:aqd_ionbit/features/messages/presentation/screens/chat_room_screen.dart';
import 'package:aqd_ionbit/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/edit_profile_screen.dart';

/// Lawyer-role routes pushed on top of the shell: notifications, requests,
/// consultations, a client's detail view, her own professional-profile
/// edit screen, and read access to the shared contracts/documents
/// features (a lawyer can see a client's paperwork, never create/delete
/// it — those actions live only in the client/company FAB flows, so
/// nothing extra needs gating here beyond just not offering them).
List<RouteBase> lawyerExtraRoutes() {
  return [
    GoRoute(path: RoutePaths.lawyerNotifications, builder: (context, state) => const NotificationsScreen()),
    GoRoute(path: RoutePaths.lawyerRequests, builder: (context, state) => const LawyerRequestsScreen()),
    GoRoute(
      path: RoutePaths.lawyerConsultations,
      builder: (context, state) => const ConsultationsListScreen(
        routeBase: RoutePaths.lawyerBase,
        showLawyerName: false,
        includePendingTab: false,
        lawyerId: kDemoLawyerId,
      ),
    ),
    GoRoute(
      path: RoutePaths.lawyerConsultationDetailsPattern,
      builder: (context, state) => ConsultationDetailsScreen(consultationId: state.pathParameters['id']!, routeBase: RoutePaths.lawyerBase),
    ),
    GoRoute(
      path: RoutePaths.lawyerConsultationRoomPattern,
      builder: (context, state) => ConsultationWaitingScreen(consultationId: state.pathParameters['id']!, routeBase: RoutePaths.lawyerBase),
    ),
    GoRoute(
      path: RoutePaths.lawyerChatRoomPattern,
      builder: (context, state) => ChatRoomScreen(consultationId: state.pathParameters['id']!, routeBase: RoutePaths.lawyerBase),
    ),
    GoRoute(
      path: RoutePaths.lawyerVoiceCallPattern,
      builder: (context, state) => VoiceCallScreen(consultationId: state.pathParameters['id']!, routeBase: RoutePaths.lawyerBase),
    ),
    GoRoute(
      path: RoutePaths.lawyerVideoCallPattern,
      builder: (context, state) => VideoCallScreen(consultationId: state.pathParameters['id']!, routeBase: RoutePaths.lawyerBase),
    ),
    GoRoute(
      path: RoutePaths.lawyerClientDetailsPattern,
      builder: (context, state) => LawyerClientDetailsScreen(clientName: state.pathParameters['id']!),
    ),
    GoRoute(path: RoutePaths.lawyerAccountEdit, builder: (context, state) => const EditProfileScreen()),
    GoRoute(path: RoutePaths.lawyerProfileEdit, builder: (context, state) => const LawyerProfileEditScreen()),
    GoRoute(path: RoutePaths.lawyerContracts, builder: (context, state) => const ContractsListScreen(routeBase: RoutePaths.lawyerBase)),
    GoRoute(
      path: RoutePaths.lawyerContractDetailsPattern,
      builder: (context, state) => ContractDetailsScreen(contractId: state.pathParameters['id']!, routeBase: RoutePaths.lawyerBase),
    ),
    GoRoute(path: RoutePaths.lawyerDocuments, builder: (context, state) => const DocumentsScreen(routeBase: RoutePaths.lawyerBase)),
    ...accountExtraRoutesFor(RoutePaths.lawyerBase),
  ];
}
