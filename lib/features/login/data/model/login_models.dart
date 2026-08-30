class SendOtpRequestModel {
  const SendOtpRequestModel({required this.phone});

  final String phone;

  Map<String, dynamic> toJson() => {'phone': phone};
}

class VerifyOtpRequestModel {
  const VerifyOtpRequestModel({
    required this.phone,
    required this.otp,
    required this.deviceFingerprint,
    required this.platform,
    required this.deviceName,
    required this.appVersion,
    required this.osVersion,
  });

  final String phone;
  final String otp;
  final String deviceFingerprint;
  final String platform;
  final String deviceName;
  final String appVersion;
  final String osVersion;

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'otp': otp,
    'device_fingerprint': deviceFingerprint,
    'platform': platform,
    'device_name': deviceName,
    'app_version': appVersion,
    'os_version': osVersion,
  };
}

class GoogleLoginRequestModel {
  const GoogleLoginRequestModel({
    required this.idToken,
    required this.deviceFingerprint,
    required this.platform,
    required this.deviceName,
    required this.appVersion,
    required this.osVersion,
    this.pushToken,
  });

  final String idToken;
  final String deviceFingerprint;
  final String platform;
  final String deviceName;
  final String appVersion;
  final String osVersion;
  final String? pushToken;

  Map<String, dynamic> toJson() => {
    'id_token': idToken,
    'device_fingerprint': deviceFingerprint,
    'platform': platform,
    'device_name': deviceName,
    'app_version': appVersion,
    'os_version': osVersion,
    'push_token': pushToken,
  };
}

class OtpSentResponseModel {
  const OtpSentResponseModel({
    required this.message,
    this.expiresInSeconds = 60,
  });

  final String message;
  final int expiresInSeconds;

  factory OtpSentResponseModel.fromJson(Map<String, dynamic> json) {
    final data = _unwrapData(json);
    return OtpSentResponseModel(
      message:
          json['message']?.toString() ??
          data['message']?.toString() ??
          'OTP sent',
      expiresInSeconds:
          (data['expires_in'] as num?)?.toInt() ??
          (data['expiresIn'] as num?)?.toInt() ??
          (json['expires_in'] as num?)?.toInt() ??
          60,
    );
  }
}

class UserModel {
  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      avatarUrl:
          json['avatar_url']?.toString() ?? json['avatarUrl']?.toString(),
      status: json['status']?.toString(),
      phoneVerifiedAt:
          json['phone_verified_at']?.toString() ??
          json['phoneVerifiedAt']?.toString(),
      emailVerifiedAt:
          json['email_verified_at']?.toString() ??
          json['emailVerifiedAt']?.toString(),
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'avatar_url': avatarUrl,
    'status': status,
    'phone_verified_at': phoneVerifiedAt,
    'email_verified_at': emailVerifiedAt,
    'created_at': createdAt,
  };
}

class DeviceModel {
  const DeviceModel({
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

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id']?.toString() ?? '',
      deviceFingerprint:
          json['device_fingerprint']?.toString() ??
          json['deviceFingerprint']?.toString(),
      deviceName:
          json['device_name']?.toString() ?? json['deviceName']?.toString(),
      platform: json['platform']?.toString(),
      appVersion:
          json['app_version']?.toString() ?? json['appVersion']?.toString(),
      osVersion:
          json['os_version']?.toString() ?? json['osVersion']?.toString(),
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool?,
      lastActiveAt:
          json['last_active_at']?.toString() ??
          json['lastActiveAt']?.toString(),
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'device_fingerprint': deviceFingerprint,
    'device_name': deviceName,
    'platform': platform,
    'app_version': appVersion,
    'os_version': osVersion,
    'is_active': isActive,
    'last_active_at': lastActiveAt,
    'created_at': createdAt,
  };
}

class LoginResponseModel {
  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.device,
    this.tokenType = 'Bearer',
    this.expiresIn,
    this.isNewUser = false,
    this.message,
    this.rawUserInfo = const {},
    this.rawDeviceInfo = const {},
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int? expiresIn;
  final bool isNewUser;
  final String? message;
  final UserModel user;
  final DeviceModel device;

  /// Raw `user` block from API `data.user`.
  final Map<String, dynamic> rawUserInfo;

  /// Raw `device` block from API `data.device`.
  final Map<String, dynamic> rawDeviceInfo;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = _unwrapData(json);
    final userJson = Map<String, dynamic>.from(
      (data['user'] as Map?) ?? const {},
    );
    final deviceJson = Map<String, dynamic>.from(
      (data['device'] as Map?) ?? const {},
    );

    return LoginResponseModel(
      accessToken:
          data['access_token']?.toString() ??
          data['accessToken']?.toString() ??
          '',
      refreshToken:
          data['refresh_token']?.toString() ??
          data['refreshToken']?.toString() ??
          '',
      tokenType:
          data['token_type']?.toString() ??
          data['tokenType']?.toString() ??
          'Bearer',
      expiresIn:
          (data['expires_in'] as num?)?.toInt() ??
          (data['expiresIn'] as num?)?.toInt(),
      isNewUser:
          data['is_new_user'] as bool? ?? data['isNewUser'] as bool? ?? false,
      message: json['message']?.toString() ?? data['message']?.toString(),
      user: UserModel.fromJson(userJson),
      device: DeviceModel.fromJson(deviceJson),
      rawUserInfo: userJson,
      rawDeviceInfo: deviceJson,
    );
  }
}

Map<String, dynamic> _unwrapData(Map<String, dynamic> json) {
  final data = json['data'];
  if (data is Map<String, dynamic>) {
    return data;
  }
  return json;
}
