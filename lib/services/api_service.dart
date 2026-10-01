import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/coin_model.dart';
import '../models/market_stats_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _headers({bool needsAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (needsAuth) {
      final token = await AuthService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }


  void _logRequest(String method, Uri url, Map<String, String> headers, dynamic body) {
    debugPrint('[API REQUEST] $method $url');
    if (body != null) {
      final bodyStr = body.toString();
      final preview = bodyStr.length > 250 ? '${bodyStr.substring(0, 250)}...' : bodyStr;
      debugPrint('[API REQUEST BODY] $preview');
    }
  }

  void _logResponse(String method, Uri url, int statusCode, int durationMs, String responseBody) {
    debugPrint('[API RESPONSE] $statusCode (${durationMs}ms) $url');
    final cleanBody = responseBody.trim();
    if (cleanBody.length > 300) {
      debugPrint('[API RESPONSE BODY] ${cleanBody.substring(0, 300)}... (truncated ${cleanBody.length} chars)');
    } else if (cleanBody.isNotEmpty) {
      debugPrint('[API RESPONSE BODY] $cleanBody');
    }
  }

  void _logError(String method, Uri url, dynamic error) {
    debugPrint('[API ERROR] $method $url -> $error');
  }

  Future<http.Response> _sendRequest({
    required String method,
    required Uri url,
    bool needsAuth = false,
    dynamic body,
  }) async {
    final headers = await _headers(needsAuth: needsAuth);
    _logRequest(method, url, headers, body);
    final stopwatch = Stopwatch()..start();

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(url, headers: headers).timeout(ApiConstants.timeout);
          break;
        case 'POST':
          response = await _client.post(url, headers: headers, body: body).timeout(ApiConstants.timeout);
          break;
        case 'PUT':
          response = await _client.put(url, headers: headers, body: body).timeout(ApiConstants.timeout);
          break;
        case 'DELETE':
          response = await _client.delete(url, headers: headers).timeout(ApiConstants.timeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      stopwatch.stop();
      _logResponse(method, url, response.statusCode, stopwatch.elapsedMilliseconds, response.body);
      return response;
    } on SocketException catch (e) {
      stopwatch.stop();
      _logError(method, url, 'SocketException: $e');
      throw ApiException('Unable to connect to backend server at ${ApiConstants.baseUrl}.');
    } on TimeoutException {
      stopwatch.stop();
      _logError(method, url, 'TimeoutException: Request exceeded ${ApiConstants.timeout.inSeconds} seconds');
      throw ApiException('Request to $url timed out.');
    } catch (e) {
      stopwatch.stop();
      _logError(method, url, e);
      if (e is ApiException) rethrow;
      throw ApiException('Network request failed: ${e.toString()}');
    }
  }

  // AUTH ENDPOINTS

  /// POST /api/auth/register
  /// Body: {"name": "...", "email": "...", "password": "..."}
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');
    final body = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
    });

    final response = await _sendRequest(method: 'POST', url: url, body: body);
    return _handleResponse(response);
  }

  /// POST /api/auth/login
  /// Body: {"email": "...", "password": "..."}
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    final response = await _sendRequest(method: 'POST', url: url, body: body);
    return _handleResponse(response);
  }

  // profile

  Future<UserProfile> getProfile() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}');
    final response = await _sendRequest(method: 'GET', url: url, needsAuth: true);
    final data = _handleResponse(response);
    final userMap = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;
    return UserProfile.fromJson(userMap);
  }

  // Update profile
  Future<UserProfile> updateProfile({
    String? name,
    String? password,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}');
    final bodyMap = <String, dynamic>{};
    if (name != null) bodyMap['name'] = name;
    if (password != null && password.isNotEmpty) bodyMap['password'] = password;

    final response = await _sendRequest(
      method: 'PUT',
      url: url,
      needsAuth: true,
      body: jsonEncode(bodyMap),
    );
    final data = _handleResponse(response);
    final userMap = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;
    return UserProfile.fromJson(userMap);
  }

  // user by id
  Future<UserProfile> getUserById(String userId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userProfile(userId)}');
    final response = await _sendRequest(method: 'GET', url: url, needsAuth: true);
    final data = _handleResponse(response);
    final userMap = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;
    return UserProfile.fromJson(userMap);
  }

  // COINS ENDPOINTS

  /// GET /api/coins?page=1&per_page=20
  Future<List<CryptoCoin>> getCoins({int page = 1, int perPage = 20}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.coins}?page=$page&per_page=$perPage');
    final response = await _sendRequest(method: 'GET', url: url, needsAuth: true);
    final dynamic data = _handleRawResponse(response);

    List<dynamic> list = [];
    if (data is List) {
      list = data;
    } else if (data is Map && data['data'] is List) {
      list = data['data'];
    } else if (data is Map && data['coins'] is List) {
      list = data['coins'];
    }

    return list
        .map((item) => CryptoCoin.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // search coins
  Future<List<CryptoCoin>> searchCoins(String query) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.search}?query=${Uri.encodeComponent(query)}');
    final response = await _sendRequest(method: 'GET', url: url);
    final dynamic data = _handleRawResponse(response);

    List<dynamic> list = [];
    if (data is List) {
      list = data;
    } else if (data is Map && data['coins'] is List) {
      list = data['coins'];
    } else if (data is Map && data['data'] is List) {
      list = data['data'];
    }

    return list
        .map((item) => CryptoCoin.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// GetCoins Details
  Future<CryptoCoin> getCoinDetail(String coinId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.coinDetail(coinId)}');
    final response = await _sendRequest(method: 'GET', url: url, needsAuth: true);
    final data = _handleResponse(response);

    final coinMap = data['coin'] is Map<String, dynamic>
        ? data['coin'] as Map<String, dynamic>
        : (data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data);

    return CryptoCoin.fromJson(coinMap);
  }

  ///  get priceechart
  Future<List<PricePoint>> getPriceChart(String coinId, {int days = 7}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.priceChart(coinId)}?days=$days');
    final response = await _sendRequest(method: 'GET', url: url);
    final dynamic data = _handleRawResponse(response);

    List<dynamic> rawPoints = [];
    if (data is List) {
      rawPoints = data;
    } else if (data is Map) {
      if (data['prices'] is List) {
        rawPoints = data['prices'];
      } else if (data['chart'] is List) {
        rawPoints = data['chart'];
      } else if (data['data'] is List) {
        rawPoints = data['data'];
      }
    }

    return rawPoints.map((p) => PricePoint.fromJson(p)).toList();
  }

  // MARKET STATS ENDPOINT

  // Market stats
  Future<MarketStats> getMarketStats() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.marketStats}');
    final response = await _sendRequest(method: 'GET', url: url);
    final data = _handleResponse(response);

    final statsMap = data['stats'] is Map<String, dynamic>
        ? data['stats'] as Map<String, dynamic>
        : (data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data);

    return MarketStats.fromJson(statsMap);
  }

  // WATCHLIST ENDPOINTS

  // list of watchlist
  Future<List<CryptoCoin>> getWatchlist() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.watchlist}');
    final response = await _sendRequest(method: 'GET', url: url, needsAuth: true);
    final dynamic data = _handleRawResponse(response);

    List<dynamic> list = [];
    if (data is List) {
      list = data;
    } else if (data is Map && data['watchlist'] is List) {
      list = data['watchlist'];
    } else if (data is Map && data['data'] is List) {
      list = data['data'];
    }

    return list
        .map((item) => CryptoCoin.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // create watchlist
  Future<bool> addToWatchlist(String coinId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.watchlist}');
    final body = jsonEncode({'coin_id': coinId});

    final response = await _sendRequest(method: 'POST', url: url, needsAuth: true, body: body);
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// DELETE /api/watchlist/{coin_id}
  /// Header: Bearer [token]
  Future<bool> removeFromWatchlist(String coinId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.watchlistDelete(coinId)}');
    final response = await _sendRequest(method: 'DELETE', url: url, needsAuth: true);
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  // RESPONSE PARSING HELPERS
  Map<String, dynamic> _handleResponse(http.Response response) {
    final dynamic decoded = _handleRawResponse(response);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {'data': decoded};
  }

  dynamic _handleRawResponse(http.Response response) {
    final code = response.statusCode;
    if (code >= 200 && code < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    }

    String message = 'API request failed with status code $code.';
    try {
      final err = jsonDecode(response.body);
      if (err is Map) {
        message = err['message'] ?? err['error'] ?? err['detail'] ?? message;
      }
    } catch (_) {}

    throw ApiException(message, code);
  }
}
