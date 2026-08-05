import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper SharedPreferences agar mudah diganti/diperluas nanti
class StorageService {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyUser = 'user_data';

  // ================= SINGLETON =================
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // ================= AUTH STATE =================
  Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool(_keyIsLoggedIn, value);
  }

  bool get isLoggedIn => _prefs?.getBool(_keyIsLoggedIn) ?? false;

  // ================= USER DATA =================
  Future<void> saveUser(Map<String, dynamic> userJson) async {
    await _prefs?.setString(_keyUser, jsonEncode(userJson));
  }

  Map<String, dynamic>? getUser() {
    final raw = _prefs?.getString(_keyUser);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ================= CLEAR =================
  Future<void> clearAuth() async {
    await _prefs?.remove(_keyIsLoggedIn);
    await _prefs?.remove(_keyUser);
  }
}
