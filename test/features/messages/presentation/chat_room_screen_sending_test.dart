import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/features/messages/data/datasources/messages_mock_data_source.dart' show kMockChatFailureTrigger;
import 'package:aqd_ionbit/features/messages/presentation/utils/mock_file_attachment.dart';
import 'package:aqd_ionbit/features/messages/presentation/utils/mock_lawyer_reply.dart';
import 'package:aqd_ionbit/features/messages/presentation/widgets/chat_typing_indicator.dart';

import 'chat_room_test_support.dart';

/// A minimal valid 1x1 transparent PNG — `Image.memory` needs real,
/// decodable bytes (arbitrary bytes like `[1, 2, 3, 4]` fail to decode and
/// surface as an uncaught `FlutterError` during paint, failing the test for
/// an unrelated reason).
const _kTransparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

void main() {
  testWidgets('the send button shows a spinner while the send is in flight', (tester) async {
    final consultation = readyConsultation(id: 'cons_send_spinner');
    await pumpChatRoom(
      tester,
      user: testClient,
      consultationId: 'cons_send_spinner',
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.enterText(find.byType(TextField), 'Hello, I need help with a lease.');
    await tester.tap(find.byIcon(Icons.send));
    // One frame in — the mock send hasn't resolved yet (it has its own
    // simulated latency), so the composer should be showing the in-flight
    // spinner instead of the send icon, and re-tapping should not be
    // possible (button disabled).
    await tester.pump();

    expect(find.byIcon(Icons.send), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final sendButton = tester.widget<IconButton>(
      find.ancestor(of: find.byType(CircularProgressIndicator), matching: find.byType(IconButton)),
    );
    expect(sendButton.onPressed, isNull);

    await tester.pump(const Duration(milliseconds: 700));
  });

  testWidgets('sending a text message appends it and clears the composer', (tester) async {
    final consultation = readyConsultation(id: 'cons_send');
    await pumpChatRoom(tester, user: testClient, consultationId: 'cons_send', consultationsDataSource: SingleConsultationDataSource(consultation));

    await tester.enterText(find.byType(TextField), 'Hello, I need help with a lease.');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Hello, I need help with a lease.'), findsOneWidget);
    final editable = tester.widget<TextField>(find.byType(TextField));
    expect(editable.controller!.text, isEmpty);

    // A successful send also raises a "new message" notification in the
    // background (NotificationsController's own cold build plus the create
    // round-trip) — flush that out before the test tears down, or the
    // still-pending mock-latency Timer trips the framework's leak check.
    await tester.pump(const Duration(milliseconds: 700));
  });

  testWidgets('does not send a whitespace-only message', (tester) async {
    final consultation = readyConsultation(id: 'cons_empty_guard');
    await pumpChatRoom(
      tester,
      user: testClient,
      consultationId: 'cons_empty_guard',
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(const Duration(milliseconds: 400));

    // Still showing the empty state — nothing was actually sent.
    expect(find.text('No messages yet'), findsOneWidget);
  });

  testWidgets('a client message triggers a deterministic lawyer reply with a typing indicator in between', (tester) async {
    final consultation = readyConsultation(id: 'cons_reply');
    await pumpChatRoom(tester, user: testClient, consultationId: 'cons_reply', consultationsDataSource: SingleConsultationDataSource(consultation));

    const triggerText = 'What should I do about this notice?';
    await tester.enterText(find.byType(TextField), triggerText);
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(const Duration(milliseconds: 50));

    // Typing indicator not immediately visible — the mock delay is >=1s.
    expect(find.byType(ChatTypingIndicator), findsNothing);

    // Advance past the worst-case "before typing" delay (up to 3s).
    await tester.pump(const Duration(seconds: 3, milliseconds: 100));
    expect(find.byType(ChatTypingIndicator), findsOneWidget);

    // Advance past the worst-case "typing visible" delay (up to 2s) — the
    // canned reply should land and the indicator should disappear. The
    // reply text itself is deterministic (seeded off consultationId +
    // triggerText), so compute the exact expected string the same way the
    // screen does rather than guessing at a substring.
    await tester.pump(const Duration(seconds: 2, milliseconds: 100));
    expect(find.byType(ChatTypingIndicator), findsNothing);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final expectedReply = pickMockLawyerReply(l10n, consultationId: 'cons_reply', triggerText: triggerText);
    expect(find.text(expectedReply), findsOneWidget);
  });

  testWidgets('attaching a mock file inserts a file message and shows mock feedback', (tester) async {
    final consultation = readyConsultation(id: 'cons_file');
    await pumpChatRoom(tester, user: testClient, consultationId: 'cons_file', consultationsDataSource: SingleConsultationDataSource(consultation));

    await tester.tap(find.byIcon(Icons.attach_file_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Attach file (mock)'));
    await tester.pump(const Duration(milliseconds: 400));

    // The chosen mock file is deterministic (seeded off consultationId +
    // message count at send time, both 'cons_file' and 0 here) — compute it
    // the same way the screen does rather than assuming pool index 0.
    final expectedFile = pickMockFileAttachment(consultationId: 'cons_file', messageCountSoFar: 0);
    expect(find.text(expectedFile.fileName), findsOneWidget);
    expect(find.textContaining('Attached'), findsOneWidget);

    // Flush the background "new message" notification round-trip (see the
    // text-send test above for why).
    await tester.pump(const Duration(milliseconds: 700));
  });

  testWidgets('picking and sending a gallery image shows the image bubble', (tester) async {
    final previous = ImagePickerPlatform.instance;
    ImagePickerPlatform.instance = FakeImagePickerPlatform(result: XFile.fromData(Uint8List.fromList(_kTransparentPng), name: 'photo.png'));
    addTearDown(() => ImagePickerPlatform.instance = previous);

    final consultation = readyConsultation(id: 'cons_image');
    await pumpChatRoom(tester, user: testClient, consultationId: 'cons_image', consultationsDataSource: SingleConsultationDataSource(consultation));

    await tester.tap(find.byIcon(Icons.attach_file_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Photo from gallery'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The preview sheet appeared with a Send action.
    expect(find.text('Send'), findsOneWidget);
    await tester.tap(find.text('Send'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byIcon(Icons.download_outlined), findsNothing); // it's an image bubble, not a file one

    // Flush the background "new message" notification round-trip (see the
    // text-send test above for why).
    await tester.pump(const Duration(milliseconds: 700));
  });

  testWidgets('sending the reserved failure-trigger text shows a retry snackbar, and retry resends successfully', (tester) async {
    final consultation = readyConsultation(id: 'cons_send_fail');
    await pumpChatRoom(
      tester,
      user: testClient,
      consultationId: 'cons_send_fail',
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.enterText(find.byType(TextField), kMockChatFailureTrigger);
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Message failed to send.'), findsOneWidget);
    expect(find.text(kMockChatFailureTrigger), findsNothing, reason: 'a failed send must not appear as a message bubble');

    // Invoke the SnackBarAction's callback directly rather than tapping by
    // coordinates — a SnackBar's hit-testable area can sit right at the
    // test viewport's bottom edge, making a geometric tap unreliable.
    final retryAction = tester.widget<SnackBarAction>(find.byType(SnackBarAction));
    retryAction.onPressed();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(kMockChatFailureTrigger), findsOneWidget);

    // Flush the background "new message" notification round-trip (see the
    // text-send test above for why).
    await tester.pump(const Duration(milliseconds: 700));
  });

  testWidgets('a cancelled image pick is a silent no-op, a picker error shows feedback', (tester) async {
    final previous = ImagePickerPlatform.instance;
    ImagePickerPlatform.instance = FakeImagePickerPlatform(result: null);
    addTearDown(() => ImagePickerPlatform.instance = previous);

    final consultation = readyConsultation(id: 'cons_image_cancel');
    await pumpChatRoom(
      tester,
      user: testClient,
      consultationId: 'cons_image_cancel',
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.tap(find.byIcon(Icons.attach_file_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Photo from gallery'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('No messages yet'), findsOneWidget);

    ImagePickerPlatform.instance = FakeImagePickerPlatform(shouldThrow: true);
    await tester.tap(find.byIcon(Icons.attach_file_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Photo from gallery'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text("Couldn't open the gallery. Please try again."), findsOneWidget);
  });
}
