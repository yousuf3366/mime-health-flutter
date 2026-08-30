import 'package:flutter/material.dart';

/// Brand color palette tuned for the dark navy app background.
///
/// Each hex value is defined once. Semantic aliases reuse the canonical token.
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────
  static const Color background = Color(0xFF0B1B3A);
  //static const Color backgroundDeep = Color(0xFF06101F);
  //static const Color backgroundDeep = Color(0xFF05153C);
  static const Color backgroundDeep =Color(0xFF071440);
  static const Color blackLight =Color(0xFF0E0E0E);
  static const Color blackExtraLight =Color(0xff192022);

  /// Shared AppBar background — deeper navy than [background] for clear contrast.
  // static const Color appBar = Color(0xFF040F2B);

  // ── Brand / actions ──────────────────────────────────────────
  static const Color primary = Color(0xFF00DAF3);
  static const Color primaryDark = Color(0xFF00B8CC);
  static const Color primaryContainer = Color(0xFF00E5FF);
  static const Color onPrimary = Color(0xFF00343A);
  static const Color onPrimaryContainer = Color(0xFF00626E);
  static const Color secondary = Color(0xFF38BDF8);
  static const Color secondaryColor = Color(0xFF09194B);

  /// Selected pill option fill (`#26387C`).
  static const Color pillSelected = Color(0xFF26387C);

  /// Alias of [primary] for button fills.
  static const Color button = primary;

  /// Alias of [onPrimary] for button labels.
  static const Color onButton = onPrimary;

  // ── Surfaces ─────────────────────────────────────────────────
  static const Color surface = Color(0x1AFFFFFF);
  static const Color surfaceSolid = Color(0xFF132744);
  static const Color surfaceElevated = Color(0xFF1A3358);
  static const Color surfaceLow = Color(0xFF141936);
  static const Color glass = Color(0x991D2755);
  static const Color greenLight = Color(0xFF7CEAA1);

  /// Alias of [backgroundDeep] for lowest surface fill.
  static const Color surfaceLowest = backgroundDeep;

  // ── Feedback ─────────────────────────────────────────────────
  static const Color error = Color(0xFFF87171);
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color offlineBanner = Color(0xFFB45309);

  // ── Text / icons / borders ─────────────────────────────────
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFB8C4D9);
  static const Color textHint = Color(0xFF8B9BB8);
  static const Color icon = Color(0xFFE2E8F0);
  static const Color border = Color(0x33FFFFFF);
  static const Color outlineVariant = Color(0xFF3B494C);

  /// Alias of [primary] for focused borders.
  static const Color borderFocused = primary;

  /// Alias of [border] for glass card edges.
  static const Color glassBorder = border;
}
