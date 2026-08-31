import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/providers/core_providers.dart';

/// Arabic is the default/primary locale; English is supported and
/// persisted once the user switches. RTL/LTR then follows automatically
/// from Flutter's `Localizations` based on this locale — no manual
/// direction handling anywhere else in the app.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final savedCode = ref.watch(appPreferencesProvider).localeCode;
    return Locale(savedCode ?? 'ar');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref.read(appPreferencesProvider).setLocaleCode(locale.languageCode);
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);
