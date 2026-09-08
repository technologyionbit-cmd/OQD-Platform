import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/app/routing/account_extra_routes.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/screens/consultation_waiting_screen.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/screens/voice_call_screen.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/screens/video_call_screen.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/booking_datetime_screen.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/booking_details_screen.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/booking_type_screen.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/consultation_details_screen.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/consultations_list_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_details_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_form_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_preview_screen.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_type_selection_screen.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/screens/lawyer_details_screen.dart';
import 'package:aqd_ionbit/features/messages/presentation/screens/chat_room_screen.dart';
import 'package:aqd_ionbit/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:aqd_ionbit/features/team/presentation/screens/team_list_screen.dart';
import 'package:aqd_ionbit/features/team/presentation/screens/team_member_details_screen.dart';

/// Company-role routes pushed on top of the shell: the contracts
/// create/edit sub-flow (the list itself is a tab, see `company_routes.dart`),
/// the lawyer-details → booking flow, consultations, team management,
/// notifications, and account editing.
List<RouteBase> companyExtraRoutes() {
  return [
    GoRoute(path: RoutePaths.companyAccountEdit, builder: (context, state) => const EditProfileScreen()),
    GoRoute(path: RoutePaths.companyNotifications, builder: (context, state) => const NotificationsScreen()),
    GoRoute(
      path: RoutePaths.companyContractsNew,
      builder: (context, state) => const ContractTypeSelectionScreen(routeBase: RoutePaths.companyBase),
    ),
    GoRoute(
      path: RoutePaths.companyContractsNewForm,
      builder: (context, state) => const ContractFormScreen(routeBase: RoutePaths.companyBase),
    ),
    GoRoute(
      path: RoutePaths.companyContractsNewPreview,
      builder: (context, state) => const ContractPreviewScreen(routeBase: RoutePaths.companyBase),
    ),
    GoRoute(
      path: RoutePaths.companyContractDetailsPattern,
      builder: (context, state) => ContractDetailsScreen(contractId: state.pathParameters['id']!, routeBase: RoutePaths.companyBase),
    ),
    GoRoute(
      path: RoutePaths.companyLawyerDetailsPattern,
      builder: (context, state) => LawyerDetailsScreen(lawyerId: state.pathParameters['id']!, routeBase: RoutePaths.companyBase),
    ),
    GoRoute(
      path: RoutePaths.companyLawyerBookingPattern,
      builder: (context, state) => BookingTypeScreen(lawyerId: state.pathParameters['id']!, routeBase: RoutePaths.companyBase),
    ),
    GoRoute(
      path: RoutePaths.companyLawyerBookingDateTimePattern,
      builder: (context, state) => BookingDateTimeScreen(lawyerId: state.pathParameters['id']!, routeBase: RoutePaths.companyBase),
    ),
    GoRoute(
      path: RoutePaths.companyLawyerBookingDetailsPattern,
      builder: (context, state) => BookingDetailsScreen(lawyerId: state.pathParameters['id']!, routeBase: RoutePaths.companyBase),
    ),
    GoRoute(
      path: RoutePaths.companyConsultations,
      builder: (context, state) => const ConsultationsListScreen(routeBase: RoutePaths.companyBase),
    ),
    GoRoute(
      path: RoutePaths.companyConsultationDetailsPattern,
      builder: (context, state) => ConsultationDetailsScreen(consultationId: state.pathParameters['id']!, routeBase: RoutePaths.companyBase),
    ),
    GoRoute(
      path: RoutePaths.companyConsultationRoomPattern,
      builder: (context, state) => ConsultationWaitingScreen(consultationId: state.pathParameters['id']!, routeBase: RoutePaths.companyBase),
    ),
    GoRoute(
      path: RoutePaths.companyChatRoomPattern,
      builder: (context, state) => ChatRoomScreen(consultationId: state.pathParameters['id']!, routeBase: RoutePaths.companyBase),
    ),
    GoRoute(
      path: RoutePaths.companyVoiceCallPattern,
      builder: (context, state) => VoiceCallScreen(consultationId: state.pathParameters['id']!, routeBase: RoutePaths.companyBase),
    ),
    GoRoute(
      path: RoutePaths.companyVideoCallPattern,
      builder: (context, state) => VideoCallScreen(consultationId: state.pathParameters['id']!, routeBase: RoutePaths.companyBase),
    ),
    GoRoute(path: RoutePaths.companyTeam, builder: (context, state) => const TeamListScreen()),
    GoRoute(
      path: RoutePaths.companyTeamMemberDetailsPattern,
      builder: (context, state) => TeamMemberDetailsScreen(memberId: state.pathParameters['id']!),
    ),
    ...accountExtraRoutesFor(RoutePaths.companyBase),
  ];
}
