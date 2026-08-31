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
  String get authLoginTitle => 'Login';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authLoginSubmit => 'Sign In';

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
  String homeWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String foundationEnvBanner(String env) {
    return 'Environment: $env';
  }
}
