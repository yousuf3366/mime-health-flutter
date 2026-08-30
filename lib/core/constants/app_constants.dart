/// Generic app-level constants that are not config or storage keys.
class AppConstants {
  AppConstants._();

  static const String contentTypeJson = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String acceptLanguageHeader = 'Accept-Language';
  static const String intelliProveApiKeyHeader = 'x-api-key';
  static const String appBackgroundImage = 'assets/images/app_bg.png';
  static const String homeBackgroundImage = 'assets/images/home_bg.png';
  static const String appFullIcon = 'assets/images/app_full_icon.png';
  static const String appVersion = '1.0.0';

  /// Brand display name for chrome / hub screens.
  static const String brandName = 'MiMe Health';

  /// UI date format, e.g. `27/07/2026`.
  static const String uiDateFormat = 'dd/MM/yyyy';

  /// Server date format, e.g. `2026-07-27`.
  static const String serverDateFormat = 'yyyy-MM-dd';

  // ── Create-profile API enum values ────────────────────────────────
  static const String profileKindSelf = 'self';
  static const String profileKindFamily = 'family';
  static const String profileKindOther = 'other';

  static const String profileSexMale = 'male';
  static const String profileSexFemale = 'female';

  static const String profileLifestyleActive = 'Active';
  static const String profileLifestyleModerate = 'Moderate';
  static const String profileLifestyleInactive = 'Inactive';

  static const String profilePrivacyFullSharing = 'full_sharing';
}
