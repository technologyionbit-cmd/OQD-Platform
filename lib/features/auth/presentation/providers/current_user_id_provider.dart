import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';

/// The signed-in account's id, or null when signed out.
///
/// Every provider that holds one account's data watches this, so signing
/// out or switching accounts rebuilds it: the next account never sees the
/// previous one's consultations, contracts or notifications. Public data
/// (the lawyers marketplace, contract templates) does not need it.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider.select((state) => state.value?.id));
});
