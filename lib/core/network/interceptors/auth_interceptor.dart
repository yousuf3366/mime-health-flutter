import 'dart:async';

import 'package:dio/dio.dart';

import '../../constants/api_endpoints.dart';
import '../../constants/app_constants.dart';
import '../../storage/secure_storage_service.dart';

/// Callback invoked when refresh-token flow fails and the user must re-auth.
typedef OnSessionExpired = FutureOr<void> Function();

/// Attaches JWT access tokens and performs silent refresh on HTTP 401.
///
/// Flow on 401:
/// 1. Call refresh-token API
/// 2. Persist new tokens
/// 3. Retry the original request
/// 4. If refresh fails → clear tokens and invoke [onSessionExpired]
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.secureStorage,
    required this.dio,
    this.onSessionExpired,
    this.refreshPath = ApiEndpoints.refreshToken,
  });

  final SecureStorageService secureStorage;
  final Dio dio;
  final OnSessionExpired? onSessionExpired;
  final String refreshPath;

  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for auth endpoints themselves.
    if (_isAuthPath(options.path)) {
      return handler.next(options);
    }

    final token = await secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers[AppConstants.authorizationHeader] =
          '${AppConstants.bearerPrefix}$token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 ||
        _isAuthPath(err.requestOptions.path)) {
      return handler.next(err);
    }

    // Avoid recursive refresh loops.
    if (err.requestOptions.extra['retried_after_refresh'] == true) {
      await _forceLogout();
      return handler.next(err);
    }

    try {
      final refreshed = await _refreshTokens();
      if (!refreshed) {
        await _forceLogout();
        return handler.next(err);
      }

      final options = err.requestOptions;
      final newToken = await secureStorage.getAccessToken();
      options.headers[AppConstants.authorizationHeader] =
          '${AppConstants.bearerPrefix}$newToken';
      options.extra['retried_after_refresh'] = true;

      final response = await dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } catch (_) {
      await _forceLogout();
      return handler.next(err);
    }
  }

  Future<bool> _refreshTokens() async {
    if (_isRefreshing) {
      // Wait briefly for an in-flight refresh initiated by another request.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final token = await secureStorage.getAccessToken();
      return token != null && token.isNotEmpty;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Dedicated Dio instance to avoid interceptor recursion.
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: dio.options.connectTimeout,
          receiveTimeout: dio.options.receiveTimeout,
          headers: {Headers.contentTypeHeader: AppConstants.contentTypeJson},
        ),
      );

      final response = await refreshDio.post<Map<String, dynamic>>(
        refreshPath,
        data: {'refresh_token': refreshToken},
      );

      final responseJson = response.data ?? <String, dynamic>{};
      final rawData = responseJson['data'];
      final data = rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : responseJson;
      final access =
          data['access_token']?.toString() ?? data['accessToken']?.toString();
      final refresh =
          data['refresh_token']?.toString() ?? data['refreshToken']?.toString();

      if (access == null || access.isEmpty) {
        return false;
      }

      await secureStorage.saveAccessToken(access);
      if (refresh != null && refresh.isNotEmpty) {
        await secureStorage.saveRefreshToken(refresh);
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _forceLogout() async {
    await secureStorage.clearTokens();
    await onSessionExpired?.call();
  }

  bool _isAuthPath(String path) {
    return path.contains(ApiEndpoints.sendOtp) ||
        path.contains(ApiEndpoints.verifyOtp) ||
        path.contains(ApiEndpoints.resendOtp) ||
        path.contains(ApiEndpoints.googleLogin) ||
        path.contains(ApiEndpoints.refreshToken);
  }
}
