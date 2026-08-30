import '../../domain/entity/user_entity.dart';
import '../model/login_models.dart';

/// Converts auth data models into domain entities.
///
/// Lives in the data layer and is used by the repository boundary.

class AuthMapper {
  AuthMapper._();

  static UserEntity toUserEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      phone: model.phone,
      name: model.name,
      email: model.email,
      avatarUrl: model.avatarUrl,
      status: model.status,
      phoneVerifiedAt: model.phoneVerifiedAt,
      emailVerifiedAt: model.emailVerifiedAt,
      createdAt: model.createdAt,
    );
  }

  static DeviceEntity toDeviceEntity(DeviceModel model) {
    return DeviceEntity(
      id: model.id,
      deviceFingerprint: model.deviceFingerprint,
      deviceName: model.deviceName,
      platform: model.platform,
      appVersion: model.appVersion,
      osVersion: model.osVersion,
      isActive: model.isActive,
      lastActiveAt: model.lastActiveAt,
      createdAt: model.createdAt,
    );
  }

  static AuthTokens toAuthTokens({
    required String accessToken,
    required String refreshToken,
    String tokenType = 'Bearer',
    int? expiresIn,
  }) {
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
    );
  }

  static OtpDispatchResult toOtpDispatchResult(OtpSentResponseModel model) {
    return OtpDispatchResult(
      message: model.message,
      expiresInSeconds: model.expiresInSeconds,
    );
  }

  static AuthSessionEntity toAuthSession(LoginResponseModel model) {
    return AuthSessionEntity(
      user: toUserEntity(model.user),
      device: toDeviceEntity(model.device),
      tokens: toAuthTokens(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
        tokenType: model.tokenType,
        expiresIn: model.expiresIn,
      ),
      isNewUser: model.isNewUser,
      message: model.message,
      rawUserInfo: model.rawUserInfo,
      rawDeviceInfo: model.rawDeviceInfo,
    );
  }
}
