import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/routing/routes/account_extra_routes.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/ai/presentation/screens/ai_analysis_result_screen.dart';
import 'package:aqd_ionbit/features/ai/presentation/screens/ai_chat_screen.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/booking_datetime_screen.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/booking_details_screen.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/booking_type_screen.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/screens/consultation_waiting_screen.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/consultation_details_screen.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/consultations_list_screen.dart';
import 'package:aqd_ionbit/features/gov_documents/presentation/screens/gov_documents_hub_screen.dart';
import 'package:aqd_ionbit/features/gov_documents/presentation/screens/gov_procedure_detail_screen.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/screens/lawyer_details_screen.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/screens/voice_call_screen.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/screens/video_call_screen.dart';
import 'package:aqd_ionbit/features/messages/presentation/screens/chat_room_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/edit_profile_screen.dart';

/// Client-role routes pushed on top of the shell that don't belong to the
/// contracts sub-flow (`client_contract_routes.dart`): AI chat/analysis
/// result, the lawyer-details → booking flow, consultations, and account
/// editing.
List<RouteBase> clientExtraRoutes() {
  return [
    GoRoute(path: RoutePaths.clientAccountEdit, builder: (context, state) => const EditProfileScreen()),
    GoRoute(
      path: RoutePaths.clientAiChat,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AiChatScreen(
          initialConversationId: extra?['conversationId'] as String?,
          initialMessage: extra?['initialMessage'] as String?,
        );
      },
    ),
    GoRoute(
      path: RoutePaths.clientAiAnalysisResultPattern,
      builder: (context, state) => AiAnalysisResultScreen(analysisId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RoutePaths.clientLawyerDetailsPattern,
      builder: (context, state) => LawyerDetailsScreen(lawyerId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RoutePaths.clientLawyerBookingPattern,
      builder: (context, state) => BookingTypeScreen(lawyerId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RoutePaths.clientLawyerBookingDateTimePattern,
      builder: (context, state) => BookingDateTimeScreen(lawyerId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RoutePaths.clientLawyerBookingDetailsPattern,
      builder: (context, state) => BookingDetailsScreen(lawyerId: state.pathParameters['id']!),
    ),
    GoRoute(path: RoutePaths.clientConsultations, builder: (context, state) => const ConsultationsListScreen()),
    GoRoute(
      path: RoutePaths.clientConsultationDetailsPattern,
      builder: (context, state) => ConsultationDetailsScreen(consultationId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RoutePaths.clientConsultationRoomPattern,
      builder: (context, state) => ConsultationWaitingScreen(consultationId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RoutePaths.clientChatRoomPattern,
      builder: (context, state) => ChatRoomScreen(consultationId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RoutePaths.clientVoiceCallPattern,
      builder: (context, state) => VoiceCallScreen(consultationId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RoutePaths.clientVideoCallPattern,
      builder: (context, state) => VideoCallScreen(consultationId: state.pathParameters['id']!),
    ),
    ...accountExtraRoutesFor(RoutePaths.clientBase),
    GoRoute(path: RoutePaths.clientGovDocuments, builder: (context, state) => const GovDocumentsHubScreen()),
    GoRoute(
      path: RoutePaths.clientGovDocumentDetailsPattern,
      builder: (context, state) => GovProcedureDetailScreen(procedureTypeName: state.pathParameters['id']!),
    ),
  ];
}
