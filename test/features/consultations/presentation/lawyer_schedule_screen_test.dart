import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_data_source_provider.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_mock_data_source.dart';
import 'package:aqd_ionbit/features/consultations/presentation/screens/lawyer_schedule_screen.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_data_source_provider.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_mock_data_source.dart';
import '../../../support/signed_in_override.dart';

/// Covers the booked-slot -> consultation deep link fix: `AvailabilitySlot`
/// now carries a `consultationId` (populated for live bookings and
/// correlated for seed data — see `ConsultationsMockDataSource`), and
/// tapping a booked slot should land on *that* consultation's details
/// rather than always falling back to the generic consultations list.
Future<ProviderContainer> _pump(WidgetTester tester, {ConsultationsMockDataSource? dataSource}) async {
  final container = ProviderContainer(
    overrides: [
      signedInOverride,
      consultationsRemoteDataSourceProvider.overrideWithValue(dataSource ?? ConsultationsMockDataSource()),
      lawyersRemoteDataSourceProvider.overrideWithValue(LawyersMockDataSource()),
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: RoutePaths.lawyerSchedule,
    routes: [
      GoRoute(path: RoutePaths.lawyerSchedule, builder: (context, state) => const LawyerScheduleScreen()),
      GoRoute(
        path: RoutePaths.lawyerConsultationDetailsPattern,
        builder: (context, state) => Scaffold(body: Text('details:${state.pathParameters['id']}')),
      ),
      GoRoute(path: RoutePaths.lawyerConsultations, builder: (context, state) => const Scaffold(body: Text('consultations list'))),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.light,
        // Assertions below are written against the English strings.
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('tapping a booked, linked slot navigates to its own consultation details, not the generic list', (
    tester,
  ) async {
    final dataSource = ConsultationsMockDataSource();
    await _pump(tester, dataSource: dataSource);

    // Today's day chip is selected by default — several seed consultations
    // are scheduled a minute from "now", so today's slot list should
    // already contain at least one booked+linked slot.
    final bookedTile = find.ancestor(of: find.text('Booked'), matching: find.byType(ListTile)).first;
    await tester.tap(bookedTile);
    await tester.pumpAndSettle();

    expect(find.text('consultations list'), findsNothing);
    final detailsText = tester.widget<Text>(find.textStarting('details:')).data!;
    final navigatedId = detailsText.substring('details:'.length);
    expect(navigatedId, isNotEmpty);

    // The id we landed on really is a real consultation — not a stray/stale
    // reference — and it's the demo lawyer's own. `runAsync` escapes the
    // fake-async zone: a bare await on the mock's simulated latency here,
    // with no further `tester.pump()` to advance the fake clock, would hang.
    final consultation = await tester.runAsync(() => dataSource.getConsultationById(navigatedId));
    expect(consultation!.lawyerId, kDemoLawyerId);
  });

  testWidgets('a booked slot has no delete affordance', (tester) async {
    await _pump(tester);

    final bookedTile = tester.widget<ListTile>(find.ancestor(of: find.text('Booked'), matching: find.byType(ListTile)).first);
    expect(bookedTile.trailing, isA<Icon>(), reason: 'booked slots show a chevron, not a delete IconButton');
  });

  testWidgets('an unbooked slot can still be removed', (tester) async {
    // Today's seed slots are all booked, and the generated calendar skips
    // Fridays/Saturdays, so "tomorrow" may have no open slot at all. Add one
    // for today (selected by default) so the test doesn't depend on the date.
    final dataSource = ConsultationsMockDataSource();
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    await tester.runAsync(
      () => dataSource.addAvailabilitySlot(lawyerId: kDemoLawyerId, start: start, end: start.add(const Duration(hours: 1))),
    );
    await _pump(tester, dataSource: dataSource);

    // Only unbooked ("Open") slots render a close/remove icon at all —
    // booked ones show a chevron instead (see the test above).
    final removeButton = find.byIcon(Icons.close);
    expect(removeButton, findsOneWidget);

    await tester.tap(removeButton);
    await tester.pumpAndSettle();
    // Confirmation dialog appears.
    expect(find.text('Remove Slot'), findsOneWidget);
  });
}

extension on CommonFinders {
  Finder textStarting(String prefix) => find.byWidgetPredicate((w) => w is Text && (w.data ?? '').startsWith(prefix));
}
