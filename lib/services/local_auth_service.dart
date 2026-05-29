import 'dart:async';
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/api_config.dart';
import '../core/utils/app_language.dart';

class LocalUser {
  const LocalUser({
    required this.name,
    required this.email,
    required this.location,
    required this.language,
    this.phone = '',
    this.authProvider = 'email',
    this.syncedOnline = false,
    this.authToken = '',
  });

  final String name;
  final String email;
  final String location;
  final String language;
  final String phone;
  final String authProvider;
  final bool syncedOnline;
  final String authToken;
}

class LocalAuthService {
  static const _isLoggedInKey = 'isLoggedIn';
  static const _nameKey = 'name';
  static const _emailKey = 'email';
  static const _passwordKey = 'password';
  static const _locationKey = 'location';
  static const _languageKey = 'language';
  static const _phoneKey = 'phone';
  static const _authProviderKey = 'authProvider';
  static const _syncedOnlineKey = 'syncedOnline';
  static const _authTokenKey = 'authToken';
  static bool _googleInitialized = false;

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
    final synced = await _registerRemote(
      name: name,
      email: email,
      password: password,
      location: location,
      authProvider: 'email',
    );
    await _saveSession(
      name: name,
      email: email,
      password: password,
      location: location,
      authProvider: 'email',
      syncedOnline: synced,
    );
  }

  Future<void> signInWithGoogle({
    required String email,
    String? name,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final displayName = (name == null || name.trim().isEmpty)
        ? normalizedEmail.split('@').first
        : name.trim();
    final synced = await _registerRemote(
      name: displayName,
      email: normalizedEmail,
      password: '',
      location: 'Desa Masewe, Mamasa',
      authProvider: 'google',
    );
    await _saveSession(
      name: displayName,
      email: normalizedEmail,
      password: '',
      location: 'Desa Masewe, Mamasa',
      authProvider: 'google',
      syncedOnline: synced,
    );
  }

  Future<void> signInWithGoogleAccount() async {
    await _ensureGoogleInitialized();
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw Exception('Google Sign-In belum didukung di platform ini.');
    }

    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Token Google tidak tersedia. Pastikan OAuth client sudah dikonfigurasi.',
      );
    }

    final response = await _postJson('/auth/google', {'id_token': idToken});
    if (response == null) {
      throw Exception('Tidak dapat terhubung ke backend.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_messageFromBody(response.body) ?? 'Login Google gagal.');
    }

    final session = _sessionFromResponse(response.body);
    await _saveSession(
      name: session.user.name,
      email: session.user.email,
      password: '',
      location: session.user.location,
      phone: session.user.phone,
      authProvider: session.user.authProvider,
      syncedOnline: true,
      authToken: session.token,
    );
  }

  Future<void> signInWithPhone({
    required String phone,
    String? name,
  }) async {
    final normalizedPhone = phone.trim();
    final start = normalizedPhone.length > 4 ? normalizedPhone.length - 4 : 0;
    final displayName = (name == null || name.trim().isEmpty)
        ? 'Pengguna ${normalizedPhone.substring(start)}'
        : name.trim();
    final emailAlias = '$normalizedPhone@phone.local';
    final synced = await _registerRemote(
      name: displayName,
      email: emailAlias,
      password: '',
      location: 'Desa Masewe, Mamasa',
      phone: normalizedPhone,
      authProvider: 'phone',
    );
    await _saveSession(
      name: displayName,
      email: emailAlias,
      password: '',
      location: 'Desa Masewe, Mamasa',
      phone: normalizedPhone,
      authProvider: 'phone',
      syncedOnline: synced,
    );
  }

  Future<void> _saveSession({
    required String name,
    required String email,
    required String password,
    required String location,
    required String authProvider,
    required bool syncedOnline,
    String phone = '',
    String authToken = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
    await prefs.setString(_locationKey, location);
    await prefs.setString(_languageKey, AppLanguage.indonesia);
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_authProviderKey, authProvider);
    await prefs.setString(_authTokenKey, authToken);
    await prefs.setBool(_syncedOnlineKey, syncedOnline);
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final remoteUser = await _loginRemote(email: email, password: password);
    if (remoteUser != null) {
      await _saveSession(
        name: remoteUser.name,
        email: remoteUser.email,
        password: password,
        location: remoteUser.location,
        phone: remoteUser.phone,
        authProvider: remoteUser.authProvider,
        syncedOnline: true,
        authToken: remoteUser.authToken,
      );
      return true;
    }

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
      phone: prefs.getString(_phoneKey) ?? '',
      authProvider: prefs.getString(_authProviderKey) ?? 'email',
      syncedOnline: prefs.getBool(_syncedOnlineKey) ?? false,
      authToken: prefs.getString(_authTokenKey) ?? '',
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
    final synced = await _updateProfileRemote(
      name: name,
      email: email,
      location: location,
      phone: prefs.getString(_phoneKey) ?? '',
      authProvider: prefs.getString(_authProviderKey) ?? 'email',
    );
    await prefs.setBool(_syncedOnlineKey, synced);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? AppLanguage.indonesia;
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  Future<bool> _registerRemote({
    required String name,
    required String email,
    required String password,
    required String location,
    required String authProvider,
    String phone = '',
  }) async {
    final response = await _postJson('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'location': location,
      'phone': phone,
      'auth_provider': authProvider,
    });
    return response != null &&
        response.statusCode >= 200 &&
        response.statusCode < 300;
  }

  Future<LocalUser?> _loginRemote({
    required String email,
    required String password,
  }) async {
    final response = await _postJson('/auth/login', {
      'email': email,
      'password': password,
    });
    if (response == null ||
        response.statusCode < 200 ||
        response.statusCode >= 300) {
      return null;
    }

    try {
      final body = jsonDecode(response.body);
      final data = body is Map<String, dynamic> && body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : body as Map<String, dynamic>;
      return LocalUser(
        name: data['name']?.toString() ?? email.split('@').first,
        email: data['email']?.toString() ?? email,
        location: data['location']?.toString() ?? 'Desa Masewe, Mamasa',
        language: data['language']?.toString() ?? AppLanguage.indonesia,
        phone: data['phone']?.toString() ?? '',
        authProvider: data['auth_provider']?.toString() ?? 'email',
        syncedOnline: true,
        authToken: body['access_token']?.toString() ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> _updateProfileRemote({
    required String name,
    required String email,
    required String location,
    required String phone,
    required String authProvider,
  }) async {
    final response = await _postJson('/users/profile', {
      'name': name,
      'email': email,
      'location': location,
      'phone': phone,
      'auth_provider': authProvider,
    });
    return response != null &&
        response.statusCode >= 200 &&
        response.statusCode < 300;
  }

  Future<http.Response?> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      return await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 6));
    } on TimeoutException {
      return null;
    } on http.ClientException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      clientId:
          ApiConfig.googleClientId.isEmpty ? null : ApiConfig.googleClientId,
      serverClientId: ApiConfig.googleServerClientId.isEmpty
          ? null
          : ApiConfig.googleServerClientId,
    );
    _googleInitialized = true;
  }

  _AuthSession _sessionFromResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Format response backend tidak sesuai.');
    }
    final data = decoded['data'];
    if (data is! Map) {
      throw const FormatException('Data user backend tidak sesuai.');
    }
    final userData = Map<String, dynamic>.from(data);
    return _AuthSession(
      token: decoded['access_token']?.toString() ?? '',
      user: LocalUser(
        name: userData['name']?.toString() ?? 'Petani Kopi',
        email: userData['email']?.toString() ?? 'user@example.com',
        location: userData['location']?.toString() ?? 'Desa Masewe, Mamasa',
        language: userData['language']?.toString() ?? AppLanguage.indonesia,
        phone: userData['phone']?.toString() ?? '',
        authProvider: userData['auth_provider']?.toString() ?? 'google',
        syncedOnline: true,
        authToken: decoded['access_token']?.toString() ?? '',
      ),
    );
  }

  String? _messageFromBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['detail']?.toString() ?? decoded['message']?.toString();
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

class _AuthSession {
  const _AuthSession({
    required this.user,
    required this.token,
  });

  final LocalUser user;
  final String token;
}
