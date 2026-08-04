import 'package:beans_detection/services/prediction_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('health succeeds only when API, database, and model are ready',
      () async {
    final service = PredictionApiService(
      client: MockClient((request) async {
        expect(request.url.toString(), 'http://203.145.35.191/health');
        return http.Response(
          '{"status":"ok","database":true,"model":true}',
          200,
        );
      }),
    );
    expect(await service.checkHealth(), isTrue);
  });

  test('health rejects partial or invalid response', () async {
    final partial = PredictionApiService(
      client: MockClient(
        (_) async =>
            http.Response('{"status":"ok","database":true,"model":false}', 200),
      ),
    );
    final invalid = PredictionApiService(
      client: MockClient((_) async => http.Response('not-json', 200)),
    );
    expect(await partial.checkHealth(), isFalse);
    expect(await invalid.checkHealth(), isFalse);
  });
}
