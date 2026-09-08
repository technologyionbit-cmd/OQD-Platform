import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';

/// Wire-level contract for the lawyers-marketplace feature. Mirrors
/// `ContractsRemoteDataSource` — throws a [Failure] on any failure path,
/// never a raw exception.
abstract interface class LawyersRemoteDataSource {
  Future<List<LawyerProfile>> getLawyers();

  Future<LawyerProfile> getLawyerById(String id);

  Future<LawyerProfile> updateProfile(LawyerProfile profile);
}
