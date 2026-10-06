import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_remote_data_source.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_specialty.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/verification_status.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/verification_document_upload.dart';

/// The seeded lawyer that tests sign in as (سارة المطيري). The consultations
/// mock seeds her slots and bookings, so the client and lawyer sides of a
/// test share the same data.
const kDemoLawyerId = 'lwr_seed_1';

/// In-memory stand-in for tests.
class LawyersMockDataSource implements LawyersRemoteDataSource {
  final List<LawyerProfile> _lawyers = [
    const LawyerProfile(
      id: kDemoLawyerId,
      fullName: 'سارة المطيري',
      specialties: [LawyerSpecialty.commercial, LawyerSpecialty.corporate],
      bio: 'محامية متخصصة في القانون التجاري والشركات مع خبرة تمتد لأكثر من 9 سنوات في صياغة العقود التجارية وتأسيس الشركات.',
      yearsOfExperience: 9,
      rating: 4.8,
      reviewsCount: 132,
      consultationTypes: [ConsultationType.video, ConsultationType.voice, ConsultationType.written],
      pricing: {ConsultationType.video: 250, ConsultationType.voice: 180, ConsultationType.written: 100},
    ),
    const LawyerProfile(
      id: 'lwr_seed_2',
      fullName: 'محمد القحطاني',
      specialties: [LawyerSpecialty.realEstate, LawyerSpecialty.general],
      bio: 'محامٍ عقاري بخبرة 12 عامًا في عقود الإيجار والبيع والتوثيق العقاري.',
      yearsOfExperience: 12,
      rating: 4.6,
      reviewsCount: 98,
      consultationTypes: [ConsultationType.video, ConsultationType.written],
      pricing: {ConsultationType.video: 220, ConsultationType.written: 90},
    ),
    const LawyerProfile(
      id: 'lwr_seed_3',
      fullName: 'نورة الحربي',
      specialties: [LawyerSpecialty.personalStatus, LawyerSpecialty.general],
      bio: 'محامية متخصصة في قضايا الأحوال الشخصية والأسرة، حاصلة على زمالة في الوساطة الأسرية.',
      yearsOfExperience: 6,
      rating: 4.9,
      reviewsCount: 210,
      consultationTypes: [ConsultationType.voice, ConsultationType.written],
      pricing: {ConsultationType.voice: 150, ConsultationType.written: 80},
    ),
    const LawyerProfile(
      id: 'lwr_seed_4',
      fullName: 'خالد العنزي',
      specialties: [LawyerSpecialty.criminal],
      bio: 'محامٍ جنائي بخبرة 15 عامًا في الترافع أمام المحاكم الجزائية.',
      yearsOfExperience: 15,
      rating: 4.4,
      reviewsCount: 76,
      consultationTypes: [ConsultationType.video, ConsultationType.voice],
      pricing: {ConsultationType.video: 300, ConsultationType.voice: 220},
    ),
    const LawyerProfile(
      id: 'lwr_seed_5',
      fullName: 'ريم الدوسري',
      specialties: [LawyerSpecialty.labor, LawyerSpecialty.intellectualProperty],
      bio: 'محامية متخصصة في قانون العمل والملكية الفكرية، عملت مع عدد من الشركات الناشئة.',
      yearsOfExperience: 4,
      rating: 4.5,
      reviewsCount: 41,
      consultationTypes: [ConsultationType.video, ConsultationType.voice, ConsultationType.written],
      pricing: {ConsultationType.video: 190, ConsultationType.voice: 140, ConsultationType.written: 70},
    ),
  ];

  @override
  Future<List<LawyerProfile>> getLawyers({String? query, LawyerSpecialty? specialty, double? minRating, int? page}) async {
    await _simulateLatency();
    final filtered =
        _lawyers.where((lawyer) {
          final matchesQuery = query == null || query.isEmpty || lawyer.fullName.toLowerCase().contains(query.toLowerCase());
          final matchesSpecialty = specialty == null || lawyer.specialties.contains(specialty);
          final matchesRating = minRating == null || lawyer.rating >= minRating;
          return matchesQuery && matchesSpecialty && matchesRating;
        }).toList();
    filtered.sort((a, b) => b.rating.compareTo(a.rating));
    return filtered;
  }

  @override
  Future<LawyerProfile> getLawyerById(String id) async {
    await _simulateLatency();
    return _lawyers.firstWhere((lawyer) => lawyer.id == id, orElse: () => throw const NotFoundFailure());
  }

  /// Tests sign in as the seeded lawyer [kDemoLawyerId].
  @override
  Future<LawyerProfile> getMyProfile() => getLawyerById(kDemoLawyerId);

  @override
  Future<LawyerProfile> updateProfile(LawyerProfile profile) async {
    await _simulateLatency();
    final index = _lawyers.indexWhere((lawyer) => lawyer.id == profile.id);
    if (index == -1) throw const NotFoundFailure();
    _lawyers[index] = profile;
    return profile;
  }

  @override
  Future<LawyerProfile> submitVerification(List<VerificationDocumentUpload> documents) async {
    final current = await getMyProfile();
    return updateProfile(current.copyWith(verificationStatus: VerificationStatus.pending, verificationRejectionReason: null));
  }

  Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 450));
}
