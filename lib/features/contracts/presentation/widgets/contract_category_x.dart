import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_category.dart';

/// Localized label + icon for each category — the type-selection grid,
/// contract cards, and details screen all pull from here instead of
/// re-declaring the mapping.
extension ContractCategoryX on ContractCategory {
  String label(AppLocalizations l10n) {
    return switch (this) {
      ContractCategory.employment => l10n.contractCategoryEmployment,
      ContractCategory.sale => l10n.contractCategorySale,
      ContractCategory.rental => l10n.contractCategoryRental,
      ContractCategory.partnership => l10n.contractCategoryPartnership,
      ContractCategory.nda => l10n.contractCategoryNda,
      ContractCategory.serviceAgreement => l10n.contractCategoryServiceAgreement,
      ContractCategory.other => l10n.contractCategoryOther,
    };
  }

  IconData get icon {
    return switch (this) {
      ContractCategory.employment => Icons.badge_outlined,
      ContractCategory.sale => Icons.shopping_bag_outlined,
      ContractCategory.rental => Icons.home_outlined,
      ContractCategory.partnership => Icons.handshake_outlined,
      ContractCategory.nda => Icons.lock_outline,
      ContractCategory.serviceAgreement => Icons.build_outlined,
      ContractCategory.other => Icons.description_outlined,
    };
  }
}
