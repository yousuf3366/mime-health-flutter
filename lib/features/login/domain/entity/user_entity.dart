import 'package:equatable/equatable.dart';

/// Authenticated user domain entity.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.avatarUrl,
    this.status,
    this.phoneVerifiedAt,
    this.emailVerifiedAt,
    this.createdAt,
  });

  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final String? status;
  final String? phoneVerifiedAt;
  final String? emailVerifiedAt;
  final String? createdAt;

  String get displayName =>
      (name != null && name!.trim().isNotEmpty) ? name!.trim() : 'User';

  @override
  List<Object?> get props => [
        id,
        phone,
        name,
        email,
        avatarUrl,
        status,
        phoneVerifiedAt,
        emailVerifiedAt,
        createdAt,
      ];
}

/// Registered device domain entity.
class DeviceEntity extends Equatable {
  const DeviceEntity({
    required this.id,
    this.deviceFingerprint,
    this.deviceName,
    this.platform,
    this.appVersion,
    this.osVersion,
    this.isActive,
    this.lastActiveAt,
    this.createdAt,
  });

  final String id;
  final String? deviceFingerprint;
  final String? deviceName;
  final String? platform;
  final String? appVersion;
  final String? osVersion;
  final bool? isActive;
  final String? lastActiveAt;
  final String? createdAt;

  @override
  List<Object?> get props => [
        id,
        deviceFingerprint,
        deviceName,
        platform,
        appVersion,
        osVersion,
        isActive,
        lastActiveAt,
        createdAt,
      ];
}

/// JWT token pair returned by auth APIs.
class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int? expiresIn;

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType, expiresIn];
}

/// Combined login outcome after successful OTP verification.
class AuthSessionEntity extends Equatable {
  const AuthSessionEntity({
    required this.user,
    required this.device,
    required this.tokens,
    this.isNewUser = false,
    this.message,
    this.rawUserInfo = const {},
    this.rawDeviceInfo = const {},
  });

  final UserEntity user;
  final DeviceEntity device;
  final AuthTokens tokens;
  final bool isNewUser;
  final String? message;

  /// Raw `user` block from API `data.user`.
  final Map<String, dynamic> rawUserInfo;

  /// Raw `device` block from API `data.device`.
  final Map<String, dynamic> rawDeviceInfo;

  @override
  List<Object?> get props => [
        user,
        device,
        tokens,
        isNewUser,
        message,
        rawUserInfo,
        rawDeviceInfo,
      ];
}

/// Result of a send/resend OTP call.
class OtpDispatchResult extends Equatable {
  const OtpDispatchResult({
    required this.message,
    required this.expiresInSeconds,
  });

  final String message;
  final int expiresInSeconds;

  @override
  List<Object?> get props => [message, expiresInSeconds];
}
