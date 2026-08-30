/// Sealed hierarchy of application exceptions.
///
/// Repositories convert Dio/network failures into these types and wrap them
/// inside [Result] so callers never catch raw exceptions.
sealed class AppException implements Exception {
  const AppException(this.message, {this.code, this.originalError});

  final String message;
  final String? code;
  final Object? originalError;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Generic API / server-side failure.
class ApiException extends AppException {
  const ApiException(
    super.message, {
    super.code,
    this.statusCode,
    super.originalError,
  });

  final int? statusCode;
}

/// Thrown when authentication is missing or invalid.
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    String message = 'Session expired. Please sign in again.',
    String? code,
    Object? originalError,
  }) : super(message, code: code, originalError: originalError);
}

/// Request timed out.
class TimeoutException extends AppException {
  const TimeoutException({
    String message = 'The request timed out. Please try again.',
    String? code,
    Object? originalError,
  }) : super(message, code: code, originalError: originalError);
}

/// Device has no active internet connection.
class NoInternetException extends AppException {
  const NoInternetException({
    String message = 'No internet connection.',
    String? code,
    Object? originalError,
  }) : super(message, code: code, originalError: originalError);
}

/// Catch-all for unexpected failures.
class UnknownException extends AppException {
  const UnknownException({
    String message = 'Something went wrong. Please try again.',
    String? code,
    Object? originalError,
  }) : super(message, code: code, originalError: originalError);
}

/// User cancelled the face-scan flow.
class FaceScanCancelledException extends AppException {
  const FaceScanCancelledException({
    String message = 'Face scan cancelled.',
    String? code,
    Object? originalError,
  }) : super(message, code: code, originalError: originalError);
}

/// Face-scan plugin / biomarker pipeline failure.
class FaceScanFailedException extends AppException {
  const FaceScanFailedException(
    super.message, {
    super.code,
    super.originalError,
  });
}
