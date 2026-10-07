import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/app_chip.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/verification_status.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/lawyer_specialty_x.dart';

/// One row in the marketplace list — also reused by the client home
/// screen's "recommended lawyers" section so both never drift apart.
class LawyerCard extends StatelessWidget {
  const LawyerCard({super.key, required this.lawyer, required this.onTap});

  final LawyerProfile lawyer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(icon: Icons.person_outline),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            lawyer.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        if (lawyer.verificationStatus == VerificationStatus.verified) ...[
                          const SizedBox(width: AppSpacing.xxs),
                          const Icon(Icons.verified, size: 16, color: AppColors.primary),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: AppColors.secondary),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          '${lawyer.rating} (${lawyer.reviewsCount})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text('·', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            l10n.lawyerYearsExperience(lawyer.yearsOfExperience),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xxs,
            runSpacing: AppSpacing.xxs,
            children: [for (final specialty in lawyer.specialties) AppChip(label: specialty.label(l10n), selected: false)],
          ),
        ],
      ),
    );
  }
}
