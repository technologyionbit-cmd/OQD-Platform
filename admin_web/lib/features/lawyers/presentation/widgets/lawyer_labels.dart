import 'package:aqd_admin/core/localization/generated/app_localizations.dart';

String specialtyLabel(AppLocalizations l10n, String specialty) => switch (specialty) {
      'commercial' => l10n.spCommercial,
      'personalStatus' => l10n.spPersonalStatus,
      'criminal' => l10n.spCriminal,
      'labor' => l10n.spLabor,
      'realEstate' => l10n.spRealEstate,
      'corporate' => l10n.spCorporate,
      'intellectualProperty' => l10n.spIntellectualProperty,
      'general' => l10n.spGeneral,
      _ => specialty,
    };
