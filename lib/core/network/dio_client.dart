import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import '../services/connectivity_service.dart';
import '../storage/secure_storage_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Factory that builds a production-ready [Dio] instance with interceptors.
class DioClient {
  DioClient({
    required SecureStorageService secureStorage,
    required ConnectivityService connectivityService,
    required Talker talker,
    OnSessionExpired? onSessionExpired,
    String? baseUrl,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl ?? AppConfig.baseUrl,
           connectTimeout: AppConfig.connectTimeout,
           receiveTimeout: AppConfig.receiveTimeout,
           sendTimeout: AppConfig.sendTimeout,
           headers: {
             Headers.contentTypeHeader: AppConstants.contentTypeJson,
             Headers.acceptHeader: AppConstants.contentTypeJson,
           },
           // 4xx responses must enter Dio's error pipeline so the auth
           // interceptor can refresh tokens or end an expired session.
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
      AuthInterceptor(
        secureStorage: secureStorage,
        dio: dio,
        onSessionExpired: onSessionExpired,
      ),
      RetryInterceptor(dio: dio),
      LoggingInterceptor(),
      // if (kDebugMode)
      // TalkerDioLogger(
      //   talker: talker,
      //   settings: const TalkerDioLoggerSettings(
      //     printRequestHeaders: true,
      //     printRequestData: true,
      //     printResponseHeaders: true,
      //     printResponseData: true,
      //     printResponseMessage: true,
      //     printErrorData: true,
      //     printErrorHeaders: true,
      //     printErrorMessage: true,
      //   ),
      // ),
    ]);
  }

  final Dio dio;

  CancelToken createCancelToken() => CancelToken();
}
