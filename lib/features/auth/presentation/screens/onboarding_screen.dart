import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_gradients.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/utils/responsive.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';

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

  Future<void> _finish() async {
    await ref.read(appPreferencesProvider).setOnboardingSeen(true);
    if (mounted) context.go(RoutePaths.login);
  }

  void _next(int slideCount) {
    if (_page == slideCount - 1) {
      _finish();
    } else {
      _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slides = [
      (icon: Icons.smart_toy_outlined, title: l10n.onboardingSlide1Title, subtitle: l10n.onboardingSlide1Subtitle),
      (icon: Icons.description_outlined, title: l10n.onboardingSlide2Title, subtitle: l10n.onboardingSlide2Subtitle),
      (icon: Icons.gavel_outlined, title: l10n.onboardingSlide3Title, subtitle: l10n.onboardingSlide3Subtitle),
    ];

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.navyHeader),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(foregroundColor: Colors.white70),
                    child: Text(l10n.commonSkip),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: (index) => setState(() => _page = index),
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    // Text length varies a lot by locale (English runs
                    // noticeably longer than Arabic here) and the smallest
                    // realistic phone heights leave little slack — a fixed
                    // centered Column would overflow for some combination
                    // of the two. Scrollable-with-a-minimum-height keeps it
                    // visually centered when it fits and simply scrolls,
                    // never overflows, when it doesn't.
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final iconSize = responsiveValue(context, standard: 140.0, small: 108.0);
                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight - AppSpacing.md * 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: iconSize,
                                  height: iconSize,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: AppRadii.xlRadius,
                                  ),
                                  child: Icon(slide.icon, size: iconSize * 0.46, color: Colors.white),
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                                Text(
                                  slide.title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  slide.subtitle,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.75)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (index) {
                  final isActive = index == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
                      borderRadius: AppRadii.smRadius,
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: AppButton(
                  label: _page == slides.length - 1 ? l10n.onboardingGetStarted : l10n.commonNext,
                  onPressed: () => _next(slides.length),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
