import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/admin_user_model.dart';
import 'local_auth_service.dart';

class AdminService {
  AdminService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<AdminUserModel>> fetchUsers() async {
    final auth = LocalAuthService();
    final currentUser = await auth.getUser();
    final token = await auth.getAuthToken();
    if (!currentUser.isAdmin || token.isEmpty) {
      throw Exception('Akses ditolak. Fitur ini hanya untuk admin.');
    }

    try {
      final response = await _client.get(
        ApiConfig.uri(ApiConfig.adminUsersEndpoint),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Akses ditolak. Fitur ini hanya untuk admin.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
            _messageFromBody(response.body) ?? 'Gagal mengambil daftar user.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Format response backend tidak sesuai.');
      }
      final usersJson = decoded['users'];
      if (usersJson is! List) return const [];
      return usersJson
          .whereType<Map>()
          .map(
            (item) => AdminUserModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on TimeoutException {
      throw Exception('Tidak dapat terhubung ke server.');
    } on http.ClientException {
      throw Exception('Tidak dapat terhubung ke server.');
    } on FormatException catch (error) {
      throw Exception(error.message);
    }
  }

  String? _messageFromBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ?? decoded['detail']?.toString();
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
