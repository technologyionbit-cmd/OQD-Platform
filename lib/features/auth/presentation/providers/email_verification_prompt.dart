import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the verify-email screen should be showing. The router reads it:
/// while it is true and the signed-in user's email is unverified, the app
/// sits on `/verify-email`; once it is false (or the email is verified)
/// the router sends the user on to their home.
///
/// Sign-up turns it on, so a new account lands on the code screen. "Later"
/// turns it off; the unverified-email banner turns it back on. It is not
/// persisted: after a restart an unverified user starts at home with the
/// banner.
class EmailVerificationPrompt extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;

  void dismiss() => state = false;
}

final emailVerificationPromptProvider = NotifierProvider<EmailVerificationPrompt, bool>(EmailVerificationPrompt.new);
