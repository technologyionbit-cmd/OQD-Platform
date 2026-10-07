import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_gradients.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/utils/responsive.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/language_switch_button.dart';
import 'package:aqd_ionbit/features/onboarding/presentation/providers/onboarding_controller.dart';

/// First-launch introduction. Completing or skipping it only reports to
/// [OnboardingController] — the router then moves on to login by itself.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() => ref.read(onboardingControllerProvider.notifier).complete();

  Future<void> _goTo(int page) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _pageController.jumpToPage(page);
      return Future.value();
    }
    return _pageController.animateToPage(page, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final slides = _OnboardingSlide.all(AppLocalizations.of(context)!);
    final isLastPage = _page == slides.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      // Android back walks back through the slides before leaving the app.
      child: PopScope(
        canPop: _page == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _goTo(_page - 1);
        },
        child: Scaffold(
          backgroundColor: AppColors.navyDarkest,
          body: DecoratedBox(
            decoration: const BoxDecoration(gradient: AppGradients.navyHeader),
            child: SafeArea(
              child: Column(
                children: [
                  _TopBar(showSkip: !isLastPage, onSkip: _complete),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: slides.length,
                      onPageChanged: (index) => setState(() => _page = index),
                      itemBuilder: (context, index) => _SlideView(slide: slides[index]),
                    ),
                  ),
                  _PageIndicator(count: slides.length, current: _page),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: _PrimaryAction(
                      isLastPage: isLastPage,
                      onNext: () => _goTo(_page + 1),
                      onComplete: _complete,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  static List<_OnboardingSlide> all(AppLocalizations l10n) => [
    _OnboardingSlide(icon: Icons.smart_toy_outlined, title: l10n.onboardingSlide1Title, subtitle: l10n.onboardingSlide1Subtitle),
    _OnboardingSlide(icon: Icons.description_outlined, title: l10n.onboardingSlide2Title, subtitle: l10n.onboardingSlide2Subtitle),
    _OnboardingSlide(icon: Icons.gavel_outlined, title: l10n.onboardingSlide3Title, subtitle: l10n.onboardingSlide3Subtitle),
  ];
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.showSkip, required this.onSkip});

  final bool showSkip;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final mutedOnNavy = AppColors.onPrimary.withValues(alpha: 0.7);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LanguageSwitchButton(foregroundColor: mutedOnNavy),
          // Hidden: keeps its space so the language button never shifts,
          // but is neither tappable nor announced (interactivity/semantics
          // are not maintained).
          Visibility(
            visible: showSkip,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(foregroundColor: mutedOnNavy),
              child: Text(AppLocalizations.of(context)!.commonSkip),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Text length varies a lot by locale (English runs noticeably longer
    // than Arabic here) and the smallest realistic phone heights leave
    // little slack — a fixed centered Column would overflow for some
    // combination of the two. Scrollable-with-a-minimum-height keeps it
    // visually centered when it fits and simply scrolls, never overflows,
    // when it doesn't.
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconSize = responsiveValue<double>(context, standard: 140, small: 108);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - AppSpacing.md * 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: iconSize,
                    height: iconSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.onPrimary.withValues(alpha: 0.1), borderRadius: AppRadii.xlRadius),
                    child: Icon(slide.icon, size: iconSize * 0.46, color: AppColors.onPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Semantics(
                  header: true,
                  child: Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(color: AppColors.onPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.75)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context)!.onboardingSlideIndicator(current + 1, count),
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < count; index++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              width: index == current ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: index == current ? AppColors.onPrimary : AppColors.onPrimary.withValues(alpha: 0.3),
                borderRadius: AppRadii.smRadius,
              ),
            ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.isLastPage, required this.onNext, required this.onComplete});

  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppButton(
      label: isLastPage ? l10n.onboardingGetStarted : l10n.commonNext,
      onPressed: isLastPage ? onComplete : onNext,
    );
  }
}
