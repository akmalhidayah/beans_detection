import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/api_config.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/app_language.dart';
import 'secure_session_storage.dart';

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
  final String id, name, email, location, language, phone, authProvider;
  final bool syncedOnline, isActive;
  final String authToken, role;
  final DateTime? lastLoginAt, lastSeenAt;
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isUser => role.toLowerCase() == 'user';
}

class LocalAuthService {
  LocalAuthService({http.Client? client, SessionStorage? sessionStorage})
      : _client = client ?? http.Client(),
        _sessionStorage = sessionStorage ?? SecureSessionStorage();

  final http.Client _client;
  final SessionStorage _sessionStorage;
  static const _sessionKeys = <String>[
    'id',
    'name',
    'email',
    'location',
    'phone',
    'authProvider',
    'syncedOnline',
    'role',
    'isActive',
    'lastLoginAt',
    'lastSeenAt',
    'isLoggedIn',
  ];
  static bool _googleInitialized = false;

  Future<bool> isLoggedIn() async {
    try {
      final token = await _sessionStorage.readToken();
      if (token.isEmpty) return false;
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('email') ?? '').isNotEmpty;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String location = 'Desa Masewe, Mamasa',
  }) async {
    final response = await _post(ApiConfig.registerEndpoint, {
      'name': name,
      'email': email.trim().toLowerCase(),
      'password': password,
      'location': location,
      'auth_provider': 'email',
    });
    final session = _requireSession(response);
    await _saveSession(session);
  }

  Future<bool> login({required String email, required String password}) async {
    final response = await _post(ApiConfig.loginEndpoint, {
      'email': email.trim().toLowerCase(),
      'password': password,
    });
    final session = _requireSession(response);
    await _saveSession(session);
    return true;
  }

  Future<void> signInWithGoogleAccount() async {
    final clientId = defaultTargetPlatform == TargetPlatform.iOS
        ? ApiConfig.googleIosClientId
        : (kIsWeb ? ApiConfig.googleWebClientId : '');
    if ((defaultTargetPlatform == TargetPlatform.iOS && clientId.isEmpty) ||
        ApiConfig.googleServerClientId.isEmpty) {
      throw const ValidationException(
        'Login Google belum dikonfigurasi untuk perangkat ini.',
      );
    }
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize(
        clientId: clientId.isEmpty ? null : clientId,
        serverClientId: ApiConfig.googleServerClientId,
      );
      _googleInitialized = true;
    }
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw const ValidationException(
        'Login Google belum dikonfigurasi untuk perangkat ini.',
      );
    }
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.trim().isEmpty) {
      throw const AuthenticationException('Token Google tidak tersedia.');
    }
    final response = await _post(
      ApiConfig.googleLoginEndpoint,
      {'id_token': idToken},
    );
    await _saveSession(_requireSession(response));
  }

  @Deprecated('Menunggu endpoint OTP request dan OTP verify di backend.')
  Future<void> signInWithPhone({required String phone, String? name}) async {
    throw const ValidationException(
      'Login nomor telepon belum tersedia karena verifikasi OTP belum dikonfigurasi.',
    );
  }

  @Deprecated('Gunakan signInWithGoogleAccount agar JWT berasal dari backend.')
  Future<void> signInWithGoogle({required String email, String? name}) async {
    throw const ValidationException(
      'Login Google harus dilakukan melalui akun Google pada perangkat.',
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = prefs.getString('authProvider') ?? '';
    await _sessionStorage.deleteToken();
    for (final key in _sessionKeys) {
      await prefs.remove(key);
    }
    await prefs.remove('password');
    if (provider == 'google') {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {/* local logout wins */}
    }
  }

  Future<LocalUser> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await getAuthToken();
    return LocalUser(
      id: prefs.getString('id') ?? '',
      name: prefs.getString('name') ?? 'Petani Kopi',
      email: prefs.getString('email') ?? '',
      location: prefs.getString('location') ?? 'Desa Masewe, Mamasa',
      language: prefs.getString('language') ?? AppLanguage.indonesia,
      phone: prefs.getString('phone') ?? '',
      authProvider: prefs.getString('authProvider') ?? 'email',
      syncedOnline: prefs.getBool('syncedOnline') ?? false,
      authToken: token,
      role: prefs.getString('role') ?? 'user',
      isActive: prefs.getBool('isActive') ?? true,
      lastLoginAt: _date(prefs.getString('lastLoginAt')),
      lastSeenAt: _date(prefs.getString('lastSeenAt')),
    );
  }

  Future<String> getAuthToken() async {
    try {
      return await _sessionStorage.readToken();
    } catch (_) {
      return '';
    }
  }

  Future<String> getToken() => getAuthToken();

  Future<LocalUser> updateProfile({
    required String name,
    required String email,
    required String location,
  }) async {
    final current = await getUser();
    final token = await getAuthToken();
    if (token.isEmpty) {
      throw const AuthenticationException(
        'Sesi login tidak ditemukan. Silakan login ulang.',
      );
    }
    late final http.Response response;
    try {
      response = await _post(
        ApiConfig.profileEndpoint,
        {
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'location': location.trim(),
          'phone': current.phone,
        },
        token: token,
      );
    } on AuthenticationException catch (error) {
      if (error.statusCode == 401) throw const SessionExpiredException();
      rethrow;
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Response server tidak valid.');
    }
    final root = Map<String, dynamic>.from(decoded);
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'])
        : root;
    final userData = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'])
        : data;
    final updated = _user(userData, token);
    await _saveSession(_AuthSession(token, updated));
    return updated;
  }

  Future<String> getLanguage() async =>
      (await SharedPreferences.getInstance()).getString('language') ??
      AppLanguage.indonesia;
  Future<void> setLanguage(String value) async =>
      (await SharedPreferences.getInstance()).setString('language', value);

  Future<http.Response> _post(
    String path,
    Map<String, dynamic> body, {
    String token = '',
  }) async {
    try {
      final response = await _client
          .post(
            ApiConfig.uri(path),
            headers: {
              'Content-Type': 'application/json',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _exceptionFor(response);
      }
      return response;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  ApiException _exceptionFor(http.Response response) {
    final message = parseFastApiMessage(response.body);
    switch (response.statusCode) {
      case 400:
      case 401:
        return AuthenticationException(
          message.isEmpty ? 'Email atau password salah.' : message,
          statusCode: response.statusCode,
        );
      case 403:
        return AuthenticationException(
          message.isEmpty ? 'Akun tidak aktif atau akses ditolak.' : message,
          statusCode: 403,
        );
      case 422:
        return ValidationException(
          message.isEmpty ? 'Data yang dikirim tidak valid.' : message,
        );
      case 409:
        return ValidationException(
          message.isEmpty ? 'Email sudah digunakan akun lain.' : message,
        );
      case 429:
        return const ApiException(
          'Terlalu banyak percobaan. Silakan tunggu lalu coba lagi.',
          statusCode: 429,
        );
      default:
        return ApiException(
          response.statusCode >= 500
              ? 'Server sedang bermasalah. Silakan coba lagi nanti.'
              : (message.isEmpty
                  ? 'Permintaan tidak dapat diproses.'
                  : message),
          statusCode: response.statusCode,
        );
    }
  }

  _AuthSession _requireSession(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Response server tidak valid.');
    }
    final root = Map<String, dynamic>.from(decoded);
    final data =
        root['data'] is Map ? Map<String, dynamic>.from(root['data']) : root;
    final token = (root['access_token'] ??
                root['token'] ??
                data['access_token'] ??
                data['token'])
            ?.toString()
            .trim() ??
        '';
    if (token.isEmpty) {
      throw const AuthenticationException(
        'Server tidak memberikan sesi login yang valid.',
      );
    }
    final nested =
        data['user'] is Map ? Map<String, dynamic>.from(data['user']) : data;
    return _AuthSession(token, _user(nested, token));
  }

  LocalUser _user(Map<String, dynamic> d, String token) => LocalUser(
        id: d['id']?.toString() ?? '',
        name: d['name']?.toString() ?? 'Petani Kopi',
        email: d['email']?.toString() ?? '',
        location: d['location']?.toString() ?? 'Desa Masewe, Mamasa',
        language: d['language']?.toString() ?? AppLanguage.indonesia,
        phone: d['phone']?.toString() ?? '',
        authProvider:
            (d['auth_provider'] ?? d['authProvider'])?.toString() ?? 'email',
        syncedOnline: true,
        authToken: token,
        role: d['role']?.toString().toLowerCase() ?? 'user',
        isActive: d['is_active'] is bool ? d['is_active'] as bool : true,
        lastLoginAt: _date(d['last_login_at']),
        lastSeenAt: _date(d['last_seen_at']),
      );

  Future<void> _saveSession(_AuthSession session) async {
    await _sessionStorage.writeToken(session.token);
    final p = await SharedPreferences.getInstance();
    final u = session.user;
    await p.setString('id', u.id);
    await p.setString('name', u.name);
    await p.setString('email', u.email);
    await p.setString('location', u.location);
    await p.setString('phone', u.phone);
    await p.setString('authProvider', u.authProvider);
    await p.setString('role', u.role);
    await p.setBool('isActive', u.isActive);
    await p.setBool('syncedOnline', true);
    await p.setBool('isLoggedIn', true);
    await p.remove('password');
    await p.remove(SecureSessionStorage.legacyTokenKey);
  }

  static String parseFastApiMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) return '';
      final detail = decoded['detail'] ?? decoded['message'];
      if (detail is String) return detail;
      if (detail is List) {
        return detail.map((item) {
          if (item is Map) return item['msg']?.toString() ?? item.toString();
          return item.toString();
        }).join('; ');
      }
    } catch (_) {}
    return '';
  }

  static DateTime? _date(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '');
}

class _AuthSession {
  const _AuthSession(this.token, this.user);
  final String token;
  final LocalUser user;
}
