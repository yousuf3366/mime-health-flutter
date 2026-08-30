import 'package:flutter/foundation.dart';

/// Application-wide configuration values.
///
/// Override at build time:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080`
class AppConfig {
  AppConfig._();

  /// Base URL for REST APIs.
  ///
  /// Defaults to this machine's LAN IP. Update if your backend runs elsewhere.
  /// - iOS Simulator / macOS / desktop: `http://127.0.0.1:8080` also works
  /// - Android Emulator → host machine: `http://10.0.2.2:8080`
  /// - Physical device: use your computer's LAN IP on the same Wi‑Fi
  //static const String baseUrl = 'http://10.204.149.33:8080';
  static const String baseUrl = 'https://test-life.mimebd.com/';

  /// Connect timeout for Dio requests.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Receive timeout for Dio requests.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Send timeout for Dio requests.
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Maximum automatic retry attempts for failed requests.
  static const int maxRetryCount = 3;

  /// Initial delay used by exponential backoff retry strategy.
  static const Duration retryBaseDelay = Duration(milliseconds: 500);

  /// Default language code when none is stored locally.
  static const String defaultLanguageCode = 'en';

  /// Application display name.
  static const String appName = 'Mime Health';

  // ── IntelliProve (Face Scan) — separate from Mime REST ─────────────

  /// IntelliProve Engine base URL.
  ///
  /// Override: `--dart-define=INTELLIPROVE_BASE_URL=https://engine.intelliprove.com`
  static const String intelliProveBaseUrl = String.fromEnvironment(
    'INTELLIPROVE_BASE_URL',
    defaultValue: 'https://engine.intelliprove.com',
  );

  /// IntelliProve API key (`x-api-key`).
  ///
  /// Override: `--dart-define=INTELLIPROVE_API_KEY=...`
  static const String intelliProveApiKey = String.fromEnvironment(
    'INTELLIPROVE_API_KEY',
    defaultValue: 'testKey-wkqhs6ya8xf295suue9gembfl1k9dwt269z1ybzj'
  );

  /// Plugin / API language for IntelliProve.
  ///
  /// Override: `--dart-define=INTELLIPROVE_LANGUAGE=en`
  static const String intelliProveLanguage = String.fromEnvironment(
    'INTELLIPROVE_LANGUAGE',
    defaultValue: 'en',
  );

  /// Default external user id when none is supplied from Mime profile.
  ///
  /// Override: `--dart-define=INTELLIPROVE_EXTERNAL_USER_ID=...`
  // static const String intelliProveExternalUserId = String.fromEnvironment(
  //   'INTELLIPROVE_EXTERNAL_USER_ID',
  //   defaultValue: 'mime-health-dev-user',
  // );

  /// When true, face-scan UI may use mock/plugin-free flows.
  ///
  /// Override: `--dart-define=USE_MOCK_SCAN=true`
  static const bool useMockFaceScan = bool.fromEnvironment(
    'USE_MOCK_SCAN',
    defaultValue: false,
  );

  static const Set<String> intelliProveSupportedLanguages = {
    'nl',
    'en',
    'fr',
    'da',
    'sv',
    'de',
    'es',
  };

  static String get intelliProveValidatedLanguage =>
      intelliProveSupportedLanguages.contains(intelliProveLanguage)
          ? intelliProveLanguage
          : 'en';

  static bool get hasIntelliProveApiKey => intelliProveApiKey.isNotEmpty;

  static void logNetworkTarget() {
    if (kDebugMode) {
      debugPrint(
        '[AppConfig] baseUrl=$baseUrl '
        'intelliProveBaseUrl=$intelliProveBaseUrl '
        'platform=$defaultTargetPlatform',
      );
    }
  }
}
