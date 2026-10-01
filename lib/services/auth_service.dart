import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserId = 'user_id';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  static Future<void> saveAuthData({
    required String token,
    required String email,
    String? name,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyAuthToken, token);
    await prefs.setString(_keyUserEmail, email);
    if (name != null) {
      await prefs.setString(_keyUserName, name);
    }
    if (userId != null) {
      await prefs.setString(_keyUserId, userId);
    }
  }

  static Future<void> setLoggedIn({
    required bool isLoggedIn,
    String? email,
    String? name,
    String? token,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
    if (email != null) {
      await prefs.setString(_keyUserEmail, email);
    }
    if (name != null) {
      await prefs.setString(_keyUserName, name);
    }
    if (token != null) {
      await prefs.setString(_keyAuthToken, token);
    }
    if (userId != null) {
      await prefs.setString(_keyUserId, userId);
    }
  }

  static Future<UserProfile?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyUserEmail);
    if (email == null) return null;
    return UserProfile(
      id: prefs.getString(_keyUserId) ?? 'user_1',
      name: prefs.getString(_keyUserName) ?? 'Crypto Researcher',
      email: email,
    );
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyAuthToken);
  }
}
