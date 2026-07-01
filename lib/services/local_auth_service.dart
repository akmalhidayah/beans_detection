import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/api_config.dart';
import '../core/utils/app_language.dart';

class LocalUser {
  const LocalUser({
    this.id = '',
    required this.name,
    required this.email,
    required this.location,
    required this.language,
    this.phone = '',
    this.authProvider = 'email',
    this.syncedOnline = false,
    this.authToken = '',
    this.role = 'user',
    this.isActive = true,
    this.lastLoginAt,
    this.lastSeenAt,
  });

  final String id;
  final String name;
  final String email;
  final String location;
  final String language;
  final String phone;
  final String authProvider;
  final bool syncedOnline;
  final String authToken;
  final String role;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime? lastSeenAt;

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isUser => role.toLowerCase() == 'user';
}

class LocalAuthService {
  static const _isLoggedInKey = 'isLoggedIn';
  static const _idKey = 'id';
  static const _nameKey = 'name';
  static const _emailKey = 'email';
  static const _passwordKey = 'password';
  static const _locationKey = 'location';
  static const _languageKey = 'language';
  static const _phoneKey = 'phone';
  static const _authProviderKey = 'authProvider';
  static const _syncedOnlineKey = 'syncedOnline';
  static const _authTokenKey = 'authToken';
  static const _roleKey = 'role';
  static const _isActiveKey = 'isActive';
  static const _lastLoginAtKey = 'lastLoginAt';
  static const _lastSeenAtKey = 'lastSeenAt';
  static bool _googleInitialized = false;
  static Future<void>? _googleInitializeFuture;

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
    final session = await _registerRemote(
      name: name,
      email: email,
      password: password,
      location: location,
      authProvider: 'email',
    );
    final user = session?.user ??
        LocalUser(
          name: name,
          email: email.trim().toLowerCase(),
          location: location,
          language: AppLanguage.indonesia,
          role: 'user',
        );
    await _saveSession(
      user: user,
      syncedOnline: session != null,
      authToken: session?.token ?? '',
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
    final session = await _registerRemote(
      name: displayName,
      email: normalizedEmail,
      password: '',
      location: 'Desa Masewe, Mamasa',
      authProvider: 'google',
    );
    final user = session?.user ??
        LocalUser(
          name: displayName,
          email: normalizedEmail,
          location: 'Desa Masewe, Mamasa',
          language: AppLanguage.indonesia,
          authProvider: 'google',
        );
    await _saveSession(
      user: user,
      syncedOnline: session != null,
      authToken: session?.token ?? '',
    );
  }

  Future<void> signInWithGoogleAccount() async {
    await _ensureGoogleInitialized();
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw Exception(
        kIsWeb
            ? 'Login Google web harus memakai tombol resmi Google. Untuk test APK, jalankan di emulator Android.'
            : 'Google Sign-In belum didukung di platform ini.',
      );
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
      user: session.user,
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
    final session = await _registerRemote(
      name: displayName,
      email: emailAlias,
      password: '',
      location: 'Desa Masewe, Mamasa',
      phone: normalizedPhone,
      authProvider: 'phone',
    );
    final user = session?.user ??
        LocalUser(
          name: displayName,
          email: emailAlias,
          location: 'Desa Masewe, Mamasa',
          language: AppLanguage.indonesia,
          phone: normalizedPhone,
          authProvider: 'phone',
        );
    await _saveSession(
      user: user,
      syncedOnline: session != null,
      authToken: session?.token ?? '',
    );
  }

  Future<void> _saveSession({
    required LocalUser user,
    required bool syncedOnline,
    required String authToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_idKey, user.id);
    await prefs.setString(_nameKey, user.name);
    await prefs.setString(_emailKey, user.email);
    await prefs.remove(_passwordKey);
    await prefs.setString(_locationKey, user.location);
    await prefs.setString(_languageKey, user.language);
    await prefs.setString(_phoneKey, user.phone);
    await prefs.setString(_authProviderKey, user.authProvider);
    await prefs.setString(_authTokenKey, authToken);
    await prefs.setString(_roleKey, user.role.isEmpty ? 'user' : user.role);
    await prefs.setBool(_isActiveKey, user.isActive);
    await prefs.setString(
      _lastLoginAtKey,
      user.lastLoginAt?.toIso8601String() ?? '',
    );
    await prefs.setString(
      _lastSeenAtKey,
      user.lastSeenAt?.toIso8601String() ?? '',
    );
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
        user: remoteUser,
        syncedOnline: true,
        authToken: remoteUser.authToken,
      );
      return true;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_emailKey);
    final legacyPassword = prefs.getString(_passwordKey);
    if (legacyPassword != null &&
        legacyPassword.isNotEmpty &&
        savedEmail == email &&
        legacyPassword == password) {
      await prefs.remove(_passwordKey);
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
      id: prefs.getString(_idKey) ?? '',
      name: prefs.getString(_nameKey) ?? 'Petani Kopi',
      email: prefs.getString(_emailKey) ?? 'user@example.com',
      location: prefs.getString(_locationKey) ?? 'Desa Masewe, Mamasa',
      language: prefs.getString(_languageKey) ?? AppLanguage.indonesia,
      phone: prefs.getString(_phoneKey) ?? '',
      authProvider: prefs.getString(_authProviderKey) ?? 'email',
      syncedOnline: prefs.getBool(_syncedOnlineKey) ?? false,
      authToken: prefs.getString(_authTokenKey) ?? '',
      role: prefs.getString(_roleKey) ?? 'user',
      isActive: prefs.getBool(_isActiveKey) ?? true,
      lastLoginAt: _parseDate(prefs.getString(_lastLoginAtKey)),
      lastSeenAt: _parseDate(prefs.getString(_lastSeenAtKey)),
    );
  }

  Future<String> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey) ?? '';
  }

  Future<String> getToken() => getAuthToken();

  Future<void> updateProfile({
    required String name,
    required String email,
    required String location,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_authTokenKey) ?? '';
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_locationKey, location);
    final synced = await _updateProfileRemote(
      name: name,
      email: email,
      location: location,
      phone: prefs.getString(_phoneKey) ?? '',
      authProvider: prefs.getString(_authProviderKey) ?? 'email',
      token: token,
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

  Future<_AuthSession?> _registerRemote({
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
    if (response == null ||
        response.statusCode < 200 ||
        response.statusCode >= 300) {
      return null;
    }
    try {
      return _sessionFromResponse(response.body);
    } catch (_) {
      return null;
    }
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
      final session = _sessionFromResponse(response.body);
      return LocalUser(
        id: session.user.id,
        name: session.user.name,
        email: session.user.email,
        location: session.user.location,
        language: session.user.language,
        phone: session.user.phone,
        authProvider: session.user.authProvider,
        syncedOnline: true,
        authToken: session.token,
        role: session.user.role,
        isActive: session.user.isActive,
        lastLoginAt: session.user.lastLoginAt,
        lastSeenAt: session.user.lastSeenAt,
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
    required String token,
  }) async {
    final response = await _postJson(
      '/users/profile',
      {
        'name': name,
        'email': email,
        'location': location,
        'phone': phone,
        'auth_provider': authProvider,
      },
      token: token,
    );
    return response != null &&
        response.statusCode >= 200 &&
        response.statusCode < 300;
  }

  Future<http.Response?> _postJson(
    String path,
    Map<String, dynamic> body, {
    String token = '',
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    try {
      return await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: headers,
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
    _googleInitializeFuture ??= GoogleSignIn.instance
        .initialize(
      clientId:
          ApiConfig.googleClientId.isEmpty ? null : ApiConfig.googleClientId,
      serverClientId: kIsWeb || ApiConfig.googleServerClientId.isEmpty
          ? null
          : ApiConfig.googleServerClientId,
    )
        .catchError((Object error) {
      final message = error.toString();
      if (message.contains('init() has already been called')) {
        return;
      }
      throw error;
    });
    await _googleInitializeFuture;
    _googleInitialized = true;
  }

  _AuthSession _sessionFromResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Format response backend tidak sesuai.');
    }
    final token = _extractToken(decoded);
    final userData = _extractUserData(decoded);
    return _AuthSession(
      token: token,
      user: _userFromMap(userData, token),
    );
  }

  String _extractToken(Map<String, dynamic> body) {
    final rootToken = body['access_token']?.toString() ??
        body['token']?.toString();
    if (rootToken != null && rootToken.isNotEmpty) return rootToken;

    final data = body['data'];
    if (data is Map) {
      final dataMap = Map<String, dynamic>.from(data);
      return dataMap['access_token']?.toString() ??
          dataMap['token']?.toString() ??
          '';
    }
    return '';
  }

  Map<String, dynamic> _extractUserData(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map) {
      final dataMap = Map<String, dynamic>.from(data);
      final nestedUser = dataMap['user'];
      if (nestedUser is Map) {
        return {
          ...dataMap,
          ...Map<String, dynamic>.from(nestedUser),
        };
      }
      return dataMap;
    }
    final user = body['user'];
    if (user is Map) {
      return {
        ...body,
        ...Map<String, dynamic>.from(user),
      };
    }
    return body;
  }

  LocalUser _userFromMap(Map<String, dynamic> data, String token) {
    return LocalUser(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? 'Petani Kopi',
      email: data['email']?.toString() ?? 'user@example.com',
      location: data['location']?.toString() ?? 'Desa Masewe, Mamasa',
      language: data['language']?.toString() ?? AppLanguage.indonesia,
      phone: data['phone']?.toString() ?? '',
      authProvider: data['auth_provider']?.toString() ??
          data['authProvider']?.toString() ??
          'email',
      syncedOnline: true,
      authToken: token,
      role: data['role']?.toString().toLowerCase() ?? 'user',
      isActive: _toBool(data['is_active'] ?? data['isActive'], fallback: true),
      lastLoginAt: _parseDate(data['last_login_at'] ?? data['lastLoginAt']),
      lastSeenAt: _parseDate(data['last_seen_at'] ?? data['lastSeenAt']),
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

  static bool _toBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    if (text == 'true') return true;
    if (text == 'false') return false;
    return fallback;
  }

  static DateTime? _parseDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
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
