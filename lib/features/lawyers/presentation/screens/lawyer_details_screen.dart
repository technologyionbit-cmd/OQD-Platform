import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/app_chip.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/section_header.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/verification_status.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/providers/lawyer_by_id_provider.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/consultation_type_x.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/lawyer_availability_x.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/lawyer_specialty_x.dart';

class LawyerDetailsScreen extends ConsumerWidget {
  const LawyerDetailsScreen({super.key, required this.lawyerId, this.routeBase = RoutePaths.clientBase});

  final String lawyerId;
  final String routeBase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lawyerState = ref.watch(lawyerByIdProvider(lawyerId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lawyerProfileTitle)),
      body: switch (lawyerState) {
        AsyncData(value: final lawyer) => _LawyerDetailsBody(lawyer: lawyer, routeBase: routeBase),
        AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.invalidate(lawyerByIdProvider(lawyerId))),
        _ => const LoadingView(),
      },
    );
  }
}

class _LawyerDetailsBody extends StatelessWidget {
  const _LawyerDetailsBody({required this.lawyer, required this.routeBase});

  final LawyerProfile lawyer;
  final String routeBase;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Row(
                  children: [
                    const IconBadge(icon: Icons.person_outline, size: 64),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(child: Text(lawyer.fullName, style: Theme.of(context).textTheme.headlineSmall)),
                              if (lawyer.verificationStatus == VerificationStatus.verified) ...[
                                const SizedBox(width: AppSpacing.xxs),
                                const Icon(Icons.verified, color: AppColors.primary, size: 20),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: AppColors.secondary),
                              const SizedBox(width: AppSpacing.xxs),
                              Text('${lawyer.rating} (${lawyer.reviewsCount})', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            l10n.lawyerAvailabilityBadge(lawyer.availabilityWindow.label(l10n)),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.statusColors.success.foreground),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          value: '${(lawyer.rating / 5 * 100).round()}%',
                          label: l10n.lawyerStatSatisfaction,
                        ),
                      ),
                      const _StatDivider(),
                      Expanded(child: _StatItem(value: '+${lawyer.reviewsCount}', label: l10n.lawyerStatConsultations)),
                      const _StatDivider(),
                      Expanded(child: _StatItem(value: '+${lawyer.yearsOfExperience}', label: l10n.lawyerStatYears)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(title: l10n.lawyerAboutTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(lawyer.bio, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(title: l10n.lawyerSpecialtiesTitle),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xxs,
                  runSpacing: AppSpacing.xxs,
                  children: [for (final specialty in lawyer.specialties) AppChip(label: specialty.label(l10n), selected: false)],
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(title: l10n.lawyerConsultationTypesTitle),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < lawyer.consultationTypes.length; i++) ...[
                        _ConsultationTypeRow(type: lawyer.consultationTypes[i], price: lawyer.pricing[lawyer.consultationTypes[i]]),
                        if (i != lawyer.consultationTypes.length - 1) const Divider(height: AppSpacing.lg),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(title: l10n.lawyerExperienceTitle),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.work_outline, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(l10n.lawyerYearsExperience(lawyer.yearsOfExperience), style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(title: l10n.lawyerReviewsTitle),
                const SizedBox(height: AppSpacing.xs),
                const _ReviewsSection(),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AppButton(
                label: l10n.lawyerBookConsultation,
                icon: Icons.event_available_outlined,
                onPressed: () => context.push(RoutePaths.lawyerBookingFor(routeBase, lawyer.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 36, child: VerticalDivider(width: AppSpacing.lg));
  }
}

class _Review {
  const _Review({required this.reviewerName, required this.rating, required this.comment});
  final String reviewerName;
  final int rating;
  final String comment;
}

/// Two illustrative reviews — the mock model has no per-lawyer review list
/// (only an aggregate rating/count), so this is presentation-only demo
/// content, same as the reference's example cards, not wired to a
/// submission flow.
class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection();

  static const _reviews = [
    _Review(reviewerName: 'م. خالد النابلسي', rating: 5, comment: 'محامٍ محترف ودقيق، ساعدني في إتمام عقد الشراكة بشكل مثالي.'),
    _Review(reviewerName: 'أ. سارة الحداد', rating: 5, comment: 'خدمة ممتازة واستجابة سريعة، أنصح بالتعامل معه.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _reviews.length; i++) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(_reviews[i].reviewerName, style: Theme.of(context).textTheme.titleSmall)),
                    Row(
                      children: [for (var s = 0; s < _reviews[i].rating; s++) const Icon(Icons.star, size: 14, color: AppColors.secondary)],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(_reviews[i].comment, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (i != _reviews.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ConsultationTypeRow extends StatelessWidget {
  const _ConsultationTypeRow({required this.type, required this.price});

  final ConsultationType type;
  final double? price;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Icon(type.icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(type.label(l10n), style: Theme.of(context).textTheme.bodyMedium)),
        if (price != null) Text(l10n.lawyerPriceSar(price!.toStringAsFixed(0)), style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
