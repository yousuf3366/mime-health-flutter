import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/usecase/login_usecase.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasource(ref.watch(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
    deviceInfoService: ref.watch(deviceInfoServiceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  ),
);

final sendOtpUseCaseProvider = Provider<SendOtpUseCase>(
  (ref) => SendOtpUseCase(ref.watch(authRepositoryProvider)),
);

final resendOtpUseCaseProvider = Provider<ResendOtpUseCase>(
  (ref) => ResendOtpUseCase(ref.watch(authRepositoryProvider)),
);

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>(
  (ref) => VerifyOtpUseCase(ref.watch(authRepositoryProvider)),
);

final googleLoginUseCaseProvider = Provider<GoogleLoginUseCase>(
  (ref) => GoogleLoginUseCase(ref.watch(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>(
  (ref) => RefreshTokenUseCase(ref.watch(authRepositoryProvider)),
);

final checkAuthUseCaseProvider = Provider<CheckAuthUseCase>(
  (ref) => CheckAuthUseCase(ref.watch(authRepositoryProvider)),
);
