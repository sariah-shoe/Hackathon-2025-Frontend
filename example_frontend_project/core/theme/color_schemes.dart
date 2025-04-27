import 'package:flutter/material.dart';

/// App color schemes
class AppColorScheme {
  /// Primary brand color - default seed color
  static const Color defaultSeedColor = Color(0xFF6750A4);

  /// Generate a light color scheme from a seed color
  static ColorScheme lightFromSeed(Color seedColor) => ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      );

  /// Generate a dark color scheme from a seed color
  static ColorScheme darkFromSeed(Color seedColor) => ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      );

  /// Default light theme color scheme
  static ColorScheme get light => lightFromSeed(defaultSeedColor);

  /// Default dark theme color scheme
  static ColorScheme get dark => darkFromSeed(defaultSeedColor);
}
