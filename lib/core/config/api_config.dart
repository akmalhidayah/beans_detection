class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://203.145.35.191',
  );

  static const String predictEndpoint = '/predict';
  static const String healthEndpoint = '/health';
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String googleLoginEndpoint = '/auth/google';
  static const String profileEndpoint = '/users/profile';
  static const String adminUsersEndpoint = '/admin/users';
  static const String modelUploadEndpoint = '/models/upload';

  static const String googleIosClientId =
      String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '839421124204-mdivcajm03elc5o5m6k256k9gra6ie82.apps.googleusercontent.com',
  );
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '839421124204-mdivcajm03elc5o5m6k256k9gra6ie82.apps.googleusercontent.com',
  );

  static Uri uri(String path, [Map<String, dynamic>? queryParameters]) =>
      buildUri(baseUrl, path, queryParameters);

  static Uri buildUri(
    String base,
    String path, [
    Map<String, dynamic>? queryParameters,
  ]) {
    final normalizedBase =
        base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$normalizedBase$normalizedPath');
    if (queryParameters == null || queryParameters.isEmpty) return uri;
    return uri.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }
}
