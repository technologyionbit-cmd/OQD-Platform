import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';

void main() {
  group('valid transitions', () {
    const validTransitions = [
      (ConsultationStatus.pendingApproval, ConsultationStatus.confirmed),
      (ConsultationStatus.confirmed, ConsultationStatus.waiting),
      (ConsultationStatus.waiting, ConsultationStatus.ready),
      (ConsultationStatus.ready, ConsultationStatus.connecting),
      (ConsultationStatus.connecting, ConsultationStatus.active),
      (ConsultationStatus.active, ConsultationStatus.ended),
      (ConsultationStatus.active, ConsultationStatus.failed),
      (ConsultationStatus.ready, ConsultationStatus.missed),
      (ConsultationStatus.pendingApproval, ConsultationStatus.declined),
      (ConsultationStatus.confirmed, ConsultationStatus.cancelled),
      (ConsultationStatus.ended, ConsultationStatus.completed),
      // Written consultations skip `connecting` entirely.
      (ConsultationStatus.ready, ConsultationStatus.active),
      // Connection failures are retried through `connecting`.
      (ConsultationStatus.connecting, ConsultationStatus.failed),
      (ConsultationStatus.pendingApproval, ConsultationStatus.cancelled),
      (ConsultationStatus.waiting, ConsultationStatus.cancelled),
      (ConsultationStatus.ready, ConsultationStatus.cancelled),
    ];

    for (final (from, to) in validTransitions) {
      test('$from -> $to is allowed', () {
        expect(from.canTransitionTo(to), isTrue);
        expect(from.transitionTo(to), to);
      });
    }
  });

  group('invalid transitions', () {
    const invalidTransitions = [
      // Can't skip straight from a pending request to a live session.
      (ConsultationStatus.pendingApproval, ConsultationStatus.active),
      (ConsultationStatus.pendingApproval, ConsultationStatus.ready),
      // Can't go backwards.
      (ConsultationStatus.confirmed, ConsultationStatus.pendingApproval),
      (ConsultationStatus.active, ConsultationStatus.waiting),
      // Can't re-approve/decline/cancel something already resolved.
      (ConsultationStatus.completed, ConsultationStatus.confirmed),
      (ConsultationStatus.cancelled, ConsultationStatus.confirmed),
      (ConsultationStatus.declined, ConsultationStatus.confirmed),
      (ConsultationStatus.missed, ConsultationStatus.waiting),
      (ConsultationStatus.failed, ConsultationStatus.active),
      // `ended` only ever resolves to `completed`.
      (ConsultationStatus.ended, ConsultationStatus.active),
      // A live/connecting session can't be declined — that's a
      // booking-stage-only outcome.
      (ConsultationStatus.waiting, ConsultationStatus.declined),
      (ConsultationStatus.active, ConsultationStatus.completed),
    ];

    for (final (from, to) in invalidTransitions) {
      test('$from -> $to is rejected', () {
        expect(from.canTransitionTo(to), isFalse);
        expect(() => from.transitionTo(to), throwsStateError);
      });
    }
  });

  test('every terminal status has no outgoing transitions except ended -> completed', () {
    const terminal = [
      ConsultationStatus.completed,
      ConsultationStatus.cancelled,
      ConsultationStatus.declined,
      ConsultationStatus.missed,
      ConsultationStatus.failed,
    ];
    for (final status in terminal) {
      for (final target in ConsultationStatus.values) {
        expect(status.canTransitionTo(target), isFalse, reason: '$status should have no valid transitions');
      }
    }
  });
}
