class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([
    super.message =
        'Server tidak dapat dihubungi. Periksa koneksi internet lalu coba lagi.',
  ]);
}

class AuthenticationException extends ApiException {
  const AuthenticationException(super.message, {super.statusCode});
}

class SessionExpiredException extends AuthenticationException {
  const SessionExpiredException([
    super.message = 'Sesi telah berakhir. Silakan login kembali.',
  ]) : super(statusCode: 401);
}

class ValidationException extends ApiException {
  const ValidationException(super.message, {super.statusCode = 422});
}
