import 'package:dio/dio.dart';

import 'exceptions.dart';

/// Maps low-level errors (Dio, Dart) into typed [AppException]s.
class ErrorHandler {
  ErrorHandler._();

  /// Converts any thrown object into a domain [AppException].
  static AppException handle(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _mapDioException(error);
    }

    return UnknownException(
      message: error.toString(),
      originalError: error,
    );
  }

  static AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return TimeoutException(
          message: 'The request timed out. Please try again.',
          code: error.response?.statusCode?.toString(),
          originalError: error,
        );
      case DioExceptionType.connectionError:
        return NoInternetException(
          message: 'Unable to reach the server. Check your connection.',
          originalError: error,
        );
      case DioExceptionType.badResponse:
        return _mapStatusCode(error);
      case DioExceptionType.cancel:
        return const ApiException('Request was cancelled.');
      case DioExceptionType.badCertificate:
        return const ApiException('Invalid SSL certificate.');
      case DioExceptionType.unknown:
        if (error.error is NoInternetException) {
          return error.error! as NoInternetException;
        }
        return UnknownException(
          message: error.message ?? 'Unexpected network error.',
          originalError: error,
        );
    }
  }

  static AppException _mapStatusCode(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = _extractMessage(error.response?.data) ??
        error.message ??
        'Request failed.';

    if (statusCode == 401) {
      return UnauthorizedException(
        message: message,
        code: statusCode?.toString(),
        originalError: error,
      );
    }

    return ApiException(
      message,
      code: statusCode?.toString(),
      statusCode: statusCode,
      originalError: error,
    );
  }

  static String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is String && data.isNotEmpty) return data;
    if (data is Map) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message is String && message.isNotEmpty) return message;
    }
    return null;
  }
}
