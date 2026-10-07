import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:aqd_ionbit/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:aqd_ionbit/features/messages/domain/repositories/messages_repository.dart';

/// Consultation-scoped unread-message counts for whichever role is
/// currently signed in — backs the badge on `ConsultationsListScreen`'s
/// cards. Deliberately its own small mechanism rather than routed through
/// the app's global notification list: that list is already a single
/// un-scoped mock with known role-routing gaps, and layering chat unread
/// state on top of it would inherit those gaps for no benefit.
class ChatUnreadCountsController extends AsyncNotifier<Map<String, int>> {
  MessagesRepository get _repository => ref.read(messagesRepositoryProvider);

  @override
  FutureOr<Map<String, int>> build() async {
    ref.watch(messagesRepositoryProvider);
    if (ref.watch(currentUserIdProvider) == null) return const {}; // Signed out: no one's data.
    final role = ref.watch(authControllerProvider).value?.role;
    if (role == null) return const {};
    final result = await _repository.getUnreadCounts(viewerRole: role);
    return result.fold((failure) => const {}, (counts) => counts);
  }
}

final chatUnreadCountsProvider = AsyncNotifierProvider<ChatUnreadCountsController, Map<String, int>>(ChatUnreadCountsController.new);

/// Unread count for one consultation card — `0` while loading/on error/for
/// a consultation with nothing unread, never a stale number.
final chatUnreadCountForProvider = Provider.family<int, String>((ref, consultationId) {
  return ref.watch(chatUnreadCountsProvider).value?[consultationId] ?? 0;
});
