class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api-beans.wisataku.web.id',
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

  static Uri uri(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }
}
