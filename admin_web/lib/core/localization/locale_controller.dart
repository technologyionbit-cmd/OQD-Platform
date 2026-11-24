import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'aqd_admin_locale';

/// Arabic by default; the choice is remembered in the browser. This is a
/// per-viewer convenience, so a failed read/write is simply ignored.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    unawaited(_restore());
    return const Locale('ar');
  }

  Future<void> _restore() async {
    try {
      final saved = (await SharedPreferences.getInstance()).getString(_key);
      if (saved == 'en' || saved == 'ar') state = Locale(saved!);
    } on Object {
      // Storage unavailable (private window): keep the default.
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      await (await SharedPreferences.getInstance()).setString(_key, locale.languageCode);
    } on Object {
      // Not remembered; still applied for this visit.
    }
  }

  Future<void> toggle() => setLocale(state.languageCode == 'ar' ? const Locale('en') : const Locale('ar'));
}

final localeProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);
