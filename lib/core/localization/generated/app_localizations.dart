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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
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

  /// No description provided for @commonLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get commonLoading;

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

  /// No description provided for @commonSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get commonSearch;

  /// No description provided for @commonDownload.
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get commonDownload;

  /// No description provided for @commonShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get commonShare;

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

  /// No description provided for @authMainSpecialtyHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: قانون تجاري، أحوال شخصية'**
  String get authMainSpecialtyHint;

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

  /// No description provided for @authContactSupport.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم الفني'**
  String get authContactSupport;

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

  /// No description provided for @errorUnauthorized.
  ///
  /// In ar, this message translates to:
  /// **'الجلسة غير صالحة، الرجاء تسجيل الدخول مرة أخرى'**
  String get errorUnauthorized;

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

  /// No description provided for @placeholderComingSoonMessage.
  ///
  /// In ar, this message translates to:
  /// **'هذا القسم قيد التطوير وسيتوفر قريبًا'**
  String get placeholderComingSoonMessage;

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

  /// No description provided for @clientHomeCreateContract.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء عقد جديد'**
  String get clientHomeCreateContract;

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
  /// **'الخدمات القانونية'**
  String get clientHomeServicesTitle;

  /// No description provided for @serviceCreateContract.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء عقد'**
  String get serviceCreateContract;

  /// No description provided for @serviceAnalyzeContract.
  ///
  /// In ar, this message translates to:
  /// **'تحليل عقد'**
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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
