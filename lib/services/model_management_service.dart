import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';

class ModelManagementService {
  Future<void> uploadModel(PlatformFile file) async {
    final extension = file.extension?.toLowerCase();
    if (extension != 'pt') {
      throw Exception('File model harus berformat .pt');
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/models/upload'),
      );
      request.headers['X-Admin-Token'] = ApiConfig.modelUploadToken;

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
      if (response.statusCode != 200) {
        throw Exception('Upload model gagal (${response.statusCode}).');
      }
    } on TimeoutException {
      throw Exception('Upload model timeout. Coba ulangi beberapa saat lagi.');
    } on http.ClientException {
      throw Exception('Tidak dapat terhubung ke backend.');
    }
  }
}
