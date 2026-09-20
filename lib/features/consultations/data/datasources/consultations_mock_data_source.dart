import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_remote_data_source.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/availability_slot.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_message.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

/// Temporary, isolated stand-in for the real backend — no
/// scheduling/booking API is available yet. `lwr_seed_1` is the lawyer
/// profile matching the demo `lawyer@aqd.test` account (see
/// `LawyersMockDataSource`'s doc), so her seeded consultations/availability
/// are what the lawyer-side dashboard/schedule/requests screens show, and
/// what the client-side booking flow actually books against.
class ConsultationsMockDataSource implements ConsultationsRemoteDataSource {
  ConsultationsMockDataSource() {
    _availabilityByLawyer['lwr_seed_1'] = _generateSlots('lwr_seed_1');
    _correlateSeededBookings('lwr_seed_1');
  }

  final List<Consultation> _consultations = [
    Consultation(
      id: 'cons_seed_1',
      lawyerId: 'lwr_seed_1',
      lawyerName: 'سارة المطيري',
      clientName: 'أحمد العتيبي',
      type: ConsultationType.video,
      status: ConsultationStatus.confirmed,
      scheduledAt: DateTime.now().add(const Duration(minutes: 20)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      price: 250,
      notes: 'أحتاج استشارة بخصوص صياغة بند عدم المنافسة في عقد عمل جديد.',
    ),
    Consultation(
      id: 'cons_seed_2',
      lawyerId: 'lwr_seed_1',
      lawyerName: 'سارة المطيري',
      clientName: 'أحمد العتيبي',
      type: ConsultationType.written,
      status: ConsultationStatus.completed,
      scheduledAt: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      price: 100,
      notes: 'مراجعة عقد إيجار تجاري قبل التوقيع.',
      messages: [
        ConsultationMessage(
          id: 'msg_1',
          text: 'مرحبًا، أرسلت لك تفاصيل العقد، هل يمكنك مراجعته؟',
          sentAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
          isFromLawyer: false,
        ),
        ConsultationMessage(
          id: 'msg_2',
          text: 'أهلاً بك، اطلعت على العقد. أنصح بتعديل بند فسخ العقد المبكر ليكون أكثر وضوحًا.',
          sentAt: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
          isFromLawyer: true,
        ),
        ConsultationMessage(
          id: 'msg_3',
          text: 'شكرًا جزيلاً، سأطلب من الطرف الآخر تعديل البند.',
          sentAt: DateTime.now().subtract(const Duration(days: 3)),
          isFromLawyer: false,
        ),
      ],
    ),
    Consultation(
      id: 'cons_seed_3',
      lawyerId: 'lwr_seed_1',
      lawyerName: 'سارة المطيري',
      clientName: 'محمد العلي',
      type: ConsultationType.voice,
      status: ConsultationStatus.pendingApproval,
      scheduledAt: DateTime.now().add(const Duration(days: 1, hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      price: 180,
      notes: 'استفسار سريع حول شروط إنهاء عقد شراكة.',
    ),
    Consultation(
      id: 'cons_seed_4',
      lawyerId: 'lwr_seed_1',
      lawyerName: 'سارة المطيري',
      clientName: 'فهد الشمري',
      type: ConsultationType.video,
      status: ConsultationStatus.cancelled,
      scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      price: 250,
    ),
    Consultation(
      id: 'cons_seed_5',
      lawyerId: 'lwr_seed_2',
      lawyerName: 'محمد القحطاني',
      clientName: 'أحمد العتيبي',
      type: ConsultationType.video,
      status: ConsultationStatus.confirmed,
      scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 5)),
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      price: 220,
    ),
    // Written, confirmed, and scheduled to start within the join window
    // right now — lets a manual tester reach the live written-chat room
    // (waiting -> ready -> active, skipping `connecting`) without waiting.
    // `MessagesMockDataSource` seeds this ID with a short pre-session
    // exchange, the lawyer's last line left unread.
    Consultation(
      id: 'cons_seed_6',
      lawyerId: 'lwr_seed_1',
      lawyerName: 'سارة المطيري',
      clientName: 'أحمد العتيبي',
      type: ConsultationType.written,
      status: ConsultationStatus.confirmed,
      scheduledAt: DateTime.now().add(const Duration(minutes: 1)),
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      price: 100,
      notes: 'استشارة سريعة حول خطاب إنذار قبل رفع دعوى.',
    ),
    // Written, confirmed, but scheduled well into the future — demonstrates
    // the chat-specific pre-consultation lobby state (disabled composer,
    // countdown) rather than the live room.
    Consultation(
      id: 'cons_seed_7',
      lawyerId: 'lwr_seed_1',
      lawyerName: 'سارة المطيري',
      clientName: 'أحمد العتيبي',
      type: ConsultationType.written,
      status: ConsultationStatus.confirmed,
      scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      price: 100,
      notes: 'مراجعة مسودة اتفاقية شراكة قبل توقيعها.',
    ),
    // Voice, confirmed, and scheduled to start right now — these three IDs
    // are specifically chosen so `ConsultationRoomMockDataSource`'s
    // hash-seeded connection profile lands on each of its three outcomes
    // (verified via `consultationId.hashCode.abs() % 3`), letting a manual
    // tester or test suite reach every Voice Call demo path deterministically:
    // a clean connection, a connection that drops and recovers on retry, and
    // one that never connects (permanent failure / lawyer unavailable).
    Consultation(
      id: 'cons_seed_8',
      lawyerId: 'lwr_seed_1',
      lawyerName: 'سارة المطيري',
      clientName: 'أحمد العتيبي',
      type: ConsultationType.voice,
      status: ConsultationStatus.confirmed,
      scheduledAt: DateTime.now().add(const Duration(minutes: 1)),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      price: 180,
      notes: 'استشارة صوتية حول شروط فسخ عقد إيجار.',
    ),
    Consultation(
      id: 'cons_seed_9',
      lawyerId: 'lwr_seed_1',
      lawyerName: 'سارة المطيري',
      clientName: 'أحمد العتيبي',
      type: ConsultationType.voice,
      status: ConsultationStatus.confirmed,
      scheduledAt: DateTime.now().add(const Duration(minutes: 1)),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      price: 180,
      notes: 'استشارة صوتية عاجلة بخصوص نزاع تجاري.',
    ),
    Consultation(
      id: 'cons_seed_11',
      lawyerId: 'lwr_seed_1',
      lawyerName: 'سارة المطيري',
      clientName: 'أحمد العتيبي',
      type: ConsultationType.voice,
      status: ConsultationStatus.confirmed,
      scheduledAt: DateTime.now().add(const Duration(minutes: 1)),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      price: 180,
      notes: 'استشارة صوتية حول تعديل بنود اتفاقية شراكة.',
    ),
  ];

  final Map<String, List<AvailabilitySlot>> _availabilityByLawyer = {};

  @override
  Future<List<Consultation>> getConsultations() async {
    await _simulateLatency();
    final sorted = List<Consultation>.of(_consultations)..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return sorted;
  }

  @override
  Future<Consultation> getConsultationById(String id) async {
    await _simulateLatency();
    return _consultations.firstWhere((c) => c.id == id, orElse: () => throw const NotFoundFailure());
  }

  @override
  Future<List<AvailabilitySlot>> getAvailability(String lawyerId) async {
    await _simulateLatency();
    final slots = _availabilityByLawyer.putIfAbsent(lawyerId, () => _generateSlots(lawyerId));
    final sorted = List<AvailabilitySlot>.of(slots)..sort((a, b) => a.start.compareTo(b.start));
    return sorted;
  }

  @override
  Future<AvailabilitySlot> addAvailabilitySlot({required String lawyerId, required DateTime start, required DateTime end}) async {
    await _simulateLatency();
    final slot = AvailabilitySlot(id: 'slot_${DateTime.now().microsecondsSinceEpoch}', lawyerId: lawyerId, start: start, end: end);
    _availabilityByLawyer.putIfAbsent(lawyerId, () => []).add(slot);
    return slot;
  }

  @override
  Future<void> removeAvailabilitySlot(String slotId) async {
    await _simulateLatency();
    for (final slots in _availabilityByLawyer.values) {
      slots.removeWhere((slot) => slot.id == slotId);
    }
  }

  @override
  Future<Consultation> bookConsultation({
    required String lawyerId,
    required String lawyerName,
    required ConsultationType type,
    required DateTime scheduledAt,
    required double price,
    required String notes,
  }) async {
    await _simulateLatency();
    final consultation = Consultation(
      id: 'cons_${DateTime.now().microsecondsSinceEpoch}',
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      clientName: 'أحمد العتيبي',
      type: type,
      status: ConsultationStatus.pendingApproval,
      scheduledAt: scheduledAt,
      createdAt: DateTime.now(),
      price: price,
      notes: notes,
    );
    _consultations.insert(0, consultation);
    _markSlot(lawyerId, scheduledAt, isBooked: true, consultationId: consultation.id);
    return consultation;
  }

  @override
  Future<Consultation> acceptRequest(String id) => _updateStatus(id, ConsultationStatus.confirmed);

  @override
  Future<Consultation> rejectRequest(String id, {String? reason}) async {
    final updated = await _updateStatus(id, ConsultationStatus.declined);
    _unmarkSlotForConsultation(updated.lawyerId, updated);
    return updated;
  }

  @override
  Future<Consultation> cancel(String id, {String? reason}) async {
    final updated = await _updateStatus(id, ConsultationStatus.cancelled);
    _unmarkSlotForConsultation(updated.lawyerId, updated);
    return updated;
  }

  @override
  Future<Consultation> reschedule({required String id, required DateTime newDateTime}) async {
    await _simulateLatency();
    final index = _consultations.indexWhere((c) => c.id == id);
    if (index == -1) throw const NotFoundFailure();
    final previous = _consultations[index];
    _unmarkSlotForConsultation(previous.lawyerId, previous);
    final updated = previous.copyWith(scheduledAt: newDateTime, status: ConsultationStatus.confirmed);
    _consultations[index] = updated;
    _markSlot(updated.lawyerId, newDateTime, isBooked: true, consultationId: updated.id);
    return updated;
  }

  @override
  Future<Consultation> complete(String id) => _updateStatus(id, ConsultationStatus.completed);

  @override
  Future<Consultation> markMissed(String id) => _updateStatus(id, ConsultationStatus.missed);

  @override
  Future<Consultation> markFailed(String id) => _updateStatus(id, ConsultationStatus.failed);

  Future<Consultation> _updateStatus(String id, ConsultationStatus status) async {
    await _simulateLatency();
    final index = _consultations.indexWhere((c) => c.id == id);
    if (index == -1) throw const NotFoundFailure();
    final updated = _consultations[index].copyWith(status: status);
    _consultations[index] = updated;
    return updated;
  }

  void _markSlot(String lawyerId, DateTime at, {required bool isBooked, String? consultationId}) {
    final slots = _availabilityByLawyer[lawyerId];
    if (slots == null) return;
    final index = slots.indexWhere((slot) => slot.start.year == at.year && slot.start.month == at.month && slot.start.day == at.day && slot.start.hour == at.hour);
    if (index == -1) return;
    slots[index] = slots[index].copyWith(isBooked: isBooked, consultationId: consultationId);
  }

  /// Frees the slot booked for [consultation] (reject/cancel/reschedule).
  /// Matches by `consultationId` first — the authoritative link — rather
  /// than by lawyerId+hour alone, since more than one slot can legitimately
  /// share the same hour (see `_correlateSeededBookings`'s doc comment) and
  /// hour-only matching would risk freeing an unrelated consultation's slot
  /// instead. Falls back to hour-matching only for a legacy/unlinked
  /// booking that has no `consultationId` on its slot at all.
  void _unmarkSlotForConsultation(String lawyerId, Consultation consultation) {
    final slots = _availabilityByLawyer[lawyerId];
    if (slots == null) return;
    final linkedIndex = slots.indexWhere((slot) => slot.consultationId == consultation.id);
    if (linkedIndex != -1) {
      slots[linkedIndex] = slots[linkedIndex].copyWith(isBooked: false, consultationId: null);
      return;
    }
    _markSlot(lawyerId, consultation.scheduledAt, isBooked: false);
  }

  /// Correlates each already-`confirmed` seeded [Consultation] belonging to
  /// [lawyerId] with a matching availability slot (by hour), so booked
  /// seed-data slots aren't the disconnected, purely-cosmetic bookings
  /// `_generateSlots`'s own ~15% random flag produces — tapping one of
  /// these in the lawyer's schedule can then deep-link straight to the
  /// consultation it belongs to. Adds a slot for the exact hour if the
  /// normal tomorrow-onward generated calendar didn't happen to cover it
  /// (e.g. a seed consultation scheduled for later today).
  void _correlateSeededBookings(String lawyerId) {
    final slots = _availabilityByLawyer[lawyerId];
    if (slots == null) return;
    for (final consultation in _consultations) {
      if (consultation.lawyerId != lawyerId || consultation.status != ConsultationStatus.confirmed) continue;
      final at = consultation.scheduledAt;
      // Only claims a slot not already linked to a *different* consultation
      // — several seed consultations intentionally share the same hour (see
      // cons_seed_6/8/9/11's doc comments), and without this guard each one
      // processed later would silently steal the link from the one before
      // it, leaving every earlier consultation at that hour unlinked.
      final index = slots.indexWhere(
        (slot) =>
            slot.consultationId == null &&
            slot.start.year == at.year &&
            slot.start.month == at.month &&
            slot.start.day == at.day &&
            slot.start.hour == at.hour,
      );
      if (index != -1) {
        slots[index] = slots[index].copyWith(isBooked: true, consultationId: consultation.id);
      } else {
        final start = DateTime(at.year, at.month, at.day, at.hour);
        slots.add(
          AvailabilitySlot(
            id: '${lawyerId}_slot_seed_${consultation.id}',
            lawyerId: lawyerId,
            start: start,
            end: start.add(const Duration(hours: 1)),
            isBooked: true,
            consultationId: consultation.id,
          ),
        );
      }
    }
  }

  /// 9:00–17:00, hourly, Sunday–Thursday, for the next 14 days — a
  /// deterministic-enough calendar that every lawyer in the marketplace can
  /// be booked against without a bespoke seed per profile. ~15% of slots
  /// start out booked (unrelated to any seeded [Consultation]) purely so
  /// the date/time picker isn't a wall of identical green slots.
  List<AvailabilitySlot> _generateSlots(String lawyerId) {
    final slots = <AvailabilitySlot>[];
    final today = DateTime.now();
    final startDay = DateTime(today.year, today.month, today.day).add(const Duration(days: 1));

    for (var dayOffset = 0; dayOffset < 14; dayOffset++) {
      final day = startDay.add(Duration(days: dayOffset));
      if (day.weekday == DateTime.friday || day.weekday == DateTime.saturday) continue;
      for (var hour = 9; hour < 17; hour++) {
        final start = DateTime(day.year, day.month, day.day, hour);
        final pseudoRandom = (lawyerId.hashCode + start.millisecondsSinceEpoch) % 100;
        slots.add(
          AvailabilitySlot(
            id: '${lawyerId}_slot_${start.millisecondsSinceEpoch}',
            lawyerId: lawyerId,
            start: start,
            end: start.add(const Duration(hours: 1)),
            isBooked: pseudoRandom < 15,
          ),
        );
      }
    }
    return slots;
  }

  Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 450));
}
