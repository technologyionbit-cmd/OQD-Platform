import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/consultations/data/repositories/consultations_repository_impl.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/availability_slot.dart';

final availabilityProvider = FutureProvider.family<List<AvailabilitySlot>, String>((ref, lawyerId) async {
  final repository = ref.watch(consultationsRepositoryProvider);
  final result = await repository.getAvailability(lawyerId);
  return result.fold((failure) => throw failure, (slots) => slots);
});
