import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/lawyers/data/repositories/lawyers_repository_impl.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';

final lawyerByIdProvider = FutureProvider.family<LawyerProfile, String>((ref, id) async {
  final repository = ref.watch(lawyersRepositoryProvider);
  final result = await repository.getLawyerById(id);
  return result.fold((failure) => throw failure, (lawyer) => lawyer);
});
