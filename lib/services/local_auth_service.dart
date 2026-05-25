import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/app_language.dart';

class LocalUser {
  const LocalUser({
    required this.name,
    required this.email,
    required this.location,
    required this.language,
  });

  final String name;
  final String email;
  final String location;
  final String language;
}

class LocalAuthService {
  static const _isLoggedInKey = 'isLoggedIn';
  static const _nameKey = 'name';
  static const _emailKey = 'email';
  static const _passwordKey = 'password';
  static const _locationKey = 'location';
  static const _languageKey = 'language';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<bool> hasAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_emailKey) ?? '').isNotEmpty;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String location = 'Desa Masewe, Mamasa',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
    await prefs.setString(_locationKey, location);
    await prefs.setString(_languageKey, AppLanguage.indonesia);
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_emailKey);
    final savedPassword = prefs.getString(_passwordKey);
    if (savedEmail == email && savedPassword == password) {
      await prefs.setBool(_isLoggedInKey, true);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
  }

  Future<LocalUser> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalUser(
      name: prefs.getString(_nameKey) ?? 'Petani Kopi',
      email: prefs.getString(_emailKey) ?? 'user@example.com',
      location: prefs.getString(_locationKey) ?? 'Desa Masewe, Mamasa',
      language: prefs.getString(_languageKey) ?? AppLanguage.indonesia,
    );
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String location,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_locationKey, location);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? AppLanguage.indonesia;
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }
}
