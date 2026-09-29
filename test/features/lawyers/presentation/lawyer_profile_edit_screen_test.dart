import 'dart:async';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_data_source_provider.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_mock_data_source.dart';
import 'package:aqd_ionbit/features/lawyers/data/repositories/lawyers_repository_impl.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/verification_status.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/screens/lawyer_profile_edit_screen.dart';
import '../../../support/signed_in_override.dart';

/// Covers the validation added on top of the previously-unvalidated Save
/// flow: a blank bio (or an invalid experience/price) must block the save
/// and show an inline error instead of silently persisting garbage. Also
/// covers the verification mock upload flow.
///
/// A minimal valid 1x1 transparent PNG — `Image.memory` needs real,
/// decodable bytes for the preview sheet to render without throwing.
const _kTransparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

Future<ProviderContainer> _pump(WidgetTester tester, {bool isVerified = true}) async {
  final container = ProviderContainer(
    overrides: [signedInOverride, lawyersRemoteDataSourceProvider.overrideWithValue(LawyersMockDataSource())],
  );
  addTearDown(container.dispose);

  if (!isVerified) {
    // The seeded demo lawyer defaults to already-verified — flip it off
    // first so tests can exercise the "not verified yet"/upload flow.
    // `runAsync` escapes the fake-async zone `testWidgets` normally runs
    // in: a bare `await` on the mock's simulated latency here (before any
    // `tester.pump()` has ever run to drive the fake clock forward) would
    // otherwise hang forever.
    await tester.runAsync(() async {
      final repo = container.read(lawyersRepositoryProvider);
      final current = (await repo.getLawyerById(kDemoLawyerId)).valueOrNull!;
      await repo.updateProfile(current.copyWith(verificationStatus: VerificationStatus.unverified));
    });
  }

  final router = GoRouter(
    initialLocation: RoutePaths.lawyerDashboard,
    routes: [
      GoRoute(path: RoutePaths.lawyerDashboard, builder: (context, state) => const Scaffold(body: Text('dashboard'))),
      GoRoute(path: RoutePaths.lawyerProfileEdit, builder: (context, state) => const LawyerProfileEditScreen()),
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
  // Push (not initialLocation) so context.pop() on a successful save has
  // the dashboard route underneath it to return to, matching how this
  // screen is actually reached from AccountScreen's menu.
  unawaited(router.push(RoutePaths.lawyerProfileEdit));
  await tester.pumpAndSettle();
  return container;
}

class _FakeImagePickerPlatform extends ImagePickerPlatform {
  _FakeImagePickerPlatform({this.result, this.shouldThrow = false});

  final XFile? result;
  final bool shouldThrow;

  @override
  Future<XFile?> getImageFromSource({required ImageSource source, ImagePickerOptions options = const ImagePickerOptions()}) async {
    if (shouldThrow) throw StateError('picker unavailable');
    return result;
  }
}

void main() {
  testWidgets('saving with a blank bio shows an inline error and does not navigate away', (tester) async {
    await _pump(tester);

    final bioField = find.widgetWithText(TextField, 'About').first;
    await tester.enterText(bioField, '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Please write a short bio before saving'), findsOneWidget);
    // Still on the edit screen — a failed validation must not pop it.
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('an invalid years-of-experience value shows an inline error', (tester) async {
    await _pump(tester);

    final experienceField = find.widgetWithText(TextField, 'Experience');
    await tester.enterText(experienceField, 'abc');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid number of years'), findsOneWidget);
  });

  testWidgets('valid data saves successfully and pops the screen', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('dashboard'), findsOneWidget);
  });

  testWidgets('an already-verified lawyer has no upload button', (tester) async {
    await _pump(tester);

    expect(find.text('Verified'), findsWidgets);
    expect(find.text('Upload Verification Document'), findsNothing);
  });

  testWidgets('upload -> preview -> submit -> status becomes Pending Review', (tester) async {
    final previous = ImagePickerPlatform.instance;
    ImagePickerPlatform.instance = _FakeImagePickerPlatform(result: XFile.fromData(Uint8List.fromList(_kTransparentPng), name: 'doc.png'));
    addTearDown(() => ImagePickerPlatform.instance = previous);

    await _pump(tester, isVerified: false);
    expect(find.text('Not verified yet'), findsWidgets);

    await tester.tap(find.text('Upload Verification Document'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Preview sheet appeared with an Upload confirmation action.
    expect(find.byType(Image), findsWidgets);
    await tester.tap(find.text('Upload'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Document submitted for review'), findsOneWidget);
    expect(find.text('Pending Review'), findsWidgets);
    // The button disappears once a document is pending review too — no
    // point offering to re-upload while one is already under review.
    expect(find.text('Upload Verification Document'), findsNothing);
  });

  testWidgets('cancelling the document preview leaves verification status untouched', (tester) async {
    final previous = ImagePickerPlatform.instance;
    ImagePickerPlatform.instance = _FakeImagePickerPlatform(result: XFile.fromData(Uint8List.fromList(_kTransparentPng), name: 'doc.png'));
    addTearDown(() => ImagePickerPlatform.instance = previous);

    await _pump(tester, isVerified: false);

    await tester.tap(find.text('Upload Verification Document'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Not verified yet'), findsWidgets);
    expect(find.text('Upload Verification Document'), findsOneWidget);
  });

  testWidgets('a cancelled document pick is a silent no-op', (tester) async {
    final previous = ImagePickerPlatform.instance;
    ImagePickerPlatform.instance = _FakeImagePickerPlatform();
    addTearDown(() => ImagePickerPlatform.instance = previous);

    await _pump(tester, isVerified: false);

    await tester.tap(find.text('Upload Verification Document'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Not verified yet'), findsWidgets);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a picker error shows feedback instead of failing silently', (tester) async {
    final previous = ImagePickerPlatform.instance;
    ImagePickerPlatform.instance = _FakeImagePickerPlatform(shouldThrow: true);
    addTearDown(() => ImagePickerPlatform.instance = previous);

    await _pump(tester, isVerified: false);

    await tester.tap(find.text('Upload Verification Document'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text("Couldn't open the gallery. Please try again."), findsOneWidget);
  });
}
