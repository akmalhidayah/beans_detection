import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
      final started = DateTime.now();
      final streamed =
          await _client.send(request).timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamed);
      if (kDebugMode) {
        debugPrint(
            'POST ${ApiConfig.predictEndpoint} -> ${response.statusCode} '
            '(${DateTime.now().difference(started).inMilliseconds} ms)');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Format response server tidak valid.');
      }
      final body = Map<String, dynamic>.from(decoded);
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const SessionExpiredException();
      }
      if (response.statusCode == 413) {
        throw const ValidationException('Ukuran gambar melebihi batas 5 MB.');
      }
      if (response.statusCode == 422) {
        throw ValidationException(_message(body, 'File gambar tidak valid.'));
      }
      if (response.statusCode >= 500) {
        throw const ApiException(
            'Server gagal memproses gambar. Silakan coba lagi.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(_message(body, 'Gambar tidak dapat diproses.'),
            statusCode: response.statusCode);
      }
      return DetectionResult.fromApiJson(
        body,
        localImagePath: kIsWeb ? null : prepared.file.path,
        localImageBytes: kIsWeb ? prepared.bytes : null,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException('Proses deteksi melewati batas waktu.');
    } on http.ClientException {
      throw const NetworkException();
    } on FormatException catch (e) {
      throw ValidationException(e.message);
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(ApiConfig.uri(ApiConfig.healthEndpoint))
          .timeout(const Duration(seconds: 7));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static String _message(Map<String, dynamic> body, String fallback) {
    final value = body['detail'] ?? body['message'];
    return value is String && value.isNotEmpty ? value : fallback;
  }
}
