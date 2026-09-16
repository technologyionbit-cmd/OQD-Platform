import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application name shown in title bars and splash screen
  ///
  /// In ar, this message translates to:
  /// **'عقد'**
  String get appName;

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @commonLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get commonLogout;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get commonConfirm;

  /// No description provided for @commonSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get commonSkip;

  /// No description provided for @commonNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get commonNext;

  /// No description provided for @commonViewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get commonViewAll;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commonDelete;

  /// No description provided for @commonContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get commonContinue;

  /// No description provided for @commonCopy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get commonCopy;

  /// No description provided for @contractContentCopiedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ محتوى العقد'**
  String get contractContentCopiedMessage;

  /// No description provided for @commonOptional.
  ///
  /// In ar, this message translates to:
  /// **'(اختياري)'**
  String get commonOptional;

  /// No description provided for @authLoginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بعودتك! سجل دخولك للمتابعة'**
  String get authLoginSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get authEmailLabel;

  /// No description provided for @authEmailOrPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو رقم الهاتف'**
  String get authEmailOrPhoneLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get authPasswordLabel;

  /// No description provided for @authPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get authPhoneLabel;

  /// No description provided for @authLoginSubmit.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get authLoginSubmit;

  /// No description provided for @authForgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get authForgotPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get authNoAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get authCreateAccount;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authLoginRoleMismatch.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحساب مسجَّل كحساب {role} — بدّل التبويب أعلاه لتسجيل الدخول'**
  String authLoginRoleMismatch(String role);

  /// No description provided for @authRegisterTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'انضم إلينا وابدأ رحلتك القانونية'**
  String get authRegisterSubtitle;

  /// No description provided for @authRegisterSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get authRegisterSubmit;

  /// No description provided for @authAccountTypeIndividual.
  ///
  /// In ar, this message translates to:
  /// **'فرد'**
  String get authAccountTypeIndividual;

  /// No description provided for @authAccountTypeCompany.
  ///
  /// In ar, this message translates to:
  /// **'شركة'**
  String get authAccountTypeCompany;

  /// No description provided for @authAccountTypeLawyer.
  ///
  /// In ar, this message translates to:
  /// **'محامٍ'**
  String get authAccountTypeLawyer;

  /// No description provided for @authFullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get authFullName;

  /// No description provided for @authFullNameTriple.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الثلاثي'**
  String get authFullNameTriple;

  /// No description provided for @authCompanyName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المنشأة / الشركة'**
  String get authCompanyName;

  /// No description provided for @authCommercialRegistrationNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم السجل التجاري'**
  String get authCommercialRegistrationNumber;

  /// No description provided for @authBarLicenseNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم إجازة المحاماة / القيد'**
  String get authBarLicenseNumber;

  /// No description provided for @authMainSpecialty.
  ///
  /// In ar, this message translates to:
  /// **'التخصص الرئيسي'**
  String get authMainSpecialty;

  /// No description provided for @authTermsAgreementPrefix.
  ///
  /// In ar, this message translates to:
  /// **'بالتسجيل توافق على '**
  String get authTermsAgreementPrefix;

  /// No description provided for @authTermsOfService.
  ///
  /// In ar, this message translates to:
  /// **'شروط الخدمة'**
  String get authTermsOfService;

  /// No description provided for @authTermsAgreementJoiner.
  ///
  /// In ar, this message translates to:
  /// **' و'**
  String get authTermsAgreementJoiner;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get authPrivacyPolicy;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر طريقة الاستعادة للمتابعة'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authMethodSms.
  ///
  /// In ar, this message translates to:
  /// **'رسالة SMS'**
  String get authMethodSms;

  /// No description provided for @authMethodEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get authMethodEmail;

  /// No description provided for @authSmsInfo.
  ///
  /// In ar, this message translates to:
  /// **'سنرسل لك رمز تحقق مؤلف من 6 أرقام لإعادة تعيين كلمة المرور'**
  String get authSmsInfo;

  /// No description provided for @authEmailInfo.
  ///
  /// In ar, this message translates to:
  /// **'سنرسل لك رابط تحقق لإعادة تعيين كلمة المرور'**
  String get authEmailInfo;

  /// No description provided for @authSendCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رمز التحقق'**
  String get authSendCode;

  /// No description provided for @authRememberPassword.
  ///
  /// In ar, this message translates to:
  /// **'تذكرت كلمة المرور؟'**
  String get authRememberPassword;

  /// No description provided for @authSentTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم الإرسال!'**
  String get authSentTitle;

  /// No description provided for @authSentSubtitleSms.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من رسائلك واتبع التعليمات لإعادة تعيين كلمة المرور'**
  String get authSentSubtitleSms;

  /// No description provided for @authSentSubtitleEmail.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من بريدك الإلكتروني واتبع التعليمات لإعادة تعيين كلمة المرور'**
  String get authSentSubtitleEmail;

  /// No description provided for @authEnterCode.
  ///
  /// In ar, this message translates to:
  /// **'إدخال رمز التحقق'**
  String get authEnterCode;

  /// No description provided for @authResend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال'**
  String get authResend;

  /// No description provided for @authOtpTitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز التحقق'**
  String get authOtpTitle;

  /// No description provided for @authOtpSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا رمزًا مكونًا من 6 أرقام إلى {destination}'**
  String authOtpSubtitle(String destination);

  /// No description provided for @authOtpConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get authOtpConfirm;

  /// No description provided for @authOtpResendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال بعد {seconds}'**
  String authOtpResendIn(String seconds);

  /// No description provided for @authOtpInvalidCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق غير صحيح'**
  String get authOtpInvalidCode;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'كلمة مرور جديدة'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ كلمة مرور قوية لحسابك'**
  String get authResetPasswordSubtitle;

  /// No description provided for @authNewPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get authNewPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get authConfirmPassword;

  /// No description provided for @authResetPasswordSubmit.
  ///
  /// In ar, this message translates to:
  /// **'حفظ كلمة المرور'**
  String get authResetPasswordSubmit;

  /// No description provided for @authResetPasswordSuccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور!'**
  String get authResetPasswordSuccessTitle;

  /// No description provided for @authResetPasswordSuccessSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة'**
  String get authResetPasswordSuccessSubtitle;

  /// No description provided for @authGoToLogin.
  ///
  /// In ar, this message translates to:
  /// **'الذهاب لتسجيل الدخول'**
  String get authGoToLogin;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get validationPasswordMismatch;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In ar, this message translates to:
  /// **'مساعدك القانوني في جيبك'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'استشارات أولية وشرح فوري للبنود القانونية بالذكاء الاصطناعي على مدار الساعة'**
  String get onboardingSlide1Subtitle;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In ar, this message translates to:
  /// **'عقود ذكية بدقائق'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ عقودًا قانونية موثوقة وحلل عقودك الحالية بالذكاء الاصطناعي'**
  String get onboardingSlide2Subtitle;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مباشرة مع محامين موثوقين'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'احجز استشارة فيديو أو صوتية أو مكتوبة مع نخبة من المحامين المرخصين'**
  String get onboardingSlide3Subtitle;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get onboardingGetStarted;

  /// No description provided for @devCredentialsTitle.
  ///
  /// In ar, this message translates to:
  /// **'بيانات تجريبية (بيئة التطوير فقط)'**
  String get devCredentialsTitle;

  /// No description provided for @devCredentialsPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور لجميع الحسابات: {password}'**
  String devCredentialsPassword(String password);

  /// No description provided for @errorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال بالشبكة، تحقق من الاتصال بالإنترنت'**
  String get errorNetwork;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو كلمة المرور غير صحيحة'**
  String get errorInvalidCredentials;

  /// No description provided for @errorServer.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في الخادم، حاول لاحقًا'**
  String get errorServer;

  /// No description provided for @errorTimeout.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الاتصال'**
  String get errorTimeout;

  /// No description provided for @validationRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get validationRequired;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'صيغة البريد الإلكتروني غير صحيحة'**
  String get validationInvalidEmail;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب ألا تقل عن 8 أحرف'**
  String get validationPasswordTooShort;

  /// No description provided for @validationInvalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف غير صحيح'**
  String get validationInvalidPhone;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navAi.
  ///
  /// In ar, this message translates to:
  /// **'AI'**
  String get navAi;

  /// No description provided for @navDocuments.
  ///
  /// In ar, this message translates to:
  /// **'المستندات'**
  String get navDocuments;

  /// No description provided for @navLawyers.
  ///
  /// In ar, this message translates to:
  /// **'المحامون'**
  String get navLawyers;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navAccount;

  /// No description provided for @navContracts.
  ///
  /// In ar, this message translates to:
  /// **'العقود'**
  String get navContracts;

  /// No description provided for @navLawyerDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get navLawyerDashboard;

  /// No description provided for @navSchedule.
  ///
  /// In ar, this message translates to:
  /// **'المواعيد'**
  String get navSchedule;

  /// No description provided for @navClients.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get navClients;

  /// No description provided for @navEarnings.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح'**
  String get navEarnings;

  /// No description provided for @navMyProfile.
  ///
  /// In ar, this message translates to:
  /// **'ملفي'**
  String get navMyProfile;

  /// No description provided for @accountLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get accountLanguage;

  /// No description provided for @accountRoleClient.
  ///
  /// In ar, this message translates to:
  /// **'عميل'**
  String get accountRoleClient;

  /// No description provided for @accountRoleLawyer.
  ///
  /// In ar, this message translates to:
  /// **'محامٍ'**
  String get accountRoleLawyer;

  /// No description provided for @accountRoleCompany.
  ///
  /// In ar, this message translates to:
  /// **'شركة'**
  String get accountRoleCompany;

  /// No description provided for @confirmLogoutTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get confirmLogoutTitle;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد تسجيل الخروج؟'**
  String get confirmLogoutMessage;

  /// No description provided for @clientHomeMyContracts.
  ///
  /// In ar, this message translates to:
  /// **'عقودي'**
  String get clientHomeMyContracts;

  /// No description provided for @clientHomeNoContractsTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عقود بعد'**
  String get clientHomeNoContractsTitle;

  /// No description provided for @clientHomeNoContractsMessage.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بإنشاء أول عقد قانوني لك بمساعدة الذكاء الاصطناعي'**
  String get clientHomeNoContractsMessage;

  /// No description provided for @clientHomeServicesTitle.
  ///
  /// In ar, this message translates to:
  /// **'خدماتك القانونية'**
  String get clientHomeServicesTitle;

  /// No description provided for @clientHomeRecommendedLawyers.
  ///
  /// In ar, this message translates to:
  /// **'محامون موصى بهم'**
  String get clientHomeRecommendedLawyers;

  /// No description provided for @serviceCreateContract.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء عقد'**
  String get serviceCreateContract;

  /// No description provided for @serviceAnalyzeContract.
  ///
  /// In ar, this message translates to:
  /// **'تحليل العقد'**
  String get serviceAnalyzeContract;

  /// No description provided for @serviceFindLawyer.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن محامٍ'**
  String get serviceFindLawyer;

  /// No description provided for @clientNotificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get clientNotificationsTitle;

  /// No description provided for @clientHomeHeroTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف يمكنني مساعدتك قانونيًا اليوم؟'**
  String get clientHomeHeroTitle;

  /// No description provided for @clientHomeSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن خدمة قانونية...'**
  String get clientHomeSearchHint;

  /// No description provided for @clientHomeSearchEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get clientHomeSearchEmptyTitle;

  /// No description provided for @clientHomeSearchEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمة بحث مختلفة'**
  String get clientHomeSearchEmptyMessage;

  /// No description provided for @clientHomeQuickAskAi.
  ///
  /// In ar, this message translates to:
  /// **'اسأل الـ AI'**
  String get clientHomeQuickAskAi;

  /// No description provided for @clientHomeQuickCreateContract.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء عقد'**
  String get clientHomeQuickCreateContract;

  /// No description provided for @clientHomeQuickFindLawyer.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن محام'**
  String get clientHomeQuickFindLawyer;

  /// No description provided for @serviceAnalyzeContractDesc.
  ///
  /// In ar, this message translates to:
  /// **'ارفع العقد ودع الذكاء الاصطناعي يساعدك'**
  String get serviceAnalyzeContractDesc;

  /// No description provided for @serviceSmartContracts.
  ///
  /// In ar, this message translates to:
  /// **'العقود الذكية'**
  String get serviceSmartContracts;

  /// No description provided for @serviceSmartContractsDesc.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ عقداً قانونياً خلال دقائق'**
  String get serviceSmartContractsDesc;

  /// No description provided for @serviceBookLawyer.
  ///
  /// In ar, this message translates to:
  /// **'حجز محام'**
  String get serviceBookLawyer;

  /// No description provided for @serviceBookLawyerDesc.
  ///
  /// In ar, this message translates to:
  /// **'احجز استشارة مع محام متخصص'**
  String get serviceBookLawyerDesc;

  /// No description provided for @serviceGovDocuments.
  ///
  /// In ar, this message translates to:
  /// **'المستندات الحكومية'**
  String get serviceGovDocuments;

  /// No description provided for @serviceGovDocumentsDesc.
  ///
  /// In ar, this message translates to:
  /// **'اعرف الأوراق والخطوات المطلوبة'**
  String get serviceGovDocumentsDesc;

  /// No description provided for @clientHomeVaultTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخزنة الرقمية'**
  String get clientHomeVaultTitle;

  /// No description provided for @clientHomeVaultSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'جميع وثائقك، عقودك وتقاريرك المحفوظة'**
  String get clientHomeVaultSubtitle;

  /// No description provided for @clientHomeRecentActivity.
  ///
  /// In ar, this message translates to:
  /// **'آخر النشاطات'**
  String get clientHomeRecentActivity;

  /// No description provided for @contractsSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في عقودك...'**
  String get contractsSearchHint;

  /// No description provided for @contractsFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get contractsFilterAll;

  /// No description provided for @contractsSearchEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عقود مطابقة'**
  String get contractsSearchEmptyTitle;

  /// No description provided for @contractsSearchEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمة بحث أو تصفية مختلفة'**
  String get contractsSearchEmptyMessage;

  /// No description provided for @contractStatusDraft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get contractStatusDraft;

  /// No description provided for @contractStatusPendingSignature.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار التوقيع'**
  String get contractStatusPendingSignature;

  /// No description provided for @contractStatusSigned.
  ///
  /// In ar, this message translates to:
  /// **'تم التوقيع'**
  String get contractStatusSigned;

  /// No description provided for @contractStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get contractStatusCompleted;

  /// No description provided for @contractStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغى'**
  String get contractStatusCancelled;

  /// No description provided for @contractCategoryEmployment.
  ///
  /// In ar, this message translates to:
  /// **'عقد عمل'**
  String get contractCategoryEmployment;

  /// No description provided for @contractCategorySale.
  ///
  /// In ar, this message translates to:
  /// **'عقد بيع'**
  String get contractCategorySale;

  /// No description provided for @contractCategoryRental.
  ///
  /// In ar, this message translates to:
  /// **'عقد إيجار'**
  String get contractCategoryRental;

  /// No description provided for @contractCategoryPartnership.
  ///
  /// In ar, this message translates to:
  /// **'عقد شراكة'**
  String get contractCategoryPartnership;

  /// No description provided for @contractCategoryNda.
  ///
  /// In ar, this message translates to:
  /// **'اتفاقية عدم إفصاح'**
  String get contractCategoryNda;

  /// No description provided for @contractCategoryServiceAgreement.
  ///
  /// In ar, this message translates to:
  /// **'عقد خدمات'**
  String get contractCategoryServiceAgreement;

  /// No description provided for @contractCategoryOther.
  ///
  /// In ar, this message translates to:
  /// **'عقد آخر'**
  String get contractCategoryOther;

  /// No description provided for @contractTypeSelectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع العقد'**
  String get contractTypeSelectionTitle;

  /// No description provided for @contractTypeSelectionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع العقد الذي تريد إنشاءه'**
  String get contractTypeSelectionSubtitle;

  /// No description provided for @contractTypeSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن نوع العقد...'**
  String get contractTypeSearchHint;

  /// No description provided for @contractTypeSearchEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أنواع عقود مطابقة لبحثك'**
  String get contractTypeSearchEmptyMessage;

  /// No description provided for @contractFormTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعبئة بيانات العقد'**
  String get contractFormTitle;

  /// No description provided for @validationInvalidNumber.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال رقم صحيح'**
  String get validationInvalidNumber;

  /// No description provided for @validationInvalidDate.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء اختيار تاريخ صحيح'**
  String get validationInvalidDate;

  /// No description provided for @contractPreviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'معاينة العقد'**
  String get contractPreviewTitle;

  /// No description provided for @contractPreviewParties.
  ///
  /// In ar, this message translates to:
  /// **'الأطراف'**
  String get contractPreviewParties;

  /// No description provided for @contractPreviewDetails.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get contractPreviewDetails;

  /// No description provided for @contractPreviewSaveDraft.
  ///
  /// In ar, this message translates to:
  /// **'حفظ كمسودة'**
  String get contractPreviewSaveDraft;

  /// No description provided for @contractPreviewGenerate.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء العقد'**
  String get contractPreviewGenerate;

  /// No description provided for @contractGeneratedSuccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء العقد بنجاح!'**
  String get contractGeneratedSuccessTitle;

  /// No description provided for @contractGeneratedSuccessMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ عقدك في الخزنة الرقمية'**
  String get contractGeneratedSuccessMessage;

  /// No description provided for @contractDraftSavedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ العقد كمسودة'**
  String get contractDraftSavedMessage;

  /// No description provided for @contractViewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get contractViewDetails;

  /// No description provided for @contractDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل العقد'**
  String get contractDetailsTitle;

  /// No description provided for @contractDetailsType.
  ///
  /// In ar, this message translates to:
  /// **'نوع العقد'**
  String get contractDetailsType;

  /// No description provided for @contractDetailsStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get contractDetailsStatus;

  /// No description provided for @contractDetailsCreated.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإنشاء'**
  String get contractDetailsCreated;

  /// No description provided for @contractDetailsUpdated.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث'**
  String get contractDetailsUpdated;

  /// No description provided for @contractDetailsContent.
  ///
  /// In ar, this message translates to:
  /// **'محتوى العقد'**
  String get contractDetailsContent;

  /// No description provided for @contractDetailsDeleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المسودة'**
  String get contractDetailsDeleteConfirmTitle;

  /// No description provided for @contractDetailsDeleteConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد حذف هذه المسودة؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get contractDetailsDeleteConfirmMessage;

  /// No description provided for @contractDetailsDeletedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المسودة'**
  String get contractDetailsDeletedMessage;

  /// No description provided for @contractSignButton.
  ///
  /// In ar, this message translates to:
  /// **'توقيع إلكتروني'**
  String get contractSignButton;

  /// No description provided for @contractSignTitle.
  ///
  /// In ar, this message translates to:
  /// **'التوقيع الإلكتروني'**
  String get contractSignTitle;

  /// No description provided for @contractSignTabSaved.
  ///
  /// In ar, this message translates to:
  /// **'توقيع محفوظ'**
  String get contractSignTabSaved;

  /// No description provided for @contractSignNoSavedSignature.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد توقيع محفوظ — أضف واحداً من حسابي أولاً'**
  String get contractSignNoSavedSignature;

  /// No description provided for @contractSignLegalNotice.
  ///
  /// In ar, this message translates to:
  /// **'بالتوقيع على هذا المستند، فإنك توافق قانونياً على جميع البنود الواردة فيه وفق أحكام قانون المعاملات الإلكترونية الأردني.'**
  String get contractSignLegalNotice;

  /// No description provided for @contractSignConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التوقيع'**
  String get contractSignConfirm;

  /// No description provided for @contractSignedSuccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم توقيع العقد بنجاح!'**
  String get contractSignedSuccessTitle;

  /// No description provided for @contractSignedSuccessMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم اعتماد توقيعك وحفظ النسخة الموقعة بأمان في خزنتك الرقمية.'**
  String get contractSignedSuccessMessage;

  /// No description provided for @documentsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مستندات بعد'**
  String get documentsEmptyTitle;

  /// No description provided for @documentsEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر عقودك ومستنداتك هنا بعد إنشائها'**
  String get documentsEmptyMessage;

  /// No description provided for @documentsSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في مستنداتك...'**
  String get documentsSearchHint;

  /// No description provided for @documentsSearchEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مستندات مطابقة'**
  String get documentsSearchEmptyTitle;

  /// No description provided for @documentsSearchEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمة بحث مختلفة'**
  String get documentsSearchEmptyMessage;

  /// Welcome message shown on home screen with the user's name
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا، {name}'**
  String homeWelcome(String name);

  /// No description provided for @commonJustNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get commonJustNow;

  /// No description provided for @commonMinutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} د'**
  String commonMinutesAgo(int count);

  /// No description provided for @commonHoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} س'**
  String commonHoursAgo(int count);

  /// No description provided for @commonDaysAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} يوم'**
  String commonDaysAgo(int count);

  /// No description provided for @commonReset.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين'**
  String get commonReset;

  /// No description provided for @navConsultations.
  ///
  /// In ar, this message translates to:
  /// **'الاستشارات'**
  String get navConsultations;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تعليم الكل كمقروء'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد جديد الآن، ستظهر إشعاراتك هنا'**
  String get notificationsEmptyMessage;

  /// No description provided for @notificationUnavailableForRole.
  ///
  /// In ar, this message translates to:
  /// **'هذا الإشعار غير متاح من حسابك الحالي'**
  String get notificationUnavailableForRole;

  /// No description provided for @specialtyCommercial.
  ///
  /// In ar, this message translates to:
  /// **'قانون تجاري'**
  String get specialtyCommercial;

  /// No description provided for @specialtyPersonalStatus.
  ///
  /// In ar, this message translates to:
  /// **'أحوال شخصية'**
  String get specialtyPersonalStatus;

  /// No description provided for @specialtyCriminal.
  ///
  /// In ar, this message translates to:
  /// **'قانون جنائي'**
  String get specialtyCriminal;

  /// No description provided for @specialtyLabor.
  ///
  /// In ar, this message translates to:
  /// **'قانون عمل'**
  String get specialtyLabor;

  /// No description provided for @specialtyRealEstate.
  ///
  /// In ar, this message translates to:
  /// **'عقارات'**
  String get specialtyRealEstate;

  /// No description provided for @specialtyCorporate.
  ///
  /// In ar, this message translates to:
  /// **'قانون شركات'**
  String get specialtyCorporate;

  /// No description provided for @specialtyIntellectualProperty.
  ///
  /// In ar, this message translates to:
  /// **'ملكية فكرية'**
  String get specialtyIntellectualProperty;

  /// No description provided for @specialtyGeneral.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get specialtyGeneral;

  /// No description provided for @consultationTypeVideo.
  ///
  /// In ar, this message translates to:
  /// **'مكالمة فيديو'**
  String get consultationTypeVideo;

  /// No description provided for @consultationTypeVoice.
  ///
  /// In ar, this message translates to:
  /// **'مكالمة صوتية'**
  String get consultationTypeVoice;

  /// No description provided for @consultationTypeWritten.
  ///
  /// In ar, this message translates to:
  /// **'استشارة مكتوبة'**
  String get consultationTypeWritten;

  /// No description provided for @lawyersSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن محامٍ بالاسم...'**
  String get lawyersSearchHint;

  /// No description provided for @lawyersEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد محامون'**
  String get lawyersEmptyTitle;

  /// No description provided for @lawyersEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'تحقق لاحقًا من توفر المحامين'**
  String get lawyersEmptyMessage;

  /// No description provided for @lawyersSearchEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد محامون مطابقون'**
  String get lawyersSearchEmptyTitle;

  /// No description provided for @lawyersSearchEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمة بحث أو تصفية مختلفة'**
  String get lawyersSearchEmptyMessage;

  /// No description provided for @lawyersFilterTitle.
  ///
  /// In ar, this message translates to:
  /// **'التصفية'**
  String get lawyersFilterTitle;

  /// No description provided for @lawyersFilterRating.
  ///
  /// In ar, this message translates to:
  /// **'التقييم'**
  String get lawyersFilterRating;

  /// No description provided for @lawyersFilterAvailability.
  ///
  /// In ar, this message translates to:
  /// **'التوفر'**
  String get lawyersFilterAvailability;

  /// No description provided for @lawyersFilterApply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق التصفية'**
  String get lawyersFilterApply;

  /// No description provided for @lawyerAvailableToday.
  ///
  /// In ar, this message translates to:
  /// **'متاح اليوم'**
  String get lawyerAvailableToday;

  /// No description provided for @lawyerAvailableThisWeek.
  ///
  /// In ar, this message translates to:
  /// **'متاح هذا الأسبوع'**
  String get lawyerAvailableThisWeek;

  /// No description provided for @lawyerAvailableLater.
  ///
  /// In ar, this message translates to:
  /// **'متاح لاحقًا'**
  String get lawyerAvailableLater;

  /// No description provided for @lawyerYearsExperience.
  ///
  /// In ar, this message translates to:
  /// **'{count} سنوات خبرة'**
  String lawyerYearsExperience(int count);

  /// No description provided for @lawyerProfileTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي للمحامي'**
  String get lawyerProfileTitle;

  /// No description provided for @lawyerAvailabilityBadge.
  ///
  /// In ar, this message translates to:
  /// **'{availability}'**
  String lawyerAvailabilityBadge(String availability);

  /// No description provided for @lawyerAboutTitle.
  ///
  /// In ar, this message translates to:
  /// **'نبذة'**
  String get lawyerAboutTitle;

  /// No description provided for @lawyerSpecialtiesTitle.
  ///
  /// In ar, this message translates to:
  /// **'التخصصات'**
  String get lawyerSpecialtiesTitle;

  /// No description provided for @lawyerConsultationTypesTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنواع الاستشارة والأسعار'**
  String get lawyerConsultationTypesTitle;

  /// No description provided for @lawyerExperienceTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخبرة'**
  String get lawyerExperienceTitle;

  /// No description provided for @lawyerStatSatisfaction.
  ///
  /// In ar, this message translates to:
  /// **'رضا العملاء'**
  String get lawyerStatSatisfaction;

  /// No description provided for @lawyerStatConsultations.
  ///
  /// In ar, this message translates to:
  /// **'الاستشارات'**
  String get lawyerStatConsultations;

  /// No description provided for @lawyerStatYears.
  ///
  /// In ar, this message translates to:
  /// **'سنوات الخبرة'**
  String get lawyerStatYears;

  /// No description provided for @lawyerReviewsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقييمات العملاء'**
  String get lawyerReviewsTitle;

  /// No description provided for @lawyerBookConsultation.
  ///
  /// In ar, this message translates to:
  /// **'حجز استشارة'**
  String get lawyerBookConsultation;

  /// No description provided for @lawyerPriceSar.
  ///
  /// In ar, this message translates to:
  /// **'{amount} د.أ'**
  String lawyerPriceSar(String amount);

  /// No description provided for @bookingSelectTypeTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الاستشارة'**
  String get bookingSelectTypeTitle;

  /// No description provided for @bookingSelectDateTimeTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر التاريخ والوقت'**
  String get bookingSelectDateTimeTitle;

  /// No description provided for @bookingNoSlotsMessage.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواعيد متاحة في هذا اليوم'**
  String get bookingNoSlotsMessage;

  /// No description provided for @bookingDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الحجز'**
  String get bookingDetailsTitle;

  /// No description provided for @bookingNotesLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get bookingNotesLabel;

  /// No description provided for @bookingNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'صف باختصار ما تود مناقشته...'**
  String get bookingNotesHint;

  /// No description provided for @bookingConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحجز والدفع'**
  String get bookingConfirm;

  /// No description provided for @bookingSuccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الحجز!'**
  String get bookingSuccessTitle;

  /// No description provided for @bookingSuccessMessage.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا طلبك إلى المحامي، سيتم إشعارك فور تأكيده'**
  String get bookingSuccessMessage;

  /// No description provided for @bookingViewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض الحجز'**
  String get bookingViewDetails;

  /// No description provided for @paymentTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get paymentTitle;

  /// No description provided for @paymentSummaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الفاتورة'**
  String get paymentSummaryTitle;

  /// No description provided for @paymentTotalLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get paymentTotalLabel;

  /// No description provided for @paymentMethodCard.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة بنكية'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodDigitalWallet.
  ///
  /// In ar, this message translates to:
  /// **'Apple / G Pay'**
  String get paymentMethodDigitalWallet;

  /// No description provided for @paymentCardNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم البطاقة'**
  String get paymentCardNumberLabel;

  /// No description provided for @paymentExpiryLabel.
  ///
  /// In ar, this message translates to:
  /// **'الشهر / السنة'**
  String get paymentExpiryLabel;

  /// No description provided for @paymentCvvLabel.
  ///
  /// In ar, this message translates to:
  /// **'رمز CVV'**
  String get paymentCvvLabel;

  /// No description provided for @paymentFirstNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأول'**
  String get paymentFirstNameLabel;

  /// No description provided for @paymentLastNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأخير'**
  String get paymentLastNameLabel;

  /// No description provided for @paymentPayNow.
  ///
  /// In ar, this message translates to:
  /// **'ادفع الآن — {amount} د.أ'**
  String paymentPayNow(String amount);

  /// No description provided for @paymentApplePayTitle.
  ///
  /// In ar, this message translates to:
  /// **'Apple Pay'**
  String get paymentApplePayTitle;

  /// No description provided for @paymentApplePaySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ادفع بأمان وبنقرة واحدة عبر محفظتك الرقمية'**
  String get paymentApplePaySubtitle;

  /// No description provided for @paymentApplePayNoCardSharing.
  ///
  /// In ar, this message translates to:
  /// **'لا تُشارك بياناتك'**
  String get paymentApplePayNoCardSharing;

  /// No description provided for @paymentApplePayInstant.
  ///
  /// In ar, this message translates to:
  /// **'دفع فوري'**
  String get paymentApplePayInstant;

  /// No description provided for @paymentPayWithApple.
  ///
  /// In ar, this message translates to:
  /// **'Pay with Apple Pay — {amount} د.أ'**
  String paymentPayWithApple(String amount);

  /// No description provided for @paymentSuccessMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم الدفع بنجاح'**
  String get paymentSuccessMessage;

  /// No description provided for @paymentCardNumberInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم بطاقة صحيح'**
  String get paymentCardNumberInvalid;

  /// No description provided for @paymentExpiryInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل تاريخ صلاحية صحيح وغير منتهٍ (MM/YY)'**
  String get paymentExpiryInvalid;

  /// No description provided for @paymentCvvInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز CVV صحيح'**
  String get paymentCvvInvalid;

  /// No description provided for @paymentFirstNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الاسم الأول'**
  String get paymentFirstNameRequired;

  /// No description provided for @paymentLastNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الاسم الأخير'**
  String get paymentLastNameRequired;

  /// No description provided for @paymentCardTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة خصم / ائتمان'**
  String get paymentCardTypeLabel;

  /// No description provided for @consultationDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الاستشارة'**
  String get consultationDetailsTitle;

  /// No description provided for @consultationStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الموافقة'**
  String get consultationStatusPending;

  /// No description provided for @consultationStatusUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'قادمة'**
  String get consultationStatusUpcoming;

  /// No description provided for @consultationStatusWaiting.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار البدء'**
  String get consultationStatusWaiting;

  /// No description provided for @consultationStatusReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهزة'**
  String get consultationStatusReady;

  /// No description provided for @consultationStatusConnecting.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الاتصال'**
  String get consultationStatusConnecting;

  /// No description provided for @consultationStatusActive.
  ///
  /// In ar, this message translates to:
  /// **'مباشرة'**
  String get consultationStatusActive;

  /// No description provided for @consultationStatusEnded.
  ///
  /// In ar, this message translates to:
  /// **'انتهت'**
  String get consultationStatusEnded;

  /// No description provided for @consultationStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get consultationStatusCompleted;

  /// No description provided for @consultationStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get consultationStatusCancelled;

  /// No description provided for @consultationStatusRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضة'**
  String get consultationStatusRejected;

  /// No description provided for @consultationStatusMissed.
  ///
  /// In ar, this message translates to:
  /// **'فائتة'**
  String get consultationStatusMissed;

  /// No description provided for @consultationStatusFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشلت'**
  String get consultationStatusFailed;

  /// No description provided for @consultationsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد شيء هنا بعد'**
  String get consultationsEmptyTitle;

  /// No description provided for @consultationsEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر هنا الاستشارات ضمن هذا التصنيف'**
  String get consultationsEmptyMessage;

  /// No description provided for @consultationCancelConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الاستشارة'**
  String get consultationCancelConfirmTitle;

  /// No description provided for @consultationCancelConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد إلغاء هذه الاستشارة؟'**
  String get consultationCancelConfirmMessage;

  /// No description provided for @consultationReschedule.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الجدولة'**
  String get consultationReschedule;

  /// No description provided for @consultationCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الاستشارة'**
  String get consultationCancel;

  /// No description provided for @consultationEnd.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الاستشارة'**
  String get consultationEnd;

  /// No description provided for @consultationMessageHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالة...'**
  String get consultationMessageHint;

  /// No description provided for @notificationConsultationBookedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الاستشارة'**
  String get notificationConsultationBookedTitle;

  /// No description provided for @notificationConsultationBookedBody.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار موافقة المحامي {lawyerName} على طلب استشارتك'**
  String notificationConsultationBookedBody(String lawyerName);

  /// No description provided for @notificationConsultationAcceptedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول طلب الاستشارة'**
  String get notificationConsultationAcceptedTitle;

  /// No description provided for @notificationConsultationAcceptedBody.
  ///
  /// In ar, this message translates to:
  /// **'وافق المحامي {lawyerName} على طلب استشارتك'**
  String notificationConsultationAcceptedBody(String lawyerName);

  /// No description provided for @notificationConsultationRejectedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض طلب الاستشارة'**
  String get notificationConsultationRejectedTitle;

  /// No description provided for @notificationConsultationRejectedBody.
  ///
  /// In ar, this message translates to:
  /// **'اعتذر المحامي {lawyerName} عن طلب استشارتك'**
  String notificationConsultationRejectedBody(String lawyerName);

  /// No description provided for @notificationConsultationCancelledTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الاستشارة'**
  String get notificationConsultationCancelledTitle;

  /// No description provided for @notificationConsultationCancelledBody.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء موعد استشارتك'**
  String get notificationConsultationCancelledBody;

  /// No description provided for @notificationConsultationCompletedTitle.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الاستشارة'**
  String get notificationConsultationCompletedTitle;

  /// No description provided for @notificationConsultationCompletedBody.
  ///
  /// In ar, this message translates to:
  /// **'انتهت جلسة استشارتك بنجاح'**
  String get notificationConsultationCompletedBody;

  /// No description provided for @notificationNewMessageTitle.
  ///
  /// In ar, this message translates to:
  /// **'رسالة جديدة'**
  String get notificationNewMessageTitle;

  /// No description provided for @notificationNewAttachmentBody.
  ///
  /// In ar, this message translates to:
  /// **'أرسل لك مرفقًا جديدًا'**
  String get notificationNewAttachmentBody;

  /// No description provided for @notificationDocumentUploadedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم رفع مستند'**
  String get notificationDocumentUploadedTitle;

  /// No description provided for @notificationDocumentUploadedBody.
  ///
  /// In ar, this message translates to:
  /// **'\"{title}\" أُضيف إلى خزنتك الرقمية'**
  String notificationDocumentUploadedBody(String title);

  /// No description provided for @notificationAiAnalysisTitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل تحليل العقد'**
  String get notificationAiAnalysisTitle;

  /// No description provided for @notificationAiAnalysisBody.
  ///
  /// In ar, this message translates to:
  /// **'تم الانتهاء من تحليل \"{documentTitle}\"'**
  String notificationAiAnalysisBody(String documentTitle);

  /// No description provided for @consultationRoomTitle.
  ///
  /// In ar, this message translates to:
  /// **'غرفة انتظار الاستشارة'**
  String get consultationRoomTitle;

  /// No description provided for @consultationRoomEnterAction.
  ///
  /// In ar, this message translates to:
  /// **'الدخول إلى الاستشارة'**
  String get consultationRoomEnterAction;

  /// No description provided for @consultationRoomBackAction.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get consultationRoomBackAction;

  /// No description provided for @consultationRoomTooEarlyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لم يحن الوقت بعد'**
  String get consultationRoomTooEarlyTitle;

  /// No description provided for @consultationRoomTooEarlyMessage.
  ///
  /// In ar, this message translates to:
  /// **'ستُفتح الاستشارة قبل 15 دقيقة من الموعد المحدد.'**
  String get consultationRoomTooEarlyMessage;

  /// No description provided for @consultationRoomStartsIn.
  ///
  /// In ar, this message translates to:
  /// **'يبدأ خلال {remaining}'**
  String consultationRoomStartsIn(String remaining);

  /// No description provided for @consultationRoomCountdownDays.
  ///
  /// In ar, this message translates to:
  /// **'{days} يوم'**
  String consultationRoomCountdownDays(int days);

  /// No description provided for @consultationRoomCountdownHours.
  ///
  /// In ar, this message translates to:
  /// **'{hours} س'**
  String consultationRoomCountdownHours(int hours);

  /// No description provided for @consultationRoomCountdownMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} د'**
  String consultationRoomCountdownMinutes(int minutes);

  /// No description provided for @consultationRoomReadyTitle.
  ///
  /// In ar, this message translates to:
  /// **'جاهز للانضمام'**
  String get consultationRoomReadyTitle;

  /// No description provided for @consultationRoomReadyMessage.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك الانضمام إلى هذه الاستشارة الآن.'**
  String get consultationRoomReadyMessage;

  /// No description provided for @consultationRoomJoinAction.
  ///
  /// In ar, this message translates to:
  /// **'الانضمام إلى الاستشارة'**
  String get consultationRoomJoinAction;

  /// No description provided for @consultationRoomJoinFailedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر بدء الجلسة. يرجى المحاولة مرة أخرى.'**
  String get consultationRoomJoinFailedMessage;

  /// No description provided for @consultationRoomMissedTitle.
  ///
  /// In ar, this message translates to:
  /// **'فاتت الاستشارة'**
  String get consultationRoomMissedTitle;

  /// No description provided for @consultationRoomMissedMessage.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الانضمام إلى هذه الاستشارة.'**
  String get consultationRoomMissedMessage;

  /// No description provided for @consultationRoomUnavailableMessage.
  ///
  /// In ar, this message translates to:
  /// **'لم تعد هذه الاستشارة متاحة للانضمام إليها.'**
  String get consultationRoomUnavailableMessage;

  /// No description provided for @consultationRoomSimulateConnectionLossAction.
  ///
  /// In ar, this message translates to:
  /// **'محاكاة انقطاع الاتصال (للمطورين)'**
  String get consultationRoomSimulateConnectionLossAction;

  /// No description provided for @chatOpenAction.
  ///
  /// In ar, this message translates to:
  /// **'فتح المحادثة'**
  String get chatOpenAction;

  /// No description provided for @chatViewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل الاستشارة'**
  String get chatViewDetails;

  /// No description provided for @chatAttachmentTooltip.
  ///
  /// In ar, this message translates to:
  /// **'إرفاق'**
  String get chatAttachmentTooltip;

  /// No description provided for @chatAttachImage.
  ///
  /// In ar, this message translates to:
  /// **'صورة من المعرض'**
  String get chatAttachImage;

  /// No description provided for @chatAttachFile.
  ///
  /// In ar, this message translates to:
  /// **'إرفاق ملف (تجريبي)'**
  String get chatAttachFile;

  /// No description provided for @chatAttachedFileSnackbar.
  ///
  /// In ar, this message translates to:
  /// **'تم إرفاق {fileName}'**
  String chatAttachedFileSnackbar(String fileName);

  /// No description provided for @chatFileDownloadedMock.
  ///
  /// In ar, this message translates to:
  /// **'تم التنزيل (تجريبي): {fileName}'**
  String chatFileDownloadedMock(String fileName);

  /// No description provided for @chatImagePreviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'صورة'**
  String get chatImagePreviewTitle;

  /// No description provided for @chatImageUnavailableMock.
  ///
  /// In ar, this message translates to:
  /// **'المعاينة غير متاحة لهذه الصورة التجريبية'**
  String get chatImageUnavailableMock;

  /// No description provided for @chatImagePickError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح معرض الصور، يرجى المحاولة مرة أخرى.'**
  String get chatImagePickError;

  /// No description provided for @chatSendAttachment.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get chatSendAttachment;

  /// No description provided for @chatSendFailedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إرسال الرسالة.'**
  String get chatSendFailedMessage;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رسائل بعد'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'أرسل رسالة لبدء المحادثة'**
  String get chatEmptyMessage;

  /// No description provided for @chatDayToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get chatDayToday;

  /// No description provided for @chatDayYesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get chatDayYesterday;

  /// No description provided for @chatTypingIndicatorLabel.
  ///
  /// In ar, this message translates to:
  /// **'يكتب الآن…'**
  String get chatTypingIndicatorLabel;

  /// No description provided for @chatTimeRemaining.
  ///
  /// In ar, this message translates to:
  /// **'متبقٍ {time}'**
  String chatTimeRemaining(String time);

  /// No description provided for @chatFirstWarning.
  ///
  /// In ar, this message translates to:
  /// **'ستنتهي الجلسة قريبًا'**
  String get chatFirstWarning;

  /// No description provided for @chatFinalWarning.
  ///
  /// In ar, this message translates to:
  /// **'تبقّت أقل من دقيقة'**
  String get chatFinalWarning;

  /// No description provided for @chatEndConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الاستشارة'**
  String get chatEndConfirmTitle;

  /// No description provided for @chatEndConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيؤدي هذا إلى إنهاء الجلسة لك وللطرف الآخر. ستظل قادرًا على الاطلاع على المحادثة لاحقًا.'**
  String get chatEndConfirmMessage;

  /// No description provided for @chatEndedBannerMessage.
  ///
  /// In ar, this message translates to:
  /// **'انتهت هذه الاستشارة'**
  String get chatEndedBannerMessage;

  /// No description provided for @chatDurationLabel.
  ///
  /// In ar, this message translates to:
  /// **'المدة: {duration}'**
  String chatDurationLabel(String duration);

  /// No description provided for @chatOpensAt.
  ///
  /// In ar, this message translates to:
  /// **'تُفتح المحادثة الساعة {time}'**
  String chatOpensAt(String time);

  /// No description provided for @chatStartsIn.
  ///
  /// In ar, this message translates to:
  /// **'يبدأ خلال {remaining}'**
  String chatStartsIn(String remaining);

  /// No description provided for @chatCountdownDays.
  ///
  /// In ar, this message translates to:
  /// **'{days} يوم'**
  String chatCountdownDays(int days);

  /// No description provided for @chatCountdownHours.
  ///
  /// In ar, this message translates to:
  /// **'{hours} س'**
  String chatCountdownHours(int hours);

  /// No description provided for @chatCountdownMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} د'**
  String chatCountdownMinutes(int minutes);

  /// No description provided for @chatInvalidConsultationMessage.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر العثور على هذه الاستشارة.'**
  String get chatInvalidConsultationMessage;

  /// No description provided for @chatReturnToCallAction.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى المكالمة — لا تزال نشطة'**
  String get chatReturnToCallAction;

  /// No description provided for @chatMockReply1.
  ///
  /// In ar, this message translates to:
  /// **'شكرًا لمشاركة هذه التفاصيل. بناءً على ما ذكرته، أنصح بمراجعة البند المعني معًا قبل اتخاذ أي خطوة تالية. هل يمكنك إرسال الجزء المحدد من المستند الذي تقصده؟'**
  String get chatMockReply1;

  /// No description provided for @chatMockReply2.
  ///
  /// In ar, this message translates to:
  /// **'هذا استفسار وجيه. بشكل عام، يمنحك النظام مهلة معقولة للرد رسميًا، لكن المدة الدقيقة تعتمد على بنود العقد. دعني أطّلع على التفاصيل بدقة وأعود إليك قريبًا.'**
  String get chatMockReply2;

  /// No description provided for @chatMockReply3.
  ///
  /// In ar, this message translates to:
  /// **'أتفهم أهمية الأمر بالنسبة لك. اقتراحي هو الانتظار قبل توقيع أي شيء حتى نتأكد من أن بند المسؤولية مصاغ لصالحك. سأعدّ لك اقتراح تعديل لمراجعته.'**
  String get chatMockReply3;

  /// No description provided for @chatMockReply4.
  ///
  /// In ar, this message translates to:
  /// **'سؤال جيد. بناءً على حالات مشابهة، عادةً ما تُحل هذه النوعية من النزاعات بشكل أسرع عبر التفاوض المباشر بدلاً من اللجوء للقضاء مباشرة. هل ترغب أن أوضح لك خطوات هذا المسار؟'**
  String get chatMockReply4;

  /// No description provided for @chatMockReply5.
  ///
  /// In ar, this message translates to:
  /// **'تم الاطلاع، شكرًا لك. أحتاج بعض التفاصيل الإضافية حول تسلسل الأحداث لأقدّم لك رأيًا دقيقًا. هل يمكنك تأكيد تاريخ صدور الإشعار؟'**
  String get chatMockReply5;

  /// No description provided for @chatMockReply6.
  ///
  /// In ar, this message translates to:
  /// **'الأمر يبدو واضحًا نسبيًا، ولا أرى ما يعرّضك لمخاطر قانونية هنا، لكن أنصح بتوثيق الاتفاق كتابيًا لتفادي أي خلاف مستقبلي.'**
  String get chatMockReply6;

  /// No description provided for @voiceCallLabel.
  ///
  /// In ar, this message translates to:
  /// **'استشارة صوتية'**
  String get voiceCallLabel;

  /// No description provided for @voiceCallConnectingLabel.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الاتصال…'**
  String get voiceCallConnectingLabel;

  /// No description provided for @voiceCallStatusConnected.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get voiceCallStatusConnected;

  /// No description provided for @voiceCallStatusReconnecting.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الاتصال…'**
  String get voiceCallStatusReconnecting;

  /// No description provided for @voiceCallConnectionLostBanner.
  ///
  /// In ar, this message translates to:
  /// **'انقطع الاتصال'**
  String get voiceCallConnectionLostBanner;

  /// No description provided for @voiceCallReconnectingAttempt.
  ///
  /// In ar, this message translates to:
  /// **'المحاولة {attempt} من {max}'**
  String voiceCallReconnectingAttempt(int attempt, int max);

  /// No description provided for @voiceCallRetryNowAction.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة الآن'**
  String get voiceCallRetryNowAction;

  /// No description provided for @voiceCallUnavailableTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال'**
  String get voiceCallUnavailableTitle;

  /// No description provided for @voiceCallUnavailableMessage.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الوصول إلى {name} لهذه الاستشارة. يمكنك عرض التفاصيل أو المحاولة لاحقًا.'**
  String voiceCallUnavailableMessage(String name);

  /// No description provided for @voiceCallEndConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الاستشارة؟'**
  String get voiceCallEndConfirmTitle;

  /// No description provided for @voiceCallEndConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيؤدي هذا إلى إنهاء المكالمة لك وللطرف الآخر.'**
  String get voiceCallEndConfirmMessage;

  /// No description provided for @voiceCallEndCallAction.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء المكالمة'**
  String get voiceCallEndCallAction;

  /// No description provided for @voiceCallKeepCallAction.
  ///
  /// In ar, this message translates to:
  /// **'متابعة المكالمة'**
  String get voiceCallKeepCallAction;

  /// No description provided for @voiceCallMuteAction.
  ///
  /// In ar, this message translates to:
  /// **'كتم الصوت'**
  String get voiceCallMuteAction;

  /// No description provided for @voiceCallUnmuteAction.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الكتم'**
  String get voiceCallUnmuteAction;

  /// No description provided for @voiceCallSpeakerOnAction.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل السماعة'**
  String get voiceCallSpeakerOnAction;

  /// No description provided for @voiceCallSpeakerOffAction.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف السماعة'**
  String get voiceCallSpeakerOffAction;

  /// No description provided for @voiceCallEndedTitle.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الاستشارة'**
  String get voiceCallEndedTitle;

  /// No description provided for @voiceCallAutoEndedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم بلوغ الحد الأقصى لمدة الاستشارة.'**
  String get voiceCallAutoEndedMessage;

  /// No description provided for @voiceCallDoneAction.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get voiceCallDoneAction;

  /// No description provided for @videoCallLabel.
  ///
  /// In ar, this message translates to:
  /// **'استشارة فيديو'**
  String get videoCallLabel;

  /// No description provided for @videoCallCameraOnAction.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل الكاميرا'**
  String get videoCallCameraOnAction;

  /// No description provided for @videoCallCameraOffAction.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف الكاميرا'**
  String get videoCallCameraOffAction;

  /// No description provided for @videoCallCameraOffPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا متوقفة'**
  String get videoCallCameraOffPlaceholder;

  /// No description provided for @videoCallSwitchCameraAction.
  ///
  /// In ar, this message translates to:
  /// **'تبديل الكاميرا'**
  String get videoCallSwitchCameraAction;

  /// No description provided for @videoCallSwitchedToFrontCamera.
  ///
  /// In ar, this message translates to:
  /// **'تم التبديل إلى الكاميرا الأمامية'**
  String get videoCallSwitchedToFrontCamera;

  /// No description provided for @videoCallSwitchedToBackCamera.
  ///
  /// In ar, this message translates to:
  /// **'تم التبديل إلى الكاميرا الخلفية'**
  String get videoCallSwitchedToBackCamera;

  /// No description provided for @videoCallLocalVideoLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفيديو المحلي'**
  String get videoCallLocalVideoLabel;

  /// No description provided for @videoCallRemoteVideoLabel.
  ///
  /// In ar, this message translates to:
  /// **'فيديو الطرف الآخر'**
  String get videoCallRemoteVideoLabel;

  /// No description provided for @videoCallChatAction.
  ///
  /// In ar, this message translates to:
  /// **'الدردشة'**
  String get videoCallChatAction;

  /// No description provided for @videoCallEndedMessage.
  ///
  /// In ar, this message translates to:
  /// **'انتهى الفيديو'**
  String get videoCallEndedMessage;

  /// No description provided for @lawyerRequestsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الاستشارة'**
  String get lawyerRequestsTitle;

  /// No description provided for @lawyerRequestsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات معلقة'**
  String get lawyerRequestsEmptyTitle;

  /// No description provided for @lawyerRequestsEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر طلبات الاستشارة الجديدة هنا'**
  String get lawyerRequestsEmptyMessage;

  /// No description provided for @lawyerRequestAccept.
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get lawyerRequestAccept;

  /// No description provided for @lawyerRequestReject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get lawyerRequestReject;

  /// No description provided for @lawyerRequestRejectConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفض الطلب'**
  String get lawyerRequestRejectConfirmTitle;

  /// No description provided for @lawyerRequestRejectConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد رفض طلب الاستشارة هذا؟'**
  String get lawyerRequestRejectConfirmMessage;

  /// No description provided for @lawyerRequestAcceptedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول الطلب'**
  String get lawyerRequestAcceptedMessage;

  /// No description provided for @lawyerRequestRejectedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الطلب'**
  String get lawyerRequestRejectedMessage;

  /// No description provided for @scheduleAddSlotTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة موعد متاح'**
  String get scheduleAddSlotTitle;

  /// No description provided for @scheduleRemoveSlotTitle.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الموعد'**
  String get scheduleRemoveSlotTitle;

  /// No description provided for @scheduleRemoveSlotMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد إزالة هذا الموعد المتاح؟'**
  String get scheduleRemoveSlotMessage;

  /// No description provided for @scheduleEmptyDayMessage.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواعيد متاحة في هذا اليوم'**
  String get scheduleEmptyDayMessage;

  /// No description provided for @scheduleSlotBooked.
  ///
  /// In ar, this message translates to:
  /// **'محجوز'**
  String get scheduleSlotBooked;

  /// No description provided for @scheduleSlotOpen.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get scheduleSlotOpen;

  /// No description provided for @scheduleActionFailedMessage.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما. يرجى المحاولة مرة أخرى.'**
  String get scheduleActionFailedMessage;

  /// No description provided for @scheduleSlotLinkedConsultationMissing.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر العثور على الاستشارة المرتبطة — سيتم عرض جميع الاستشارات بدلاً من ذلك.'**
  String get scheduleSlotLinkedConsultationMissing;

  /// No description provided for @aiRecentConversationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحادثات الأخيرة'**
  String get aiRecentConversationsTitle;

  /// No description provided for @aiNoConversationsMessage.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ محادثة للحصول على إجابات سريعة لأسئلتك القانونية'**
  String get aiNoConversationsMessage;

  /// No description provided for @aiDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'يقدم هذا المساعد معلومات قانونية عامة، وهو ليس بديلاً عن استشارة محامٍ مرخّص.'**
  String get aiDisclaimer;

  /// No description provided for @aiChatTitle.
  ///
  /// In ar, this message translates to:
  /// **'المساعد القانوني الذكي'**
  String get aiChatTitle;

  /// No description provided for @aiChatInputHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سؤالك...'**
  String get aiChatInputHint;

  /// No description provided for @aiNewConversation.
  ///
  /// In ar, this message translates to:
  /// **'محادثة جديدة'**
  String get aiNewConversation;

  /// No description provided for @aiClearConversationTitle.
  ///
  /// In ar, this message translates to:
  /// **'مسح المحادثة'**
  String get aiClearConversationTitle;

  /// No description provided for @aiClearConversationMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد مسح جميع الرسائل في هذه المحادثة؟'**
  String get aiClearConversationMessage;

  /// No description provided for @aiStatusAvailable.
  ///
  /// In ar, this message translates to:
  /// **'متاح الآن — يرد فوراً'**
  String get aiStatusAvailable;

  /// No description provided for @aiWelcomeMessage.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً! أنا مساعدك القانوني الذكي. يمكنني مساعدتك في فهم عقودك، معرفة حقوقك، وصياغة عقود جديدة. كيف يمكنني مساعدتك اليوم؟'**
  String get aiWelcomeMessage;

  /// No description provided for @aiQuickActionCreateContract.
  ///
  /// In ar, this message translates to:
  /// **'أريد إنشاء عقد'**
  String get aiQuickActionCreateContract;

  /// No description provided for @aiQuickActionHrIssue.
  ///
  /// In ar, this message translates to:
  /// **'لدي مشكلة مع موظف'**
  String get aiQuickActionHrIssue;

  /// No description provided for @aiQuickActionExplainClause.
  ///
  /// In ar, this message translates to:
  /// **'اشرح لي بند قانوني'**
  String get aiQuickActionExplainClause;

  /// No description provided for @aiContractWizardIntro.
  ///
  /// In ar, this message translates to:
  /// **'ممتاز! سأساعدك في صياغة عقد قانوني موثوق. اختر نوع العقد الذي تريد إنشاءه من القائمة:'**
  String get aiContractWizardIntro;

  /// No description provided for @aiContractWizardAskParty1.
  ///
  /// In ar, this message translates to:
  /// **'من هو الطرف الأول في العقد (صاحب العمل / المنشأة)؟'**
  String get aiContractWizardAskParty1;

  /// No description provided for @aiContractWizardAskParty2.
  ///
  /// In ar, this message translates to:
  /// **'تمام. من هو الطرف الثاني في العقد؟'**
  String get aiContractWizardAskParty2;

  /// No description provided for @aiContractWizardAskSubject.
  ///
  /// In ar, this message translates to:
  /// **'ما هو موضوع العقد أو المهام الرئيسية؟'**
  String get aiContractWizardAskSubject;

  /// No description provided for @aiContractWizardAskValue.
  ///
  /// In ar, this message translates to:
  /// **'أخيرًا، ما القيمة المالية ومدة العقد؟'**
  String get aiContractWizardAskValue;

  /// No description provided for @aiContractWizardDraftTitle.
  ///
  /// In ar, this message translates to:
  /// **'مسودة {type}'**
  String aiContractWizardDraftTitle(String type);

  /// No description provided for @aiContractWizardStatusDraft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة أولية — قيد المراجعة'**
  String get aiContractWizardStatusDraft;

  /// No description provided for @aiContractWizardStatusSent.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار توقيع الطرف الآخر'**
  String get aiContractWizardStatusSent;

  /// No description provided for @aiContractWizardPartyA.
  ///
  /// In ar, this message translates to:
  /// **'الطرف الأول'**
  String get aiContractWizardPartyA;

  /// No description provided for @aiContractWizardPartyB.
  ///
  /// In ar, this message translates to:
  /// **'الطرف الثاني'**
  String get aiContractWizardPartyB;

  /// No description provided for @aiContractWizardSubjectLabel.
  ///
  /// In ar, this message translates to:
  /// **'الموضوع'**
  String get aiContractWizardSubjectLabel;

  /// No description provided for @aiContractWizardValueLabel.
  ///
  /// In ar, this message translates to:
  /// **'القيمة والمدة'**
  String get aiContractWizardValueLabel;

  /// No description provided for @aiContractWizardSendSignature.
  ///
  /// In ar, this message translates to:
  /// **'إرسال طلب التوقيع'**
  String get aiContractWizardSendSignature;

  /// No description provided for @aiContractWizardSaveVault.
  ///
  /// In ar, this message translates to:
  /// **'حفظ في الخزنة'**
  String get aiContractWizardSaveVault;

  /// No description provided for @aiContractWizardSentMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب التوقيع بنجاح'**
  String get aiContractWizardSentMessage;

  /// No description provided for @aiContractWizardSavedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المسودة في خزنتك الرقمية'**
  String get aiContractWizardSavedMessage;

  /// No description provided for @aiContractWizardInputHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب إجابتك هنا...'**
  String get aiContractWizardInputHint;

  /// No description provided for @analysisAnalyzingMessage.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحليل المستند...'**
  String get analysisAnalyzingMessage;

  /// No description provided for @analysisUploadTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفع مستند'**
  String get analysisUploadTitle;

  /// No description provided for @analysisUploadLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المستند'**
  String get analysisUploadLabel;

  /// No description provided for @analysisUploadHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: عقد عمل - شركة الأفق'**
  String get analysisUploadHint;

  /// No description provided for @analysisAnalyzeButton.
  ///
  /// In ar, this message translates to:
  /// **'تحليل المستند'**
  String get analysisAnalyzeButton;

  /// No description provided for @analysisSelectFromVaultTitle.
  ///
  /// In ar, this message translates to:
  /// **'أو اختر من خزنتك الرقمية'**
  String get analysisSelectFromVaultTitle;

  /// No description provided for @analysisResultTitle.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة التحليل'**
  String get analysisResultTitle;

  /// No description provided for @analysisInvalidMessage.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر العثور على هذا التحليل.'**
  String get analysisInvalidMessage;

  /// No description provided for @analysisClausesTitle.
  ///
  /// In ar, this message translates to:
  /// **'البنود'**
  String get analysisClausesTitle;

  /// No description provided for @analysisAskAi.
  ///
  /// In ar, this message translates to:
  /// **'اسأل الذكاء الاصطناعي عن هذا البند'**
  String get analysisAskAi;

  /// No description provided for @analysisAskAboutClause.
  ///
  /// In ar, this message translates to:
  /// **'هل يمكنك شرح بند \"{clauseTitle}\" بمزيد من التفصيل؟'**
  String analysisAskAboutClause(String clauseTitle);

  /// No description provided for @analysisRiskLow.
  ///
  /// In ar, this message translates to:
  /// **'خطورة منخفضة'**
  String get analysisRiskLow;

  /// No description provided for @analysisRiskMedium.
  ///
  /// In ar, this message translates to:
  /// **'خطورة متوسطة'**
  String get analysisRiskMedium;

  /// No description provided for @analysisRiskHigh.
  ///
  /// In ar, this message translates to:
  /// **'خطورة عالية'**
  String get analysisRiskHigh;

  /// No description provided for @dashboardTodayAppointments.
  ///
  /// In ar, this message translates to:
  /// **'مواعيد اليوم'**
  String get dashboardTodayAppointments;

  /// No description provided for @dashboardPendingRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات معلقة'**
  String get dashboardPendingRequests;

  /// No description provided for @dashboardMonthEarnings.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get dashboardMonthEarnings;

  /// No description provided for @dashboardQuickActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة'**
  String get dashboardQuickActions;

  /// No description provided for @dashboardNoAppointmentsToday.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواعيد مجدولة اليوم'**
  String get dashboardNoAppointmentsToday;

  /// No description provided for @dashboardActiveSessionBadge.
  ///
  /// In ar, this message translates to:
  /// **'استشارة عاجلة — الآن'**
  String get dashboardActiveSessionBadge;

  /// No description provided for @dashboardActiveSessionStartingIn.
  ///
  /// In ar, this message translates to:
  /// **'تبدأ خلال {minutes} د'**
  String dashboardActiveSessionStartingIn(int minutes);

  /// No description provided for @dashboardActiveSessionReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهزة للبدء الآن'**
  String get dashboardActiveSessionReady;

  /// No description provided for @dashboardStartSession.
  ///
  /// In ar, this message translates to:
  /// **'بدء الجلسة'**
  String get dashboardStartSession;

  /// No description provided for @earningsBalance.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأرباح'**
  String get earningsBalance;

  /// No description provided for @earningsPending.
  ///
  /// In ar, this message translates to:
  /// **'{amount} بانتظار الاستشارات القادمة'**
  String earningsPending(String amount);

  /// No description provided for @earningsMonthlySummary.
  ///
  /// In ar, this message translates to:
  /// **'الملخص الشهري'**
  String get earningsMonthlySummary;

  /// No description provided for @earningsHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل الأرباح'**
  String get earningsHistoryTitle;

  /// No description provided for @earningsEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر هنا الاستشارات المكتملة'**
  String get earningsEmptyMessage;

  /// No description provided for @clientsSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن عميل...'**
  String get clientsSearchHint;

  /// No description provided for @clientsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عملاء بعد'**
  String get clientsEmptyTitle;

  /// No description provided for @clientsEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيظهر هنا العملاء الذين أجريت معهم استشارة'**
  String get clientsEmptyMessage;

  /// No description provided for @clientsConsultationCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} استشارات'**
  String clientsConsultationCount(int count);

  /// No description provided for @editProfileTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfileTitle;

  /// No description provided for @accountEditProfileSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الاسم والبريد الإلكتروني'**
  String get accountEditProfileSubtitle;

  /// No description provided for @lawyerEditProfileSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'النبذة والتخصصات والأسعار والتوثيق'**
  String get lawyerEditProfileSubtitle;

  /// No description provided for @profileUpdatedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الملف الشخصي'**
  String get profileUpdatedMessage;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل التغييرات؟'**
  String get unsavedChangesTitle;

  /// No description provided for @unsavedChangesMessage.
  ///
  /// In ar, this message translates to:
  /// **'لديك تغييرات غير محفوظة. هل أنت متأكد أنك تريد المغادرة دون حفظها؟'**
  String get unsavedChangesMessage;

  /// No description provided for @unsavedChangesDiscard.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get unsavedChangesDiscard;

  /// No description provided for @lawyerEditProfileTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف المهني'**
  String get lawyerEditProfileTitle;

  /// No description provided for @lawyerVerificationSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'التوثيق'**
  String get lawyerVerificationSectionTitle;

  /// No description provided for @lawyerVerified.
  ///
  /// In ar, this message translates to:
  /// **'موثّق'**
  String get lawyerVerified;

  /// No description provided for @lawyerPendingVerification.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get lawyerPendingVerification;

  /// No description provided for @lawyerNotVerified.
  ///
  /// In ar, this message translates to:
  /// **'غير موثّق بعد'**
  String get lawyerNotVerified;

  /// No description provided for @lawyerUploadVerificationDocument.
  ///
  /// In ar, this message translates to:
  /// **'رفع مستند توثيق'**
  String get lawyerUploadVerificationDocument;

  /// No description provided for @lawyerVerificationDocumentPreviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'معاينة المستند'**
  String get lawyerVerificationDocumentPreviewTitle;

  /// No description provided for @lawyerVerificationSubmittedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال المستند للمراجعة'**
  String get lawyerVerificationSubmittedMessage;

  /// No description provided for @lawyerPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get lawyerPriceLabel;

  /// No description provided for @lawyerBioRequiredError.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة نبذة تعريفية قبل الحفظ'**
  String get lawyerBioRequiredError;

  /// No description provided for @lawyerExperienceInvalidError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عدد سنوات صحيحًا'**
  String get lawyerExperienceInvalidError;

  /// No description provided for @lawyerPriceRequiredError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سعرًا أكبر من صفر'**
  String get lawyerPriceRequiredError;

  /// No description provided for @lawyerSelectSpecialtyError.
  ///
  /// In ar, this message translates to:
  /// **'اختر تخصصًا واحدًا على الأقل'**
  String get lawyerSelectSpecialtyError;

  /// No description provided for @lawyerSelectConsultationTypeError.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع استشارة واحدًا على الأقل تقدمه'**
  String get lawyerSelectConsultationTypeError;

  /// No description provided for @navTeam.
  ///
  /// In ar, this message translates to:
  /// **'الفريق'**
  String get navTeam;

  /// No description provided for @teamAddMemberTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عضو للفريق'**
  String get teamAddMemberTitle;

  /// No description provided for @teamAddMemberAction.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عضو'**
  String get teamAddMemberAction;

  /// No description provided for @teamRoleLabel.
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get teamRoleLabel;

  /// No description provided for @teamRoleAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مدير'**
  String get teamRoleAdmin;

  /// No description provided for @teamRoleManager.
  ///
  /// In ar, this message translates to:
  /// **'مشرف'**
  String get teamRoleManager;

  /// No description provided for @teamRoleMember.
  ///
  /// In ar, this message translates to:
  /// **'عضو'**
  String get teamRoleMember;

  /// No description provided for @teamMemberAddedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة عضو الفريق'**
  String get teamMemberAddedMessage;

  /// No description provided for @teamSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن عضو في الفريق...'**
  String get teamSearchHint;

  /// No description provided for @teamEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد أعضاء بعد'**
  String get teamEmptyTitle;

  /// No description provided for @teamEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'أضف أول عضو في فريقك للبدء'**
  String get teamEmptyMessage;

  /// No description provided for @teamJoinedOn.
  ///
  /// In ar, this message translates to:
  /// **'انضم في {date}'**
  String teamJoinedOn(String date);

  /// No description provided for @teamRemoveMember.
  ///
  /// In ar, this message translates to:
  /// **'إزالة العضو'**
  String get teamRemoveMember;

  /// No description provided for @teamRemoveConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إزالة العضو'**
  String get teamRemoveConfirmTitle;

  /// No description provided for @teamRemoveConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد إزالة هذا العضو من فريقك؟'**
  String get teamRemoveConfirmMessage;

  /// No description provided for @companyActiveConsultations.
  ///
  /// In ar, this message translates to:
  /// **'استشارات نشطة'**
  String get companyActiveConsultations;

  /// No description provided for @documentsUploadTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفع مستند'**
  String get documentsUploadTitle;

  /// No description provided for @documentsUploadHint.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد منتقي ملفات حقيقي في هذه المعاينة بعد — فقط أدخل عنوانًا للمستند.'**
  String get documentsUploadHint;

  /// No description provided for @documentsUploadLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المستند'**
  String get documentsUploadLabel;

  /// No description provided for @commonUpload.
  ///
  /// In ar, this message translates to:
  /// **'رفع'**
  String get commonUpload;

  /// No description provided for @documentsUploadedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم رفع المستند'**
  String get documentsUploadedMessage;

  /// No description provided for @documentsRenameTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تسمية المستند'**
  String get documentsRenameTitle;

  /// No description provided for @commonRename.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تسمية'**
  String get commonRename;

  /// No description provided for @documentsDeleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المستند'**
  String get documentsDeleteConfirmTitle;

  /// No description provided for @documentsDeleteConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد حذف هذا المستند؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get documentsDeleteConfirmMessage;

  /// No description provided for @documentsDeletedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المستند'**
  String get documentsDeletedMessage;

  /// No description provided for @accountNotificationsSetting.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get accountNotificationsSetting;

  /// No description provided for @accountStatDocuments.
  ///
  /// In ar, this message translates to:
  /// **'مستند'**
  String get accountStatDocuments;

  /// No description provided for @accountStatConsultations.
  ///
  /// In ar, this message translates to:
  /// **'استشارة'**
  String get accountStatConsultations;

  /// No description provided for @accountStatContracts.
  ///
  /// In ar, this message translates to:
  /// **'عقد'**
  String get accountStatContracts;

  /// No description provided for @subscriptionTierBasic.
  ///
  /// In ar, this message translates to:
  /// **'الباقة الأساسية'**
  String get subscriptionTierBasic;

  /// No description provided for @subscriptionTierPro.
  ///
  /// In ar, this message translates to:
  /// **'باقة الأعمال Pro'**
  String get subscriptionTierPro;

  /// No description provided for @subscriptionTierEnterprise.
  ///
  /// In ar, this message translates to:
  /// **'الباقة المؤسسية'**
  String get subscriptionTierEnterprise;

  /// No description provided for @subscriptionNoPlan.
  ///
  /// In ar, this message translates to:
  /// **'بدون اشتراك'**
  String get subscriptionNoPlan;

  /// No description provided for @accountMenuSubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات والباقات'**
  String get accountMenuSubscriptions;

  /// No description provided for @accountMenuPaymentMethods.
  ///
  /// In ar, this message translates to:
  /// **'طرق الدفع'**
  String get accountMenuPaymentMethods;

  /// No description provided for @accountMenuSavedSignature.
  ///
  /// In ar, this message translates to:
  /// **'التوقيع المحفوظ'**
  String get accountMenuSavedSignature;

  /// No description provided for @accountMenuBookings.
  ///
  /// In ar, this message translates to:
  /// **'الحجوزات'**
  String get accountMenuBookings;

  /// No description provided for @accountMenuInvoices.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير'**
  String get accountMenuInvoices;

  /// No description provided for @accountMenuSecurity.
  ///
  /// In ar, this message translates to:
  /// **'الأمان والخصوصية'**
  String get accountMenuSecurity;

  /// No description provided for @accountMenuHelp.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get accountMenuHelp;

  /// No description provided for @paymentMethodsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طرق الدفع'**
  String get paymentMethodsTitle;

  /// No description provided for @paymentMethodsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طرق دفع محفوظة'**
  String get paymentMethodsEmptyTitle;

  /// No description provided for @paymentMethodsEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'أضف بطاقة لتسهيل عمليات الدفع القادمة'**
  String get paymentMethodsEmptyMessage;

  /// No description provided for @paymentMethodsAddCard.
  ///
  /// In ar, this message translates to:
  /// **'إضافة بطاقة'**
  String get paymentMethodsAddCard;

  /// No description provided for @paymentMethodsSetDefault.
  ///
  /// In ar, this message translates to:
  /// **'تعيين كافتراضي'**
  String get paymentMethodsSetDefault;

  /// No description provided for @paymentMethodsDefaultBadge.
  ///
  /// In ar, this message translates to:
  /// **'افتراضي'**
  String get paymentMethodsDefaultBadge;

  /// No description provided for @paymentMethodsLast4Label.
  ///
  /// In ar, this message translates to:
  /// **'آخر 4 أرقام'**
  String get paymentMethodsLast4Label;

  /// No description provided for @paymentMethodsHolderLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم حامل البطاقة'**
  String get paymentMethodsHolderLabel;

  /// No description provided for @paymentMethodsAddedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة البطاقة بنجاح'**
  String get paymentMethodsAddedMessage;

  /// No description provided for @paymentMethodsLast4Invalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل 4 أرقام بالضبط'**
  String get paymentMethodsLast4Invalid;

  /// No description provided for @paymentMethodsHolderRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم حامل البطاقة'**
  String get paymentMethodsHolderRequired;

  /// No description provided for @paymentMethodsRemoveConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف البطاقة'**
  String get paymentMethodsRemoveConfirmTitle;

  /// No description provided for @paymentMethodsRemoveConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد حذف هذه البطاقة؟'**
  String get paymentMethodsRemoveConfirmMessage;

  /// No description provided for @savedSignatureTitle.
  ///
  /// In ar, this message translates to:
  /// **'التوقيع المحفوظ'**
  String get savedSignatureTitle;

  /// No description provided for @savedSignatureTabDraw.
  ///
  /// In ar, this message translates to:
  /// **'رسم التوقيع'**
  String get savedSignatureTabDraw;

  /// No description provided for @savedSignatureTabUpload.
  ///
  /// In ar, this message translates to:
  /// **'رفع صورة'**
  String get savedSignatureTabUpload;

  /// No description provided for @savedSignatureTabType.
  ///
  /// In ar, this message translates to:
  /// **'توقيع مكتوب'**
  String get savedSignatureTabType;

  /// No description provided for @savedSignatureClear.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get savedSignatureClear;

  /// No description provided for @savedSignatureSavedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التوقيع'**
  String get savedSignatureSavedMessage;

  /// No description provided for @savedSignatureTypedHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسمك هنا'**
  String get savedSignatureTypedHint;

  /// No description provided for @savedSignatureUploadPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'انقر لرفع صورة التوقيع'**
  String get savedSignatureUploadPlaceholder;

  /// No description provided for @savedSignatureUploadedLabel.
  ///
  /// In ar, this message translates to:
  /// **'توقيع مرفوع كصورة'**
  String get savedSignatureUploadedLabel;

  /// No description provided for @savedSignatureLastSaved.
  ///
  /// In ar, this message translates to:
  /// **'آخر حفظ: {date}'**
  String savedSignatureLastSaved(String date);

  /// No description provided for @securityPrivacyTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأمان والخصوصية'**
  String get securityPrivacyTitle;

  /// No description provided for @securityChangePasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get securityChangePasswordTitle;

  /// No description provided for @securityCurrentPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get securityCurrentPasswordLabel;

  /// No description provided for @securityNewPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get securityNewPasswordLabel;

  /// No description provided for @securityConfirmPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور الجديدة'**
  String get securityConfirmPasswordLabel;

  /// No description provided for @securityPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get securityPasswordMismatch;

  /// No description provided for @securityPasswordUpdatedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث كلمة المرور بنجاح'**
  String get securityPasswordUpdatedMessage;

  /// No description provided for @securityTwoFactorTitle.
  ///
  /// In ar, this message translates to:
  /// **'المصادقة الثنائية'**
  String get securityTwoFactorTitle;

  /// No description provided for @securityTwoFactorSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'طبقة حماية إضافية عند تسجيل الدخول'**
  String get securityTwoFactorSubtitle;

  /// No description provided for @securityBiometricTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول ببصمة الإصبع'**
  String get securityBiometricTitle;

  /// No description provided for @securityBiometricSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استخدم بصمتك بدلاً من كلمة المرور'**
  String get securityBiometricSubtitle;

  /// No description provided for @securityActiveSessionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الجلسات النشطة'**
  String get securityActiveSessionsTitle;

  /// No description provided for @securityEndSession.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الجلسة'**
  String get securityEndSession;

  /// No description provided for @securitySessionEndedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم إنهاء الجلسة'**
  String get securitySessionEndedMessage;

  /// No description provided for @securitySessionLocationJordan.
  ///
  /// In ar, this message translates to:
  /// **'الأردن'**
  String get securitySessionLocationJordan;

  /// No description provided for @securityTwoFactorUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح حالياً'**
  String get securityTwoFactorUnavailable;

  /// No description provided for @securitySessionsError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الجلسات'**
  String get securitySessionsError;

  /// No description provided for @securityThisDevice.
  ///
  /// In ar, this message translates to:
  /// **'هذا الجهاز'**
  String get securityThisDevice;

  /// No description provided for @securityUnknownDevice.
  ///
  /// In ar, this message translates to:
  /// **'جهاز غير معروف'**
  String get securityUnknownDevice;

  /// No description provided for @securityEndAllOtherSessions.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج من كل الأجهزة الأخرى'**
  String get securityEndAllOtherSessions;

  /// No description provided for @helpSupportTitle.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get helpSupportTitle;

  /// No description provided for @helpFaqTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة'**
  String get helpFaqTitle;

  /// No description provided for @helpContactUs.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم'**
  String get helpContactUs;

  /// No description provided for @helpSubjectLabel.
  ///
  /// In ar, this message translates to:
  /// **'الموضوع'**
  String get helpSubjectLabel;

  /// No description provided for @helpMessageLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرسالة'**
  String get helpMessageLabel;

  /// No description provided for @helpSendMessage.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get helpSendMessage;

  /// No description provided for @helpRequestSentMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلبك، سنتواصل معك قريباً'**
  String get helpRequestSentMessage;

  /// No description provided for @helpFaqNewContractQuestion.
  ///
  /// In ar, this message translates to:
  /// **'كيف أنشئ عقداً جديداً؟'**
  String get helpFaqNewContractQuestion;

  /// No description provided for @helpFaqNewContractAnswer.
  ///
  /// In ar, this message translates to:
  /// **'من الرئيسية اختر \"العقود الذكية\"، ثم اختر نوع العقد واملأ البيانات المطلوبة خطوة بخطوة.'**
  String get helpFaqNewContractAnswer;

  /// No description provided for @helpFaqEsignatureQuestion.
  ///
  /// In ar, this message translates to:
  /// **'هل التوقيع الإلكتروني معتمد قانونياً؟'**
  String get helpFaqEsignatureQuestion;

  /// No description provided for @helpFaqEsignatureAnswer.
  ///
  /// In ar, this message translates to:
  /// **'نعم، يتوافق التوقيع الإلكتروني مع أحكام قانون المعاملات الإلكترونية الأردني.'**
  String get helpFaqEsignatureAnswer;

  /// No description provided for @helpFaqBookConsultationQuestion.
  ///
  /// In ar, this message translates to:
  /// **'كيف أحجز استشارة مع محامٍ؟'**
  String get helpFaqBookConsultationQuestion;

  /// No description provided for @helpFaqBookConsultationAnswer.
  ///
  /// In ar, this message translates to:
  /// **'من تبويب \"المحامون\" اختر المحامي المناسب ثم اضغط \"احجز استشارة الآن\" واتبع خطوات الحجز.'**
  String get helpFaqBookConsultationAnswer;

  /// No description provided for @helpFaqManageSubscriptionQuestion.
  ///
  /// In ar, this message translates to:
  /// **'كيف ألغي أو أغيّر باقة اشتراكي؟'**
  String get helpFaqManageSubscriptionQuestion;

  /// No description provided for @helpFaqManageSubscriptionAnswer.
  ///
  /// In ar, this message translates to:
  /// **'من \"حسابي\" اختر \"الاشتراكات والباقات\" لاختيار باقة أخرى أو تغيير دورة الفوترة في أي وقت.'**
  String get helpFaqManageSubscriptionAnswer;

  /// No description provided for @invoicesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير'**
  String get invoicesTitle;

  /// No description provided for @invoicesEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير بعد'**
  String get invoicesEmptyTitle;

  /// No description provided for @invoicesEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر هنا فواتيرك بعد أول عملية دفع'**
  String get invoicesEmptyMessage;

  /// No description provided for @invoiceStatusPaid.
  ///
  /// In ar, this message translates to:
  /// **'مدفوعة'**
  String get invoiceStatusPaid;

  /// No description provided for @invoiceStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get invoiceStatusPending;

  /// No description provided for @vaultFilterDocuments.
  ///
  /// In ar, this message translates to:
  /// **'مستند'**
  String get vaultFilterDocuments;

  /// No description provided for @vaultFilterAiReports.
  ///
  /// In ar, this message translates to:
  /// **'تقارير تحليل AI'**
  String get vaultFilterAiReports;

  /// No description provided for @vaultFilterContracts.
  ///
  /// In ar, this message translates to:
  /// **'عقود تم إنشاؤها'**
  String get vaultFilterContracts;

  /// No description provided for @vaultSavedFilesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} ملفات محفوظة'**
  String vaultSavedFilesCount(int count);

  /// No description provided for @vaultAiReportBadge.
  ///
  /// In ar, this message translates to:
  /// **'تقرير جاهز'**
  String get vaultAiReportBadge;

  /// No description provided for @subscriptionPlansTitle.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات والترقية'**
  String get subscriptionPlansTitle;

  /// No description provided for @subscriptionCycleMonthly.
  ///
  /// In ar, this message translates to:
  /// **'شهري'**
  String get subscriptionCycleMonthly;

  /// No description provided for @subscriptionCycleSixMonths.
  ///
  /// In ar, this message translates to:
  /// **'6 شهور'**
  String get subscriptionCycleSixMonths;

  /// No description provided for @subscriptionCycleAnnual.
  ///
  /// In ar, this message translates to:
  /// **'سنوي'**
  String get subscriptionCycleAnnual;

  /// No description provided for @subscriptionSaveBadge.
  ///
  /// In ar, this message translates to:
  /// **'وفّر {percent}٪'**
  String subscriptionSaveBadge(int percent);

  /// No description provided for @subscriptionMostPopular.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر شيوعاً'**
  String get subscriptionMostPopular;

  /// No description provided for @subscriptionUpgradeButton.
  ///
  /// In ar, this message translates to:
  /// **'ترقية لـ {tier}'**
  String subscriptionUpgradeButton(String tier);

  /// No description provided for @subscriptionPerMonth.
  ///
  /// In ar, this message translates to:
  /// **'{amount} د.أ/شهر'**
  String subscriptionPerMonth(String amount);

  /// No description provided for @subscriptionPerSixMonths.
  ///
  /// In ar, this message translates to:
  /// **'{amount} د.أ/6 أشهر'**
  String subscriptionPerSixMonths(String amount);

  /// No description provided for @subscriptionPerYear.
  ///
  /// In ar, this message translates to:
  /// **'{amount} د.أ/سنة'**
  String subscriptionPerYear(String amount);

  /// No description provided for @subscriptionBasicDesc.
  ///
  /// In ar, this message translates to:
  /// **'يشمل عدداً معيناً من خدمات الذكاء الاصطناعي وصياغة العقود'**
  String get subscriptionBasicDesc;

  /// No description provided for @subscriptionBasicFeature1.
  ///
  /// In ar, this message translates to:
  /// **'5 عقود شهرياً'**
  String get subscriptionBasicFeature1;

  /// No description provided for @subscriptionBasicFeature2.
  ///
  /// In ar, this message translates to:
  /// **'تحليل عقد واحد'**
  String get subscriptionBasicFeature2;

  /// No description provided for @subscriptionBasicFeature3.
  ///
  /// In ar, this message translates to:
  /// **'استشارة ذكاء اصطناعي'**
  String get subscriptionBasicFeature3;

  /// No description provided for @subscriptionBasicFeature4.
  ///
  /// In ar, this message translates to:
  /// **'دعم البريد الإلكتروني'**
  String get subscriptionBasicFeature4;

  /// No description provided for @subscriptionProDesc.
  ///
  /// In ar, this message translates to:
  /// **'كل ما تحتاجه لإدارة عقودك واستشاراتك القانونية بلا حدود'**
  String get subscriptionProDesc;

  /// No description provided for @subscriptionProFeature1.
  ///
  /// In ar, this message translates to:
  /// **'عقود غير محدودة'**
  String get subscriptionProFeature1;

  /// No description provided for @subscriptionProFeature2.
  ///
  /// In ar, this message translates to:
  /// **'تحليل غير محدود'**
  String get subscriptionProFeature2;

  /// No description provided for @subscriptionProFeature3.
  ///
  /// In ar, this message translates to:
  /// **'استشارة ذكاء اصطناعي'**
  String get subscriptionProFeature3;

  /// No description provided for @subscriptionProFeature4.
  ///
  /// In ar, this message translates to:
  /// **'3 استشارات محام شهرياً'**
  String get subscriptionProFeature4;

  /// No description provided for @subscriptionProFeature5.
  ///
  /// In ar, this message translates to:
  /// **'توقيع إلكتروني متقدم'**
  String get subscriptionProFeature5;

  /// No description provided for @subscriptionProFeature6.
  ///
  /// In ar, this message translates to:
  /// **'دعم أولوية 24/7'**
  String get subscriptionProFeature6;

  /// No description provided for @subscriptionEnterpriseDesc.
  ///
  /// In ar, this message translates to:
  /// **'حل شامل للشركات والمؤسسات القانونية الكبيرة'**
  String get subscriptionEnterpriseDesc;

  /// No description provided for @subscriptionEnterpriseFeature1.
  ///
  /// In ar, this message translates to:
  /// **'كل مميزات Pro'**
  String get subscriptionEnterpriseFeature1;

  /// No description provided for @subscriptionEnterpriseFeature2.
  ///
  /// In ar, this message translates to:
  /// **'توفير يصل لـ 30%'**
  String get subscriptionEnterpriseFeature2;

  /// No description provided for @subscriptionEnterpriseFeature3.
  ///
  /// In ar, this message translates to:
  /// **'12 استشارة محام'**
  String get subscriptionEnterpriseFeature3;

  /// No description provided for @subscriptionEnterpriseFeature4.
  ///
  /// In ar, this message translates to:
  /// **'مدير حساب شخصي'**
  String get subscriptionEnterpriseFeature4;

  /// No description provided for @subscriptionEnterpriseFeature5.
  ///
  /// In ar, this message translates to:
  /// **'تقارير قانونية شهرية'**
  String get subscriptionEnterpriseFeature5;

  /// No description provided for @subscriptionEnterpriseFeature6.
  ///
  /// In ar, this message translates to:
  /// **'تكاملات مخصصة'**
  String get subscriptionEnterpriseFeature6;

  /// No description provided for @subscriptionSuccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'تمت ترقية باقتك بنجاح!'**
  String get subscriptionSuccessTitle;

  /// No description provided for @subscriptionSuccessMessage.
  ///
  /// In ar, this message translates to:
  /// **'حلول قانونية شاملة لفريقك ومؤسستك'**
  String get subscriptionSuccessMessage;

  /// No description provided for @subscriptionBackHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة للرئيسية'**
  String get subscriptionBackHome;

  /// No description provided for @govDocumentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المستندات الحكومية'**
  String get govDocumentsTitle;

  /// No description provided for @govDocumentsSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ماذا تريد إنجازه؟ (مثال: تسجيل شركة، تسجيل عقار...)'**
  String get govDocumentsSearchHint;

  /// No description provided for @govProcedureCompanyRegistration.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل شركة'**
  String get govProcedureCompanyRegistration;

  /// No description provided for @govProcedureCompanyRegistrationCategory.
  ///
  /// In ar, this message translates to:
  /// **'الأعمال والتجارة'**
  String get govProcedureCompanyRegistrationCategory;

  /// No description provided for @govProcedurePropertyRegistration.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل عقار'**
  String get govProcedurePropertyRegistration;

  /// No description provided for @govProcedurePropertyRegistrationCategory.
  ///
  /// In ar, this message translates to:
  /// **'العقارات والأملاك'**
  String get govProcedurePropertyRegistrationCategory;

  /// No description provided for @govProcedureContractNotarization.
  ///
  /// In ar, this message translates to:
  /// **'توثيق عقد'**
  String get govProcedureContractNotarization;

  /// No description provided for @govProcedureContractNotarizationCategory.
  ///
  /// In ar, this message translates to:
  /// **'التوثيق القانوني'**
  String get govProcedureContractNotarizationCategory;

  /// No description provided for @govProcedureLawsuitFiling.
  ///
  /// In ar, this message translates to:
  /// **'رفع دعوى قضائية'**
  String get govProcedureLawsuitFiling;

  /// No description provided for @govProcedureLawsuitFilingCategory.
  ///
  /// In ar, this message translates to:
  /// **'القضايا والمحاكم'**
  String get govProcedureLawsuitFilingCategory;

  /// No description provided for @govAccessDirectLink.
  ///
  /// In ar, this message translates to:
  /// **'ربط إلكتروني مباشر'**
  String get govAccessDirectLink;

  /// No description provided for @govAccessGuide.
  ///
  /// In ar, this message translates to:
  /// **'دليل إرشادي'**
  String get govAccessGuide;

  /// No description provided for @govStepsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} خطوات'**
  String govStepsCount(int count);

  /// No description provided for @govRequiredDocumentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المستندات المطلوبة'**
  String get govRequiredDocumentsTitle;

  /// No description provided for @govRequiredDocumentsProgress.
  ///
  /// In ar, this message translates to:
  /// **'{done}/{total} تم التجهيز'**
  String govRequiredDocumentsProgress(int done, int total);

  /// No description provided for @govProcedureStepsTitle.
  ///
  /// In ar, this message translates to:
  /// **'خطوات الإجراء'**
  String get govProcedureStepsTitle;

  /// No description provided for @govStartProcedure.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الإجراء الآن'**
  String get govStartProcedure;

  /// No description provided for @govProcedureStartedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم بدء متابعة الإجراء — يمكنك متابعة حالته من هنا'**
  String get govProcedureStartedMessage;

  /// No description provided for @govProcedureStatusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'قيد الإجراء — بانتظار المستندات'**
  String get govProcedureStatusInProgress;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
