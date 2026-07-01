import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../core/config/api_config.dart';
import '../models/detection_result.dart';

class PredictionApiService {
  Future<DetectionResult> predictImage(
    XFile imageFile, {
    String authToken = '',
  }) async {
    try {
      Uint8List? imageBytes;
      final endpoint = '${ApiConfig.baseUrl}${ApiConfig.predictEndpoint}';
      final mediaType = _imageMediaType(imageFile);

      if (mediaType == null) {
        throw Exception(
          'Format gambar tidak didukung. Gunakan JPG, JPEG, atau PNG.',
        );
      }

      if (kIsWeb) {
        imageBytes = await imageFile.readAsBytes();
        _validateImageBytes(imageBytes);
      } else {
        final path = imageFile.path;
        if (path.isEmpty) {
          throw Exception('File gambar tidak ditemukan.');
        }
        final image = File(path);
        if (!await image.exists()) {
          throw Exception('File gambar tidak ditemukan.');
        }
        final size = await image.length();
        _validateImageSize(size);
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(endpoint),
      );
      if (authToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes!,
            filename: imageFile.name,
            contentType: mediaType,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
            contentType: mediaType,
          ),
        );
      }

      _debugUploadInfo(
        endpoint: endpoint,
        imageFile: imageFile,
        mediaType: mediaType,
        sizeBytes: kIsWeb ? imageBytes!.length : await File(imageFile.path).length(),
      );

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
          );
      final response = await http.Response.fromStream(streamedResponse);
      _debugResponse(response);
      final jsonBody = _decodeMap(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final apiStatus = jsonBody['status']?.toString();
        if (apiStatus == 'error') {
          return DetectionResult.fromApiJson(
            jsonBody,
            localImagePath: kIsWeb ? null : imageFile.path,
            localImageBytes: imageBytes,
          );
        }
        final message = _messageFromBody(response.body);
        throw Exception(message ?? 'API gagal memproses gambar.');
      }

      final apiStatus = _statusFromResponse(jsonBody);
      if (apiStatus == 'error') {
        return DetectionResult.fromApiJson(
          jsonBody,
          localImagePath: kIsWeb ? null : imageFile.path,
          localImageBytes: imageBytes,
        );
      }

      if (apiStatus == 'detected' || apiStatus == 'not_detected') {
        return DetectionResult.fromApiJson(
          jsonBody,
          localImagePath: kIsWeb ? null : imageFile.path,
          localImageBytes: imageBytes,
        );
      }

      final data = jsonBody['data'];
      if (data is Map) {
        return DetectionResult.fromApiJson(
          {
            'status': 'detected',
            'data': Map<String, dynamic>.from(data),
          },
          localImagePath: kIsWeb ? null : imageFile.path,
          localImageBytes: imageBytes,
        );
      }

      throw const FormatException('Format response backend tidak sesuai.');
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke server. Pastikan backend aktif dan koneksi internet tersedia.',
      );
    } on TimeoutException {
      throw Exception(
        'Tidak dapat terhubung ke server. Pastikan backend aktif dan koneksi internet tersedia.',
      );
    } on FormatException catch (error) {
      throw Exception(error.message);
    } on http.ClientException {
      throw Exception(
        'Tidak dapat terhubung ke server. Pastikan backend aktif dan koneksi internet tersedia.',
      );
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

  Map<String, dynamic> _decodeMap(String body) {
    final jsonBody = jsonDecode(body);
    if (jsonBody is! Map<String, dynamic>) {
      throw const FormatException('Format response backend tidak sesuai.');
    }
    return jsonBody;
  }

  String _statusFromResponse(Map<String, dynamic> body) {
    final rootStatus = body['status']?.toString();
    if (_isApiStatus(rootStatus)) return rootStatus!;

    final data = body['data'];
    if (data is Map) {
      final dataStatus = data['detection_status']?.toString();
      if (_isApiStatus(dataStatus)) return dataStatus!;
      final nestedStatus = data['status']?.toString();
      if (_isApiStatus(nestedStatus)) return nestedStatus!;
    }

    if (body['success'] == true) return 'detected';
    return '';
  }

  bool _isApiStatus(String? value) {
    return value == 'detected' || value == 'not_detected' || value == 'error';
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

  MediaType? _imageMediaType(XFile imageFile) {
    final source = '${imageFile.path} ${imageFile.name}'.toLowerCase();
    if (source.contains('.jpg') || source.contains('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (source.contains('.png')) {
      return MediaType('image', 'png');
    }
    if (source.contains('.webp') || source.contains('.heic')) {
      return null;
    }
    return null;
  }

  void _validateImageBytes(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw Exception('File gambar tidak ditemukan.');
    }
    _validateImageSize(bytes.length);
  }

  void _validateImageSize(int sizeBytes) {
    if (sizeBytes <= 0) {
      throw Exception('File gambar tidak ditemukan.');
    }
    const maxBytes = 5 * 1024 * 1024;
    if (sizeBytes > maxBytes) {
      throw Exception('Ukuran gambar terlalu besar. Gunakan gambar maksimal 5 MB.');
    }
  }

  void _debugUploadInfo({
    required String endpoint,
    required XFile imageFile,
    required MediaType mediaType,
    required int sizeBytes,
  }) {
    if (!kDebugMode) return;
    debugPrint('Predict upload endpoint: $endpoint');
    debugPrint('Predict upload path: ${imageFile.path}');
    debugPrint('Predict upload name: ${imageFile.name}');
    debugPrint('Predict upload MIME: $mediaType');
    debugPrint('Predict upload size: $sizeBytes bytes');
  }

  void _debugResponse(http.Response response) {
    if (!kDebugMode) return;
    debugPrint('Predict response status: ${response.statusCode}');
    debugPrint('Predict response body: ${response.body}');
  }
}
