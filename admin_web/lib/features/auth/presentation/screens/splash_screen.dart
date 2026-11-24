import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/theme/app_colors.dart';
import 'package:aqd_admin/core/widgets/state_views.dart';
import 'package:aqd_admin/features/auth/presentation/providers/auth_controller.dart';

/// Held while the session is restored from the refresh cookie. If the
/// server cannot be reached, offers a retry instead of showing sign-in
/// (the user is not signed out, we just do not know yet).
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: auth.hasError
          ? Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
              ),
              child: ErrorView(
                error: auth.error!,
                onRetry: () => ref.invalidate(authControllerProvider),
              ),
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.balance, size: 48, color: Colors.white),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(l10n.restoringSession, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
    );
  }
}
