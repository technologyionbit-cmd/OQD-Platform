class RoutePaths {
  const RoutePaths._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otpVerification = '/otp-verification';
  static const resetPassword = '/reset-password';

  /// Signed-in only; the router decides when it shows (see app_router).
  static const verifyEmail = '/verify-email';

  // Role shells — each is a StatefulShellRoute branch prefix. Guard logic
  // in app_router.dart checks these prefixes, so keep every new
  // role-scoped route nested under its role's base.
  static const clientBase = '/client';
  static const clientHome = '/client/home';
  static const clientAi = '/client/ai';
  static const clientDocuments = '/client/documents';
  static const clientLawyers = '/client/lawyers';
  static const clientAccount = '/client/account';

  // Pushed full-screen on top of the client shell (no bottom nav while
  // mid-flow) — still nested under clientBase so the role guard covers
  // them automatically.
  static const clientNotifications = '/client/notifications';
  static const clientAccountEdit = '/client/account/edit';
  static const clientContracts = '/client/contracts';
  static const clientContractsAnalyze = '/client/contracts/analyze';
  static const clientContractsNew = '/client/contracts/new';
  static const clientContractsNewForm = '/client/contracts/new/form';
  static const clientContractsNewPreview = '/client/contracts/new/preview';
  static const clientContractDetailsPattern = '/client/contracts/details/:id';
  static String clientContractDetails(String id) => '/client/contracts/details/$id';

  static const clientAiChat = '/client/ai/chat';
  static const clientAiAnalysis = '/client/ai/analysis';
  static const clientAiAnalysisResultPattern = '/client/ai/analysis/:id';
  static String clientAiAnalysisResult(String id) => '/client/ai/analysis/$id';

  static const clientLawyerDetailsPattern = '/client/lawyers/:id';
  static String clientLawyerDetails(String id) => '/client/lawyers/$id';
  static String clientLawyerBooking(String lawyerId) => '/client/lawyers/$lawyerId/book';
  static const clientLawyerBookingPattern = '/client/lawyers/:id/book';
  static const clientLawyerBookingDateTimePattern = '/client/lawyers/:id/book/datetime';
  static const clientLawyerBookingDetailsPattern = '/client/lawyers/:id/book/details';

  static const clientConsultations = '/client/consultations';
  static const clientConsultationDetailsPattern = '/client/consultations/:id';
  static String clientConsultationDetails(String id) => '/client/consultations/$id';
  static const clientChatRoomPattern = '/client/consultations/:id/chat';
  static const clientConsultationRoomPattern = '/client/consultations/:id/room';
  static const clientVoiceCallPattern = '/client/consultations/:id/voice';
  static const clientVideoCallPattern = '/client/consultations/:id/video';

  // Government documents hub — informational/procedural flows (mock only,
  // no real government integration). Mounted under the client base only;
  // add other roles' bases here if/when they need it too.
  static const clientGovDocuments = '/client/gov-documents';
  static const clientGovDocumentDetailsPattern = '/client/gov-documents/:id';
  static String clientGovDocumentDetails(String id) => '/client/gov-documents/$id';

  // Subscriptions & billing — mock plan upgrade flow, no real payment
  // processor. Shared across roles the same way contracts/lawyers are.
  // Payment is an inline step within the plans screen (same pattern as
  // booking's payment step), so there's no separate payment route.
  static String subscriptionPlansFor(String base) => '$base/subscription';

  // Account sub-screens introduced for reference parity — no role-specific
  // logic, so these are pure path-string helpers (unlike contracts/lawyers,
  // the screens behind them never navigate onward to another role-scoped
  // route, so they don't need a `routeBase` constructor param).
  /// The role's own account/profile tab — "حسابي" for client/company,
  /// "ملفي" (a different path segment, `lawyerProfile`) for lawyer.
  static String accountTabFor(String base) => switch (base) {
    lawyerBase => lawyerProfile,
    _ => '$base/account',
  };

  static String paymentMethodsFor(String base) => '$base/account/payment-methods';
  static String savedSignatureFor(String base) => '$base/account/signature';
  static String securityPrivacyFor(String base) => '$base/account/security';
  static String helpSupportFor(String base) => '$base/account/help';
  static String invoicesFor(String base) => '$base/account/invoices';

  static const lawyerBase = '/lawyer';
  static const lawyerDashboard = '/lawyer/dashboard';
  static const lawyerSchedule = '/lawyer/schedule';
  static const lawyerClients = '/lawyer/clients';
  static const lawyerClientDetailsPattern = '/lawyer/clients/:id';
  // The "id" here is a client display name (no real client-id backend
  // exists yet). go_router percent-encodes/decodes path parameters itself,
  // so pass the raw name — encoding it here too caused a double-encode/
  // double-decode mismatch that crashed on non-ASCII (Arabic) names.
  static String lawyerClientDetails(String name) => '/lawyer/clients/$name';
  static const lawyerEarnings = '/lawyer/earnings';
  static const lawyerProfile = '/lawyer/profile';
  static const lawyerAccountEdit = '/lawyer/account/edit';
  static const lawyerProfileEdit = '/lawyer/profile/edit';
  static const lawyerNotifications = '/lawyer/notifications';
  static const lawyerRequests = '/lawyer/requests';
  static const lawyerRequestDetailsPattern = '/lawyer/requests/:id';
  static String lawyerRequestDetails(String id) => '/lawyer/requests/$id';
  static const lawyerConsultations = '/lawyer/consultations';
  static const lawyerConsultationDetailsPattern = '/lawyer/consultations/:id';
  static String lawyerConsultationDetails(String id) => '/lawyer/consultations/$id';
  static const lawyerChatRoomPattern = '/lawyer/consultations/:id/chat';
  static const lawyerConsultationRoomPattern = '/lawyer/consultations/:id/room';
  static const lawyerVoiceCallPattern = '/lawyer/consultations/:id/voice';
  static const lawyerVideoCallPattern = '/lawyer/consultations/:id/video';
  static const lawyerContracts = '/lawyer/contracts';
  static const lawyerContractDetailsPattern = '/lawyer/contracts/details/:id';
  static String lawyerContractDetails(String id) => '/lawyer/contracts/details/$id';
  static const lawyerDocuments = '/lawyer/documents';

  static const companyBase = '/company';
  static const companyHome = '/company/home';
  static const companyContracts = '/company/contracts';
  static const companyLawyers = '/company/lawyers';
  static const companyDocuments = '/company/documents';
  static const companyAccount = '/company/account';
  static const companyAccountEdit = '/company/account/edit';
  static const companyNotifications = '/company/notifications';
  static const companyTeam = '/company/team';
  static const companyTeamMemberDetailsPattern = '/company/team/:id';
  static String companyTeamMemberDetails(String id) => '/company/team/$id';
  static const companyContractsNew = '/company/contracts/new';
  static const companyContractsNewForm = '/company/contracts/new/form';
  static const companyContractsNewPreview = '/company/contracts/new/preview';
  static const companyContractDetailsPattern = '/company/contracts/details/:id';
  static String companyContractDetails(String id) => '/company/contracts/details/$id';
  static const companyConsultations = '/company/consultations';
  static const companyConsultationDetailsPattern = '/company/consultations/:id';
  static String companyConsultationDetails(String id) => '/company/consultations/$id';
  static const companyChatRoomPattern = '/company/consultations/:id/chat';
  static const companyConsultationRoomPattern = '/company/consultations/:id/room';
  static const companyVoiceCallPattern = '/company/consultations/:id/voice';
  static const companyVideoCallPattern = '/company/consultations/:id/video';
  static const companyLawyerDetailsPattern = '/company/lawyers/:id';
  static const companyLawyerBookingPattern = '/company/lawyers/:id/book';
  static const companyLawyerBookingDateTimePattern = '/company/lawyers/:id/book/datetime';
  static const companyLawyerBookingDetailsPattern = '/company/lawyers/:id/book/details';

  // --- Shared-feature helpers -------------------------------------------
  // Contracts, documents, the lawyers marketplace, and consultations are
  // mounted under more than one role's base (client + company for
  // contracts/documents/lawyers; client + lawyer + company for
  // consultations). The screens themselves take a `routeBase` constructor
  // param (default [clientBase], so every existing call site/test is
  // unaffected) and use these pure string-suffix helpers to build their
  // internal navigation targets — this keeps role-awareness out of
  // `core/routing` (still plain, feature-agnostic path strings) while
  // letting one screen implementation serve multiple roles.
  static String contractsRootFor(String base) => '$base/contracts';
  static String contractsNewFor(String base) => '$base/contracts/new';
  static String contractsNewFormFor(String base) => '$base/contracts/new/form';
  static String contractsNewPreviewFor(String base) => '$base/contracts/new/preview';
  static String contractDetailsFor(String base, String id) => '$base/contracts/details/$id';

  static String lawyersRootFor(String base) => '$base/lawyers';
  static String lawyerDetailsFor(String base, String id) => '$base/lawyers/$id';
  static String lawyerBookingFor(String base, String lawyerId) => '$base/lawyers/$lawyerId/book';
  static String lawyerBookingDateTimeFor(String base, String lawyerId) => '$base/lawyers/$lawyerId/book/datetime';
  static String lawyerBookingDetailsFor(String base, String lawyerId) => '$base/lawyers/$lawyerId/book/details';

  static String consultationsRootFor(String base) => '$base/consultations';
  static String consultationDetailsFor(String base, String id) => '$base/consultations/$id';
  static String chatRoomFor(String base, String id) => '$base/consultations/$id/chat';
  static String consultationRoomFor(String base, String id) => '$base/consultations/$id/room';
  static String voiceCallFor(String base, String id) => '$base/consultations/$id/voice';
  static String videoCallFor(String base, String id) => '$base/consultations/$id/video';
}
