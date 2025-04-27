import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'text_themes.dart';

/// Custom theme extension for additional styling
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color primaryGradientStart;
  final Color primaryGradientEnd;
  final Color secondaryGradientStart;
  final Color secondaryGradientEnd;
  final BorderRadius defaultBorderRadius;
  final EdgeInsets defaultPadding;
  final Duration defaultAnimationDuration;

  const AppThemeExtension({
    required this.primaryGradientStart,
    required this.primaryGradientEnd,
    required this.secondaryGradientStart,
    required this.secondaryGradientEnd,
    required this.defaultBorderRadius,
    required this.defaultPadding,
    required this.defaultAnimationDuration,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? primaryGradientStart,
    Color? primaryGradientEnd,
    Color? secondaryGradientStart,
    Color? secondaryGradientEnd,
    BorderRadius? defaultBorderRadius,
    EdgeInsets? defaultPadding,
    Duration? defaultAnimationDuration,
  }) {
    return AppThemeExtension(
      primaryGradientStart: primaryGradientStart ?? this.primaryGradientStart,
      primaryGradientEnd: primaryGradientEnd ?? this.primaryGradientEnd,
      secondaryGradientStart:
          secondaryGradientStart ?? this.secondaryGradientStart,
      secondaryGradientEnd: secondaryGradientEnd ?? this.secondaryGradientEnd,
      defaultBorderRadius: defaultBorderRadius ?? this.defaultBorderRadius,
      defaultPadding: defaultPadding ?? this.defaultPadding,
      defaultAnimationDuration:
          defaultAnimationDuration ?? this.defaultAnimationDuration,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }

    return AppThemeExtension(
      primaryGradientStart:
          Color.lerp(primaryGradientStart, other.primaryGradientStart, t)!,
      primaryGradientEnd:
          Color.lerp(primaryGradientEnd, other.primaryGradientEnd, t)!,
      secondaryGradientStart:
          Color.lerp(secondaryGradientStart, other.secondaryGradientStart, t)!,
      secondaryGradientEnd:
          Color.lerp(secondaryGradientEnd, other.secondaryGradientEnd, t)!,
      defaultBorderRadius:
          BorderRadius.lerp(defaultBorderRadius, other.defaultBorderRadius, t)!,
      defaultPadding: EdgeInsets.lerp(defaultPadding, other.defaultPadding, t)!,
      defaultAnimationDuration: Duration(
        milliseconds: (defaultAnimationDuration.inMilliseconds +
                (other.defaultAnimationDuration.inMilliseconds -
                        defaultAnimationDuration.inMilliseconds) *
                    t)
            .round(),
      ),
    );
  }

  /// Create theme extension from color scheme
  static AppThemeExtension fromColorScheme(ColorScheme colorScheme) =>
      AppThemeExtension(
        primaryGradientStart: colorScheme.primary,
        primaryGradientEnd: colorScheme.primary.withValues(alpha: .8),
        secondaryGradientStart: colorScheme.secondary,
        secondaryGradientEnd: colorScheme.secondary.withValues(alpha: .8),
        defaultBorderRadius: BorderRadius.circular(12),
        defaultPadding: const EdgeInsets.all(16),
        defaultAnimationDuration: const Duration(milliseconds: 300),
      );
}

/// App theme configuration
class AppTheme {
  static ThemeData _baseTheme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: AppTextTheme.textTheme,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        dividerTheme: const DividerThemeData(
          space: 24,
          thickness: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          elevation: 8,
          selectedIconTheme: IconThemeData(size: 24),
          unselectedIconTheme: IconThemeData(size: 24),
          selectedLabelStyle: TextStyle(fontSize: 12),
          unselectedLabelStyle: TextStyle(fontSize: 12),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          elevation: 8,
          modalElevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
        ),
        dialogTheme: DialogTheme(
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        chipTheme: ChipThemeData(
          elevation: 0,
          pressElevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        extensions: [
          AppThemeExtension.fromColorScheme(colorScheme),
        ],
      );

  /// Create a light theme from a seed color
  static ThemeData lightFromSeed(Color seedColor,
      {double contrastLevel = 0.0}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      contrastLevel: contrastLevel,
    );
    return _baseTheme(colorScheme);
  }

  /// Create a dark theme from a seed color
  static ThemeData darkFromSeed(Color seedColor, {double contrastLevel = 0.0}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      contrastLevel: contrastLevel,
    );
    return _baseTheme(colorScheme);
  }

  /// Default light theme
  static ThemeData get light => lightFromSeed(AppColorScheme.defaultSeedColor);

  /// Default dark theme
  static ThemeData get dark => darkFromSeed(AppColorScheme.defaultSeedColor);
}
