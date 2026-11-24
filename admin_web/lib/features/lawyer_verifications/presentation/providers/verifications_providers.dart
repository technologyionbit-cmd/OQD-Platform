import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/features/lawyer_verifications/data/verifications_repository.dart';
import 'package:aqd_admin/features/lawyer_verifications/domain/pending_lawyer.dart';

final verificationsRepositoryProvider = Provider<VerificationsRepository>((ref) => VerificationsRepository(ref.watch(apiClientProvider).dio));

final pendingLawyersProvider = FutureProvider.autoDispose<List<PendingLawyer>>((ref) => ref.watch(verificationsRepositoryProvider).pending());
