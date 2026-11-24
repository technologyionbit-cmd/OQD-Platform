import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/providers/core_providers.dart';

/// True while the app must be unlocked with the fingerprint / Face ID before
/// a restored session can be used. Turned on at cold start when the device
/// has biometric sign-in set up, turned off by a successful unlock, a fresh
/// sign-in or a sign-out. The router reads it.
class BiometricLock extends Notifier<bool> {
  @override
  bool build() => false;

  void lock() => state = true;

  void unlock() => state = false;
}

final biometricLockProvider = NotifierProvider<BiometricLock, bool>(BiometricLock.new);

/// Phone + password of a sign-in that just succeeded, held in memory only
/// until the user answers the "enable fingerprint" offer. Null when there is
/// nothing to offer.
class BiometricOffer extends Notifier<({String phone, String password})?> {
  @override
  ({String phone, String password})? build() => null;

  void offer({required String phone, required String password}) => state = (phone: phone, password: password);

  void clear() => state = null;
}

final biometricOfferProvider = NotifierProvider<BiometricOffer, ({String phone, String password})?>(BiometricOffer.new);

/// Called after a successful password sign-in or sign-up. If the device can do
/// biometrics and this login isn't saved yet, queues the "enable fingerprint"
/// offer; if it is already saved with an older password, refreshes it quietly.
Future<void> offerBiometricAfterLogin(WidgetRef ref, {required String phone, required String password}) async {
  // Read before any await: a successful sign-in can dispose the calling screen.
  final service = ref.read(biometricServiceProvider);
  final offers = ref.read(biometricOfferProvider.notifier);
  if (!await service.isAvailable()) return;
  final saved = await service.readCredentials();
  if (saved != null && saved.phone == phone) {
    if (saved.password != password) await service.saveCredentials(phone: phone, password: password);
    return;
  }
  offers.offer(phone: phone, password: password);
}
