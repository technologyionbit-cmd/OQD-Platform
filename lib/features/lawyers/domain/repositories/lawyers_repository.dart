import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';

abstract interface class LawyersRepository {
  Future<Result<List<LawyerProfile>>> getLawyers();

  Future<Result<LawyerProfile>> getLawyerById(String id);

  Future<Result<LawyerProfile>> updateProfile(LawyerProfile profile);
}
