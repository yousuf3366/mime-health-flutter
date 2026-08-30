import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../constants/storage_keys.dart';

/// Non-sensitive preference storage (language, theme, flags).
class SharedPrefsService {
  SharedPrefsService(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPrefsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsService(prefs);
  }

  String get languageCode =>
      _prefs.getString(StorageKeys.languageCode) ??
      AppConfig.defaultLanguageCode;

  Future<bool> setLanguageCode(String code) =>
      _prefs.setString(StorageKeys.languageCode, code);

  String get themeMode => _prefs.getString(StorageKeys.themeMode) ?? 'system';

  Future<bool> setThemeMode(String mode) =>
      _prefs.setString(StorageKeys.themeMode, mode);

  bool get isFirstLaunch => _prefs.getBool(StorageKeys.isFirstLaunch) ?? true;

  Future<bool> setFirstLaunch(bool value) =>
      _prefs.setBool(StorageKeys.isFirstLaunch, value);

  // String? get selectedPlanCode =>
  //     _prefs.getString(StorageKeys.selectedPlanCode);
  //
  // Future<bool> setSelectedPlanCode(String? code) {
  //   if (code == null || code.isEmpty) {
  //     return _prefs.remove(StorageKeys.selectedPlanCode);
  //   }
  //   return _prefs.setString(StorageKeys.selectedPlanCode, code);
  // }
  //
  // String? get selectedBillingInterval =>
  //     _prefs.getString(StorageKeys.selectedBillingInterval);
  //
  // Future<bool> setSelectedBillingInterval(String? interval) {
  //   if (interval == null || interval.isEmpty) {
  //     return _prefs.remove(StorageKeys.selectedBillingInterval);
  //   }
  //   return _prefs.setString(StorageKeys.selectedBillingInterval, interval);
  // }

  // bool get hasSelectedPlan =>
  //     (selectedPlanCode?.trim().isNotEmpty ?? false);
}
