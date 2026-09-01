import 'package:flutter/material.dart';

/// Brand palette for PulseHub. PulseHub is meant to read as a social/
/// community app first, not a finance dashboard, so the primary hues stay
/// warm/approachable and the "data-heavy" dashboard screens (built in a
/// later phase) lean on the same palette rather than a separate look.
abstract final class AppColors {
  static const Color primary = Color(0xFF5B5BF0);
  static const Color primaryDark = Color(0xFF8A8AF7);

  static const Color secondary = Color(0xFF00C2A8);

  static const Color error = Color(0xFFE5484D);
  static const Color warning = Color(0xFFF5A623);
  static const Color success = Color(0xFF30A46C);

  static const Color lightBackground = Color(0xFFF7F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);

  static const Color darkBackground = Color(0xFF121214);
  static const Color darkSurface = Color(0xFF1C1C1F);
}
