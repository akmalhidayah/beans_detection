import 'package:beans_detection/core/config/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default API URL and endpoints are correct', () {
    expect(ApiConfig.baseUrl, 'http://203.145.35.191');
    expect(
      ApiConfig.uri(ApiConfig.registerEndpoint).toString(),
      'http://203.145.35.191/auth/register',
    );
  });

  test('normalizes slashes and query parameters', () {
    expect(
      ApiConfig.buildUri('http://203.145.35.191/', 'health').toString(),
      'http://203.145.35.191/health',
    );
    expect(
      ApiConfig.buildUri(
        'http://203.145.35.191/',
        '/admin/users',
        {'page': 2},
      ).toString(),
      'http://203.145.35.191/admin/users?page=2',
    );
  });
}
