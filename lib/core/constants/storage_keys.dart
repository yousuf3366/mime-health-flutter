/// Keys used for secure storage and shared preferences.
class StorageKeys {
  StorageKeys._();

  static const selectedPlanCode = 'selected_plan_code';
  static const selectedBillingInterval = 'selected_billing_interval';

  // Secure storage
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userInfo = 'user_info';
  static const String deviceInfo = 'device_info';

  // Shared preferences
  static const String languageCode = 'language_code';
  static const String themeMode = 'theme_mode';
  static const String isFirstLaunch = 'is_first_launch';
}
