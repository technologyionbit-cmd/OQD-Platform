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
  String get splashTagline => 'Your smart legal platform';

  @override
  String get splashLoading => 'Loading';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLogout => 'Logout';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonChangeLanguage => 'Change language';

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
  String authLoginRoleMismatch(String role) {
    return 'This account is registered as a $role account — switch the tab above to sign in';
  }

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
  String get authCommercialRegistrationNumber =>
      'Commercial Registration Number';

  @override
  String get authBarLicenseNumber => 'Bar License / Registration Number';

  @override
  String get authMainSpecialty => 'Main Specialty';

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
  String get authForgotPasswordSubtitle =>
      'Choose a recovery method to continue';

  @override
  String get authMethodSms => 'SMS';

  @override
  String get authMethodEmail => 'Email';

  @override
  String get authSmsInfo =>
      'We\'ll send a 6-digit verification code to reset your password';

  @override
  String get authEmailInfo =>
      'We\'ll send a verification link to reset your password';

  @override
  String get authSendCode => 'Send Verification Code';

  @override
  String get authRememberPassword => 'Remember your password?';

  @override
  String get authSentTitle => 'Sent!';

  @override
  String get authSentSubtitleSms =>
      'Check your messages and follow the instructions to reset your password';

  @override
  String get authSentSubtitleEmail =>
      'Check your email and follow the instructions to reset your password';

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
  String get authResetPasswordSubtitle =>
      'Create a strong password for your account';

  @override
  String get authNewPassword => 'New Password';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authResetPasswordSubmit => 'Save Password';

  @override
  String get authResetPasswordSuccessTitle => 'Password Changed!';

  @override
  String get authResetPasswordSuccessSubtitle =>
      'You can now sign in with your new password';

  @override
  String get authGoToLogin => 'Go to Login';

  @override
  String get validationPasswordMismatch => 'Passwords do not match';

  @override
  String get onboardingSlide1Title => 'Your legal assistant in your pocket';

  @override
  String get onboardingSlide1Subtitle =>
      'AI-powered preliminary consultations and instant explanations of legal terms, around the clock';

  @override
  String get onboardingSlide2Title => 'Smart contracts in minutes';

  @override
  String get onboardingSlide2Subtitle =>
      'Generate trusted legal contracts and analyze your existing ones with AI';

  @override
  String get onboardingSlide3Title => 'Connect directly with verified lawyers';

  @override
  String get onboardingSlide3Subtitle =>
      'Book a video, voice, or written consultation with top licensed lawyers';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String onboardingSlideIndicator(int current, int total) {
    return 'Slide $current of $total';
  }

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorNetwork =>
      'Could not connect, check your internet connection';

  @override
  String get errorInvalidCredentials => 'Invalid email or password';

  @override
  String get errorServer => 'A server error occurred, please try again later';

  @override
  String get errorTimeout => 'The connection timed out';

  @override
  String get errorTooManyAttempts =>
      'Too many attempts, please try again later';

  @override
  String errorTooManyAttemptsRetryIn(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Too many attempts, try again in $minutes minutes',
      one: 'Too many attempts, try again in 1 minute',
    );
    return '$_temp0';
  }

  @override
  String get errorAccountInactive =>
      'This account is not active, please contact support';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationInvalidEmail => 'Enter a valid email address';

  @override
  String get validationPasswordTooShort =>
      'Password must be at least 8 characters';

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
  String get clientHomeMyContracts => 'My Contracts';

  @override
  String get clientHomeNoContractsTitle => 'No contracts yet';

  @override
  String get clientHomeNoContractsMessage =>
      'Start creating your first legal contract with AI assistance';

  @override
  String get clientHomeServicesTitle => 'Your Legal Services';

  @override
  String get clientHomeRecommendedLawyers => 'Recommended Lawyers';

  @override
  String get serviceCreateContract => 'Create Contract';

  @override
  String get serviceAnalyzeContract => 'Analyze Contract';

  @override
  String get serviceFindLawyer => 'Find a Lawyer';

  @override
  String get clientNotificationsTitle => 'Notifications';

  @override
  String get clientHomeHeroTitle => 'How can I help you legally today?';

  @override
  String get clientHomeSearchHint => 'Search for a legal service...';

  @override
  String get clientHomeSearchEmptyTitle => 'No results found';

  @override
  String get clientHomeSearchEmptyMessage => 'Try a different search term';

  @override
  String get clientHomeQuickAskAi => 'Ask AI';

  @override
  String get clientHomeQuickCreateContract => 'Create Contract';

  @override
  String get clientHomeQuickFindLawyer => 'Find a Lawyer';

  @override
  String get serviceAnalyzeContractDesc =>
      'Upload your contract and let AI help you';

  @override
  String get serviceSmartContracts => 'Smart Contracts';

  @override
  String get serviceSmartContractsDesc => 'Create a legal contract in minutes';

  @override
  String get serviceBookLawyer => 'Book a Lawyer';

  @override
  String get serviceBookLawyerDesc =>
      'Book a consultation with a specialist lawyer';

  @override
  String get serviceGovDocuments => 'Government Documents';

  @override
  String get serviceGovDocumentsDesc => 'Know the required papers and steps';

  @override
  String get clientHomeVaultTitle => 'Digital Vault';

  @override
  String get clientHomeVaultSubtitle =>
      'All your documents, contracts and reports, saved';

  @override
  String get clientHomeRecentActivity => 'Recent Activity';

  @override
  String get contractsSearchHint => 'Search your contracts...';

  @override
  String get contractsFilterAll => 'All';

  @override
  String get contractsSearchEmptyTitle => 'No matching contracts';

  @override
  String get contractsSearchEmptyMessage =>
      'Try a different search term or filter';

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
  String get contractTypeSelectionSubtitle =>
      'Select the type of contract you want to create';

  @override
  String get contractTypeSearchHint => 'Search contract types...';

  @override
  String get contractTypeSearchEmptyMessage =>
      'No contract types match your search';

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
  String get contractGeneratedSuccessTitle =>
      'Contract Generated Successfully!';

  @override
  String get contractGeneratedSuccessMessage =>
      'Your contract has been saved to your digital vault';

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
  String get contractDetailsDeleteConfirmMessage =>
      'Are you sure you want to delete this draft? This action cannot be undone.';

  @override
  String get contractDetailsDeletedMessage => 'Draft deleted';

  @override
  String get contractSignButton => 'E-Signature';

  @override
  String get contractSignTitle => 'Electronic Signature';

  @override
  String get contractSignTabSaved => 'Saved Signature';

  @override
  String get contractSignNoSavedSignature =>
      'No saved signature — add one from your account first';

  @override
  String get contractSignLegalNotice =>
      'By signing this document, you legally agree to all its terms under the Jordanian Electronic Transactions Law.';

  @override
  String get contractSignConfirm => 'Confirm Signature';

  @override
  String get contractSignedSuccessTitle => 'Contract signed successfully!';

  @override
  String get contractSignedSuccessMessage =>
      'Your signature was recorded and the signed copy was saved securely to your digital vault.';

  @override
  String get documentsEmptyTitle => 'No documents yet';

  @override
  String get documentsEmptyMessage =>
      'Your contracts and documents will appear here once created';

  @override
  String get documentsSearchHint => 'Search your documents...';

  @override
  String get documentsSearchEmptyTitle => 'No matching documents';

  @override
  String get documentsSearchEmptyMessage => 'Try a different search term';

  @override
  String homeWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get commonJustNow => 'Just now';

  @override
  String commonMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String commonHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String commonDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get commonReset => 'Reset';

  @override
  String get navConsultations => 'Consultations';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsEmptyTitle => 'No notifications';

  @override
  String get notificationsEmptyMessage =>
      'You\'re all caught up — new notifications will show up here';

  @override
  String get notificationUnavailableForRole =>
      'This notification isn\'t available from your current account';

  @override
  String get specialtyCommercial => 'Commercial Law';

  @override
  String get specialtyPersonalStatus => 'Personal Status';

  @override
  String get specialtyCriminal => 'Criminal Law';

  @override
  String get specialtyLabor => 'Labor Law';

  @override
  String get specialtyRealEstate => 'Real Estate';

  @override
  String get specialtyCorporate => 'Corporate Law';

  @override
  String get specialtyIntellectualProperty => 'Intellectual Property';

  @override
  String get specialtyGeneral => 'General Practice';

  @override
  String get consultationTypeVideo => 'Video Call';

  @override
  String get consultationTypeVoice => 'Voice Call';

  @override
  String get consultationTypeWritten => 'Written Consultation';

  @override
  String get lawyersSearchHint => 'Search lawyers by name...';

  @override
  String get lawyersEmptyTitle => 'No lawyers found';

  @override
  String get lawyersEmptyMessage => 'Check back later for available lawyers';

  @override
  String get lawyersSearchEmptyTitle => 'No matching lawyers';

  @override
  String get lawyersSearchEmptyMessage =>
      'Try a different search term or filter';

  @override
  String get lawyersFilterTitle => 'Filters';

  @override
  String get lawyersFilterRating => 'Rating';

  @override
  String get lawyersFilterAvailability => 'Availability';

  @override
  String get lawyersFilterApply => 'Apply Filters';

  @override
  String get lawyerAvailableToday => 'Available Today';

  @override
  String get lawyerAvailableThisWeek => 'Available This Week';

  @override
  String get lawyerAvailableLater => 'Available Later';

  @override
  String lawyerYearsExperience(int count) {
    return '$count years experience';
  }

  @override
  String get lawyerProfileTitle => 'Lawyer Profile';

  @override
  String lawyerAvailabilityBadge(String availability) {
    return '$availability';
  }

  @override
  String get lawyerAboutTitle => 'About';

  @override
  String get lawyerSpecialtiesTitle => 'Specialties';

  @override
  String get lawyerConsultationTypesTitle => 'Consultation Types & Pricing';

  @override
  String get lawyerExperienceTitle => 'Experience';

  @override
  String get lawyerStatSatisfaction => 'Client Satisfaction';

  @override
  String get lawyerStatConsultations => 'Consultations';

  @override
  String get lawyerStatYears => 'Years of Experience';

  @override
  String get lawyerReviewsTitle => 'Client Reviews';

  @override
  String get lawyerBookConsultation => 'Book Consultation';

  @override
  String lawyerPriceSar(String amount) {
    return '$amount JOD';
  }

  @override
  String get bookingSelectTypeTitle => 'Select Consultation Type';

  @override
  String get bookingSelectDateTimeTitle => 'Select Date & Time';

  @override
  String get bookingNoSlotsMessage => 'No available slots for this day';

  @override
  String get bookingDetailsTitle => 'Booking Details';

  @override
  String get bookingNotesLabel => 'Notes';

  @override
  String get bookingNotesHint =>
      'Briefly describe what you\'d like to discuss...';

  @override
  String get bookingConfirm => 'Confirm & Pay';

  @override
  String get bookingSuccessTitle => 'Booking Request Sent!';

  @override
  String get bookingSuccessMessage =>
      'We\'ve sent your request to the lawyer — you\'ll be notified once it\'s confirmed';

  @override
  String get bookingViewDetails => 'View Booking';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentSummaryTitle => 'Invoice Summary';

  @override
  String get paymentTotalLabel => 'Total';

  @override
  String get paymentMethodCard => 'Debit/Credit Card';

  @override
  String get paymentMethodDigitalWallet => 'Apple / G Pay';

  @override
  String get paymentCardNumberLabel => 'Card number';

  @override
  String get paymentExpiryLabel => 'MM / YY';

  @override
  String get paymentCvvLabel => 'CVV';

  @override
  String get paymentFirstNameLabel => 'First name';

  @override
  String get paymentLastNameLabel => 'Last name';

  @override
  String paymentPayNow(String amount) {
    return 'Pay Now — $amount JOD';
  }

  @override
  String get paymentApplePayTitle => 'Apple Pay';

  @override
  String get paymentApplePaySubtitle =>
      'Pay securely with one tap through your digital wallet';

  @override
  String get paymentApplePayNoCardSharing => 'No card details shared';

  @override
  String get paymentApplePayInstant => 'Instant payment';

  @override
  String paymentPayWithApple(String amount) {
    return 'Pay with Apple Pay — $amount JOD';
  }

  @override
  String get paymentSuccessMessage => 'Payment successful';

  @override
  String get paymentCardNumberInvalid => 'Enter a valid card number';

  @override
  String get paymentExpiryInvalid => 'Enter a valid, non-expired date (MM/YY)';

  @override
  String get paymentCvvInvalid => 'Enter a valid CVV';

  @override
  String get paymentFirstNameRequired => 'Enter your first name';

  @override
  String get paymentLastNameRequired => 'Enter your last name';

  @override
  String get paymentCardTypeLabel => 'DEBIT / CREDIT';

  @override
  String get consultationDetailsTitle => 'Consultation Details';

  @override
  String get consultationStatusPending => 'Pending';

  @override
  String get consultationStatusUpcoming => 'Upcoming';

  @override
  String get consultationStatusWaiting => 'Waiting';

  @override
  String get consultationStatusReady => 'Ready';

  @override
  String get consultationStatusConnecting => 'Connecting';

  @override
  String get consultationStatusActive => 'Live';

  @override
  String get consultationStatusEnded => 'Ended';

  @override
  String get consultationStatusCompleted => 'Completed';

  @override
  String get consultationStatusCancelled => 'Cancelled';

  @override
  String get consultationStatusRejected => 'Rejected';

  @override
  String get consultationStatusMissed => 'Missed';

  @override
  String get consultationStatusFailed => 'Failed';

  @override
  String get consultationsEmptyTitle => 'Nothing here yet';

  @override
  String get consultationsEmptyMessage =>
      'Consultations in this category will show up here';

  @override
  String get consultationCancelConfirmTitle => 'Cancel Consultation';

  @override
  String get consultationCancelConfirmMessage =>
      'Are you sure you want to cancel this consultation?';

  @override
  String get consultationReschedule => 'Reschedule';

  @override
  String get consultationCancel => 'Cancel Consultation';

  @override
  String get consultationEnd => 'End Consultation';

  @override
  String get consultationMessageHint => 'Type a message...';

  @override
  String get notificationConsultationBookedTitle => 'Consultation request sent';

  @override
  String notificationConsultationBookedBody(String lawyerName) {
    return 'Waiting for $lawyerName to approve your consultation request';
  }

  @override
  String get notificationConsultationAcceptedTitle =>
      'Consultation request accepted';

  @override
  String notificationConsultationAcceptedBody(String lawyerName) {
    return '$lawyerName approved your consultation request';
  }

  @override
  String get notificationConsultationRejectedTitle =>
      'Consultation request declined';

  @override
  String notificationConsultationRejectedBody(String lawyerName) {
    return '$lawyerName declined your consultation request';
  }

  @override
  String get notificationConsultationCancelledTitle => 'Consultation cancelled';

  @override
  String get notificationConsultationCancelledBody =>
      'Your consultation appointment was cancelled';

  @override
  String get notificationConsultationCompletedTitle => 'Consultation ended';

  @override
  String get notificationConsultationCompletedBody =>
      'Your consultation session has ended';

  @override
  String get notificationNewMessageTitle => 'New message';

  @override
  String get notificationNewAttachmentBody => 'Sent you a new attachment';

  @override
  String get notificationDocumentUploadedTitle => 'Document uploaded';

  @override
  String notificationDocumentUploadedBody(String title) {
    return '\"$title\" was added to your digital vault';
  }

  @override
  String get notificationAiAnalysisTitle => 'Contract analysis complete';

  @override
  String notificationAiAnalysisBody(String documentTitle) {
    return 'Finished analyzing \"$documentTitle\"';
  }

  @override
  String get consultationRoomTitle => 'Consultation Lobby';

  @override
  String get consultationRoomEnterAction => 'Enter Consultation';

  @override
  String get consultationRoomBackAction => 'Back';

  @override
  String get consultationRoomTooEarlyTitle => 'Not time yet';

  @override
  String get consultationRoomTooEarlyMessage =>
      'Your consultation will open 15 minutes before the scheduled time.';

  @override
  String consultationRoomStartsIn(String remaining) {
    return 'Starts in $remaining';
  }

  @override
  String consultationRoomCountdownDays(int days) {
    return '${days}d';
  }

  @override
  String consultationRoomCountdownHours(int hours) {
    return '${hours}h';
  }

  @override
  String consultationRoomCountdownMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String get consultationRoomReadyTitle => 'Ready to join';

  @override
  String get consultationRoomReadyMessage =>
      'You can join this consultation now.';

  @override
  String get consultationRoomJoinAction => 'Join Consultation';

  @override
  String get consultationRoomJoinFailedMessage =>
      'We couldn\'t start the session. Please try again.';

  @override
  String get consultationRoomMissedTitle => 'Consultation missed';

  @override
  String get consultationRoomMissedMessage =>
      'The join window for this consultation has expired.';

  @override
  String get consultationRoomUnavailableMessage =>
      'This consultation is no longer available to join.';

  @override
  String get consultationRoomSimulateConnectionLossAction =>
      'Simulate connection loss (dev)';

  @override
  String get chatOpenAction => 'Open Chat';

  @override
  String get chatViewDetails => 'View consultation details';

  @override
  String get chatAttachmentTooltip => 'Attach';

  @override
  String get chatAttachImage => 'Photo from gallery';

  @override
  String get chatAttachFile => 'Attach file (mock)';

  @override
  String chatAttachedFileSnackbar(String fileName) {
    return 'Attached $fileName';
  }

  @override
  String chatFileDownloadedMock(String fileName) {
    return 'Downloaded (mock): $fileName';
  }

  @override
  String get chatImagePreviewTitle => 'Image';

  @override
  String get chatImageUnavailableMock =>
      'Preview unavailable for this mock image';

  @override
  String get chatImagePickError =>
      'Couldn\'t open the gallery. Please try again.';

  @override
  String get chatSendAttachment => 'Send';

  @override
  String get chatSendFailedMessage => 'Message failed to send.';

  @override
  String get chatEmptyTitle => 'No messages yet';

  @override
  String get chatEmptyMessage => 'Send a message to start the conversation';

  @override
  String get chatDayToday => 'Today';

  @override
  String get chatDayYesterday => 'Yesterday';

  @override
  String get chatTypingIndicatorLabel => 'Typing…';

  @override
  String chatTimeRemaining(String time) {
    return '$time remaining';
  }

  @override
  String get chatFirstWarning => 'The session will end soon';

  @override
  String get chatFinalWarning => 'Less than a minute left';

  @override
  String get chatEndConfirmTitle => 'End Consultation';

  @override
  String get chatEndConfirmMessage =>
      'This will end the session for both you and the other party. You\'ll still be able to view the transcript afterwards.';

  @override
  String get chatEndedBannerMessage => 'This consultation has ended';

  @override
  String chatDurationLabel(String duration) {
    return 'Duration: $duration';
  }

  @override
  String chatOpensAt(String time) {
    return 'Chat opens at $time';
  }

  @override
  String chatStartsIn(String remaining) {
    return 'Starts in $remaining';
  }

  @override
  String chatCountdownDays(int days) {
    return '${days}d';
  }

  @override
  String chatCountdownHours(int hours) {
    return '${hours}h';
  }

  @override
  String chatCountdownMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String get chatInvalidConsultationMessage =>
      'This consultation could not be found.';

  @override
  String get chatReturnToCallAction => 'Return to call — it\'s still active';

  @override
  String get chatMockReply1 =>
      'Thank you for sharing that — based on what you\'ve described, I\'d recommend we review the relevant clause together before taking any next steps. Could you send over the specific document section you\'re referring to?';

  @override
  String get chatMockReply2 =>
      'That\'s a fair concern. Generally speaking, the law gives you a reasonable window to respond formally, but the exact timeline depends on the contract terms. Let me take a closer look and get back to you shortly.';

  @override
  String get chatMockReply3 =>
      'I understand the urgency here. My suggestion is to hold off on signing anything until we\'ve confirmed the liability clause is worded in your favor. I\'ll draft a suggested revision for you to review.';

  @override
  String get chatMockReply4 =>
      'Good question. Based on similar cases, this type of dispute is usually resolved faster through direct negotiation rather than going straight to court. Would you like me to outline the steps for that route?';

  @override
  String get chatMockReply5 =>
      'Noted, thank you. I\'ll need a bit more context on the timeline of events to give you an accurate opinion — could you confirm the date the notice was issued?';

  @override
  String get chatMockReply6 =>
      'This looks straightforward enough — I don\'t see anything that puts you at legal risk here, but I\'d still recommend documenting the agreement in writing to avoid any future disputes.';

  @override
  String get voiceCallLabel => 'Voice Consultation';

  @override
  String get voiceCallConnectingLabel => 'Connecting…';

  @override
  String get voiceCallStatusConnected => 'Connected';

  @override
  String get voiceCallStatusReconnecting => 'Reconnecting…';

  @override
  String get voiceCallConnectionLostBanner => 'Connection lost';

  @override
  String voiceCallReconnectingAttempt(int attempt, int max) {
    return 'Attempt $attempt of $max';
  }

  @override
  String get voiceCallRetryNowAction => 'Retry Now';

  @override
  String get voiceCallUnavailableTitle => 'Unable to connect';

  @override
  String voiceCallUnavailableMessage(String name) {
    return '$name couldn\'t be reached for this consultation. You can view the details or try again later.';
  }

  @override
  String get voiceCallEndConfirmTitle => 'End consultation?';

  @override
  String get voiceCallEndConfirmMessage =>
      'This will end the call for both you and the other party.';

  @override
  String get voiceCallEndCallAction => 'End Call';

  @override
  String get voiceCallKeepCallAction => 'Keep Call';

  @override
  String get voiceCallMuteAction => 'Mute';

  @override
  String get voiceCallUnmuteAction => 'Unmute';

  @override
  String get voiceCallSpeakerOnAction => 'Turn speaker on';

  @override
  String get voiceCallSpeakerOffAction => 'Turn speaker off';

  @override
  String get voiceCallEndedTitle => 'Consultation ended';

  @override
  String get voiceCallAutoEndedMessage =>
      'The maximum consultation duration has been reached.';

  @override
  String get voiceCallDoneAction => 'Done';

  @override
  String get videoCallLabel => 'Video Consultation';

  @override
  String get videoCallCameraOnAction => 'Camera on';

  @override
  String get videoCallCameraOffAction => 'Camera off';

  @override
  String get videoCallCameraOffPlaceholder => 'Camera is off';

  @override
  String get videoCallSwitchCameraAction => 'Switch camera';

  @override
  String get videoCallSwitchedToFrontCamera => 'Switched to front camera';

  @override
  String get videoCallSwitchedToBackCamera => 'Switched to back camera';

  @override
  String get videoCallLocalVideoLabel => 'Local video';

  @override
  String get videoCallRemoteVideoLabel => 'Remote video';

  @override
  String get videoCallChatAction => 'Chat';

  @override
  String get videoCallEndedMessage => 'Video ended';

  @override
  String get lawyerRequestsTitle => 'Consultation Requests';

  @override
  String get lawyerRequestsEmptyTitle => 'No pending requests';

  @override
  String get lawyerRequestsEmptyMessage =>
      'New consultation requests will show up here';

  @override
  String get lawyerRequestAccept => 'Accept';

  @override
  String get lawyerRequestReject => 'Decline';

  @override
  String get lawyerRequestRejectConfirmTitle => 'Decline Request';

  @override
  String get lawyerRequestRejectConfirmMessage =>
      'Are you sure you want to decline this consultation request?';

  @override
  String get lawyerRequestAcceptedMessage => 'Request accepted';

  @override
  String get lawyerRequestRejectedMessage => 'Request declined';

  @override
  String get scheduleAddSlotTitle => 'Add Availability';

  @override
  String get scheduleRemoveSlotTitle => 'Remove Slot';

  @override
  String get scheduleRemoveSlotMessage =>
      'Are you sure you want to remove this available slot?';

  @override
  String get scheduleEmptyDayMessage => 'No availability set for this day';

  @override
  String get scheduleSlotBooked => 'Booked';

  @override
  String get scheduleSlotOpen => 'Open';

  @override
  String get scheduleActionFailedMessage =>
      'Something went wrong. Please try again.';

  @override
  String get scheduleSlotLinkedConsultationMissing =>
      'Couldn\'t find the linked consultation — showing all consultations instead.';

  @override
  String get aiRecentConversationsTitle => 'Recent Conversations';

  @override
  String get aiNoConversationsMessage =>
      'Start a conversation to get quick answers to your legal questions';

  @override
  String get aiDisclaimer =>
      'This assistant provides general legal information, not a substitute for advice from a licensed lawyer.';

  @override
  String get aiChatTitle => 'Smart Legal Assistant';

  @override
  String get aiChatInputHint => 'Type your question...';

  @override
  String get aiNewConversation => 'New Conversation';

  @override
  String get aiClearConversationTitle => 'Clear Conversation';

  @override
  String get aiClearConversationMessage =>
      'Are you sure you want to clear all messages in this conversation?';

  @override
  String get aiStatusAvailable => 'Available now — replies instantly';

  @override
  String get aiWelcomeMessage =>
      'Hello! I\'m your smart legal assistant. I can help you understand your contracts, know your rights, and draft new contracts. How can I help you today?';

  @override
  String get aiQuickActionCreateContract => 'I want to create a contract';

  @override
  String get aiQuickActionHrIssue => 'I have an issue with an employee';

  @override
  String get aiQuickActionExplainClause => 'Explain a legal clause to me';

  @override
  String get aiContractWizardIntro =>
      'Great! I\'ll help you draft a trusted legal contract. Choose the contract type you want to create from the list:';

  @override
  String get aiContractWizardAskParty1 =>
      'Who is the first party to the contract (employer / entity)?';

  @override
  String get aiContractWizardAskParty2 =>
      'Got it. Who is the second party to the contract?';

  @override
  String get aiContractWizardAskSubject =>
      'What is the contract\'s subject or main duties?';

  @override
  String get aiContractWizardAskValue =>
      'Finally, what\'s the financial value and duration of the contract?';

  @override
  String aiContractWizardDraftTitle(String type) {
    return '$type draft';
  }

  @override
  String get aiContractWizardStatusDraft => 'Initial draft — under review';

  @override
  String get aiContractWizardStatusSent =>
      'Awaiting the other party\'s signature';

  @override
  String get aiContractWizardPartyA => 'First party';

  @override
  String get aiContractWizardPartyB => 'Second party';

  @override
  String get aiContractWizardSubjectLabel => 'Subject';

  @override
  String get aiContractWizardValueLabel => 'Value & duration';

  @override
  String get aiContractWizardSendSignature => 'Send Signature Request';

  @override
  String get aiContractWizardSaveVault => 'Save to Vault';

  @override
  String get aiContractWizardSentMessage =>
      'Signature request sent successfully';

  @override
  String get aiContractWizardSavedMessage =>
      'Draft saved to your digital vault';

  @override
  String get aiContractWizardInputHint => 'Type your answer here...';

  @override
  String get analysisAnalyzingMessage => 'Analyzing your document...';

  @override
  String get analysisUploadTitle => 'Upload a Document';

  @override
  String get analysisUploadLabel => 'Document Title';

  @override
  String get analysisUploadHint => 'e.g. Employment Contract - Acme Inc.';

  @override
  String get analysisAnalyzeButton => 'Analyze Document';

  @override
  String get analysisSelectFromVaultTitle => 'Or select from your vault';

  @override
  String get analysisResultTitle => 'Analysis Result';

  @override
  String get analysisInvalidMessage => 'This analysis could not be found.';

  @override
  String get analysisClausesTitle => 'Clauses';

  @override
  String get analysisAskAi => 'Ask AI about this clause';

  @override
  String analysisAskAboutClause(String clauseTitle) {
    return 'Can you explain the \"$clauseTitle\" clause in more detail?';
  }

  @override
  String get analysisRiskLow => 'Low Risk';

  @override
  String get analysisRiskMedium => 'Medium Risk';

  @override
  String get analysisRiskHigh => 'High Risk';

  @override
  String get dashboardTodayAppointments => 'Today\'s Appointments';

  @override
  String get dashboardPendingRequests => 'Pending Requests';

  @override
  String get dashboardMonthEarnings => 'This Month';

  @override
  String get dashboardQuickActions => 'Quick Actions';

  @override
  String get dashboardNoAppointmentsToday =>
      'No appointments scheduled for today';

  @override
  String get dashboardActiveSessionBadge => 'Urgent Consultation — Now';

  @override
  String dashboardActiveSessionStartingIn(int minutes) {
    return 'Starts in $minutes min';
  }

  @override
  String get dashboardActiveSessionReady => 'Ready to start now';

  @override
  String get dashboardStartSession => 'Start Session';

  @override
  String get earningsBalance => 'Total Earned';

  @override
  String earningsPending(String amount) {
    return '$amount pending from upcoming consultations';
  }

  @override
  String get earningsMonthlySummary => 'Monthly Summary';

  @override
  String get earningsHistoryTitle => 'Earnings History';

  @override
  String get earningsEmptyMessage =>
      'Completed consultations will show up here';

  @override
  String get clientsSearchHint => 'Search clients...';

  @override
  String get clientsEmptyTitle => 'No clients yet';

  @override
  String get clientsEmptyMessage =>
      'Clients you\'ve had a consultation with will show up here';

  @override
  String clientsConsultationCount(int count) {
    return '$count consultations';
  }

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get accountEditProfileSubtitle => 'Name, email';

  @override
  String get lawyerEditProfileSubtitle =>
      'Bio, specialties, pricing, verification';

  @override
  String get profileUpdatedMessage => 'Profile updated';

  @override
  String get unsavedChangesTitle => 'Discard changes?';

  @override
  String get unsavedChangesMessage =>
      'You have unsaved changes. Are you sure you want to leave without saving?';

  @override
  String get unsavedChangesDiscard => 'Discard';

  @override
  String get lawyerEditProfileTitle => 'Professional Profile';

  @override
  String get lawyerVerificationSectionTitle => 'Verification';

  @override
  String get lawyerVerified => 'Verified';

  @override
  String get lawyerPendingVerification => 'Pending Review';

  @override
  String get lawyerNotVerified => 'Not verified yet';

  @override
  String get lawyerUploadVerificationDocument => 'Upload Verification Document';

  @override
  String get lawyerVerificationDocumentPreviewTitle => 'Document preview';

  @override
  String get lawyerVerificationSubmittedMessage =>
      'Document submitted for review';

  @override
  String get lawyerPriceLabel => 'Price';

  @override
  String get lawyerBioRequiredError => 'Please write a short bio before saving';

  @override
  String get lawyerExperienceInvalidError => 'Enter a valid number of years';

  @override
  String get lawyerPriceRequiredError => 'Enter a price greater than 0';

  @override
  String get lawyerSelectSpecialtyError => 'Select at least one specialty';

  @override
  String get lawyerSelectConsultationTypeError =>
      'Select at least one consultation type you offer';

  @override
  String get navTeam => 'Team';

  @override
  String get teamAddMemberTitle => 'Add Team Member';

  @override
  String get teamAddMemberAction => 'Add Member';

  @override
  String get teamRoleLabel => 'Role';

  @override
  String get teamRoleAdmin => 'Admin';

  @override
  String get teamRoleManager => 'Manager';

  @override
  String get teamRoleMember => 'Member';

  @override
  String get teamMemberAddedMessage => 'Team member added';

  @override
  String get teamSearchHint => 'Search team members...';

  @override
  String get teamEmptyTitle => 'No team members yet';

  @override
  String get teamEmptyMessage => 'Add your first team member to get started';

  @override
  String teamJoinedOn(String date) {
    return 'Joined $date';
  }

  @override
  String get teamRemoveMember => 'Remove Member';

  @override
  String get teamRemoveConfirmTitle => 'Remove Member';

  @override
  String get teamRemoveConfirmMessage =>
      'Are you sure you want to remove this member from your team?';

  @override
  String get companyActiveConsultations => 'Active Consultations';

  @override
  String get documentsUploadTitle => 'Upload Document';

  @override
  String get documentsUploadHint =>
      'There\'s no file picker in this preview yet — just give the document a title.';

  @override
  String get documentsUploadLabel => 'Document Title';

  @override
  String get commonUpload => 'Upload';

  @override
  String get documentsUploadedMessage => 'Document uploaded';

  @override
  String get documentsRenameTitle => 'Rename Document';

  @override
  String get commonRename => 'Rename';

  @override
  String get documentsDeleteConfirmTitle => 'Delete Document';

  @override
  String get documentsDeleteConfirmMessage =>
      'Are you sure you want to delete this document? This action cannot be undone.';

  @override
  String get documentsDeletedMessage => 'Document deleted';

  @override
  String get accountNotificationsSetting => 'Push Notifications';

  @override
  String get accountStatDocuments => 'Documents';

  @override
  String get accountStatConsultations => 'Consultations';

  @override
  String get accountStatContracts => 'Contracts';

  @override
  String get subscriptionTierBasic => 'Basic Plan';

  @override
  String get subscriptionTierPro => 'Business Pro Plan';

  @override
  String get subscriptionTierEnterprise => 'Enterprise Plan';

  @override
  String get subscriptionNoPlan => 'No active plan';

  @override
  String get accountMenuSubscriptions => 'Subscriptions & Plans';

  @override
  String get accountMenuPaymentMethods => 'Payment Methods';

  @override
  String get accountMenuSavedSignature => 'Saved Signature';

  @override
  String get accountMenuBookings => 'Bookings';

  @override
  String get accountMenuInvoices => 'Invoices';

  @override
  String get accountMenuSecurity => 'Security & Privacy';

  @override
  String get accountMenuHelp => 'Help & Support';

  @override
  String get paymentMethodsTitle => 'Payment Methods';

  @override
  String get paymentMethodsEmptyTitle => 'No saved payment methods';

  @override
  String get paymentMethodsEmptyMessage =>
      'Add a card to speed up future payments';

  @override
  String get paymentMethodsAddCard => 'Add Card';

  @override
  String get paymentMethodsSetDefault => 'Set as default';

  @override
  String get paymentMethodsDefaultBadge => 'Default';

  @override
  String get paymentMethodsLast4Label => 'Last 4 digits';

  @override
  String get paymentMethodsHolderLabel => 'Cardholder name';

  @override
  String get paymentMethodsAddedMessage => 'Card added successfully';

  @override
  String get paymentMethodsLast4Invalid => 'Enter exactly 4 digits';

  @override
  String get paymentMethodsHolderRequired => 'Enter the cardholder name';

  @override
  String get paymentMethodsRemoveConfirmTitle => 'Remove Card';

  @override
  String get paymentMethodsRemoveConfirmMessage =>
      'Are you sure you want to remove this card?';

  @override
  String get savedSignatureTitle => 'Saved Signature';

  @override
  String get savedSignatureTabDraw => 'Draw Signature';

  @override
  String get savedSignatureTabUpload => 'Upload Photo';

  @override
  String get savedSignatureTabType => 'Typed Signature';

  @override
  String get savedSignatureClear => 'Clear';

  @override
  String get savedSignatureSavedMessage => 'Signature saved';

  @override
  String get savedSignatureTypedHint => 'Type your name here';

  @override
  String get savedSignatureUploadPlaceholder =>
      'Tap to upload a signature image';

  @override
  String get savedSignatureUploadedLabel => 'Signature uploaded as image';

  @override
  String savedSignatureLastSaved(String date) {
    return 'Last saved: $date';
  }

  @override
  String get securityPrivacyTitle => 'Security & Privacy';

  @override
  String get securityChangePasswordTitle => 'Change Password';

  @override
  String get securityCurrentPasswordLabel => 'Current password';

  @override
  String get securityNewPasswordLabel => 'New password';

  @override
  String get securityConfirmPasswordLabel => 'Confirm new password';

  @override
  String get securityPasswordMismatch => 'Passwords do not match';

  @override
  String get securityPasswordUpdatedMessage => 'Password updated successfully';

  @override
  String get securityTwoFactorTitle => 'Two-Factor Authentication';

  @override
  String get securityTwoFactorSubtitle =>
      'An extra layer of protection at sign-in';

  @override
  String get securityBiometricTitle => 'Biometric Sign-In';

  @override
  String get securityBiometricSubtitle =>
      'Use your fingerprint instead of a password';

  @override
  String get securityActiveSessionsTitle => 'Active Sessions';

  @override
  String get securityEndSession => 'End Session';

  @override
  String get securitySessionEndedMessage => 'Session ended';

  @override
  String get securitySessionLocationJordan => 'Jordan';

  @override
  String get securityTwoFactorUnavailable => 'Not available yet';

  @override
  String get securitySessionsError => 'Couldn\'t load your sessions';

  @override
  String get securityThisDevice => 'This device';

  @override
  String get securityUnknownDevice => 'Unknown device';

  @override
  String get securityEndAllOtherSessions => 'Sign out of all other devices';

  @override
  String get helpSupportTitle => 'Help & Support';

  @override
  String get helpFaqTitle => 'Frequently Asked Questions';

  @override
  String get helpContactUs => 'Contact Support';

  @override
  String get helpSubjectLabel => 'Subject';

  @override
  String get helpMessageLabel => 'Message';

  @override
  String get helpSendMessage => 'Send';

  @override
  String get helpRequestSentMessage =>
      'Your request has been sent, we\'ll get back to you soon';

  @override
  String get helpFaqNewContractQuestion => 'How do I create a new contract?';

  @override
  String get helpFaqNewContractAnswer =>
      'From Home, choose \"Smart Contracts\", then pick a contract type and fill in the required details step by step.';

  @override
  String get helpFaqEsignatureQuestion =>
      'Is the electronic signature legally recognized?';

  @override
  String get helpFaqEsignatureAnswer =>
      'Yes, the electronic signature complies with the Jordanian Electronic Transactions Law.';

  @override
  String get helpFaqBookConsultationQuestion =>
      'How do I book a consultation with a lawyer?';

  @override
  String get helpFaqBookConsultationAnswer =>
      'From the \"Lawyers\" tab, choose the right lawyer, tap \"Book a consultation now\", and follow the booking steps.';

  @override
  String get helpFaqManageSubscriptionQuestion =>
      'How do I cancel or change my subscription?';

  @override
  String get helpFaqManageSubscriptionAnswer =>
      'From \"Account\", choose \"Subscriptions\" to pick another plan or change your billing cycle at any time.';

  @override
  String get invoicesTitle => 'Invoices';

  @override
  String get invoicesEmptyTitle => 'No invoices yet';

  @override
  String get invoicesEmptyMessage =>
      'Your invoices will appear here after your first payment';

  @override
  String get invoiceStatusPaid => 'Paid';

  @override
  String get invoiceStatusPending => 'Pending';

  @override
  String get vaultFilterDocuments => 'Documents';

  @override
  String get vaultFilterAiReports => 'AI Analysis Reports';

  @override
  String get vaultFilterContracts => 'Created Contracts';

  @override
  String vaultSavedFilesCount(int count) {
    return '$count saved files';
  }

  @override
  String get vaultAiReportBadge => 'Report Ready';

  @override
  String get subscriptionPlansTitle => 'Subscriptions & Upgrade';

  @override
  String get subscriptionCycleMonthly => 'Monthly';

  @override
  String get subscriptionCycleSixMonths => '6 Months';

  @override
  String get subscriptionCycleAnnual => 'Annual';

  @override
  String subscriptionSaveBadge(int percent) {
    return 'Save $percent%';
  }

  @override
  String get subscriptionMostPopular => 'Most Popular';

  @override
  String subscriptionUpgradeButton(String tier) {
    return 'Upgrade to $tier';
  }

  @override
  String subscriptionPerMonth(String amount) {
    return '$amount JOD/month';
  }

  @override
  String subscriptionPerSixMonths(String amount) {
    return '$amount JOD/6 months';
  }

  @override
  String subscriptionPerYear(String amount) {
    return '$amount JOD/year';
  }

  @override
  String get subscriptionBasicDesc =>
      'Includes a set amount of AI services and contract drafting';

  @override
  String get subscriptionBasicFeature1 => '5 contracts per month';

  @override
  String get subscriptionBasicFeature2 => 'One contract analysis';

  @override
  String get subscriptionBasicFeature3 => 'AI consultation';

  @override
  String get subscriptionBasicFeature4 => 'Email support';

  @override
  String get subscriptionProDesc =>
      'Everything you need to manage your contracts and legal consultations, unlimited';

  @override
  String get subscriptionProFeature1 => 'Unlimited contracts';

  @override
  String get subscriptionProFeature2 => 'Unlimited analysis';

  @override
  String get subscriptionProFeature3 => 'AI consultation';

  @override
  String get subscriptionProFeature4 => '3 lawyer consultations per month';

  @override
  String get subscriptionProFeature5 => 'Advanced e-signature';

  @override
  String get subscriptionProFeature6 => '24/7 priority support';

  @override
  String get subscriptionEnterpriseDesc =>
      'A comprehensive solution for large companies and legal institutions';

  @override
  String get subscriptionEnterpriseFeature1 => 'Everything in Pro';

  @override
  String get subscriptionEnterpriseFeature2 => 'Savings of up to 30%';

  @override
  String get subscriptionEnterpriseFeature3 => '12 lawyer consultations';

  @override
  String get subscriptionEnterpriseFeature4 => 'Personal account manager';

  @override
  String get subscriptionEnterpriseFeature5 => 'Monthly legal reports';

  @override
  String get subscriptionEnterpriseFeature6 => 'Custom integrations';

  @override
  String get subscriptionSuccessTitle => 'Your plan was upgraded successfully!';

  @override
  String get subscriptionSuccessMessage =>
      'Comprehensive legal solutions for your team and organization';

  @override
  String get subscriptionBackHome => 'Back to Home';

  @override
  String get govDocumentsTitle => 'Government Documents';

  @override
  String get govDocumentsSearchHint =>
      'What do you want to get done? (e.g. register a company...)';

  @override
  String get govProcedureCompanyRegistration => 'Company Registration';

  @override
  String get govProcedureCompanyRegistrationCategory => 'Business & Trade';

  @override
  String get govProcedurePropertyRegistration => 'Property Registration';

  @override
  String get govProcedurePropertyRegistrationCategory =>
      'Real Estate & Property';

  @override
  String get govProcedureContractNotarization => 'Contract Notarization';

  @override
  String get govProcedureContractNotarizationCategory => 'Legal Notarization';

  @override
  String get govProcedureLawsuitFiling => 'Filing a Lawsuit';

  @override
  String get govProcedureLawsuitFilingCategory => 'Cases & Courts';

  @override
  String get govAccessDirectLink => 'Direct Online Link';

  @override
  String get govAccessGuide => 'Step-by-Step Guide';

  @override
  String govStepsCount(int count) {
    return '$count steps';
  }

  @override
  String get govRequiredDocumentsTitle => 'Required Documents';

  @override
  String govRequiredDocumentsProgress(int done, int total) {
    return '$done/$total ready';
  }

  @override
  String get govProcedureStepsTitle => 'Procedure Steps';

  @override
  String get govStartProcedure => 'Start Procedure Now';

  @override
  String get govProcedureStartedMessage =>
      'You\'re now tracking this procedure — follow its status here';

  @override
  String get govProcedureStatusInProgress => 'In progress — awaiting documents';
}
