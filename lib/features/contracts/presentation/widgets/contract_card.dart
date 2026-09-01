import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/presentation/widgets/contract_category_x.dart';
import 'package:aqd_ionbit/features/contracts/presentation/widgets/contract_status_x.dart';

/// One row in "My Contracts" — used identically on the home screen's
/// recent-contracts section and the full contracts list, so the two never
/// drift into two different-looking cards for the same data.
class ContractCard extends StatelessWidget {
  const ContractCard({super.key, required this.contract, required this.onTap});

  final Contract contract;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(icon: contract.category.icon, size: 44),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contract.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(contract.updatedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(label: contract.status.label(l10n), tone: contract.status.tone),
        ],
      ),
    );
  }
}
