/// Centralized API path constants.
class ApiEndpoints {
  ApiEndpoints._();

  static const String sendOtp = '/api/v1/auth/otp/send';
  static const String verifyOtp = '/api/v1/auth/otp/verify';
  static const String resendOtp = '/api/v1/auth/otp/resend';
  static const String googleLogin = '/api/v1/auth/google-login';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String profiles = '/api/v1/profiles';

  static String profile(int id) => '$profiles/$id';

  static String profileAvatar(int id) => '$profiles/$id/avatar';

  /// e.g. `/translations/locales/bn`
  static String translations(String locale) =>
      '/api/v1/translations/locales/$locale';

  static const String scans = '/api/v1/scans';
  static const String faceScanUrl = '/api/v1/scans/get-face-scan-url';

  static const String subscriptionPlans = '/api/v1/subscription/plans';
  static const String mySubscribedPlan = '/api/v1/subscription/me';
  static const String latestScansResult = '/api/v1/scans/latest';
  static const String feedback = '/api/v1/feedback';
  static const String subscriptionSelectPlan =
      '/api/v1/subscription/select-plan';
}
