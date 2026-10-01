import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const String _keyBaseUrl = 'custom_base_url';

  // Base backend server URL on your current Mobile Hotspot Wi-Fi
  static String baseUrl = 'http://10.243.159.82:8000';

  // Request timeout duration
  static const Duration timeout = Duration(seconds: 6);

  // Load any saved custom base URL from preferences
  static Future<void> loadSavedBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyBaseUrl);
    if (saved != null && saved.isNotEmpty) {
      baseUrl = saved;
    }
  }

  // Update base URL
  static Future<void> setBaseUrl(String newUrl) async {
    baseUrl = newUrl.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseUrl, baseUrl);
  }

  // Auth endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String profile = '/api/auth/profile';
  static String userProfile(String userId) => '/api/auth/user/$userId';

  // Coins endpoints
  static const String coins = '/api/coins';
  static const String search = '/api/coins/search';
  static String coinDetail(String coinId) => '/api/coins/$coinId';
  static String priceChart(String coinId) => '/api/coins/$coinId/chart';

  // Market stats endpoint
  static const String marketStats = '/api/market/stats';

  // Watchlist endpoints
  static const String watchlist = '/api/watchlist';
  static String watchlistDelete(String coinId) => '/api/watchlist/$coinId';
}
