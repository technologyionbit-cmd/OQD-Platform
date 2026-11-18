import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/failure_message.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_gradients.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_logo.dart';
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
        // Full-bleed: without the explicit expand the gradient and the
        // centered column shrink to the width of their widest child.
        body: SizedBox.expand(
          child: DecoratedBox(
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
                      child:
                          failure == null
                              ? const _SessionLoading()
                              : _SessionRestoreError(
                                failure:
                                    failure is Failure
                                        ? failure
                                        : const UnknownFailure(),
                                onRetry:
                                    () =>
                                        ref.invalidate(authControllerProvider),
                              ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The wordmark "written" onto the screen: a soft-edged wipe travels from
/// right to left (the direction Arabic is written), whatever the app
/// locale, so the calligraphy appears stroke by stroke.
class _DrawnLogo extends StatelessWidget {
  const _DrawnLogo();

  static const _edge = 0.22; // softness of the leading edge

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 2400),
      curve: Curves.easeInOutCubic,
      builder: (context, t, child) {
        // Edge position runs from fully hidden to fully revealed.
        final head = t * (1 + _edge);
        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback:
              (bounds) => LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: const [Colors.white, Colors.white, Colors.transparent],
                stops: [
                  0,
                  (head - _edge).clamp(0.0, 1.0),
                  head.clamp(0.0, 1.0),
                ],
              ).createShader(bounds),
          child: child,
        );
      },
      child: const AppLogo(width: 220, onDark: true),
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
          const _DrawnLogo(),
          const SizedBox(height: AppSpacing.md),
          // Tagline: appears after the logo has mostly settled.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 3200),
            curve: const Interval(0.75, 1, curve: Curves.easeOut),
            builder: (context, t, child) => Opacity(opacity: t, child: child),
            child: Text(
              l10n.splashTagline,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.75),
              ),
            ),
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
      // A slim line under the wordmark reads calmer than a ring spinner and
      // sits on the same axis as the logo.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          width: 96,
          height: 3,
          child: LinearProgressIndicator(
            color: AppColors.onPrimary,
            backgroundColor: AppColors.onPrimary.withValues(alpha: 0.16),
            minHeight: 3,
          ),
        ),
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
          Icon(
            Icons.wifi_off_rounded,
            color: AppColors.onPrimary.withValues(alpha: 0.75),
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            failure.localizedMessage(l10n),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.commonRetry,
            onPressed: onRetry,
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }
}
