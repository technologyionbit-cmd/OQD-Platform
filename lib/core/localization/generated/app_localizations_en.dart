// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Aqd';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLogout => 'Logout';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonNext => 'Next';

  @override
  String get commonViewAll => 'View All';

  @override
  String get commonSave => 'Save';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonDownload => 'Download';

  @override
  String get commonShare => 'Share';

  @override
  String get commonCopy => 'Copy';

  @override
  String get contractContentCopiedMessage => 'Contract content copied';

  @override
  String get commonOptional => '(optional)';

  @override
  String get authLoginTitle => 'Login';

  @override
  String get authLoginSubtitle => 'Welcome back! Sign in to continue';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailOrPhoneLabel => 'Email or phone number';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPhoneLabel => 'Phone number';

  @override
  String get authLoginSubmit => 'Sign In';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authCreateAccount => 'Create a new account';

  @override
  String get authAlreadyHaveAccount => 'Already have an account?';

  @override
  String get authRegisterTitle => 'Create Account';

  @override
  String get authRegisterSubtitle => 'Join us and start your legal journey';

  @override
  String get authRegisterSubmit => 'Create Account';

  @override
  String get authAccountTypeIndividual => 'Individual';

  @override
  String get authAccountTypeCompany => 'Company';

  @override
  String get authAccountTypeLawyer => 'Lawyer';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authFullNameTriple => 'Full Name';

  @override
  String get authCompanyName => 'Company / Entity Name';

  @override
  String get authCommercialRegistrationNumber => 'Commercial Registration Number';

  @override
  String get authBarLicenseNumber => 'Bar License / Registration Number';

  @override
  String get authMainSpecialty => 'Main Specialty';

  @override
  String get authMainSpecialtyHint => 'e.g. Commercial law, Personal status';

  @override
  String get authTermsAgreementPrefix => 'By registering you agree to the ';

  @override
  String get authTermsOfService => 'Terms of Service';

  @override
  String get authTermsAgreementJoiner => ' and ';

  @override
  String get authPrivacyPolicy => 'Privacy Policy';

  @override
  String get authForgotPasswordTitle => 'Forgot Password?';

  @override
  String get authForgotPasswordSubtitle => 'Choose a recovery method to continue';

  @override
  String get authMethodSms => 'SMS';

  @override
  String get authMethodEmail => 'Email';

  @override
  String get authSmsInfo => 'We\'ll send a 6-digit verification code to reset your password';

  @override
  String get authEmailInfo => 'We\'ll send a verification link to reset your password';

  @override
  String get authSendCode => 'Send Verification Code';

  @override
  String get authContactSupport => 'Contact Support';

  @override
  String get authRememberPassword => 'Remember your password?';

  @override
  String get authSentTitle => 'Sent!';

  @override
  String get authSentSubtitleSms => 'Check your messages and follow the instructions to reset your password';

  @override
  String get authSentSubtitleEmail => 'Check your email and follow the instructions to reset your password';

  @override
  String get authEnterCode => 'Enter Verification Code';

  @override
  String get authResend => 'Resend';

  @override
  String get authOtpTitle => 'Enter Verification Code';

  @override
  String authOtpSubtitle(String destination) {
    return 'We sent a 6-digit code to $destination';
  }

  @override
  String get authOtpConfirm => 'Confirm';

  @override
  String authOtpResendIn(String seconds) {
    return 'Resend in $seconds';
  }

  @override
  String get authOtpInvalidCode => 'Invalid verification code';

  @override
  String get authResetPasswordTitle => 'New Password';

  @override
  String get authResetPasswordSubtitle => 'Create a strong password for your account';

  @override
  String get authNewPassword => 'New Password';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authResetPasswordSubmit => 'Save Password';

  @override
  String get authResetPasswordSuccessTitle => 'Password Changed!';

  @override
  String get authResetPasswordSuccessSubtitle => 'You can now sign in with your new password';

  @override
  String get authGoToLogin => 'Go to Login';

  @override
  String get validationPasswordMismatch => 'Passwords do not match';

  @override
  String get onboardingSlide1Title => 'Your legal assistant in your pocket';

  @override
  String get onboardingSlide1Subtitle => 'AI-powered preliminary consultations and instant explanations of legal terms, around the clock';

  @override
  String get onboardingSlide2Title => 'Smart contracts in minutes';

  @override
  String get onboardingSlide2Subtitle => 'Generate trusted legal contracts and analyze your existing ones with AI';

  @override
  String get onboardingSlide3Title => 'Connect directly with verified lawyers';

  @override
  String get onboardingSlide3Subtitle => 'Book a video, voice, or written consultation with top licensed lawyers';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get devCredentialsTitle => 'Demo credentials (development only)';

  @override
  String devCredentialsPassword(String password) {
    return 'Password for all accounts: $password';
  }

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorNetwork => 'Could not connect, check your internet connection';

  @override
  String get errorUnauthorized => 'Your session has expired, please sign in again';

  @override
  String get errorInvalidCredentials => 'Invalid email or password';

  @override
  String get errorServer => 'A server error occurred, please try again later';

  @override
  String get errorTimeout => 'The connection timed out';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationInvalidEmail => 'Enter a valid email address';

  @override
  String get validationPasswordTooShort => 'Password must be at least 8 characters';

  @override
  String get validationInvalidPhone => 'Enter a valid phone number';

  @override
  String get navHome => 'Home';

  @override
  String get navAi => 'AI';

  @override
  String get navDocuments => 'Documents';

  @override
  String get navLawyers => 'Lawyers';

  @override
  String get navAccount => 'Account';

  @override
  String get navContracts => 'Contracts';

  @override
  String get navLawyerDashboard => 'Dashboard';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navClients => 'Clients';

  @override
  String get navEarnings => 'Earnings';

  @override
  String get navMyProfile => 'My Profile';

  @override
  String get placeholderComingSoonMessage => 'This section is under development and will be available soon';

  @override
  String get accountLanguage => 'Language';

  @override
  String get accountRoleClient => 'Client';

  @override
  String get accountRoleLawyer => 'Lawyer';

  @override
  String get accountRoleCompany => 'Company';

  @override
  String get confirmLogoutTitle => 'Log Out';

  @override
  String get confirmLogoutMessage => 'Are you sure you want to log out?';

  @override
  String get clientHomeCreateContract => 'Create New Contract';

  @override
  String get clientHomeMyContracts => 'My Contracts';

  @override
  String get clientHomeNoContractsTitle => 'No contracts yet';

  @override
  String get clientHomeNoContractsMessage => 'Start creating your first legal contract with AI assistance';

  @override
  String get clientHomeServicesTitle => 'Legal Services';

  @override
  String get serviceCreateContract => 'Create Contract';

  @override
  String get serviceAnalyzeContract => 'Analyze Contract';

  @override
  String get serviceFindLawyer => 'Find a Lawyer';

  @override
  String get clientNotificationsTitle => 'Notifications';

  @override
  String get contractsSearchHint => 'Search your contracts...';

  @override
  String get contractsFilterAll => 'All';

  @override
  String get contractStatusDraft => 'Draft';

  @override
  String get contractStatusPendingSignature => 'Pending Signature';

  @override
  String get contractStatusSigned => 'Signed';

  @override
  String get contractStatusCompleted => 'Completed';

  @override
  String get contractStatusCancelled => 'Cancelled';

  @override
  String get contractCategoryEmployment => 'Employment Contract';

  @override
  String get contractCategorySale => 'Sale Contract';

  @override
  String get contractCategoryRental => 'Rental Contract';

  @override
  String get contractCategoryPartnership => 'Partnership Contract';

  @override
  String get contractCategoryNda => 'NDA Agreement';

  @override
  String get contractCategoryServiceAgreement => 'Service Agreement';

  @override
  String get contractCategoryOther => 'Other Contract';

  @override
  String get contractTypeSelectionTitle => 'Choose Contract Type';

  @override
  String get contractTypeSelectionSubtitle => 'Select the type of contract you want to create';

  @override
  String get contractTypeSearchHint => 'Search contract types...';

  @override
  String get contractFormTitle => 'Fill Contract Details';

  @override
  String get validationInvalidNumber => 'Please enter a valid number';

  @override
  String get validationInvalidDate => 'Please select a valid date';

  @override
  String get contractPreviewTitle => 'Contract Preview';

  @override
  String get contractPreviewParties => 'Parties';

  @override
  String get contractPreviewDetails => 'Details';

  @override
  String get contractPreviewSaveDraft => 'Save as Draft';

  @override
  String get contractPreviewGenerate => 'Generate Contract';

  @override
  String get contractGeneratedSuccessTitle => 'Contract Generated Successfully!';

  @override
  String get contractGeneratedSuccessMessage => 'Your contract has been saved to your digital vault';

  @override
  String get contractDraftSavedMessage => 'Contract saved as draft';

  @override
  String get contractViewDetails => 'View Details';

  @override
  String get contractDetailsTitle => 'Contract Details';

  @override
  String get contractDetailsType => 'Contract Type';

  @override
  String get contractDetailsStatus => 'Status';

  @override
  String get contractDetailsCreated => 'Created';

  @override
  String get contractDetailsUpdated => 'Last Updated';

  @override
  String get contractDetailsContent => 'Contract Content';

  @override
  String get contractDetailsDeleteConfirmTitle => 'Delete Draft';

  @override
  String get contractDetailsDeleteConfirmMessage => 'Are you sure you want to delete this draft? This action cannot be undone.';

  @override
  String get contractDetailsDeletedMessage => 'Draft deleted';

  @override
  String get documentsEmptyTitle => 'No documents yet';

  @override
  String get documentsEmptyMessage => 'Your contracts and documents will appear here once created';

  @override
  String get documentsSearchHint => 'Search your documents...';

  @override
  String homeWelcome(String name) {
    return 'Welcome, $name';
  }
}
