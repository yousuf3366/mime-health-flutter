import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import '../services/connectivity_service.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Dio factory for IntelliProve Engine APIs.
///
/// Separate from [DioClient] — different base URL, `x-api-key` auth, and no
/// Mime JWT / session refresh.
class IntelliProveDioClient {
  IntelliProveDioClient({
    required ConnectivityService connectivityService,
    required Talker talker,
    String? baseUrl,
    String? apiKey,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl ?? AppConfig.intelliProveBaseUrl,
           connectTimeout: AppConfig.connectTimeout,
           receiveTimeout: AppConfig.receiveTimeout,
           sendTimeout: AppConfig.sendTimeout,
           headers: {
             Headers.contentTypeHeader: AppConstants.contentTypeJson,
             Headers.acceptHeader: AppConstants.contentTypeJson,
             if ((apiKey ?? AppConfig.intelliProveApiKey).isNotEmpty)
               AppConstants.intelliProveApiKeyHeader:
                   apiKey ?? AppConfig.intelliProveApiKey,
           },
           validateStatus: (status) => status != null && status < 400,
         ),
       ) {
    dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final online = await connectivityService.checkConnectivity();
          if (!online) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: const NoInternetException(),
                type: DioExceptionType.connectionError,
                message: 'No internet connection.',
              ),
            );
          }
          handler.next(options);
        },
      ),
      RetryInterceptor(dio: dio),
      LoggingInterceptor(),
    ]);
  }

  final Dio dio;
}
