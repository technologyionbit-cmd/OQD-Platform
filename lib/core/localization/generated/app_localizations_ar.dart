// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'عقد';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonLogout => 'تسجيل الخروج';

  @override
  String get commonLoading => 'جارٍ التحميل...';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonSkip => 'تخطي';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonViewAll => 'عرض الكل';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonDownload => 'تحميل';

  @override
  String get commonShare => 'مشاركة';

  @override
  String get commonCopy => 'نسخ';

  @override
  String get contractContentCopiedMessage => 'تم نسخ محتوى العقد';

  @override
  String get commonOptional => '(اختياري)';

  @override
  String get authLoginTitle => 'تسجيل الدخول';

  @override
  String get authLoginSubtitle => 'أهلاً بعودتك! سجل دخولك للمتابعة';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authEmailOrPhoneLabel => 'البريد الإلكتروني أو رقم الهاتف';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authPhoneLabel => 'رقم الهاتف';

  @override
  String get authLoginSubmit => 'دخول';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authNoAccount => 'ليس لديك حساب؟';

  @override
  String get authCreateAccount => 'إنشاء حساب جديد';

  @override
  String get authAlreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authRegisterTitle => 'إنشاء حساب جديد';

  @override
  String get authRegisterSubtitle => 'انضم إلينا وابدأ رحلتك القانونية';

  @override
  String get authRegisterSubmit => 'إنشاء الحساب';

  @override
  String get authAccountTypeIndividual => 'فرد';

  @override
  String get authAccountTypeCompany => 'شركة';

  @override
  String get authAccountTypeLawyer => 'محامٍ';

  @override
  String get authFullName => 'الاسم الكامل';

  @override
  String get authFullNameTriple => 'الاسم الثلاثي';

  @override
  String get authCompanyName => 'اسم المنشأة / الشركة';

  @override
  String get authCommercialRegistrationNumber => 'رقم السجل التجاري';

  @override
  String get authBarLicenseNumber => 'رقم إجازة المحاماة / القيد';

  @override
  String get authMainSpecialty => 'التخصص الرئيسي';

  @override
  String get authMainSpecialtyHint => 'مثال: قانون تجاري، أحوال شخصية';

  @override
  String get authTermsAgreementPrefix => 'بالتسجيل توافق على ';

  @override
  String get authTermsOfService => 'شروط الخدمة';

  @override
  String get authTermsAgreementJoiner => ' و';

  @override
  String get authPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get authForgotPasswordTitle => 'نسيت كلمة المرور؟';

  @override
  String get authForgotPasswordSubtitle => 'اختر طريقة الاستعادة للمتابعة';

  @override
  String get authMethodSms => 'رسالة SMS';

  @override
  String get authMethodEmail => 'البريد الإلكتروني';

  @override
  String get authSmsInfo => 'سنرسل لك رمز تحقق مؤلف من 6 أرقام لإعادة تعيين كلمة المرور';

  @override
  String get authEmailInfo => 'سنرسل لك رابط تحقق لإعادة تعيين كلمة المرور';

  @override
  String get authSendCode => 'إرسال رمز التحقق';

  @override
  String get authContactSupport => 'تواصل مع الدعم الفني';

  @override
  String get authRememberPassword => 'تذكرت كلمة المرور؟';

  @override
  String get authSentTitle => 'تم الإرسال!';

  @override
  String get authSentSubtitleSms => 'تحقق من رسائلك واتبع التعليمات لإعادة تعيين كلمة المرور';

  @override
  String get authSentSubtitleEmail => 'تحقق من بريدك الإلكتروني واتبع التعليمات لإعادة تعيين كلمة المرور';

  @override
  String get authEnterCode => 'إدخال رمز التحقق';

  @override
  String get authResend => 'إعادة الإرسال';

  @override
  String get authOtpTitle => 'أدخل رمز التحقق';

  @override
  String authOtpSubtitle(String destination) {
    return 'أرسلنا رمزًا مكونًا من 6 أرقام إلى $destination';
  }

  @override
  String get authOtpConfirm => 'تأكيد';

  @override
  String authOtpResendIn(String seconds) {
    return 'إعادة الإرسال بعد $seconds';
  }

  @override
  String get authOtpInvalidCode => 'رمز التحقق غير صحيح';

  @override
  String get authResetPasswordTitle => 'كلمة مرور جديدة';

  @override
  String get authResetPasswordSubtitle => 'أنشئ كلمة مرور قوية لحسابك';

  @override
  String get authNewPassword => 'كلمة المرور الجديدة';

  @override
  String get authConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authResetPasswordSubmit => 'حفظ كلمة المرور';

  @override
  String get authResetPasswordSuccessTitle => 'تم تغيير كلمة المرور!';

  @override
  String get authResetPasswordSuccessSubtitle => 'يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة';

  @override
  String get authGoToLogin => 'الذهاب لتسجيل الدخول';

  @override
  String get validationPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get onboardingSlide1Title => 'مساعدك القانوني في جيبك';

  @override
  String get onboardingSlide1Subtitle => 'استشارات أولية وشرح فوري للبنود القانونية بالذكاء الاصطناعي على مدار الساعة';

  @override
  String get onboardingSlide2Title => 'عقود ذكية بدقائق';

  @override
  String get onboardingSlide2Subtitle => 'أنشئ عقودًا قانونية موثوقة وحلل عقودك الحالية بالذكاء الاصطناعي';

  @override
  String get onboardingSlide3Title => 'تواصل مباشرة مع محامين موثوقين';

  @override
  String get onboardingSlide3Subtitle => 'احجز استشارة فيديو أو صوتية أو مكتوبة مع نخبة من المحامين المرخصين';

  @override
  String get onboardingGetStarted => 'ابدأ';

  @override
  String get devCredentialsTitle => 'بيانات تجريبية (بيئة التطوير فقط)';

  @override
  String devCredentialsPassword(String password) {
    return 'كلمة المرور لجميع الحسابات: $password';
  }

  @override
  String get errorGeneric => 'حدث خطأ غير متوقع';

  @override
  String get errorNetwork => 'تعذّر الاتصال بالشبكة، تحقق من الاتصال بالإنترنت';

  @override
  String get errorUnauthorized => 'الجلسة غير صالحة، الرجاء تسجيل الدخول مرة أخرى';

  @override
  String get errorInvalidCredentials => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get errorServer => 'حدث خطأ في الخادم، حاول لاحقًا';

  @override
  String get errorTimeout => 'انتهت مهلة الاتصال';

  @override
  String get validationRequired => 'هذا الحقل مطلوب';

  @override
  String get validationInvalidEmail => 'صيغة البريد الإلكتروني غير صحيحة';

  @override
  String get validationPasswordTooShort => 'كلمة المرور يجب ألا تقل عن 8 أحرف';

  @override
  String get validationInvalidPhone => 'رقم الهاتف غير صحيح';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navAi => 'AI';

  @override
  String get navDocuments => 'المستندات';

  @override
  String get navLawyers => 'المحامون';

  @override
  String get navAccount => 'حسابي';

  @override
  String get navContracts => 'العقود';

  @override
  String get navLawyerDashboard => 'لوحة التحكم';

  @override
  String get navSchedule => 'المواعيد';

  @override
  String get navClients => 'العملاء';

  @override
  String get navEarnings => 'الأرباح';

  @override
  String get navMyProfile => 'ملفي';

  @override
  String get placeholderComingSoonMessage => 'هذا القسم قيد التطوير وسيتوفر قريبًا';

  @override
  String get accountLanguage => 'اللغة';

  @override
  String get accountRoleClient => 'عميل';

  @override
  String get accountRoleLawyer => 'محامٍ';

  @override
  String get accountRoleCompany => 'شركة';

  @override
  String get confirmLogoutTitle => 'تسجيل الخروج';

  @override
  String get confirmLogoutMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get clientHomeCreateContract => 'إنشاء عقد جديد';

  @override
  String get clientHomeMyContracts => 'عقودي';

  @override
  String get clientHomeNoContractsTitle => 'لا توجد عقود بعد';

  @override
  String get clientHomeNoContractsMessage => 'ابدأ بإنشاء أول عقد قانوني لك بمساعدة الذكاء الاصطناعي';

  @override
  String get clientHomeServicesTitle => 'الخدمات القانونية';

  @override
  String get serviceCreateContract => 'إنشاء عقد';

  @override
  String get serviceAnalyzeContract => 'تحليل عقد';

  @override
  String get serviceFindLawyer => 'البحث عن محامٍ';

  @override
  String get clientNotificationsTitle => 'الإشعارات';

  @override
  String get contractsSearchHint => 'ابحث في عقودك...';

  @override
  String get contractsFilterAll => 'الكل';

  @override
  String get contractStatusDraft => 'مسودة';

  @override
  String get contractStatusPendingSignature => 'بانتظار التوقيع';

  @override
  String get contractStatusSigned => 'تم التوقيع';

  @override
  String get contractStatusCompleted => 'مكتمل';

  @override
  String get contractStatusCancelled => 'ملغى';

  @override
  String get contractCategoryEmployment => 'عقد عمل';

  @override
  String get contractCategorySale => 'عقد بيع';

  @override
  String get contractCategoryRental => 'عقد إيجار';

  @override
  String get contractCategoryPartnership => 'عقد شراكة';

  @override
  String get contractCategoryNda => 'اتفاقية عدم إفصاح';

  @override
  String get contractCategoryServiceAgreement => 'عقد خدمات';

  @override
  String get contractCategoryOther => 'عقد آخر';

  @override
  String get contractTypeSelectionTitle => 'اختر نوع العقد';

  @override
  String get contractTypeSelectionSubtitle => 'اختر نوع العقد الذي تريد إنشاءه';

  @override
  String get contractTypeSearchHint => 'ابحث عن نوع العقد...';

  @override
  String get contractFormTitle => 'تعبئة بيانات العقد';

  @override
  String get validationInvalidNumber => 'الرجاء إدخال رقم صحيح';

  @override
  String get validationInvalidDate => 'الرجاء اختيار تاريخ صحيح';

  @override
  String get contractPreviewTitle => 'معاينة العقد';

  @override
  String get contractPreviewParties => 'الأطراف';

  @override
  String get contractPreviewDetails => 'التفاصيل';

  @override
  String get contractPreviewSaveDraft => 'حفظ كمسودة';

  @override
  String get contractPreviewGenerate => 'إنشاء العقد';

  @override
  String get contractGeneratedSuccessTitle => 'تم إنشاء العقد بنجاح!';

  @override
  String get contractGeneratedSuccessMessage => 'تم حفظ عقدك في الخزنة الرقمية';

  @override
  String get contractDraftSavedMessage => 'تم حفظ العقد كمسودة';

  @override
  String get contractViewDetails => 'عرض التفاصيل';

  @override
  String get contractDetailsTitle => 'تفاصيل العقد';

  @override
  String get contractDetailsType => 'نوع العقد';

  @override
  String get contractDetailsStatus => 'الحالة';

  @override
  String get contractDetailsCreated => 'تاريخ الإنشاء';

  @override
  String get contractDetailsUpdated => 'آخر تحديث';

  @override
  String get contractDetailsContent => 'محتوى العقد';

  @override
  String get contractDetailsDeleteConfirmTitle => 'حذف المسودة';

  @override
  String get contractDetailsDeleteConfirmMessage => 'هل أنت متأكد أنك تريد حذف هذه المسودة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get contractDetailsDeletedMessage => 'تم حذف المسودة';

  @override
  String get documentsEmptyTitle => 'لا توجد مستندات بعد';

  @override
  String get documentsEmptyMessage => 'ستظهر عقودك ومستنداتك هنا بعد إنشائها';

  @override
  String get documentsSearchHint => 'ابحث في مستنداتك...';

  @override
  String homeWelcome(String name) {
    return 'مرحبًا، $name';
  }
}
