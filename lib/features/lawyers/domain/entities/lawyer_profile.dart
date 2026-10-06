import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_specialty.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/verification_status.dart';

part 'lawyer_profile.freezed.dart';

@freezed
abstract class LawyerProfile with _$LawyerProfile {
  const factory LawyerProfile({
    required String id,
    required String fullName,
    required List<LawyerSpecialty> specialties,
    required String bio,
    required int yearsOfExperience,
    required double rating,
    required int reviewsCount,
    required List<ConsultationType> consultationTypes,
    required Map<ConsultationType, double> pricing,
    @Default(VerificationStatus.verified) VerificationStatus verificationStatus,
    /// Why an admin rejected verification — only on the lawyer's own
    /// profile (`GET /lawyers/me`), never on public ones.
    String? verificationRejectionReason,
  }) = _LawyerProfile;
}
