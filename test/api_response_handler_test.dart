import 'package:beans_detection/core/errors/app_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('parses detail, message, error, and non-JSON safely', () {
    expect(
        ApiResponseHandler.message('{"detail":"Email salah"}'), 'Email salah');
    expect(ApiResponseHandler.message('{"message":"Gagal"}'), 'Gagal');
    expect(
        ApiResponseHandler.message('{"error":"Tidak valid"}'), 'Tidak valid');
    expect(ApiResponseHandler.message('<html>error</html>', fallback: 'Aman'),
        'Aman');
  });

  test('parses FastAPI validation detail list', () {
    expect(
      ApiResponseHandler.message(
        '{"detail":[{"loc":["body","email"],"msg":"email tidak valid"},{"msg":"password terlalu pendek"}]}',
      ),
      'email tidak valid; password terlalu pendek',
    );
  });

  test('409 and 422 remain validation errors, not network errors', () {
    final conflict = ApiResponseHandler.exception(
      http.Response('{"detail":"Email sudah terdaftar."}', 409),
    );
    final invalid = ApiResponseHandler.exception(
      http.Response('{"detail":[{"msg":"field wajib diisi"}]}', 422),
    );
    expect(conflict, isA<ValidationException>());
    expect(conflict, isNot(isA<NetworkException>()));
    expect(conflict.statusCode, 409);
    expect(invalid, isA<ValidationException>());
    expect(invalid.message, 'field wajib diisi');
  });
}
