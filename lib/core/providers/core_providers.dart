import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../network/dio_client.dart';
import '../network/intelliprove_dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../router/route_names.dart';
import '../services/connectivity_service.dart';
import '../services/device_info_service.dart';
import '../services/dialog_service.dart';
import '../services/snackbar_service.dart' show SnackbarService, rootNavigatorKey;
import '../storage/secure_storage_service.dart';
import '../storage/shared_prefs_service.dart';

/// Shared Talker instance used by the network inspector (debug only).
final talkerProvider = Provider<Talker>((ref) => Talker());

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

final sharedPrefsProvider = Provider<SharedPrefsService>((ref) {
  throw UnimplementedError('sharedPrefsProvider must be overridden in main()');
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

final deviceInfoServiceProvider = Provider<DeviceInfoService>(
  (ref) => DeviceInfoService(),
);

final deviceInfoProvider = FutureProvider((ref) {
  return ref.watch(deviceInfoServiceProvider).getDeviceInfo();
});

final snackbarServiceProvider = Provider<SnackbarService>(
  (ref) => SnackbarService(),
);

final dialogServiceProvider = Provider<DialogService>(
  (ref) => DialogService(),
);

/// Session-expired callback used by [AuthInterceptor].
final sessionExpiredHandlerProvider = Provider<OnSessionExpired>((ref) {
  return () async {
    await ref.read(secureStorageProvider).clearTokens();
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      GoRouter.of(context).go(RouteNames.login);
      ref.read(snackbarServiceProvider).showWarning(
            'Session expired. Please sign in again.',
          );
    }
  };
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    secureStorage: ref.watch(secureStorageProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
    talker: ref.watch(talkerProvider),
    onSessionExpired: ref.watch(sessionExpiredHandlerProvider),
  );
});

final dioProvider = Provider<Dio>((ref) => ref.watch(dioClientProvider).dio);

/// Separate Dio for IntelliProve Face Scan (own base URL + API key).
final intelliProveDioClientProvider = Provider<IntelliProveDioClient>((ref) {
  return IntelliProveDioClient(
    connectivityService: ref.watch(connectivityServiceProvider),
    talker: ref.watch(talkerProvider),
  );
});

final intelliProveDioProvider = Provider<Dio>(
  (ref) => ref.watch(intelliProveDioClientProvider).dio,
);

/// Exposes connectivity as a reactive stream for the offline banner.
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final async = ref.watch(connectivityStreamProvider);
  return async.when(
    data: (online) => online,
    loading: () => ref.watch(connectivityServiceProvider).isOnline,
    error: (error, stackTrace) => false,
  );
});
