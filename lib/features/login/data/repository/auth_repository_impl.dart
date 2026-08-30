import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/result.dart';
import '../../../../core/repository/base_repository.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../mapper/auth_mapper.dart';
import '../model/login_models.dart';

class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
    required SecureStorageService secureStorage,
    required DeviceInfoService deviceInfoService,
    required super.connectivityService,
  }) : _remote = remoteDatasource,
       _secureStorage = secureStorage,
       _deviceInfoService = deviceInfoService;

  final AuthRemoteDatasource _remote;
  final SecureStorageService _secureStorage;
  final DeviceInfoService _deviceInfoService;

  @override
  Future<Result<OtpDispatchResult>> sendOtp({required String phone}) {
    return safeApiCall(() async {
      final response = await _remote.sendOtp(SendOtpRequestModel(phone: phone));
      return AuthMapper.toOtpDispatchResult(response);
    });
  }

  @override
  Future<Result<OtpDispatchResult>> resendOtp({required String phone}) {
    return safeApiCall(() async {
      final response = await _remote.resendOtp(
        SendOtpRequestModel(phone: phone),
      );
      return AuthMapper.toOtpDispatchResult(response);
    });
  }

  @override
  Future<Result<AuthSessionEntity>> verifyOtp({
    required String phone,
    required String otp,
  }) {
    return safeApiCall(() async {
      final device = await _deviceInfoService.getDeviceInfo();
      final response = await _remote.verifyOtp(
        VerifyOtpRequestModel(
          phone: phone,
          otp: otp,
          deviceFingerprint: device.uniqueId,
          platform: device.platform,
          deviceName: '${device.brand} ${device.model}'.trim(),
          appVersion: AppConstants.appVersion,
          osVersion: '${device.platform} ${device.osVersion}'.trim(),
        ),
      );

      await _persistSession(response);
      return AuthMapper.toAuthSession(response);
    });
  }

  @override
  Future<Result<AuthSessionEntity>> googleLogin({
    required String idToken,
    String? pushToken,
  }) {
    return safeApiCall(() async {
      final device = await _deviceInfoService.getDeviceInfo();
      final response = await _remote.googleLogin(
        GoogleLoginRequestModel(
          idToken: idToken,
          deviceFingerprint: device.uniqueId,
          platform: device.platform,
          deviceName: device.model,
          appVersion: AppConstants.appVersion,
          osVersion: device.osVersion,
          pushToken: pushToken,
        ),
      );

      await _persistSession(response);
      return AuthMapper.toAuthSession(response);
    });
  }

  @override
  Future<Result<void>> logout() {
    return safeApiCall(() async {
      try {
        await _remote.logout();
      } catch (_) {
        // Local logout must succeed even if remote logout fails.
      }
      await _secureStorage.clearAll();
    });
  }

  @override
  Future<Result<AuthTokens>> refreshToken() {
    return safeApiCall(() async {
      final refresh = await _secureStorage.getRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        throw Exception('Missing refresh token');
      }

      final response = await _remote.refresh(refresh);
      await _secureStorage.saveAccessToken(response.accessToken);
      await _secureStorage.saveRefreshToken(response.refreshToken);

      return AuthMapper.toAuthTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        tokenType: response.tokenType,
        expiresIn: response.expiresIn,
      );
    });
  }

  @override
  Future<bool> isLoggedIn() => _secureStorage.hasAccessToken;

  @override
  Future<UserEntity?> getCachedUser() async {
    final raw = await _secureStorage.getUserInfo();
    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthMapper.toUserEntity(UserModel.fromJson(json));
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistSession(LoginResponseModel response) async {
    await _secureStorage.saveAccessToken(response.accessToken);
    await _secureStorage.saveRefreshToken(response.refreshToken);
    await _secureStorage.saveUserInfo(
      jsonEncode(
        response.rawUserInfo.isNotEmpty
            ? response.rawUserInfo
            : response.user.toJson(),
      ),
    );
    await _secureStorage.saveDeviceInfo(
      jsonEncode(
        response.rawDeviceInfo.isNotEmpty
            ? response.rawDeviceInfo
            : response.device.toJson(),
      ),
    );
  }
}
