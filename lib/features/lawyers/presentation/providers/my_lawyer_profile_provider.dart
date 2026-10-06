import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:aqd_ionbit/features/lawyers/data/repositories/lawyers_repository_impl.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';

/// The signed-in lawyer's own profile (`GET /lawyers/me`), whatever its
/// verification state. Only lawyer screens read it; null when signed out.
/// Rebuilds when the account changes, like every account-scoped provider.
final myLawyerProfileProvider = FutureProvider<LawyerProfile?>((ref) async {
  if (ref.watch(currentUserIdProvider) == null) return null;
  final result = await ref.watch(lawyersRepositoryProvider).getMyProfile();
  return result.fold((failure) => throw failure, (profile) => profile);
});
