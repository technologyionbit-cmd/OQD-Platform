import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keychain/Keystore-backed storage. Used exclusively for auth tokens and
/// any other value that must never sit in `SharedPreferences` in plaintext.
///
/// This is intentionally a thin wrapper (no generic cache abstraction on
/// top) — the only consumer is [TokenManager]; adding more indirection here
/// would not serve a real need yet.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage(iOptions: _appleOptions, mOptions: _macOptions);

  /// Readable only after the device's first unlock since boot (so a refresh
  /// can still run in the background), and never migrated to another device
  /// through a backup or iCloud Keychain.
  static const _appleOptions = IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device);
  static const _macOptions = MacOsOptions(accessibility: KeychainAccessibility.first_unlock_this_device);

  final FlutterSecureStorage _storage;

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();
}
