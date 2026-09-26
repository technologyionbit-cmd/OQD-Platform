import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/failure_message.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_gradients.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';

/// Shown while [AuthController] resolves the stored session on cold start,
/// and kept up with a retry when the server can't be reached to verify it.
/// The router's redirect moves on from here once the session resolves —
/// this screen never navigates itself.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final failure = authState.isLoading ? null : authState.error;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.navyDarkest,
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppGradients.navyHeader),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  const _BrandMark(),
                  const Spacer(flex: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: failure == null
                        ? const _SessionLoading()
                        : _SessionRestoreError(
                            failure: failure is Failure ? failure : const UnknownFailure(),
                            onRetry: () => ref.invalidate(authControllerProvider),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      header: true,
      label: l10n.appName,
      excludeSemantics: true,
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.onPrimary.withValues(alpha: 0.12), borderRadius: AppRadii.xlRadius),
            child: const Icon(Icons.gavel_rounded, color: AppColors.onPrimary, size: 44),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.appName,
            style: textTheme.displaySmall?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.splashTagline,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.75)),
          ),
        ],
      ),
    );
  }
}

class _SessionLoading extends StatelessWidget {
  const _SessionLoading();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context)!.splashLoading,
      child: const SizedBox.square(
        dimension: 28,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onPrimary),
      ),
    );
  }
}

class _SessionRestoreError extends StatelessWidget {
  const _SessionRestoreError({required this.failure, required this.onRetry});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, color: AppColors.onPrimary.withValues(alpha: 0.75), size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(
            failure.localizedMessage(l10n),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: l10n.commonRetry, onPressed: onRetry, icon: Icons.refresh_rounded),
        ],
      ),
    );
  }
}
