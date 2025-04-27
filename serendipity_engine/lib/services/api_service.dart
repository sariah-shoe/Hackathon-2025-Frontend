import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:serendipity_engine/services/token_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  
  factory ApiService() {
    return _instance;
  }
  
  ApiService._internal();
  
  final TokenService _tokenService = TokenService();
  final String _baseUrl = 'https://teaching-neutral-rattler.ngrok-free.app/api';
  
  // Function to refresh the token
  Future<bool> refreshToken() async {
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/token/refresh/'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['access'];
        
        // Get existing refresh token since the Django refresh endpoint might not return it
        final existingRefreshToken = await _tokenService.getRefreshToken();
        
        // Save the new access token with existing refresh token
        await _tokenService.saveTokens(
          accessToken: newAccessToken,
          refreshToken: existingRefreshToken ?? '',
        );
        
        return true;
      } else {
        // If refresh token is invalid, clear tokens and require re-login
        await _tokenService.deleteTokens();
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  
  // Add authorization header to request
  Future<Map<String, String>> _getAuthHeaders() async {
    final accessToken = await _tokenService.getAccessToken();
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (accessToken != null) HttpHeaders.authorizationHeader: 'Bearer $accessToken',
    };
  }
  
  // GET request with authentication
  Future<http.Response> get(String endpoint) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: headers,
    );
    
    // Handle token expiration
    if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        // Retry with new token
        final newHeaders = await _getAuthHeaders();
        return http.get(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: newHeaders,
        );
      }
    }
    
    return response;
  }
  
  // POST request with authentication
  Future<http.Response> post(String endpoint, dynamic body) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    
    // Handle token expiration
    if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        // Retry with new token
        final newHeaders = await _getAuthHeaders();
        return http.post(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: newHeaders,
          body: jsonEncode(body),
        );
      }
    }
    
    return response;
  }
  
  // Similar implementations for put(), delete(), etc.
  Future<http.Response> put(String endpoint, dynamic body) async {
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    
    if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        final newHeaders = await _getAuthHeaders();
        return http.put(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: newHeaders,
          body: jsonEncode(body),
        );
      }
    }
    
    return response;
  }
  
  Future<http.Response> delete(String endpoint) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: headers,
    );
    
    if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        final newHeaders = await _getAuthHeaders();
        return http.delete(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: newHeaders,
        );
      }
    }
    
    return response;
  }
}
