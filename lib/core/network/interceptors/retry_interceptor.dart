import 'dart:math';

import 'package:dio/dio.dart';

import '../../config/app_config.dart';

/// Retries failed requests with exponential backoff.
///
/// Supports GET, POST, PUT, DELETE, PATCH and multipart uploads.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = AppConfig.maxRetryCount,
    this.baseDelay = AppConfig.retryBaseDelay,
  });

  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;

  static const _retryableMethods = {
    'GET',
    'POST',
    'PUT',
    'DELETE',
    'PATCH',
  };

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra['retry_attempt'] as int?) ?? 0;

    if (!_shouldRetry(err, attempt)) {
      return handler.next(err);
    }

    final nextAttempt = attempt + 1;
    options.extra['retry_attempt'] = nextAttempt;

    final delay = _computeDelay(nextAttempt);
    await Future<void>.delayed(delay);

    try {
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err, int attempt) {
    if (attempt >= maxRetries) return false;
    if (!_retryableMethods.contains(err.requestOptions.method.toUpperCase())) {
      return false;
    }

    // Do not retry cancelled requests or successful client auth errors.
    if (err.type == DioExceptionType.cancel) return false;
    if (err.response?.statusCode == 401) return false;
    if (err.response?.statusCode == 403) return false;
    if (err.response?.statusCode == 400) return false;

    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }

  Duration _computeDelay(int attempt) {
    final millis = baseDelay.inMilliseconds * pow(2, attempt - 1);
    final jitter = Random().nextInt(100);
    return Duration(milliseconds: millis.toInt() + jitter);
  }
}
