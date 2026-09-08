import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/features/consultation_room/data/datasources/consultation_room_mock_data_source.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/session_state.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

void main() {
  late ConsultationRoomMockDataSource dataSource;

  setUp(() => dataSource = ConsultationRoomMockDataSource());

  test('getSession seeds a new session at waiting', () async {
    final session = await dataSource.getSession('room_1', type: ConsultationType.video);
    expect(session.state, SessionState.waiting);
    expect(session.reconnectAttempts, 0);
  });

  test('join moves waiting to ready', () async {
    await dataSource.getSession('room_1', type: ConsultationType.video);
    final session = await dataSource.join('room_1');
    expect(session.state, SessionState.ready);
  });

  test('written consultations connect straight to active, skipping connecting', () async {
    await dataSource.getSession('room_written', type: ConsultationType.written);
    await dataSource.join('room_written');
    final session = await dataSource.connect('room_written');
    expect(session.state, SessionState.active);
  });

  test('the same consultation ID always produces the same connection outcome', () async {
    Future<SessionState> outcomeFor(String id) async {
      await dataSource.getSession(id, type: ConsultationType.video);
      await dataSource.join(id);
      return (await dataSource.connect(id)).state;
    }

    final first = await outcomeFor('cons_deterministic_a');
    final freshDataSource = ConsultationRoomMockDataSource();
    await freshDataSource.getSession('cons_deterministic_a', type: ConsultationType.video);
    await freshDataSource.join('cons_deterministic_a');
    final second = (await freshDataSource.connect('cons_deterministic_a')).state;

    expect(first, second);
  });

  test('connect can fail for voice/video, and endSession works from failed', () async {
    // Deterministically find a seed that fails on first connect.
    String? failingId;
    for (var i = 0; i < 20; i++) {
      final id = 'probe_$i';
      final ds = ConsultationRoomMockDataSource();
      await ds.getSession(id, type: ConsultationType.video);
      await ds.join(id);
      final result = await ds.connect(id);
      if (result.state == SessionState.failed) {
        failingId = id;
        break;
      }
    }
    expect(failingId, isNotNull, reason: 'expected at least one seed among 20 to fail on first connect');

    final ds = ConsultationRoomMockDataSource();
    await ds.getSession(failingId!, type: ConsultationType.video);
    await ds.join(failingId);
    await ds.connect(failingId);
    final ended = await ds.endSession(failingId);
    expect(ended.state, SessionState.ended);
  });

  test('reportConnectionLost moves an active session to failed', () async {
    await dataSource.getSession('room_written_2', type: ConsultationType.written);
    await dataSource.join('room_written_2');
    await dataSource.connect('room_written_2');
    final lost = await dataSource.reportConnectionLost('room_written_2');
    expect(lost.state, SessionState.failed);
  });

  test('retryConnection throws once max reconnection attempts are exhausted', () async {
    // Find a seed whose retries never recover (the "neverConnects" profile),
    // and drive that same data source until its attempts run out.
    ConsultationRoomMockDataSource? brokenDataSource;
    String? brokenId;
    for (var i = 0; i < 30; i++) {
      final id = 'broken_probe_$i';
      final ds = ConsultationRoomMockDataSource();
      await ds.getSession(id, type: ConsultationType.video);
      await ds.join(id);
      var result = await ds.connect(id);
      if (result.state != SessionState.failed) continue;
      var recovered = false;
      for (var attempt = 0; attempt < 3; attempt++) {
        result = await ds.retryConnection(id);
        if (result.state == SessionState.active) {
          recovered = true;
          break;
        }
        if (result.state != SessionState.failed) break;
      }
      if (!recovered) {
        brokenDataSource = ds;
        brokenId = id;
        break;
      }
    }
    expect(brokenId, isNotNull, reason: 'expected at least one seed among 30 to never recover');

    // Attempts are now exhausted (3 retries already made above).
    expect(() => brokenDataSource!.retryConnection(brokenId!), throwsA(isA<ValidationFailure>()));
  });

  test('a mid-call reportConnectionLost also exhausts after max retries (active -> failed -> unavailable)', () async {
    // Unlike the "connect throws when not ready" style seeds above, this
    // drives a session that actually reaches `active` first (written
    // consultations skip the connect-time profile gate entirely), then
    // simulates a drop via reportConnectionLost — the path
    // VoiceCallScreen/VideoCallScreen's dev-only trigger now exercises —
    // and confirms retries still exhaust deterministically for a
    // never-recovers seed found the same probing way as the test above.
    ConsultationRoomMockDataSource? brokenDataSource;
    String? brokenId;
    for (var i = 0; i < 30; i++) {
      final id = 'broken_active_probe_$i';
      final ds = ConsultationRoomMockDataSource();
      await ds.getSession(id, type: ConsultationType.written);
      await ds.join(id);
      final connected = await ds.connect(id);
      expect(connected.state, SessionState.active, reason: 'written consultations always connect straight to active');

      final lost = await ds.reportConnectionLost(id);
      expect(lost.state, SessionState.failed);

      var recovered = false;
      var result = lost;
      for (var attempt = 0; attempt < 3; attempt++) {
        result = await ds.retryConnection(id);
        if (result.state == SessionState.active) {
          recovered = true;
          break;
        }
      }
      if (!recovered) {
        brokenDataSource = ds;
        brokenId = id;
        break;
      }
    }
    expect(brokenId, isNotNull, reason: 'expected at least one seed among 30 to never recover from a mid-call drop');
    expect(() => brokenDataSource!.retryConnection(brokenId!), throwsA(isA<ValidationFailure>()));
  });

  test('connect throws when the session is not ready', () async {
    await dataSource.getSession('room_2', type: ConsultationType.video);
    expect(() => dataSource.connect('room_2'), throwsA(isA<ValidationFailure>()));
  });
}
