import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_specialty.dart';

extension LawyerSpecialtyX on LawyerSpecialty {
  String label(AppLocalizations l10n) {
    return switch (this) {
      LawyerSpecialty.commercial => l10n.specialtyCommercial,
      LawyerSpecialty.personalStatus => l10n.specialtyPersonalStatus,
      LawyerSpecialty.criminal => l10n.specialtyCriminal,
      LawyerSpecialty.labor => l10n.specialtyLabor,
      LawyerSpecialty.realEstate => l10n.specialtyRealEstate,
      LawyerSpecialty.corporate => l10n.specialtyCorporate,
      LawyerSpecialty.intellectualProperty => l10n.specialtyIntellectualProperty,
      LawyerSpecialty.general => l10n.specialtyGeneral,
    };
  }
}
