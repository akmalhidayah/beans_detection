import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../core/config/api_config.dart';
import '../core/errors/app_exceptions.dart';
import '../models/detection_result.dart';
import 'image_preparation_service.dart';

class PredictionApiService {
  PredictionApiService(
      {http.Client? client, ImagePreparationService? preparation})
      : _client = client ?? http.Client(),
        _preparation = preparation ?? ImagePreparationService();
  final http.Client _client;
  final ImagePreparationService _preparation;

  Future<DetectionResult> predictImage(XFile source,
      {String authToken = ''}) async {
    try {
      final prepared = await _preparation.prepare(source);
      final request = http.MultipartRequest(
          'POST', ApiConfig.uri(ApiConfig.predictEndpoint));
      ApiResponseHandler.logRequest('POST', request.url);
      if (authToken.trim().isNotEmpty) {
        request.headers['Authorization'] = 'Bearer ${authToken.trim()}';
      }
      final type = prepared.mimeType.split('/');
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          prepared.bytes!,
          filename: prepared.file.name,
          contentType: MediaType(type[0], type[1]),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          prepared.file.path,
          filename: prepared.file.name,
          contentType: MediaType(type[0], type[1]),
        ));
      }
      final streamed =
          await _client.send(request).timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamed);
      ApiResponseHandler.logResponse(response);
      if (response.statusCode == 413) {
        throw const ValidationException('Ukuran gambar melebihi batas 5 MB.');
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
        localImagePath: kIsWeb ? null : prepared.file.path,
        localImageBytes: kIsWeb ? prepared.bytes : null,
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
