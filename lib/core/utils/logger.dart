import 'package:flutter/foundation.dart';

/// Thin wrapper around [debugPrint] for structured logging.
class AppLogger {
  AppLogger._();

  static void d(String message, {String tag = 'MimeHealth'}) {
    if (kDebugMode) debugPrint('[$tag] $message');
  }

  static void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String tag = 'MimeHealth',
  }) {
    if (kDebugMode) {
      debugPrint('[$tag][ERROR] $message');
      if (error != null) debugPrint('[$tag][ERROR] $error');
      if (stackTrace != null) debugPrint('$stackTrace');
    }
  }
}
