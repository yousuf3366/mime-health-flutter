import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Verbose request/response logger covering JSON and multipart payloads.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['request_start_ms'] = DateTime.now().millisecondsSinceEpoch;

    if (kDebugMode) {
      debugPrint('┌── REQUEST ──────────────────────────────────────');
      debugPrint('│ ${options.method} ${options.uri}');
      debugPrint('│ Headers: ${_pretty(options.headers)}');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('│ Query: ${_pretty(options.queryParameters)}');
      }
      debugPrint('│ Body: ${_formatBody(options.data)}');
      debugPrint('└─────────────────────────────────────────────────');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final start = response.requestOptions.extra['request_start_ms'] as int?;
      final elapsed = start == null
          ? 'n/a'
          : '${DateTime.now().millisecondsSinceEpoch - start}ms';

      debugPrint('┌── RESPONSE ─────────────────────────────────────');
      debugPrint(
        '│ ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}',
      );
      debugPrint('│ Time: $elapsed');
      debugPrint('│ Body: ${_formatBody(response.data)}');
      debugPrint('└─────────────────────────────────────────────────');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final start = err.requestOptions.extra['request_start_ms'] as int?;
      final elapsed = start == null
          ? 'n/a'
          : '${DateTime.now().millisecondsSinceEpoch - start}ms';

      debugPrint('┌── ERROR ────────────────────────────────────────');
      debugPrint(
        '│ ${err.response?.statusCode ?? '-'} ${err.requestOptions.method} '
        '${err.requestOptions.uri}',
      );
      debugPrint('│ Type: ${err.type}');
      debugPrint('│ Time: $elapsed');
      debugPrint('│ Message: ${err.message}');
      debugPrint('│ Body: ${_formatBody(err.response?.data)}');
      debugPrint('└─────────────────────────────────────────────────');
    }

    handler.next(err);
  }

  String _formatBody(dynamic data) {
    if (data == null) return 'null';
    if (data is FormData) {
      final fields = data.fields.map((e) => '${e.key}=${e.value}').join(', ');
      final files = data.files
          .map(
            (e) =>
                '${e.key}=${e.value.filename} (${e.value.contentType}, '
                '${e.value.length} bytes)',
          )
          .join(', ');
      return 'Multipart{fields: [$fields], files: [$files]}';
    }
    if (data is Map || data is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(data);
      } catch (_) {
        return data.toString();
      }
    }
    return data.toString();
  }

  String _pretty(Object value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }
}
