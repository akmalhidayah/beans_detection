import 'package:beans_detection/services/local_auth_service.dart';
import 'package:beans_detection/services/secure_session_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemorySessionStorage implements SessionStorage {
  String token = '';
  @override
  Future<void> deleteToken() async => token = '';
  @override
  Future<String> readToken() async => token;
  @override
  Future<void> writeToken(String value) async => token = value;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('register failure does not create a local session', () async {
    final storage = MemorySessionStorage();
    final service = LocalAuthService(
      sessionStorage: storage,
      client: MockClient((_) async => http.Response('unavailable', 503)),
    );
    await expectLater(
      service.register(name: 'A', email: 'a@b.com', password: 'secret'),
      throwsException,
    );
    expect(storage.token, isEmpty);
    expect(await service.isLoggedIn(), isFalse);
  });

  test('422 FastAPI list is readable', () {
    expect(
      LocalAuthService.parseFastApiMessage(
        '{"detail":[{"loc":["body","email"],"msg":"email tidak valid"}]}',
      ),
      'email tidak valid',
    );
  });

  test('logout removes token and preserves language', () async {
    SharedPreferences.setMockInitialValues(
        {'language': 'en', 'isLoggedIn': true});
    final storage = MemorySessionStorage()..token = 'jwt';
    final service = LocalAuthService(sessionStorage: storage);
    await service.logout();
    expect(storage.token, isEmpty);
    expect((await SharedPreferences.getInstance()).getString('language'), 'en');
  });

  test('profile cache changes only after authenticated server success', () async {
    SharedPreferences.setMockInitialValues({
      'id': 'user-1',
      'name': 'Nama Lama',
      'email': 'lama@example.com',
      'location': 'Lokasi Lama',
      'phone': '0812',
    });
    final storage = MemorySessionStorage()..token = 'jwt-valid';
    final service = LocalAuthService(
      sessionStorage: storage,
      client: MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer jwt-valid');
        return http.Response(
          '{"data":{"id":"user-1","name":"Nama Baru","email":"baru@example.com","location":"Lokasi Baru","phone":"0812","role":"user","is_active":true}}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    final user = await service.updateProfile(
      name: 'Nama Baru',
      email: 'baru@example.com',
      location: 'Lokasi Baru',
    );
    expect(user.name, 'Nama Baru');
    expect((await service.getUser()).email, 'baru@example.com');
  });

  test('profile server failure keeps existing local cache', () async {
    SharedPreferences.setMockInitialValues({
      'name': 'Nama Lama',
      'email': 'lama@example.com',
      'location': 'Lokasi Lama',
    });
    final storage = MemorySessionStorage()..token = 'jwt-valid';
    final service = LocalAuthService(
      sessionStorage: storage,
      client: MockClient((_) async => http.Response('{"detail":"konflik"}', 409)),
    );
    await expectLater(
      service.updateProfile(
        name: 'Nama Baru',
        email: 'baru@example.com',
        location: 'Lokasi Baru',
      ),
      throwsException,
    );
    expect((await service.getUser()).name, 'Nama Lama');
  });
}
