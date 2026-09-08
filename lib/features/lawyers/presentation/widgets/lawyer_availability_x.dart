import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';

/// Coarse "how soon can I book this lawyer" bucket shown as a marketplace
/// filter/badge. Derived deterministically from the lawyer's id rather than
/// reading the real slot calendar (owned by the consultations feature) —
/// keeps the marketplace feature from depending on consultations just to
/// render a filter chip; the actual date/time picker in the booking flow
/// is the source of truth for real slot availability.
enum LawyerAvailabilityWindow { today, thisWeek, later }

extension LawyerAvailabilityX on LawyerProfile {
  LawyerAvailabilityWindow get availabilityWindow {
    final bucket = id.hashCode % 3;
    return switch (bucket) {
      0 => LawyerAvailabilityWindow.today,
      1 => LawyerAvailabilityWindow.thisWeek,
      _ => LawyerAvailabilityWindow.later,
    };
  }
}

extension LawyerAvailabilityWindowX on LawyerAvailabilityWindow {
  String label(AppLocalizations l10n) {
    return switch (this) {
      LawyerAvailabilityWindow.today => l10n.lawyerAvailableToday,
      LawyerAvailabilityWindow.thisWeek => l10n.lawyerAvailableThisWeek,
      LawyerAvailabilityWindow.later => l10n.lawyerAvailableLater,
    };
  }
}
