import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:serendipity_engine/services/token_service.dart';

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  
  factory AuthRepository() {
    return _instance;
  }
  
  AuthRepository._internal();
  
  final TokenService _tokenService = TokenService();
  final String _baseUrl = 'https://teaching-neutral-rattler.ngrok-free.app/api';
  
  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/token/'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['access'];
        final refreshToken = responseData['refresh'];
        
        // Store tokens securely
        await _tokenService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        
        return {
          'success': true,
          'message': 'Login successful',
          'data': responseData,
        };
      } else {
        String errorMessage = 'Authentication failed';
        
        try {
          final responseData = jsonDecode(response.body);
          if (responseData.containsKey('detail')) {
            errorMessage = responseData['detail'];
          }
        } catch (e) {
          // Use default error message
        }
        
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
  
  // Logout method
  Future<void> logout() async {
    await _tokenService.deleteTokens();
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _tokenService.isLoggedIn();
  }
}
