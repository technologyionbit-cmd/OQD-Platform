import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/utils/app_logger.dart';

/// Whether the user has been through onboarding. The router watches this
/// and redirects on its own once it flips — the onboarding screen only
/// reports completion, it never navigates itself.
class OnboardingController extends Notifier<bool> {
  @override
  bool build() => ref.watch(appPreferencesProvider).hasSeenOnboarding;

  /// Idempotent. State flips before persisting, so the user moves on even
  /// if the write fails — at worst onboarding shows again next launch.
  Future<void> complete() async {
    if (state) return;
    state = true;
    try {
      await ref.read(appPreferencesProvider).setOnboardingSeen(true);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to persist onboarding completion', error: e, stackTrace: stackTrace);
    }
  }
}

final onboardingControllerProvider = NotifierProvider<OnboardingController, bool>(OnboardingController.new);
