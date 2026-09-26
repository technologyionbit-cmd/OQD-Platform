import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';

/// The device's preferred languages, most preferred first. A provider (not
/// a direct platform read inside [LocaleController]) so tests can pin it.
final deviceLocalesProvider = Provider<List<Locale>>((ref) => WidgetsBinding.instance.platformDispatcher.locales);

/// Arabic is the primary locale. Until the user picks a language, the app
/// follows the device: the first device language the app supports wins,
/// otherwise Arabic. An explicit choice is persisted and always wins after
/// that. RTL/LTR follows automatically from Flutter's `Localizations` based
/// on this locale — no manual direction handling anywhere else in the app.
class LocaleController extends Notifier<Locale> {
  static const fallback = Locale('ar');

  @override
  Locale build() {
    final savedCode = ref.watch(appPreferencesProvider).localeCode;
    if (savedCode != null) return Locale(savedCode);
    return resolveDeviceLocale(ref.watch(deviceLocalesProvider));
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref.read(appPreferencesProvider).setLocaleCode(locale.languageCode);
  }

  /// Switches between the two supported languages.
  Future<void> toggle() => setLocale(state.languageCode == 'ar' ? const Locale('en') : const Locale('ar'));

  /// Visible for testing.
  static Locale resolveDeviceLocale(List<Locale> deviceLocales) {
    final supportedCodes = AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
    for (final locale in deviceLocales) {
      if (supportedCodes.contains(locale.languageCode)) return Locale(locale.languageCode);
    }
    return fallback;
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);
