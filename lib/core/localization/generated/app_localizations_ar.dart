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
  String authLoginRoleMismatch(String role) {
    return 'هذا الحساب مسجَّل كحساب $role — بدّل التبويب أعلاه لتسجيل الدخول';
  }

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
  String get authSmsInfo =>
      'سنرسل لك رمز تحقق مؤلف من 6 أرقام لإعادة تعيين كلمة المرور';

  @override
  String get authEmailInfo => 'سنرسل لك رابط تحقق لإعادة تعيين كلمة المرور';

  @override
  String get authSendCode => 'إرسال رمز التحقق';

  @override
  String get authRememberPassword => 'تذكرت كلمة المرور؟';

  @override
  String get authSentTitle => 'تم الإرسال!';

  @override
  String get authSentSubtitleSms =>
      'تحقق من رسائلك واتبع التعليمات لإعادة تعيين كلمة المرور';

  @override
  String get authSentSubtitleEmail =>
      'تحقق من بريدك الإلكتروني واتبع التعليمات لإعادة تعيين كلمة المرور';

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
  String get authResetPasswordSuccessSubtitle =>
      'يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة';

  @override
  String get authGoToLogin => 'الذهاب لتسجيل الدخول';

  @override
  String get validationPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get onboardingSlide1Title => 'مساعدك القانوني في جيبك';

  @override
  String get onboardingSlide1Subtitle =>
      'استشارات أولية وشرح فوري للبنود القانونية بالذكاء الاصطناعي على مدار الساعة';

  @override
  String get onboardingSlide2Title => 'عقود ذكية بدقائق';

  @override
  String get onboardingSlide2Subtitle =>
      'أنشئ عقودًا قانونية موثوقة وحلل عقودك الحالية بالذكاء الاصطناعي';

  @override
  String get onboardingSlide3Title => 'تواصل مباشرة مع محامين موثوقين';

  @override
  String get onboardingSlide3Subtitle =>
      'احجز استشارة فيديو أو صوتية أو مكتوبة مع نخبة من المحامين المرخصين';

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
  String get errorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

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
  String get clientHomeMyContracts => 'عقودي';

  @override
  String get clientHomeNoContractsTitle => 'لا توجد عقود بعد';

  @override
  String get clientHomeNoContractsMessage =>
      'ابدأ بإنشاء أول عقد قانوني لك بمساعدة الذكاء الاصطناعي';

  @override
  String get clientHomeServicesTitle => 'خدماتك القانونية';

  @override
  String get clientHomeRecommendedLawyers => 'محامون موصى بهم';

  @override
  String get serviceCreateContract => 'إنشاء عقد';

  @override
  String get serviceAnalyzeContract => 'تحليل العقد';

  @override
  String get serviceFindLawyer => 'البحث عن محامٍ';

  @override
  String get clientNotificationsTitle => 'الإشعارات';

  @override
  String get clientHomeHeroTitle => 'كيف يمكنني مساعدتك قانونيًا اليوم؟';

  @override
  String get clientHomeSearchHint => 'ابحث عن خدمة قانونية...';

  @override
  String get clientHomeSearchEmptyTitle => 'لا توجد نتائج';

  @override
  String get clientHomeSearchEmptyMessage => 'جرّب كلمة بحث مختلفة';

  @override
  String get clientHomeQuickAskAi => 'اسأل الـ AI';

  @override
  String get clientHomeQuickCreateContract => 'إنشاء عقد';

  @override
  String get clientHomeQuickFindLawyer => 'ابحث عن محام';

  @override
  String get serviceAnalyzeContractDesc =>
      'ارفع العقد ودع الذكاء الاصطناعي يساعدك';

  @override
  String get serviceSmartContracts => 'العقود الذكية';

  @override
  String get serviceSmartContractsDesc => 'أنشئ عقداً قانونياً خلال دقائق';

  @override
  String get serviceBookLawyer => 'حجز محام';

  @override
  String get serviceBookLawyerDesc => 'احجز استشارة مع محام متخصص';

  @override
  String get serviceGovDocuments => 'المستندات الحكومية';

  @override
  String get serviceGovDocumentsDesc => 'اعرف الأوراق والخطوات المطلوبة';

  @override
  String get clientHomeVaultTitle => 'الخزنة الرقمية';

  @override
  String get clientHomeVaultSubtitle => 'جميع وثائقك، عقودك وتقاريرك المحفوظة';

  @override
  String get clientHomeRecentActivity => 'آخر النشاطات';

  @override
  String get contractsSearchHint => 'ابحث في عقودك...';

  @override
  String get contractsFilterAll => 'الكل';

  @override
  String get contractsSearchEmptyTitle => 'لا توجد عقود مطابقة';

  @override
  String get contractsSearchEmptyMessage => 'جرّب كلمة بحث أو تصفية مختلفة';

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
  String get contractTypeSearchEmptyMessage =>
      'لا توجد أنواع عقود مطابقة لبحثك';

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
  String get contractDetailsDeleteConfirmMessage =>
      'هل أنت متأكد أنك تريد حذف هذه المسودة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get contractDetailsDeletedMessage => 'تم حذف المسودة';

  @override
  String get contractSignButton => 'توقيع إلكتروني';

  @override
  String get contractSignTitle => 'التوقيع الإلكتروني';

  @override
  String get contractSignTabSaved => 'توقيع محفوظ';

  @override
  String get contractSignNoSavedSignature =>
      'لا يوجد توقيع محفوظ — أضف واحداً من حسابي أولاً';

  @override
  String get contractSignLegalNotice =>
      'بالتوقيع على هذا المستند، فإنك توافق قانونياً على جميع البنود الواردة فيه وفق أحكام قانون المعاملات الإلكترونية الأردني.';

  @override
  String get contractSignConfirm => 'تأكيد التوقيع';

  @override
  String get contractSignedSuccessTitle => 'تم توقيع العقد بنجاح!';

  @override
  String get contractSignedSuccessMessage =>
      'تم اعتماد توقيعك وحفظ النسخة الموقعة بأمان في خزنتك الرقمية.';

  @override
  String get documentsEmptyTitle => 'لا توجد مستندات بعد';

  @override
  String get documentsEmptyMessage => 'ستظهر عقودك ومستنداتك هنا بعد إنشائها';

  @override
  String get documentsSearchHint => 'ابحث في مستنداتك...';

  @override
  String get documentsSearchEmptyTitle => 'لا توجد مستندات مطابقة';

  @override
  String get documentsSearchEmptyMessage => 'جرّب كلمة بحث مختلفة';

  @override
  String homeWelcome(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get commonJustNow => 'الآن';

  @override
  String commonMinutesAgo(int count) {
    return 'منذ $count د';
  }

  @override
  String commonHoursAgo(int count) {
    return 'منذ $count س';
  }

  @override
  String commonDaysAgo(int count) {
    return 'منذ $count يوم';
  }

  @override
  String get commonReset => 'إعادة تعيين';

  @override
  String get navConsultations => 'الاستشارات';

  @override
  String get notificationsMarkAllRead => 'تعليم الكل كمقروء';

  @override
  String get notificationsEmptyTitle => 'لا توجد إشعارات';

  @override
  String get notificationsEmptyMessage =>
      'لا يوجد جديد الآن، ستظهر إشعاراتك هنا';

  @override
  String get notificationUnavailableForRole =>
      'هذا الإشعار غير متاح من حسابك الحالي';

  @override
  String get specialtyCommercial => 'قانون تجاري';

  @override
  String get specialtyPersonalStatus => 'أحوال شخصية';

  @override
  String get specialtyCriminal => 'قانون جنائي';

  @override
  String get specialtyLabor => 'قانون عمل';

  @override
  String get specialtyRealEstate => 'عقارات';

  @override
  String get specialtyCorporate => 'قانون شركات';

  @override
  String get specialtyIntellectualProperty => 'ملكية فكرية';

  @override
  String get specialtyGeneral => 'عام';

  @override
  String get consultationTypeVideo => 'مكالمة فيديو';

  @override
  String get consultationTypeVoice => 'مكالمة صوتية';

  @override
  String get consultationTypeWritten => 'استشارة مكتوبة';

  @override
  String get lawyersSearchHint => 'ابحث عن محامٍ بالاسم...';

  @override
  String get lawyersEmptyTitle => 'لا يوجد محامون';

  @override
  String get lawyersEmptyMessage => 'تحقق لاحقًا من توفر المحامين';

  @override
  String get lawyersSearchEmptyTitle => 'لا يوجد محامون مطابقون';

  @override
  String get lawyersSearchEmptyMessage => 'جرّب كلمة بحث أو تصفية مختلفة';

  @override
  String get lawyersFilterTitle => 'التصفية';

  @override
  String get lawyersFilterRating => 'التقييم';

  @override
  String get lawyersFilterAvailability => 'التوفر';

  @override
  String get lawyersFilterApply => 'تطبيق التصفية';

  @override
  String get lawyerAvailableToday => 'متاح اليوم';

  @override
  String get lawyerAvailableThisWeek => 'متاح هذا الأسبوع';

  @override
  String get lawyerAvailableLater => 'متاح لاحقًا';

  @override
  String lawyerYearsExperience(int count) {
    return '$count سنوات خبرة';
  }

  @override
  String get lawyerProfileTitle => 'الملف الشخصي للمحامي';

  @override
  String lawyerAvailabilityBadge(String availability) {
    return '$availability';
  }

  @override
  String get lawyerAboutTitle => 'نبذة';

  @override
  String get lawyerSpecialtiesTitle => 'التخصصات';

  @override
  String get lawyerConsultationTypesTitle => 'أنواع الاستشارة والأسعار';

  @override
  String get lawyerExperienceTitle => 'الخبرة';

  @override
  String get lawyerStatSatisfaction => 'رضا العملاء';

  @override
  String get lawyerStatConsultations => 'الاستشارات';

  @override
  String get lawyerStatYears => 'سنوات الخبرة';

  @override
  String get lawyerReviewsTitle => 'تقييمات العملاء';

  @override
  String get lawyerBookConsultation => 'حجز استشارة';

  @override
  String lawyerPriceSar(String amount) {
    return '$amount د.أ';
  }

  @override
  String get bookingSelectTypeTitle => 'اختر نوع الاستشارة';

  @override
  String get bookingSelectDateTimeTitle => 'اختر التاريخ والوقت';

  @override
  String get bookingNoSlotsMessage => 'لا توجد مواعيد متاحة في هذا اليوم';

  @override
  String get bookingDetailsTitle => 'تفاصيل الحجز';

  @override
  String get bookingNotesLabel => 'ملاحظات';

  @override
  String get bookingNotesHint => 'صف باختصار ما تود مناقشته...';

  @override
  String get bookingConfirm => 'تأكيد الحجز والدفع';

  @override
  String get bookingSuccessTitle => 'تم إرسال طلب الحجز!';

  @override
  String get bookingSuccessMessage =>
      'أرسلنا طلبك إلى المحامي، سيتم إشعارك فور تأكيده';

  @override
  String get bookingViewDetails => 'عرض الحجز';

  @override
  String get paymentTitle => 'الدفع';

  @override
  String get paymentSummaryTitle => 'ملخص الفاتورة';

  @override
  String get paymentTotalLabel => 'الإجمالي';

  @override
  String get paymentMethodCard => 'بطاقة بنكية';

  @override
  String get paymentMethodDigitalWallet => 'Apple / G Pay';

  @override
  String get paymentCardNumberLabel => 'رقم البطاقة';

  @override
  String get paymentExpiryLabel => 'الشهر / السنة';

  @override
  String get paymentCvvLabel => 'رمز CVV';

  @override
  String get paymentFirstNameLabel => 'الاسم الأول';

  @override
  String get paymentLastNameLabel => 'الاسم الأخير';

  @override
  String paymentPayNow(String amount) {
    return 'ادفع الآن — $amount د.أ';
  }

  @override
  String get paymentApplePayTitle => 'Apple Pay';

  @override
  String get paymentApplePaySubtitle =>
      'ادفع بأمان وبنقرة واحدة عبر محفظتك الرقمية';

  @override
  String get paymentApplePayNoCardSharing => 'لا تُشارك بياناتك';

  @override
  String get paymentApplePayInstant => 'دفع فوري';

  @override
  String paymentPayWithApple(String amount) {
    return 'Pay with Apple Pay — $amount د.أ';
  }

  @override
  String get paymentSuccessMessage => 'تم الدفع بنجاح';

  @override
  String get paymentCardNumberInvalid => 'أدخل رقم بطاقة صحيح';

  @override
  String get paymentExpiryInvalid =>
      'أدخل تاريخ صلاحية صحيح وغير منتهٍ (MM/YY)';

  @override
  String get paymentCvvInvalid => 'أدخل رمز CVV صحيح';

  @override
  String get paymentFirstNameRequired => 'أدخل الاسم الأول';

  @override
  String get paymentLastNameRequired => 'أدخل الاسم الأخير';

  @override
  String get paymentCardTypeLabel => 'بطاقة خصم / ائتمان';

  @override
  String get consultationDetailsTitle => 'تفاصيل الاستشارة';

  @override
  String get consultationStatusPending => 'بانتظار الموافقة';

  @override
  String get consultationStatusUpcoming => 'قادمة';

  @override
  String get consultationStatusWaiting => 'بانتظار البدء';

  @override
  String get consultationStatusReady => 'جاهزة';

  @override
  String get consultationStatusConnecting => 'جارٍ الاتصال';

  @override
  String get consultationStatusActive => 'مباشرة';

  @override
  String get consultationStatusEnded => 'انتهت';

  @override
  String get consultationStatusCompleted => 'مكتملة';

  @override
  String get consultationStatusCancelled => 'ملغاة';

  @override
  String get consultationStatusRejected => 'مرفوضة';

  @override
  String get consultationStatusMissed => 'فائتة';

  @override
  String get consultationStatusFailed => 'فشلت';

  @override
  String get consultationsEmptyTitle => 'لا يوجد شيء هنا بعد';

  @override
  String get consultationsEmptyMessage =>
      'ستظهر هنا الاستشارات ضمن هذا التصنيف';

  @override
  String get consultationCancelConfirmTitle => 'إلغاء الاستشارة';

  @override
  String get consultationCancelConfirmMessage =>
      'هل أنت متأكد أنك تريد إلغاء هذه الاستشارة؟';

  @override
  String get consultationReschedule => 'إعادة الجدولة';

  @override
  String get consultationCancel => 'إلغاء الاستشارة';

  @override
  String get consultationEnd => 'إنهاء الاستشارة';

  @override
  String get consultationMessageHint => 'اكتب رسالة...';

  @override
  String get notificationConsultationBookedTitle => 'تم إرسال طلب الاستشارة';

  @override
  String notificationConsultationBookedBody(String lawyerName) {
    return 'بانتظار موافقة المحامي $lawyerName على طلب استشارتك';
  }

  @override
  String get notificationConsultationAcceptedTitle => 'تم قبول طلب الاستشارة';

  @override
  String notificationConsultationAcceptedBody(String lawyerName) {
    return 'وافق المحامي $lawyerName على طلب استشارتك';
  }

  @override
  String get notificationConsultationRejectedTitle => 'تم رفض طلب الاستشارة';

  @override
  String notificationConsultationRejectedBody(String lawyerName) {
    return 'اعتذر المحامي $lawyerName عن طلب استشارتك';
  }

  @override
  String get notificationConsultationCancelledTitle => 'تم إلغاء الاستشارة';

  @override
  String get notificationConsultationCancelledBody => 'تم إلغاء موعد استشارتك';

  @override
  String get notificationConsultationCompletedTitle => 'انتهت الاستشارة';

  @override
  String get notificationConsultationCompletedBody =>
      'انتهت جلسة استشارتك بنجاح';

  @override
  String get notificationNewMessageTitle => 'رسالة جديدة';

  @override
  String get notificationNewAttachmentBody => 'أرسل لك مرفقًا جديدًا';

  @override
  String get notificationDocumentUploadedTitle => 'تم رفع مستند';

  @override
  String notificationDocumentUploadedBody(String title) {
    return '\"$title\" أُضيف إلى خزنتك الرقمية';
  }

  @override
  String get notificationAiAnalysisTitle => 'اكتمل تحليل العقد';

  @override
  String notificationAiAnalysisBody(String documentTitle) {
    return 'تم الانتهاء من تحليل \"$documentTitle\"';
  }

  @override
  String get consultationRoomTitle => 'غرفة انتظار الاستشارة';

  @override
  String get consultationRoomEnterAction => 'الدخول إلى الاستشارة';

  @override
  String get consultationRoomBackAction => 'رجوع';

  @override
  String get consultationRoomTooEarlyTitle => 'لم يحن الوقت بعد';

  @override
  String get consultationRoomTooEarlyMessage =>
      'ستُفتح الاستشارة قبل 15 دقيقة من الموعد المحدد.';

  @override
  String consultationRoomStartsIn(String remaining) {
    return 'يبدأ خلال $remaining';
  }

  @override
  String consultationRoomCountdownDays(int days) {
    return '$days يوم';
  }

  @override
  String consultationRoomCountdownHours(int hours) {
    return '$hours س';
  }

  @override
  String consultationRoomCountdownMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String get consultationRoomReadyTitle => 'جاهز للانضمام';

  @override
  String get consultationRoomReadyMessage =>
      'يمكنك الانضمام إلى هذه الاستشارة الآن.';

  @override
  String get consultationRoomJoinAction => 'الانضمام إلى الاستشارة';

  @override
  String get consultationRoomJoinFailedMessage =>
      'تعذّر بدء الجلسة. يرجى المحاولة مرة أخرى.';

  @override
  String get consultationRoomMissedTitle => 'فاتت الاستشارة';

  @override
  String get consultationRoomMissedMessage =>
      'انتهت مهلة الانضمام إلى هذه الاستشارة.';

  @override
  String get consultationRoomUnavailableMessage =>
      'لم تعد هذه الاستشارة متاحة للانضمام إليها.';

  @override
  String get consultationRoomSimulateConnectionLossAction =>
      'محاكاة انقطاع الاتصال (للمطورين)';

  @override
  String get chatOpenAction => 'فتح المحادثة';

  @override
  String get chatViewDetails => 'عرض تفاصيل الاستشارة';

  @override
  String get chatAttachmentTooltip => 'إرفاق';

  @override
  String get chatAttachImage => 'صورة من المعرض';

  @override
  String get chatAttachFile => 'إرفاق ملف (تجريبي)';

  @override
  String chatAttachedFileSnackbar(String fileName) {
    return 'تم إرفاق $fileName';
  }

  @override
  String chatFileDownloadedMock(String fileName) {
    return 'تم التنزيل (تجريبي): $fileName';
  }

  @override
  String get chatImagePreviewTitle => 'صورة';

  @override
  String get chatImageUnavailableMock =>
      'المعاينة غير متاحة لهذه الصورة التجريبية';

  @override
  String get chatImagePickError =>
      'تعذّر فتح معرض الصور، يرجى المحاولة مرة أخرى.';

  @override
  String get chatSendAttachment => 'إرسال';

  @override
  String get chatSendFailedMessage => 'تعذّر إرسال الرسالة.';

  @override
  String get chatEmptyTitle => 'لا توجد رسائل بعد';

  @override
  String get chatEmptyMessage => 'أرسل رسالة لبدء المحادثة';

  @override
  String get chatDayToday => 'اليوم';

  @override
  String get chatDayYesterday => 'أمس';

  @override
  String get chatTypingIndicatorLabel => 'يكتب الآن…';

  @override
  String chatTimeRemaining(String time) {
    return 'متبقٍ $time';
  }

  @override
  String get chatFirstWarning => 'ستنتهي الجلسة قريبًا';

  @override
  String get chatFinalWarning => 'تبقّت أقل من دقيقة';

  @override
  String get chatEndConfirmTitle => 'إنهاء الاستشارة';

  @override
  String get chatEndConfirmMessage =>
      'سيؤدي هذا إلى إنهاء الجلسة لك وللطرف الآخر. ستظل قادرًا على الاطلاع على المحادثة لاحقًا.';

  @override
  String get chatEndedBannerMessage => 'انتهت هذه الاستشارة';

  @override
  String chatDurationLabel(String duration) {
    return 'المدة: $duration';
  }

  @override
  String chatOpensAt(String time) {
    return 'تُفتح المحادثة الساعة $time';
  }

  @override
  String chatStartsIn(String remaining) {
    return 'يبدأ خلال $remaining';
  }

  @override
  String chatCountdownDays(int days) {
    return '$days يوم';
  }

  @override
  String chatCountdownHours(int hours) {
    return '$hours س';
  }

  @override
  String chatCountdownMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String get chatInvalidConsultationMessage =>
      'تعذّر العثور على هذه الاستشارة.';

  @override
  String get chatReturnToCallAction => 'العودة إلى المكالمة — لا تزال نشطة';

  @override
  String get chatMockReply1 =>
      'شكرًا لمشاركة هذه التفاصيل. بناءً على ما ذكرته، أنصح بمراجعة البند المعني معًا قبل اتخاذ أي خطوة تالية. هل يمكنك إرسال الجزء المحدد من المستند الذي تقصده؟';

  @override
  String get chatMockReply2 =>
      'هذا استفسار وجيه. بشكل عام، يمنحك النظام مهلة معقولة للرد رسميًا، لكن المدة الدقيقة تعتمد على بنود العقد. دعني أطّلع على التفاصيل بدقة وأعود إليك قريبًا.';

  @override
  String get chatMockReply3 =>
      'أتفهم أهمية الأمر بالنسبة لك. اقتراحي هو الانتظار قبل توقيع أي شيء حتى نتأكد من أن بند المسؤولية مصاغ لصالحك. سأعدّ لك اقتراح تعديل لمراجعته.';

  @override
  String get chatMockReply4 =>
      'سؤال جيد. بناءً على حالات مشابهة، عادةً ما تُحل هذه النوعية من النزاعات بشكل أسرع عبر التفاوض المباشر بدلاً من اللجوء للقضاء مباشرة. هل ترغب أن أوضح لك خطوات هذا المسار؟';

  @override
  String get chatMockReply5 =>
      'تم الاطلاع، شكرًا لك. أحتاج بعض التفاصيل الإضافية حول تسلسل الأحداث لأقدّم لك رأيًا دقيقًا. هل يمكنك تأكيد تاريخ صدور الإشعار؟';

  @override
  String get chatMockReply6 =>
      'الأمر يبدو واضحًا نسبيًا، ولا أرى ما يعرّضك لمخاطر قانونية هنا، لكن أنصح بتوثيق الاتفاق كتابيًا لتفادي أي خلاف مستقبلي.';

  @override
  String get voiceCallLabel => 'استشارة صوتية';

  @override
  String get voiceCallConnectingLabel => 'جارٍ الاتصال…';

  @override
  String get voiceCallStatusConnected => 'متصل';

  @override
  String get voiceCallStatusReconnecting => 'إعادة الاتصال…';

  @override
  String get voiceCallConnectionLostBanner => 'انقطع الاتصال';

  @override
  String voiceCallReconnectingAttempt(int attempt, int max) {
    return 'المحاولة $attempt من $max';
  }

  @override
  String get voiceCallRetryNowAction => 'إعادة المحاولة الآن';

  @override
  String get voiceCallUnavailableTitle => 'تعذّر الاتصال';

  @override
  String voiceCallUnavailableMessage(String name) {
    return 'تعذّر الوصول إلى $name لهذه الاستشارة. يمكنك عرض التفاصيل أو المحاولة لاحقًا.';
  }

  @override
  String get voiceCallEndConfirmTitle => 'إنهاء الاستشارة؟';

  @override
  String get voiceCallEndConfirmMessage =>
      'سيؤدي هذا إلى إنهاء المكالمة لك وللطرف الآخر.';

  @override
  String get voiceCallEndCallAction => 'إنهاء المكالمة';

  @override
  String get voiceCallKeepCallAction => 'متابعة المكالمة';

  @override
  String get voiceCallMuteAction => 'كتم الصوت';

  @override
  String get voiceCallUnmuteAction => 'إلغاء الكتم';

  @override
  String get voiceCallSpeakerOnAction => 'تشغيل السماعة';

  @override
  String get voiceCallSpeakerOffAction => 'إيقاف السماعة';

  @override
  String get voiceCallEndedTitle => 'انتهت الاستشارة';

  @override
  String get voiceCallAutoEndedMessage => 'تم بلوغ الحد الأقصى لمدة الاستشارة.';

  @override
  String get voiceCallDoneAction => 'تم';

  @override
  String get videoCallLabel => 'استشارة فيديو';

  @override
  String get videoCallCameraOnAction => 'تشغيل الكاميرا';

  @override
  String get videoCallCameraOffAction => 'إيقاف الكاميرا';

  @override
  String get videoCallCameraOffPlaceholder => 'الكاميرا متوقفة';

  @override
  String get videoCallSwitchCameraAction => 'تبديل الكاميرا';

  @override
  String get videoCallSwitchedToFrontCamera =>
      'تم التبديل إلى الكاميرا الأمامية';

  @override
  String get videoCallSwitchedToBackCamera => 'تم التبديل إلى الكاميرا الخلفية';

  @override
  String get videoCallLocalVideoLabel => 'الفيديو المحلي';

  @override
  String get videoCallRemoteVideoLabel => 'فيديو الطرف الآخر';

  @override
  String get videoCallChatAction => 'الدردشة';

  @override
  String get videoCallEndedMessage => 'انتهى الفيديو';

  @override
  String get lawyerRequestsTitle => 'طلبات الاستشارة';

  @override
  String get lawyerRequestsEmptyTitle => 'لا توجد طلبات معلقة';

  @override
  String get lawyerRequestsEmptyMessage => 'ستظهر طلبات الاستشارة الجديدة هنا';

  @override
  String get lawyerRequestAccept => 'قبول';

  @override
  String get lawyerRequestReject => 'رفض';

  @override
  String get lawyerRequestRejectConfirmTitle => 'رفض الطلب';

  @override
  String get lawyerRequestRejectConfirmMessage =>
      'هل أنت متأكد أنك تريد رفض طلب الاستشارة هذا؟';

  @override
  String get lawyerRequestAcceptedMessage => 'تم قبول الطلب';

  @override
  String get lawyerRequestRejectedMessage => 'تم رفض الطلب';

  @override
  String get scheduleAddSlotTitle => 'إضافة موعد متاح';

  @override
  String get scheduleRemoveSlotTitle => 'إزالة الموعد';

  @override
  String get scheduleRemoveSlotMessage =>
      'هل أنت متأكد أنك تريد إزالة هذا الموعد المتاح؟';

  @override
  String get scheduleEmptyDayMessage => 'لا توجد مواعيد متاحة في هذا اليوم';

  @override
  String get scheduleSlotBooked => 'محجوز';

  @override
  String get scheduleSlotOpen => 'متاح';

  @override
  String get scheduleActionFailedMessage =>
      'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get scheduleSlotLinkedConsultationMissing =>
      'تعذّر العثور على الاستشارة المرتبطة — سيتم عرض جميع الاستشارات بدلاً من ذلك.';

  @override
  String get aiRecentConversationsTitle => 'المحادثات الأخيرة';

  @override
  String get aiNoConversationsMessage =>
      'ابدأ محادثة للحصول على إجابات سريعة لأسئلتك القانونية';

  @override
  String get aiDisclaimer =>
      'يقدم هذا المساعد معلومات قانونية عامة، وهو ليس بديلاً عن استشارة محامٍ مرخّص.';

  @override
  String get aiChatTitle => 'المساعد القانوني الذكي';

  @override
  String get aiChatInputHint => 'اكتب سؤالك...';

  @override
  String get aiNewConversation => 'محادثة جديدة';

  @override
  String get aiClearConversationTitle => 'مسح المحادثة';

  @override
  String get aiClearConversationMessage =>
      'هل أنت متأكد أنك تريد مسح جميع الرسائل في هذه المحادثة؟';

  @override
  String get aiStatusAvailable => 'متاح الآن — يرد فوراً';

  @override
  String get aiWelcomeMessage =>
      'مرحباً! أنا مساعدك القانوني الذكي. يمكنني مساعدتك في فهم عقودك، معرفة حقوقك، وصياغة عقود جديدة. كيف يمكنني مساعدتك اليوم؟';

  @override
  String get aiQuickActionCreateContract => 'أريد إنشاء عقد';

  @override
  String get aiQuickActionHrIssue => 'لدي مشكلة مع موظف';

  @override
  String get aiQuickActionExplainClause => 'اشرح لي بند قانوني';

  @override
  String get aiContractWizardIntro =>
      'ممتاز! سأساعدك في صياغة عقد قانوني موثوق. اختر نوع العقد الذي تريد إنشاءه من القائمة:';

  @override
  String get aiContractWizardAskParty1 =>
      'من هو الطرف الأول في العقد (صاحب العمل / المنشأة)؟';

  @override
  String get aiContractWizardAskParty2 => 'تمام. من هو الطرف الثاني في العقد؟';

  @override
  String get aiContractWizardAskSubject =>
      'ما هو موضوع العقد أو المهام الرئيسية؟';

  @override
  String get aiContractWizardAskValue =>
      'أخيرًا، ما القيمة المالية ومدة العقد؟';

  @override
  String aiContractWizardDraftTitle(String type) {
    return 'مسودة $type';
  }

  @override
  String get aiContractWizardStatusDraft => 'مسودة أولية — قيد المراجعة';

  @override
  String get aiContractWizardStatusSent => 'بانتظار توقيع الطرف الآخر';

  @override
  String get aiContractWizardPartyA => 'الطرف الأول';

  @override
  String get aiContractWizardPartyB => 'الطرف الثاني';

  @override
  String get aiContractWizardSubjectLabel => 'الموضوع';

  @override
  String get aiContractWizardValueLabel => 'القيمة والمدة';

  @override
  String get aiContractWizardSendSignature => 'إرسال طلب التوقيع';

  @override
  String get aiContractWizardSaveVault => 'حفظ في الخزنة';

  @override
  String get aiContractWizardSentMessage => 'تم إرسال طلب التوقيع بنجاح';

  @override
  String get aiContractWizardSavedMessage => 'تم حفظ المسودة في خزنتك الرقمية';

  @override
  String get aiContractWizardInputHint => 'اكتب إجابتك هنا...';

  @override
  String get analysisAnalyzingMessage => 'جارٍ تحليل المستند...';

  @override
  String get analysisUploadTitle => 'رفع مستند';

  @override
  String get analysisUploadLabel => 'عنوان المستند';

  @override
  String get analysisUploadHint => 'مثال: عقد عمل - شركة الأفق';

  @override
  String get analysisAnalyzeButton => 'تحليل المستند';

  @override
  String get analysisSelectFromVaultTitle => 'أو اختر من خزنتك الرقمية';

  @override
  String get analysisResultTitle => 'نتيجة التحليل';

  @override
  String get analysisInvalidMessage => 'تعذّر العثور على هذا التحليل.';

  @override
  String get analysisClausesTitle => 'البنود';

  @override
  String get analysisAskAi => 'اسأل الذكاء الاصطناعي عن هذا البند';

  @override
  String analysisAskAboutClause(String clauseTitle) {
    return 'هل يمكنك شرح بند \"$clauseTitle\" بمزيد من التفصيل؟';
  }

  @override
  String get analysisRiskLow => 'خطورة منخفضة';

  @override
  String get analysisRiskMedium => 'خطورة متوسطة';

  @override
  String get analysisRiskHigh => 'خطورة عالية';

  @override
  String get dashboardTodayAppointments => 'مواعيد اليوم';

  @override
  String get dashboardPendingRequests => 'طلبات معلقة';

  @override
  String get dashboardMonthEarnings => 'هذا الشهر';

  @override
  String get dashboardQuickActions => 'إجراءات سريعة';

  @override
  String get dashboardNoAppointmentsToday => 'لا توجد مواعيد مجدولة اليوم';

  @override
  String get dashboardActiveSessionBadge => 'استشارة عاجلة — الآن';

  @override
  String dashboardActiveSessionStartingIn(int minutes) {
    return 'تبدأ خلال $minutes د';
  }

  @override
  String get dashboardActiveSessionReady => 'جاهزة للبدء الآن';

  @override
  String get dashboardStartSession => 'بدء الجلسة';

  @override
  String get earningsBalance => 'إجمالي الأرباح';

  @override
  String earningsPending(String amount) {
    return '$amount بانتظار الاستشارات القادمة';
  }

  @override
  String get earningsMonthlySummary => 'الملخص الشهري';

  @override
  String get earningsHistoryTitle => 'سجل الأرباح';

  @override
  String get earningsEmptyMessage => 'ستظهر هنا الاستشارات المكتملة';

  @override
  String get clientsSearchHint => 'ابحث عن عميل...';

  @override
  String get clientsEmptyTitle => 'لا يوجد عملاء بعد';

  @override
  String get clientsEmptyMessage =>
      'سيظهر هنا العملاء الذين أجريت معهم استشارة';

  @override
  String clientsConsultationCount(int count) {
    return '$count استشارات';
  }

  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get accountEditProfileSubtitle => 'الاسم والبريد الإلكتروني';

  @override
  String get lawyerEditProfileSubtitle => 'النبذة والتخصصات والأسعار والتوثيق';

  @override
  String get profileUpdatedMessage => 'تم تحديث الملف الشخصي';

  @override
  String get unsavedChangesTitle => 'تجاهل التغييرات؟';

  @override
  String get unsavedChangesMessage =>
      'لديك تغييرات غير محفوظة. هل أنت متأكد أنك تريد المغادرة دون حفظها؟';

  @override
  String get unsavedChangesDiscard => 'تجاهل';

  @override
  String get lawyerEditProfileTitle => 'الملف المهني';

  @override
  String get lawyerVerificationSectionTitle => 'التوثيق';

  @override
  String get lawyerVerified => 'موثّق';

  @override
  String get lawyerPendingVerification => 'قيد المراجعة';

  @override
  String get lawyerNotVerified => 'غير موثّق بعد';

  @override
  String get lawyerUploadVerificationDocument => 'رفع مستند توثيق';

  @override
  String get lawyerVerificationDocumentPreviewTitle => 'معاينة المستند';

  @override
  String get lawyerVerificationSubmittedMessage => 'تم إرسال المستند للمراجعة';

  @override
  String get lawyerPriceLabel => 'السعر';

  @override
  String get lawyerBioRequiredError => 'يرجى كتابة نبذة تعريفية قبل الحفظ';

  @override
  String get lawyerExperienceInvalidError => 'أدخل عدد سنوات صحيحًا';

  @override
  String get lawyerPriceRequiredError => 'أدخل سعرًا أكبر من صفر';

  @override
  String get lawyerSelectSpecialtyError => 'اختر تخصصًا واحدًا على الأقل';

  @override
  String get lawyerSelectConsultationTypeError =>
      'اختر نوع استشارة واحدًا على الأقل تقدمه';

  @override
  String get navTeam => 'الفريق';

  @override
  String get teamAddMemberTitle => 'إضافة عضو للفريق';

  @override
  String get teamAddMemberAction => 'إضافة عضو';

  @override
  String get teamRoleLabel => 'الدور';

  @override
  String get teamRoleAdmin => 'مدير';

  @override
  String get teamRoleManager => 'مشرف';

  @override
  String get teamRoleMember => 'عضو';

  @override
  String get teamMemberAddedMessage => 'تمت إضافة عضو الفريق';

  @override
  String get teamSearchHint => 'ابحث عن عضو في الفريق...';

  @override
  String get teamEmptyTitle => 'لا يوجد أعضاء بعد';

  @override
  String get teamEmptyMessage => 'أضف أول عضو في فريقك للبدء';

  @override
  String teamJoinedOn(String date) {
    return 'انضم في $date';
  }

  @override
  String get teamRemoveMember => 'إزالة العضو';

  @override
  String get teamRemoveConfirmTitle => 'إزالة العضو';

  @override
  String get teamRemoveConfirmMessage =>
      'هل أنت متأكد أنك تريد إزالة هذا العضو من فريقك؟';

  @override
  String get companyActiveConsultations => 'استشارات نشطة';

  @override
  String get documentsUploadTitle => 'رفع مستند';

  @override
  String get documentsUploadHint =>
      'لا يوجد منتقي ملفات حقيقي في هذه المعاينة بعد — فقط أدخل عنوانًا للمستند.';

  @override
  String get documentsUploadLabel => 'عنوان المستند';

  @override
  String get commonUpload => 'رفع';

  @override
  String get documentsUploadedMessage => 'تم رفع المستند';

  @override
  String get documentsRenameTitle => 'إعادة تسمية المستند';

  @override
  String get commonRename => 'إعادة تسمية';

  @override
  String get documentsDeleteConfirmTitle => 'حذف المستند';

  @override
  String get documentsDeleteConfirmMessage =>
      'هل أنت متأكد أنك تريد حذف هذا المستند؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get documentsDeletedMessage => 'تم حذف المستند';

  @override
  String get accountNotificationsSetting => 'الإشعارات';

  @override
  String get accountStatDocuments => 'مستند';

  @override
  String get accountStatConsultations => 'استشارة';

  @override
  String get accountStatContracts => 'عقد';

  @override
  String get subscriptionTierBasic => 'الباقة الأساسية';

  @override
  String get subscriptionTierPro => 'باقة الأعمال Pro';

  @override
  String get subscriptionTierEnterprise => 'الباقة المؤسسية';

  @override
  String get subscriptionNoPlan => 'بدون اشتراك';

  @override
  String get accountMenuSubscriptions => 'الاشتراكات والباقات';

  @override
  String get accountMenuPaymentMethods => 'طرق الدفع';

  @override
  String get accountMenuSavedSignature => 'التوقيع المحفوظ';

  @override
  String get accountMenuBookings => 'الحجوزات';

  @override
  String get accountMenuInvoices => 'الفواتير';

  @override
  String get accountMenuSecurity => 'الأمان والخصوصية';

  @override
  String get accountMenuHelp => 'المساعدة والدعم';

  @override
  String get paymentMethodsTitle => 'طرق الدفع';

  @override
  String get paymentMethodsEmptyTitle => 'لا توجد طرق دفع محفوظة';

  @override
  String get paymentMethodsEmptyMessage =>
      'أضف بطاقة لتسهيل عمليات الدفع القادمة';

  @override
  String get paymentMethodsAddCard => 'إضافة بطاقة';

  @override
  String get paymentMethodsSetDefault => 'تعيين كافتراضي';

  @override
  String get paymentMethodsDefaultBadge => 'افتراضي';

  @override
  String get paymentMethodsLast4Label => 'آخر 4 أرقام';

  @override
  String get paymentMethodsHolderLabel => 'اسم حامل البطاقة';

  @override
  String get paymentMethodsAddedMessage => 'تمت إضافة البطاقة بنجاح';

  @override
  String get paymentMethodsLast4Invalid => 'أدخل 4 أرقام بالضبط';

  @override
  String get paymentMethodsHolderRequired => 'أدخل اسم حامل البطاقة';

  @override
  String get paymentMethodsRemoveConfirmTitle => 'حذف البطاقة';

  @override
  String get paymentMethodsRemoveConfirmMessage =>
      'هل أنت متأكد أنك تريد حذف هذه البطاقة؟';

  @override
  String get savedSignatureTitle => 'التوقيع المحفوظ';

  @override
  String get savedSignatureTabDraw => 'رسم التوقيع';

  @override
  String get savedSignatureTabUpload => 'رفع صورة';

  @override
  String get savedSignatureTabType => 'توقيع مكتوب';

  @override
  String get savedSignatureClear => 'مسح';

  @override
  String get savedSignatureSavedMessage => 'تم حفظ التوقيع';

  @override
  String get savedSignatureTypedHint => 'اكتب اسمك هنا';

  @override
  String get savedSignatureUploadPlaceholder => 'انقر لرفع صورة التوقيع';

  @override
  String get savedSignatureUploadedLabel => 'توقيع مرفوع كصورة';

  @override
  String savedSignatureLastSaved(String date) {
    return 'آخر حفظ: $date';
  }

  @override
  String get securityPrivacyTitle => 'الأمان والخصوصية';

  @override
  String get securityChangePasswordTitle => 'تغيير كلمة المرور';

  @override
  String get securityCurrentPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get securityNewPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get securityConfirmPasswordLabel => 'تأكيد كلمة المرور الجديدة';

  @override
  String get securityPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get securityPasswordUpdatedMessage => 'تم تحديث كلمة المرور بنجاح';

  @override
  String get securityTwoFactorTitle => 'المصادقة الثنائية';

  @override
  String get securityTwoFactorSubtitle => 'طبقة حماية إضافية عند تسجيل الدخول';

  @override
  String get securityBiometricTitle => 'تسجيل الدخول ببصمة الإصبع';

  @override
  String get securityBiometricSubtitle => 'استخدم بصمتك بدلاً من كلمة المرور';

  @override
  String get securityActiveSessionsTitle => 'الجلسات النشطة';

  @override
  String get securityEndSession => 'إنهاء الجلسة';

  @override
  String get securitySessionEndedMessage => 'تم إنهاء الجلسة';

  @override
  String get securitySessionLocationJordan => 'الأردن';

  @override
  String get securityTwoFactorUnavailable => 'غير متاح حالياً';

  @override
  String get securitySessionsError => 'تعذّر تحميل الجلسات';

  @override
  String get securityThisDevice => 'هذا الجهاز';

  @override
  String get securityUnknownDevice => 'جهاز غير معروف';

  @override
  String get securityEndAllOtherSessions => 'تسجيل الخروج من كل الأجهزة الأخرى';

  @override
  String get helpSupportTitle => 'المساعدة والدعم';

  @override
  String get helpFaqTitle => 'الأسئلة الشائعة';

  @override
  String get helpContactUs => 'تواصل مع الدعم';

  @override
  String get helpSubjectLabel => 'الموضوع';

  @override
  String get helpMessageLabel => 'الرسالة';

  @override
  String get helpSendMessage => 'إرسال';

  @override
  String get helpRequestSentMessage => 'تم إرسال طلبك، سنتواصل معك قريباً';

  @override
  String get helpFaqNewContractQuestion => 'كيف أنشئ عقداً جديداً؟';

  @override
  String get helpFaqNewContractAnswer =>
      'من الرئيسية اختر \"العقود الذكية\"، ثم اختر نوع العقد واملأ البيانات المطلوبة خطوة بخطوة.';

  @override
  String get helpFaqEsignatureQuestion =>
      'هل التوقيع الإلكتروني معتمد قانونياً؟';

  @override
  String get helpFaqEsignatureAnswer =>
      'نعم، يتوافق التوقيع الإلكتروني مع أحكام قانون المعاملات الإلكترونية الأردني.';

  @override
  String get helpFaqBookConsultationQuestion => 'كيف أحجز استشارة مع محامٍ؟';

  @override
  String get helpFaqBookConsultationAnswer =>
      'من تبويب \"المحامون\" اختر المحامي المناسب ثم اضغط \"احجز استشارة الآن\" واتبع خطوات الحجز.';

  @override
  String get helpFaqManageSubscriptionQuestion =>
      'كيف ألغي أو أغيّر باقة اشتراكي؟';

  @override
  String get helpFaqManageSubscriptionAnswer =>
      'من \"حسابي\" اختر \"الاشتراكات والباقات\" لاختيار باقة أخرى أو تغيير دورة الفوترة في أي وقت.';

  @override
  String get invoicesTitle => 'الفواتير';

  @override
  String get invoicesEmptyTitle => 'لا توجد فواتير بعد';

  @override
  String get invoicesEmptyMessage => 'ستظهر هنا فواتيرك بعد أول عملية دفع';

  @override
  String get invoiceStatusPaid => 'مدفوعة';

  @override
  String get invoiceStatusPending => 'قيد الانتظار';

  @override
  String get vaultFilterDocuments => 'مستند';

  @override
  String get vaultFilterAiReports => 'تقارير تحليل AI';

  @override
  String get vaultFilterContracts => 'عقود تم إنشاؤها';

  @override
  String vaultSavedFilesCount(int count) {
    return '$count ملفات محفوظة';
  }

  @override
  String get vaultAiReportBadge => 'تقرير جاهز';

  @override
  String get subscriptionPlansTitle => 'الاشتراكات والترقية';

  @override
  String get subscriptionCycleMonthly => 'شهري';

  @override
  String get subscriptionCycleSixMonths => '6 شهور';

  @override
  String get subscriptionCycleAnnual => 'سنوي';

  @override
  String subscriptionSaveBadge(int percent) {
    return 'وفّر $percent٪';
  }

  @override
  String get subscriptionMostPopular => 'الأكثر شيوعاً';

  @override
  String subscriptionUpgradeButton(String tier) {
    return 'ترقية لـ $tier';
  }

  @override
  String subscriptionPerMonth(String amount) {
    return '$amount د.أ/شهر';
  }

  @override
  String subscriptionPerSixMonths(String amount) {
    return '$amount د.أ/6 أشهر';
  }

  @override
  String subscriptionPerYear(String amount) {
    return '$amount د.أ/سنة';
  }

  @override
  String get subscriptionBasicDesc =>
      'يشمل عدداً معيناً من خدمات الذكاء الاصطناعي وصياغة العقود';

  @override
  String get subscriptionBasicFeature1 => '5 عقود شهرياً';

  @override
  String get subscriptionBasicFeature2 => 'تحليل عقد واحد';

  @override
  String get subscriptionBasicFeature3 => 'استشارة ذكاء اصطناعي';

  @override
  String get subscriptionBasicFeature4 => 'دعم البريد الإلكتروني';

  @override
  String get subscriptionProDesc =>
      'كل ما تحتاجه لإدارة عقودك واستشاراتك القانونية بلا حدود';

  @override
  String get subscriptionProFeature1 => 'عقود غير محدودة';

  @override
  String get subscriptionProFeature2 => 'تحليل غير محدود';

  @override
  String get subscriptionProFeature3 => 'استشارة ذكاء اصطناعي';

  @override
  String get subscriptionProFeature4 => '3 استشارات محام شهرياً';

  @override
  String get subscriptionProFeature5 => 'توقيع إلكتروني متقدم';

  @override
  String get subscriptionProFeature6 => 'دعم أولوية 24/7';

  @override
  String get subscriptionEnterpriseDesc =>
      'حل شامل للشركات والمؤسسات القانونية الكبيرة';

  @override
  String get subscriptionEnterpriseFeature1 => 'كل مميزات Pro';

  @override
  String get subscriptionEnterpriseFeature2 => 'توفير يصل لـ 30%';

  @override
  String get subscriptionEnterpriseFeature3 => '12 استشارة محام';

  @override
  String get subscriptionEnterpriseFeature4 => 'مدير حساب شخصي';

  @override
  String get subscriptionEnterpriseFeature5 => 'تقارير قانونية شهرية';

  @override
  String get subscriptionEnterpriseFeature6 => 'تكاملات مخصصة';

  @override
  String get subscriptionSuccessTitle => 'تمت ترقية باقتك بنجاح!';

  @override
  String get subscriptionSuccessMessage => 'حلول قانونية شاملة لفريقك ومؤسستك';

  @override
  String get subscriptionBackHome => 'العودة للرئيسية';

  @override
  String get govDocumentsTitle => 'المستندات الحكومية';

  @override
  String get govDocumentsSearchHint =>
      'ماذا تريد إنجازه؟ (مثال: تسجيل شركة، تسجيل عقار...)';

  @override
  String get govProcedureCompanyRegistration => 'تسجيل شركة';

  @override
  String get govProcedureCompanyRegistrationCategory => 'الأعمال والتجارة';

  @override
  String get govProcedurePropertyRegistration => 'تسجيل عقار';

  @override
  String get govProcedurePropertyRegistrationCategory => 'العقارات والأملاك';

  @override
  String get govProcedureContractNotarization => 'توثيق عقد';

  @override
  String get govProcedureContractNotarizationCategory => 'التوثيق القانوني';

  @override
  String get govProcedureLawsuitFiling => 'رفع دعوى قضائية';

  @override
  String get govProcedureLawsuitFilingCategory => 'القضايا والمحاكم';

  @override
  String get govAccessDirectLink => 'ربط إلكتروني مباشر';

  @override
  String get govAccessGuide => 'دليل إرشادي';

  @override
  String govStepsCount(int count) {
    return '$count خطوات';
  }

  @override
  String get govRequiredDocumentsTitle => 'المستندات المطلوبة';

  @override
  String govRequiredDocumentsProgress(int done, int total) {
    return '$done/$total تم التجهيز';
  }

  @override
  String get govProcedureStepsTitle => 'خطوات الإجراء';

  @override
  String get govStartProcedure => 'ابدأ الإجراء الآن';

  @override
  String get govProcedureStartedMessage =>
      'تم بدء متابعة الإجراء — يمكنك متابعة حالته من هنا';

  @override
  String get govProcedureStatusInProgress => 'قيد الإجراء — بانتظار المستندات';
}
