import 'package:flutter/foundation.dart';

/// API and Network Constants
class ApiConstants {
  static const devBaseUrl = 'http://localhost:3000/api/v1';
  static const prodBaseUrl = 'https://api.ironiq.dev';
  static String get baseUrl => kDebugMode ? devBaseUrl : prodBaseUrl;

  static const timeout = Duration(seconds: 30);
  static const maxRetries = 3;
  static const apiVersion = 'v1';
}

/// Storage Keys for both secure and regular storage
class StorageKeys {
  // Auth Related
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const tokenExpiry = 'token_expiry';
  static const rememberMe = 'remember_me';

  // User Related
  static const userId = 'user_id';
  static const userProfile = 'user_profile';
  static const userPreferences = 'user_preferences';
  static const lastSync = 'last_sync';
}

/// UI Layout and Animation Constants
class UiConstants {
  // Layout
  static const defaultSpacing = 16.0;
  static const defaultPadding = 16.0;
  static const defaultRadius = 8.0;
  static const maxContentWidth = 1200.0;
  static const minTouchSize = 48.0;

  // Animations
  static const pageTransition = Duration(milliseconds: 300);
  static const buttonPress = Duration(milliseconds: 150);
  static const loadingIndicator = Duration(milliseconds: 1500);
  static const snackbarDuration = Duration(seconds: 4);
}

/// Validation Rules and Constraints
class ValidationConstants {
  // Auth
  static const passwordMinLength = 8;
  static const passwordMaxLength = 32;
  static const otpLength = 6;

  // User Input
  static const nameMinLength = 2;
  static const nameMaxLength = 50;
  static const bioMaxLength = 500;
  static const phoneMinLength = 10;

  // Regex Patterns
  static const emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const passwordPattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$';
  static const phonePattern = r'^\+?[\d\s-]{10,}$';
}

/// Asset Paths
class AssetPaths {
  // Images
  static const logoPath = 'assets/images/logo.png';
  static const placeholderPath = 'assets/images/placeholder.png';
  static const defaultAvatar = 'assets/images/default_avatar.png';

  // Icons
  static const appIcon = 'assets/icons/app_icon.png';

  // Data
  static const exercisesJson = 'assets/data/exercises.json';
}

/// Environment and App Configuration
class AppConfig {
  static const appName = 'IronIQ';
  static const appVersion = '1.0.0';
  static const buildNumber = '1';

  static bool get isDev => kDebugMode;
  static bool get isProd => !kDebugMode;

  static const supportEmail = 'support@ironiq.dev';
  static const privacyPolicyUrl = 'https://ironiq.dev/privacy';
  static const termsOfServiceUrl = 'https://ironiq.dev/terms';
}
