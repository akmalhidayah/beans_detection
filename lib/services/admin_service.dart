import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/errors/app_exceptions.dart';
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
      final uri = ApiConfig.uri(ApiConfig.adminUsersEndpoint);
      ApiResponseHandler.logRequest('GET', uri);
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 12));
      ApiResponseHandler.logResponse(response);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiResponseHandler.exception(response);
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
    } on ApiException {
      rethrow;
    } on TimeoutException catch (error) {
      ApiResponseHandler.logException(error);
      throw const NetworkException(
        'Waktu koneksi ke server habis. Silakan coba lagi.',
      );
    } on http.ClientException catch (error) {
      ApiResponseHandler.logException(error);
      throw const NetworkException();
    } on FormatException catch (error) {
      throw Exception(error.message);
    }
  }
}
