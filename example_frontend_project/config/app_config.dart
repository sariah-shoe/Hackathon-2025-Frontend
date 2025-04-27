import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

enum Environment { dev, staging, prod }

class AppConfig {
  final String apiBaseUrl;
  final Environment environment;
  final bool enableLogging;
  final Duration timeoutDuration;
  final int maxRetries;

  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() => _instance;

  AppConfig._internal()
      : environment = kDebugMode ? Environment.dev : Environment.prod,
        apiBaseUrl = kDebugMode
            ? Platform.isAndroid
                ? 'http://10.0.2.2:3000/api/v1'
                : 'http://localhost:3000/api/v1'
            : 'https://api.ironiq.dev',
        enableLogging = kDebugMode,
        timeoutDuration = const Duration(seconds: 30),
        maxRetries = 3;

  static bool get isDevelopment => _instance.environment == Environment.dev;
  static bool get isStaging => _instance.environment == Environment.staging;
  static bool get isProduction => _instance.environment == Environment.prod;
}
