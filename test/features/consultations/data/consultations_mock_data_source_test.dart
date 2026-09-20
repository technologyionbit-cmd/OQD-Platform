import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_mock_data_source.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';

void main() {
  late ConsultationsMockDataSource dataSource;

  setUp(() => dataSource = ConsultationsMockDataSource());

  test('getConsultations returns the seeded consultations', () async {
    final consultations = await dataSource.getConsultations();
    expect(consultations.length, 10);
  });

  test('bookConsultation creates a pending-approval consultation and books the matching slot', () async {
    final slots = await dataSource.getAvailability(kDemoLawyerId);
    final openSlot = slots.firstWhere((s) => !s.isBooked);

    final booked = await dataSource.bookConsultation(
      lawyerId: kDemoLawyerId,
      lawyerName: 'سارة المطيري',
      type: ConsultationType.video,
      scheduledAt: openSlot.start,
      price: 100,
      notes: 'ملاحظة',
    );

    expect(booked.status, ConsultationStatus.pendingApproval);

    final updatedSlots = await dataSource.getAvailability(kDemoLawyerId);
    final matching = updatedSlots.firstWhere((s) => s.id == openSlot.id);
    expect(matching.isBooked, isTrue);
  });

  test('acceptRequest moves a consultation to confirmed', () async {
    final updated = await dataSource.acceptRequest('cons_seed_3');
    expect(updated.status, ConsultationStatus.confirmed);
  });

  test('rejectRequest moves a consultation to declined and frees its slot', () async {
    final updated = await dataSource.rejectRequest('cons_seed_3');
    expect(updated.status, ConsultationStatus.declined);
  });

  test('complete moves a confirmed consultation to completed', () async {
    final updated = await dataSource.complete('cons_seed_1');
    expect(updated.status, ConsultationStatus.completed);
  });

  test('getAvailability generates slots only on working days (Sun-Thu)', () async {
    final slots = await dataSource.getAvailability('lwr_seed_2');
    expect(slots, isNotEmpty);
    expect(slots.any((s) => s.start.weekday == DateTime.friday || s.start.weekday == DateTime.saturday), isFalse);
  });

  test('markMissed moves a consultation to missed', () async {
    final updated = await dataSource.markMissed('cons_seed_1');
    expect(updated.status, ConsultationStatus.missed);
  });

  test('markFailed moves a consultation to failed', () async {
    final updated = await dataSource.markFailed('cons_seed_1');
    expect(updated.status, ConsultationStatus.failed);
  });

  test('bookConsultation sets consultationId on the slot it books', () async {
    final slots = await dataSource.getAvailability(kDemoLawyerId);
    final openSlot = slots.firstWhere((s) => !s.isBooked);

    final booked = await dataSource.bookConsultation(
      lawyerId: kDemoLawyerId,
      lawyerName: 'سارة المطيري',
      type: ConsultationType.video,
      scheduledAt: openSlot.start,
      price: 100,
      notes: '',
    );

    final updatedSlots = await dataSource.getAvailability(kDemoLawyerId);
    final matching = updatedSlots.firstWhere((s) => s.id == openSlot.id);
    expect(matching.consultationId, booked.id);
  });

  test('rejecting a request clears consultationId along with unbooking the slot', () async {
    final slotsBefore = await dataSource.getAvailability(kDemoLawyerId);
    final bookedSlot = slotsBefore.firstWhere((s) => s.isBooked && s.consultationId != null);

    await dataSource.rejectRequest(bookedSlot.consultationId!);

    final slotsAfter = await dataSource.getAvailability(kDemoLawyerId);
    final matching = slotsAfter.firstWhere((s) => s.id == bookedSlot.id);
    expect(matching.isBooked, isFalse);
    expect(matching.consultationId, isNull);
  });

  test('every confirmed seeded consultation for the demo lawyer has a correlated, correctly-linked slot', () async {
    final consultations = await dataSource.getConsultations();
    final slots = await dataSource.getAvailability(kDemoLawyerId);
    final confirmedForDemoLawyer = consultations.where((c) => c.lawyerId == kDemoLawyerId && c.status == ConsultationStatus.confirmed);

    for (final consultation in confirmedForDemoLawyer) {
      final matching = slots.where((s) => s.consultationId == consultation.id);
      expect(matching, hasLength(1), reason: 'expected exactly one linked slot for ${consultation.id}');
      expect(matching.single.isBooked, isTrue);
    }
  });

  test('addAvailabilitySlot / removeAvailabilitySlot round-trip', () async {
    final start = DateTime.now().add(const Duration(days: 20));
    final added = await dataSource.addAvailabilitySlot(lawyerId: kDemoLawyerId, start: start, end: start.add(const Duration(hours: 1)));
    expect((await dataSource.getAvailability(kDemoLawyerId)).any((s) => s.id == added.id), isTrue);

    await dataSource.removeAvailabilitySlot(added.id);
    expect((await dataSource.getAvailability(kDemoLawyerId)).any((s) => s.id == added.id), isFalse);
  });
}
