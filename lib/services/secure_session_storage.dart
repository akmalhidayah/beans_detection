import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SessionStorage {
  Future<void> writeToken(String token);
  Future<String> readToken();
  Future<void> deleteToken();
}

class SecureSessionStorage implements SessionStorage {
  SecureSessionStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const tokenKey = 'coffee_quality_access_token';
  static const legacyTokenKey = 'authToken';
  final FlutterSecureStorage _storage;

  @override
  Future<void> writeToken(String token) async {
    if (token.trim().isEmpty) {
      throw const FormatException('Token sesi dari server tidak valid.');
    }
    await _storage.write(key: tokenKey, value: token);
  }

  @override
  Future<String> readToken() async {
    final secureToken = (await _storage.read(key: tokenKey))?.trim() ?? '';
    if (secureToken.isNotEmpty) return secureToken;
    final prefs = await SharedPreferences.getInstance();
    final legacyToken = prefs.getString(legacyTokenKey)?.trim() ?? '';
    if (legacyToken.isEmpty) return '';
    await writeToken(legacyToken);
    await prefs.remove(legacyTokenKey);
    return legacyToken;
  }

  @override
  Future<void> deleteToken() async {
    await _storage.delete(key: tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(legacyTokenKey);
  }
}
