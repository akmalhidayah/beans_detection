import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

class ApiResponseHandler {
  const ApiResponseHandler._();

  static String message(String body, {String fallback = ''}) {
    if (body.trim().isEmpty) return fallback;
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) return fallback;
      final value = decoded['detail'] ?? decoded['message'] ?? decoded['error'];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is List) {
        final messages = value
            .map((item) {
              if (item is Map) {
                return (item['msg'] ?? item['message'] ?? item['detail'])
                        ?.toString()
                        .trim() ??
                    '';
              }
              return item.toString().trim();
            })
            .where((item) => item.isNotEmpty)
            .toList();
        if (messages.isNotEmpty) return messages.join('; ');
      }
    } on FormatException {
      return fallback;
    }
    return fallback;
  }

  static ApiException exception(http.Response response) {
    final backendMessage = message(response.body);
    switch (response.statusCode) {
      case 400:
        return ValidationException(
          backendMessage.isEmpty ? 'Permintaan tidak valid.' : backendMessage,
          statusCode: 400,
        );
      case 401:
        return AuthenticationException(
          backendMessage.isEmpty
              ? 'Email atau password tidak valid.'
              : backendMessage,
          statusCode: 401,
        );
      case 403:
        return AuthenticationException(
          backendMessage.isEmpty ? 'Akses ditolak.' : backendMessage,
          statusCode: 403,
        );
      case 409:
        return ValidationException(
          backendMessage.isEmpty ? 'Email sudah digunakan.' : backendMessage,
          statusCode: 409,
        );
      case 422:
        return ValidationException(
          backendMessage.isEmpty
              ? 'Data yang dikirim tidak valid.'
              : backendMessage,
          statusCode: 422,
        );
      default:
        return ApiException(
          response.statusCode >= 500
              ? 'Terjadi kesalahan pada server. Silakan coba lagi.'
              : (backendMessage.isEmpty
                  ? 'Permintaan tidak dapat diproses.'
                  : backendMessage),
          statusCode: response.statusCode,
        );
    }
  }

  static void logRequest(String method, Uri uri) {
    if (kDebugMode) debugPrint('[API] $method $uri');
  }

  static void logResponse(http.Response response) {
    if (!kDebugMode) return;
    final safeBody = _redactedBody(response.body);
    final body =
        safeBody.length > 500 ? '${safeBody.substring(0, 500)}…' : safeBody;
    debugPrint('[API] Status: ${response.statusCode}');
    debugPrint('[API] Body: $body');
  }

  static void logException(Object error) {
    if (kDebugMode) debugPrint('[API] Exception: ${error.runtimeType}');
  }

  static String _redactedBody(String body) {
    try {
      return jsonEncode(_redact(jsonDecode(body)));
    } on FormatException {
      return body;
    }
  }

  static dynamic _redact(dynamic value) {
    if (value is List) return value.map(_redact).toList();
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _isSensitive(entry.key.toString())
              ? '[REDACTED]'
              : _redact(entry.value),
      };
    }
    return value;
  }

  static bool _isSensitive(String key) {
    final normalized = key.toLowerCase();
    return normalized.contains('token') ||
        normalized.contains('password') ||
        normalized.contains('secret');
  }
}
