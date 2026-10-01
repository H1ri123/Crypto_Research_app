import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;

  UserProfile? _currentUser;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  UserProfile? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loggedIn = await AuthService.isLoggedIn();
      _token = await AuthService.getToken();
      _isAuthenticated = loggedIn;

      if (loggedIn) {
        _currentUser = await AuthService.getSavedUser();
        debugPrint('[AuthProvider] User session restored for: ${_currentUser?.email ?? "Unknown"}');
        // Attempt to fetch fresh profile from API
        if (_token != null && _token!.isNotEmpty) {
          try {
            final freshProfile = await _apiService.getProfile();
            _currentUser = freshProfile;
            await AuthService.saveAuthData(
              token: _token!,
              email: freshProfile.email,
              name: freshProfile.name,
              userId: freshProfile.id,
            );
            debugPrint('[AuthProvider] Fresh profile synced from server: ${freshProfile.email}');
          } catch (e) {
            debugPrint('[AuthProvider] Could not refresh profile from server: $e. Using cached profile.');
          }
        }
      } else {
        debugPrint('[AuthProvider] No active user session found.');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    debugPrint('[AuthProvider] Attempting login for: $email');

    try {
      final res = await _apiService.login(email: email, password: password);
      // Extract token
      final token = res['access_token']?.toString() ??
          res['token']?.toString() ??
          res['jwt']?.toString() ??
          'token_${DateTime.now().millisecondsSinceEpoch}';

      final userData = res['user'] is Map<String, dynamic>
          ? res['user'] as Map<String, dynamic>
          : res;

      final user = UserProfile.fromJson(userData).copyWith(
        email: email,
        name: userData['name']?.toString() ?? (await AuthService.getUserName()) ?? 'Crypto Researcher',
      );

      _token = token;
      _currentUser = user;
      _isAuthenticated = true;

      await AuthService.saveAuthData(
        token: token,
        email: email,
        name: user.name,
        userId: user.id,
      );

      _isLoading = false;
      notifyListeners();
      debugPrint('[AuthProvider] Login successful for: ${user.email} (ID: ${user.id})');
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      debugPrint('[AuthProvider] Login failed: ${e.message} (Status: ${e.statusCode})');
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('[AuthProvider] Unexpected login error: $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    debugPrint('[AuthProvider] Attempting registration for: $email ($name)');

    try {
      final res = await _apiService.register(
        name: name,
        email: email,
        password: password,
      );

      final token = res['access_token']?.toString() ??
          res['token']?.toString() ??
          'token_${DateTime.now().millisecondsSinceEpoch}';

      final user = UserProfile(
        id: res['id']?.toString() ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
      );

      _token = token;
      _currentUser = user;
      _isAuthenticated = true;

      await AuthService.saveAuthData(
        token: token,
        email: email,
        name: name,
        userId: user.id,
      );

      _isLoading = false;
      notifyListeners();
      debugPrint('[AuthProvider] Registration successful for: ${user.email}');
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      debugPrint('[AuthProvider] Registration failed: ${e.message} (Status: ${e.statusCode})');
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('[AuthProvider] Unexpected registration error: $e');
      return false;
    }
  }

  Future<bool> updateProfile({String? name, String? password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    debugPrint('[AuthProvider] Updating profile for: ${_currentUser?.email}');

    try {
      final updated = await _apiService.updateProfile(
        name: name,
        password: password,
      );
      _currentUser = updated;
      if (name != null) {
        await AuthService.setLoggedIn(isLoggedIn: true, name: name);
      }
      _isLoading = false;
      notifyListeners();
      debugPrint('[AuthProvider] Profile updated successfully for: ${updated.email}');
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      debugPrint('[AuthProvider] Profile update failed: ${e.message}');
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('[AuthProvider] Unexpected profile update error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final userEmail = _currentUser?.email;
    await AuthService.logout();
    _currentUser = null;
    _token = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
    debugPrint('[AuthProvider] User logged out successfully: $userEmail');
  }
}
