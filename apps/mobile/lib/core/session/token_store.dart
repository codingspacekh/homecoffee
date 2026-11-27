import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the sign-in token between app starts. main() loads it before the
/// first frame, so the app knows straight away whether you are signed in.
abstract class TokenStore {
  String? get token;
  Future<void> save(String? token);
}

/// The phone's Keychain (iOS) or Keystore-backed storage (Android), so the
/// token never sits in plain app preferences.
class SecureTokenStore implements TokenStore {
  SecureTokenStore._(this._storage, this._token);

  static const _key = 'auth.token';

  static Future<SecureTokenStore> load([
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  ]) async {
    String? token;
    try {
      token = await storage.read(key: _key);
    } on Object {
      // A phone restored from a backup can't read the old Keychain item.
      // Then you sign in again.
    }
    return SecureTokenStore._(storage, token);
  }

  final FlutterSecureStorage _storage;
  String? _token;

  @override
  String? get token => _token;

  @override
  Future<void> save(String? token) async {
    _token = token;
    token == null
        ? await _storage.delete(key: _key)
        : await _storage.write(key: _key, value: token);
  }
}

class MemoryTokenStore implements TokenStore {
  MemoryTokenStore([this.token]);

  @override
  String? token;

  @override
  Future<void> save(String? token) async => this.token = token;
}
