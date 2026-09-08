import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultations_controller.dart';

/// Derived from the already-loaded list instead of a separate fetch —
/// consultation details are always reached by tapping a card that's
/// already in [consultationsControllerProvider]'s state.
final consultationByIdProvider = Provider.autoDispose.family<Consultation?, String>(
  (ref, id) => ref.watch(consultationsControllerProvider).value?.where((c) => c.id == id).firstOrNull,
);
