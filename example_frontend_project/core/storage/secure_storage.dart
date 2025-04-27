import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Handles secure storage of sensitive data like authentication tokens
class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  late final FlutterSecureStorage _storage;

  factory SecureStorage() => _instance;

  SecureStorage._internal() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
  }

  // Token Storage Keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _rememberMeKey = 'remember_me';
  static const String _cookieKey = 'session_cookie';

  /// Stores authentication tokens and related data
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required bool rememberMe,
  }) async {
    final expiryTime = DateTime.now()
        .add(Duration(seconds: expiresIn))
        .millisecondsSinceEpoch
        .toString();

    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _tokenExpiryKey, value: expiryTime),
      _storage.write(key: _rememberMeKey, value: rememberMe.toString()),
    ]);
  }

  /// Retrieves the stored access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Retrieves the stored refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Checks if the stored token is still valid
  Future<bool> hasValidToken() async {
    try {
      final expiryStr = await _storage.read(key: _tokenExpiryKey);
      if (expiryStr == null) return false;

      final expiry = int.parse(expiryStr);
      return DateTime.now().millisecondsSinceEpoch < expiry;
    } catch (e) {
      return false;
    }
  }

  /// Checks if "Remember Me" was enabled during login
  Future<bool> isRememberMeEnabled() async {
    final value = await _storage.read(key: _rememberMeKey);
    return value?.toLowerCase() == 'true';
  }

  /// Clears all stored authentication data
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _tokenExpiryKey),
      _storage.delete(key: _rememberMeKey),
    ]);
  }

  /// Stores additional secure data
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Retrieves stored secure data
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Removes specific stored secure data
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> storeCookie(String cookie) async {
    await _storage.write(key: _cookieKey, value: cookie);
  }

  Future<String?> getCookie() async {
    return await _storage.read(key: _cookieKey);
  }

  Future<void> clearCookie() async {
    await _storage.delete(key: _cookieKey);
  }
}
