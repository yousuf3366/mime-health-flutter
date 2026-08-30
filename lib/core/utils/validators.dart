/// Form-field validators used across auth and profile screens.
class Validators {
  Validators._();

  /// Accepts BD-style mobiles (01XXXXXXXXX) and international digits (10–15).
  static final _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
  static final _emailRegex = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
  );

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final normalized = value.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (!_phoneRegex.hasMatch(normalized)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? optionalPhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return phone(value);
  }

  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? otp(String? value, {int length = 4}) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }
    final trimmed = value.trim();
    if (!RegExp('^\\d{$length}\$').hasMatch(trimmed)) {
      return 'Enter the $length-digit OTP';
    }
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
