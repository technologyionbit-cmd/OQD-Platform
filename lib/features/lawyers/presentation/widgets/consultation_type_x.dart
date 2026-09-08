import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

extension ConsultationTypeX on ConsultationType {
  String label(AppLocalizations l10n) {
    return switch (this) {
      ConsultationType.video => l10n.consultationTypeVideo,
      ConsultationType.voice => l10n.consultationTypeVoice,
      ConsultationType.written => l10n.consultationTypeWritten,
    };
  }

  IconData get icon {
    return switch (this) {
      ConsultationType.video => Icons.videocam_outlined,
      ConsultationType.voice => Icons.call_outlined,
      ConsultationType.written => Icons.chat_bubble_outline,
    };
  }
}
