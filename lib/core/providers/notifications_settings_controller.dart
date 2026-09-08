import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/providers/core_providers.dart';

/// Whether the user wants push notifications — a genuine local preference
/// (mirrors [LocaleController]'s pattern), not wired to a real push
/// service in this phase; the notification *center* itself is unaffected
/// either way.
class NotificationsSettingsController extends Notifier<bool> {
  @override
  bool build() => ref.watch(appPreferencesProvider).notificationsEnabled;

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await ref.read(appPreferencesProvider).setNotificationsEnabled(enabled);
  }
}

final notificationsSettingsControllerProvider = NotifierProvider<NotificationsSettingsController, bool>(
  NotificationsSettingsController.new,
);
