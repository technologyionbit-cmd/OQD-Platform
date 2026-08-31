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
  String get authLoginTitle => 'تسجيل الدخول';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authLoginSubmit => 'دخول';

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
  String homeWelcome(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String foundationEnvBanner(String env) {
    return 'بيئة: $env';
  }
}
