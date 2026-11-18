import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import 'package:aqd_ionbit/core/security/secure_storage_service.dart';

/// Fingerprint / Face sign-in. The phone + password are kept in the
/// Keychain/Keystore (never in preferences) and only read back after the OS
/// biometric prompt succeeds.
class BiometricService {
  BiometricService(this._storage, {LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  static const _phoneKey = 'biometric_phone';
  static const _passwordKey = 'biometric_password';

  final SecureStorageService _storage;
  final LocalAuthentication _auth;

  /// True when the device has biometric hardware with something enrolled.
  Future<bool> isAvailable() async {
    try {
      if (!await _auth.isDeviceSupported() || !await _auth.canCheckBiometrics) return false;
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> hasSavedCredentials() async => await _storage.read(_phoneKey) != null && await _storage.read(_passwordKey) != null;

  Future<void> saveCredentials({required String phone, required String password}) async {
    await _storage.write(_phoneKey, phone);
    await _storage.write(_passwordKey, password);
  }

  Future<void> clearCredentials() async {
    await _storage.delete(_phoneKey);
    await _storage.delete(_passwordKey);
  }

  /// Shows the OS prompt; false when cancelled, failed or unavailable.
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, biometricOnly: true);
    } on PlatformException {
      return false;
    }
  }

  /// The saved login, or null if none is stored.
  Future<({String phone, String password})?> readCredentials() async {
    final phone = await _storage.read(_phoneKey);
    final password = await _storage.read(_passwordKey);
    if (phone == null || password == null) return null;
    return (phone: phone, password: password);
  }
}
