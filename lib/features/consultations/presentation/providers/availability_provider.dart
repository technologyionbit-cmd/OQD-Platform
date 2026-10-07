import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/consultations/data/repositories/consultations_repository_impl.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/availability_slot.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/providers/my_lawyer_profile_provider.dart';

/// The signed-in lawyer's own slots (empty for any other account).
final myAvailabilityProvider = FutureProvider<List<AvailabilitySlot>>((ref) async {
  final profile = await ref.watch(myLawyerProfileProvider.future);
  if (profile == null) return const [];
  return ref.watch(availabilityProvider(profile.id).future);
});

final availabilityProvider = FutureProvider.family<List<AvailabilitySlot>, String>((ref, lawyerId) async {
  final repository = ref.watch(consultationsRepositoryProvider);
  final result = await repository.getAvailability(lawyerId);
  return result.fold((failure) => throw failure, (slots) => slots);
});
