import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

/// Encrypted persistence for tokens and sensitive user data.
///
/// Tokens are **never** stored in SharedPreferences.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: StorageKeys.accessToken, value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: StorageKeys.accessToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: StorageKeys.refreshToken, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  Future<void> saveUserInfo(String json) =>
      _storage.write(key: StorageKeys.userInfo, value: json);

  Future<String?> getUserInfo() => _storage.read(key: StorageKeys.userInfo);

  Future<String?> getDeviceInfo() => _storage.read(key: StorageKeys.deviceInfo);

  Future<void> saveDeviceInfo(String json) =>
      _storage.write(key: StorageKeys.deviceInfo, value: json);

  Future<void> clearTokens() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }

  Future<void> clearAll() => _storage.deleteAll();

  Future<bool> get hasAccessToken async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
