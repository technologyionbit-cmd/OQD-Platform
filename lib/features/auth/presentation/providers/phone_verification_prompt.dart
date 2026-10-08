import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the verify-phone screen should be showing. The router reads it:
/// while it is true and the signed-in user's phone is unverified, the app
/// sits on `/verify-phone`; once it is false (or the phone is verified)
/// the router sends the user on to their home.
///
/// Sign-up turns it on, so a new account lands on the code screen. "Later"
/// turns it off; the unverified-phone banner turns it back on. It is not
/// persisted: after a restart an unverified user starts at home with the
/// banner.
class PhoneVerificationPrompt extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;

  void dismiss() => state = false;
}

final phoneVerificationPromptProvider = NotifierProvider<PhoneVerificationPrompt, bool>(PhoneVerificationPrompt.new);
