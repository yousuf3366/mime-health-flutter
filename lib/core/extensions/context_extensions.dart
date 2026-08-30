import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  bool get isDarkMode => theme.brightness == Brightness.dark;
}

/// Responsive scaling helpers based on iPhone X design size (375 × 812).
extension ResponsiveContext on BuildContext {
  static const double baseWidth = 375.0;
  static const double baseHeight = 812.0;

  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  double get defaultMarginSc => scaleWidth(16);

  double get defaultPaddingSc => scaleWidth(10);

  double scaleWidth(double value) => value * (screenWidth / baseWidth);

  double scaleHeight(double value) => value * (screenHeight / baseHeight);

  double get extraLargeFontSize => scaleWidth(22);

  double get largeFontSize => scaleWidth(20);

  double get titleFontSize => scaleWidth(18);

  double get bodyFontSize => scaleWidth(16);

  double get fontSize => scaleWidth(14);

  double get smallFontSize => scaleWidth(12);

  double get extraSmallFontSize => scaleWidth(10);

  double get defaultLineSpace => scaleHeight(10);
}

extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isBlank => trim().isEmpty;
}
