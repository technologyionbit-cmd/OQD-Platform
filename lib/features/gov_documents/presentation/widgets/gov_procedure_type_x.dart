import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/features/gov_documents/domain/entities/gov_procedure.dart';

extension GovProcedureTypeX on GovProcedureType {
  String title(AppLocalizations l10n) {
    return switch (this) {
      GovProcedureType.companyRegistration => l10n.govProcedureCompanyRegistration,
      GovProcedureType.propertyRegistration => l10n.govProcedurePropertyRegistration,
      GovProcedureType.contractNotarization => l10n.govProcedureContractNotarization,
      GovProcedureType.lawsuitFiling => l10n.govProcedureLawsuitFiling,
    };
  }

  String category(AppLocalizations l10n) {
    return switch (this) {
      GovProcedureType.companyRegistration => l10n.govProcedureCompanyRegistrationCategory,
      GovProcedureType.propertyRegistration => l10n.govProcedurePropertyRegistrationCategory,
      GovProcedureType.contractNotarization => l10n.govProcedureContractNotarizationCategory,
      GovProcedureType.lawsuitFiling => l10n.govProcedureLawsuitFilingCategory,
    };
  }

  IconData get icon {
    return switch (this) {
      GovProcedureType.companyRegistration => Icons.apartment_outlined,
      GovProcedureType.propertyRegistration => Icons.home_work_outlined,
      GovProcedureType.contractNotarization => Icons.fact_check_outlined,
      GovProcedureType.lawsuitFiling => Icons.gavel_outlined,
    };
  }
}

extension GovProcedureAccessTypeX on GovProcedureAccessType {
  String label(AppLocalizations l10n) {
    return switch (this) {
      GovProcedureAccessType.directLink => l10n.govAccessDirectLink,
      GovProcedureAccessType.guide => l10n.govAccessGuide,
    };
  }

  IconData get icon {
    return switch (this) {
      GovProcedureAccessType.directLink => Icons.bolt,
      GovProcedureAccessType.guide => Icons.menu_book_outlined,
    };
  }
}
