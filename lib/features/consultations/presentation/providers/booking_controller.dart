import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:aqd_ionbit/features/consultations/data/repositories/consultations_repository_impl.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/availability_provider.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/booking_state.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultations_controller.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

/// Drives the type → date/time → details → confirm booking flow. Mirrors
/// `ContractDraftController`.
class BookingController extends Notifier<BookingState> {
  @override
  BookingState build() {
    ref.watch(currentUserIdProvider); // Fresh state for each account.
    return const BookingState();
  }

  void startBooking({required String lawyerId, required String lawyerName}) {
    state = BookingState(lawyerId: lawyerId, lawyerName: lawyerName);
  }

  void selectType(ConsultationType type, double price) {
    state = state.copyWith(type: type, price: price);
  }

  void selectSlot(DateTime dateTime) {
    state = state.copyWith(scheduledAt: dateTime);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  Future<Result<Consultation>> confirm() async {
    final lawyerId = state.lawyerId;
    final lawyerName = state.lawyerName;
    final type = state.type;
    final scheduledAt = state.scheduledAt;
    if (lawyerId == null || lawyerName == null || type == null || scheduledAt == null) {
      throw StateError('BookingController.confirm called with an incomplete booking flow');
    }

    final repository = ref.read(consultationsRepositoryProvider);
    final result = await repository.bookConsultation(
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      type: type,
      scheduledAt: scheduledAt,
      price: state.price ?? 0,
      notes: state.notes,
    );

    if (result.isSuccess) {
      await ref.read(consultationsControllerProvider.notifier).refresh();
      ref.invalidate(availabilityProvider(lawyerId));
      state = const BookingState();
    }
    return result;
  }

  void reset() => state = const BookingState();
}

final bookingControllerProvider = NotifierProvider<BookingController, BookingState>(BookingController.new);
