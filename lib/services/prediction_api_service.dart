import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/detection_result.dart';

class PredictionApiService {
  Future<DetectionResult> predictImage(File imageFile) async {
    if (!await imageFile.exists()) {
      throw Exception('File gambar tidak ditemukan.');
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/predict'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
          );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        final message = _messageFromBody(response.body);
        throw Exception(message ?? 'API gagal memproses gambar.');
      }

      final jsonBody = jsonDecode(response.body);
      if (jsonBody is! Map<String, dynamic>) {
        throw const FormatException('Format response backend tidak sesuai.');
      }

      if (jsonBody['success'] != true) {
        throw Exception(
          jsonBody['message']?.toString() ?? 'API gagal memproses gambar.',
        );
      }

      final data = jsonBody['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Format response backend tidak sesuai.');
      }

      return DetectionResult.fromApiJson(
        data,
        localImagePath: imageFile.path,
      );
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke backend. Pastikan server FastAPI sedang berjalan.',
      );
    } on TimeoutException {
      throw Exception(
          'Koneksi ke backend timeout. Coba ulangi beberapa saat lagi.');
    } on FormatException catch (error) {
      throw Exception(error.message);
    } on http.ClientException {
      throw Exception('Tidak dapat terhubung ke server backend.');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  String? _messageFromBody(String body) {
    try {
      final jsonBody = jsonDecode(body);
      if (jsonBody is Map<String, dynamic>) {
        return jsonBody['detail']?.toString() ??
            jsonBody['message']?.toString();
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
