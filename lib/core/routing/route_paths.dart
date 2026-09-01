class RoutePaths {
  const RoutePaths._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otpVerification = '/otp-verification';
  static const resetPassword = '/reset-password';

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
  static const clientContracts = '/client/contracts';
  static const clientContractsAnalyze = '/client/contracts/analyze';
  static const clientContractsNew = '/client/contracts/new';
  static const clientContractsNewForm = '/client/contracts/new/form';
  static const clientContractsNewPreview = '/client/contracts/new/preview';
  static const clientContractDetailsPattern = '/client/contracts/details/:id';
  static String clientContractDetails(String id) => '/client/contracts/details/$id';

  static const lawyerBase = '/lawyer';
  static const lawyerDashboard = '/lawyer/dashboard';
  static const lawyerSchedule = '/lawyer/schedule';
  static const lawyerClients = '/lawyer/clients';
  static const lawyerEarnings = '/lawyer/earnings';
  static const lawyerProfile = '/lawyer/profile';

  static const companyBase = '/company';
  static const companyHome = '/company/home';
  static const companyContracts = '/company/contracts';
  static const companyLawyers = '/company/lawyers';
  static const companyDocuments = '/company/documents';
  static const companyAccount = '/company/account';
}
