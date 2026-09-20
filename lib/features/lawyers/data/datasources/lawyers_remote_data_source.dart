import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_specialty.dart';

/// Wire-level contract for the lawyers-marketplace feature. Mirrors
/// `ContractsRemoteDataSource` — throws a [Failure] on any failure path,
/// never a raw exception.
abstract interface class LawyersRemoteDataSource {
  /// All filters optional and additive — calling with none returns the
  /// same full (verified) list as before real search/filtering existed
  /// server-side (docs/plans/individual-user-rollout.md Part 3, correction 1).
  Future<List<LawyerProfile>> getLawyers({String? query, LawyerSpecialty? specialty, double? minRating, int? page});

  Future<LawyerProfile> getLawyerById(String id);

  Future<LawyerProfile> updateProfile(LawyerProfile profile);
}
