import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import 'local_auth_service.dart';

class ModelManagementService {
  Future<void> uploadModel(PlatformFile file) async {
    final authService = LocalAuthService();
    final currentUser = await authService.getUser();
    final token = await authService.getToken();
    if (token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan. Silakan login ulang.');
    }
    if (!currentUser.isAdmin) {
      throw Exception('Akses ditolak. Hanya admin yang dapat mengunggah model.');
    }

    final extension = file.extension?.toLowerCase();
    if (extension != 'pt') {
      throw Exception('File model harus berformat .pt');
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.modelUploadEndpoint}'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null || bytes.isEmpty) {
          throw Exception('File model tidak dapat dibaca.');
        }
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: file.name,
          ),
        );
      } else {
        final path = file.path;
        if (path == null || path.isEmpty) {
          throw Exception('Lokasi file model tidak valid.');
        }
        request.files.add(await http.MultipartFile.fromPath('file', path));
      }

      final streamedResponse = await request.send().timeout(
            const Duration(minutes: 2),
          );
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Akses ditolak. Hanya admin yang dapat mengunggah model.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_messageFromBody(response.body) ??
            'Upload model gagal (${response.statusCode}).');
      }
    } on TimeoutException {
      throw Exception('Upload model timeout. Coba ulangi beberapa saat lagi.');
    } on http.ClientException {
      throw Exception('Tidak dapat terhubung ke backend.');
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
