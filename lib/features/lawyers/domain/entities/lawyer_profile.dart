import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_specialty.dart';

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
    @Default(true) bool isVerified,
    // Mock-only session state: flips true once a verification document has
    // been "submitted" via the profile screen's upload flow, so the status
    // card can show "Pending Review" without pretending anything was
    // actually sent to a backend. Meaningless once [isVerified] is true.
    @Default(false) bool hasPendingVerification,
  }) = _LawyerProfile;
}
