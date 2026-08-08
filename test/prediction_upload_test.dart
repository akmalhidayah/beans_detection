import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:beans_detection/core/errors/app_exceptions.dart';
import 'package:beans_detection/services/prediction_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_test/flutter_test.dart';

class _CaptureClient extends http.BaseClient {
  http.MultipartRequest? request;
  Uint8List? encodedBody;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest incoming) async {
    request = incoming as http.MultipartRequest;
    encodedBody = await incoming.finalize().toBytes();
    final response = jsonEncode({
      'status': 'not_detected',
      'data': {
        'detection_status': 'not_detected',
        'status': 'Tidak Terdeteksi',
        'summary': <String, dynamic>{},
      },
    });
    return http.StreamedResponse(
      Stream.value(utf8.encode(response)),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}

void main() {
  const originalBytes = <int>[0xff, 0xd8, 0xff, 0x01, 0x02, 0x03, 0xff, 0xd9];

  test('mobile upload uses original path, file field, MIME, and bearer',
      () async {
    final directory = await Directory.systemTemp.createTemp('coffee-upload-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/original.jpeg');
    await file.writeAsBytes(originalBytes);
    final client = _CaptureClient();

    await PredictionApiService(client: client, useWebBytes: false).predictImage(
      XFile(file.path),
      authToken: 'test-token',
    );

    final part = client.request!.files.single;
    expect(part.field, 'file');
    expect(part.filename, 'original.jpeg');
    expect(part.contentType.toString(), 'image/jpeg');
    expect(client.request!.headers['Authorization'], 'Bearer test-token');
    expect(_containsBytes(client.encodedBody!, originalBytes), isTrue);
  });

  test('web upload sends unchanged XFile bytes and PNG MIME without token',
      () async {
    final client = _CaptureClient();
    final source = XFile.fromData(
      Uint8List.fromList(originalBytes),
      name: 'original.png',
      path: 'original.png',
      mimeType: 'image/png',
    );

    await PredictionApiService(client: client, useWebBytes: true)
        .predictImage(source);

    final part = client.request!.files.single;
    expect(part.field, 'file');
    expect(part.filename, 'original.png');
    expect(part.contentType.toString(), 'image/png');
    expect(client.request!.headers, isNot(contains('Authorization')));
    expect(_containsBytes(client.encodedBody!, originalBytes), isTrue);
  });

  test('20 MB is accepted and one byte above is rejected clearly', () {
    expect(
      () => PredictionApiService.validateImageSize(
        PredictionApiService.maxImageSizeBytes,
      ),
      returnsNormally,
    );
    expect(
      () => PredictionApiService.validateImageSize(
        PredictionApiService.maxImageSizeBytes + 1,
      ),
      throwsA(
        isA<ValidationException>().having(
          (error) => error.message,
          'message',
          contains('maksimal 20 MB'),
        ),
      ),
    );
  });
}

bool _containsBytes(List<int> haystack, List<int> needle) {
  for (var start = 0; start <= haystack.length - needle.length; start++) {
    var matches = true;
    for (var index = 0; index < needle.length; index++) {
      if (haystack[start + index] != needle[index]) {
        matches = false;
        break;
      }
    }
    if (matches) return true;
  }
  return false;
}
