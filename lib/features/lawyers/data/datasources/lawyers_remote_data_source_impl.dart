import 'package:dio/dio.dart';

import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_remote_data_source.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_specialty.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/verification_status.dart';

/// Dio-backed implementation talking to `<apiBaseUrl>/lawyers/*`
/// (docs/backend/09-lawyers-marketplace.md, docs/plans/individual-user-rollout.md
/// Part 3). Transport errors are mapped to typed `Failure`s via
/// [ApiErrorMapper] so nothing above this layer ever sees a [DioException].
///
/// [updateProfile] is lawyer-side self-service (out of this part's scope —
/// no `/lawyers/me` endpoint exists yet) and is intentionally left calling
/// a route the backend doesn't serve yet; `lawyer_profile_edit_screen_test.dart`
/// covers that screen entirely against [LawyersMockDataSource] via provider
/// override, so this never runs in tests.
class LawyersRemoteDataSourceImpl implements LawyersRemoteDataSource {
  LawyersRemoteDataSourceImpl(this._dio, {ApiErrorMapper errorMapper = const ApiErrorMapper()}) : _errorMapper = errorMapper;

  final Dio _dio;
  final ApiErrorMapper _errorMapper;

  @override
  Future<List<LawyerProfile>> getLawyers({String? query, LawyerSpecialty? specialty, double? minRating, int? page}) {
    return _call(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/lawyers',
        queryParameters: {
          if (query != null && query.isNotEmpty) 'query': query,
          if (specialty != null) 'specialty': specialty.name,
          if (minRating != null) 'minRating': minRating,
          if (page != null) 'page': page,
        },
      );
      final rows = (res.data!['data'] as List).cast<Map<String, dynamic>>();
      return rows.map(_parseLawyer).toList(growable: false);
    });
  }

  @override
  Future<LawyerProfile> getLawyerById(String id) {
    return _call(() async {
      final res = await _dio.get<Map<String, dynamic>>('/lawyers/$id');
      return _parseLawyer(res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<LawyerProfile> updateProfile(LawyerProfile profile) {
    return _call(() async {
      final res = await _dio.patch<Map<String, dynamic>>(
        '/lawyers/me',
        data: {
          'bio': profile.bio,
          'yearsOfExperience': profile.yearsOfExperience,
          'specialties': profile.specialties.map((s) => s.name).toList(),
          'pricing': profile.pricing.map((type, price) => MapEntry(type.name, price)),
        },
      );
      return _parseLawyer(res.data!['data'] as Map<String, dynamic>);
    });
  }

  LawyerProfile _parseLawyer(Map<String, dynamic> row) {
    final pricing = (row['pricing'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(ConsultationType.values.byName(key), (value as num).toDouble()),
    );
    return LawyerProfile(
      id: row['id'] as String,
      fullName: row['fullName'] as String,
      specialties: (row['specialties'] as List).cast<String>().map(LawyerSpecialty.values.byName).toList(growable: false),
      bio: row['bio'] as String,
      yearsOfExperience: row['yearsOfExperience'] as int,
      rating: (row['rating'] as num).toDouble(),
      reviewsCount: row['reviewsCount'] as int,
      consultationTypes: (row['consultationTypes'] as List)
          .cast<String>()
          .map(ConsultationType.values.byName)
          .toList(growable: false),
      pricing: pricing,
      verificationStatus: VerificationStatus.values.byName(row['verificationStatus'] as String),
    );
  }

  /// Runs [action], translating any [DioException] (or unexpected error)
  /// into a typed [Failure] before it escapes this layer.
  Future<T> _call<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      throw _errorMapper.map(error);
    }
  }
}
