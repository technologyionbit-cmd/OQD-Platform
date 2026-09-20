import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_specialty.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/verification_status.dart';

part 'lawyer_profile.freezed.dart';

/// The one lawyer profile that matches the demo `lawyer@aqd.test` account
/// — there's no real multi-tenant backend, so every lawyer-role screen
/// (dashboard, schedule, requests, clients, earnings, profile) scopes
/// itself to this id rather than to a real signed-in lawyer's id.
const kDemoLawyerId = 'lwr_seed_1';

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
  }) = _LawyerProfile;
}
