import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../core/config/api_config.dart';
import '../core/errors/app_exceptions.dart';
import '../models/detection_result.dart';

class PredictionApiService {
  PredictionApiService({
    http.Client? client,
    @visibleForTesting bool? useWebBytes,
  })  : _client = client ?? http.Client(),
        _useWebBytes = useWebBytes ?? kIsWeb;

  static const int maxImageSizeMb = 20;
  static const int maxImageSizeBytes = maxImageSizeMb * 1024 * 1024;

  final http.Client _client;
  final bool _useWebBytes;

  Future<DetectionResult> predictImage(
    XFile source, {
    String authToken = '',
    String sourceType = '',
  }) async {
    try {
      final mimeType = _mimeType(source.name);
      final imageBytes = _useWebBytes ? await source.readAsBytes() : null;
      final sizeBytes = imageBytes?.length ?? await source.length();
      validateImageSize(sizeBytes);
      final request = http.MultipartRequest(
          'POST', ApiConfig.uri(ApiConfig.predictEndpoint));
      ApiResponseHandler.logRequest('POST', request.url);
      if (kDebugMode) {
        debugPrint(
          '[PREDICTION] file=${source.name} mime=$mimeType bytes=$sizeBytes '
          'source=${sourceType.isEmpty ? 'unknown' : sourceType} endpoint=${request.url}',
        );
      }
      if (authToken.trim().isNotEmpty) {
        request.headers['Authorization'] = 'Bearer ${authToken.trim()}';
      }
      final type = mimeType.split('/');
      if (_useWebBytes) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          imageBytes!,
          filename: source.name,
          contentType: MediaType(type[0], type[1]),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          source.path,
          filename: source.name,
          contentType: MediaType(type[0], type[1]),
        ));
      }
      final streamed =
          await _client.send(request).timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamed);
      ApiResponseHandler.logResponse(response);
      if (response.statusCode == 413) {
        throw const ValidationException(
          'Ukuran gambar terlalu besar. Gunakan gambar maksimal 20 MB.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiResponseHandler.exception(response);
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Format response server tidak valid.');
      }
      final body = Map<String, dynamic>.from(decoded);
      return DetectionResult.fromApiJson(
        body,
        localImagePath: _useWebBytes ? null : source.path,
        localImageBytes: imageBytes,
      );
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
    } on FormatException catch (e) {
      throw ValidationException(e.message);
    }
  }

  static String _mimeType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    if (extension == 'jpg' || extension == 'jpeg') return 'image/jpeg';
    if (extension == 'png') return 'image/png';
    throw const FormatException('Format gambar harus JPG, JPEG, atau PNG.');
  }

  @visibleForTesting
  static void validateImageSize(int sizeBytes) {
    if (sizeBytes <= 0) {
      throw const ValidationException('File gambar kosong.');
    }
    if (sizeBytes > maxImageSizeBytes) {
      throw const ValidationException(
        'Ukuran gambar terlalu besar. Gunakan gambar maksimal 20 MB.',
      );
    }
  }

  Future<bool> checkHealth() async {
    try {
      final uri = ApiConfig.uri(ApiConfig.healthEndpoint);
      ApiResponseHandler.logRequest('GET', uri);
      final response = await _client.get(uri, headers: const {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 7));
      ApiResponseHandler.logResponse(response);
      if (response.statusCode != 200) return false;
      final decoded = jsonDecode(response.body);
      return decoded is Map &&
          decoded['status'] == 'ok' &&
          decoded['database'] == true &&
          decoded['model'] == true;
    } catch (error) {
      ApiResponseHandler.logException(error);
      return false;
    }
  }
}
