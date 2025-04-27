import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  late final SharedPreferences _prefs;
  
  factory StorageService() => _instance;

  StorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await _prefs.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final data = _prefs.getString(key);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }

  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }
} 