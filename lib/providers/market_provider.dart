import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/coin_model.dart';
import '../models/market_stats_model.dart';
import '../services/api_service.dart';

class MarketProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<CryptoCoin> _coins = [];
  MarketStats _marketStats = AppConstants.sampleMarketStats;
  final Set<String> _watchlistedIds = {};
  List<CryptoCoin> _searchResults = [];

  final Map<String, CryptoCoin> _coinDetailsCache = {};
  final Map<String, List<PricePoint>> _coinChartsCache = {};

  bool _isLoadingCoins = false;
  bool _isLoadingStats = false;
  bool _isLoadingSearch = false;
  bool _isOffline = false;
  String? _errorMessage;

  MarketProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    _coins = AppConstants.getInitialCoins();
    for (final c in _coins) {
      if (c.isWatchlisted) {
        _watchlistedIds.add(c.id);
      }
    }
  }

  List<CryptoCoin> get coins => _coins.map((c) {
        return c.copyWith(isWatchlisted: _watchlistedIds.contains(c.id));
      }).toList();

  List<CryptoCoin> get watchlistCoins => coins.where((c) => c.isWatchlisted).toList();

  MarketStats get marketStats => _marketStats;
  List<CryptoCoin> get searchResults => _searchResults.map((c) {
        return c.copyWith(isWatchlisted: _watchlistedIds.contains(c.id));
      }).toList();

  bool get isLoadingCoins => _isLoadingCoins;
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingSearch => _isLoadingSearch;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;

  // FETCH COINS (GET /api/coins)
  Future<void> fetchCoins({int page = 1, int perPage = 20, bool refresh = false}) async {
    if (_isLoadingCoins && !refresh) return;

    _isLoadingCoins = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _apiService.getCoins(page: page, perPage: perPage);
      if (fetched.isNotEmpty) {
        _coins = fetched;
        _isOffline = false;
        debugPrint('[MarketProvider] Successfully fetched ${fetched.length} coins from API (page: $page)');
      }
    } catch (e) {
      // Graceful fallback to initial mock coins so the app always functions smoothly
      _isOffline = true;
      _errorMessage = e.toString();
      debugPrint('[MarketProvider] Failed to fetch coins: $e. Falling back to cached data.');
      if (_coins.isEmpty) {
        _coins = AppConstants.getInitialCoins();
      }
    } finally {
      _isLoadingCoins = false;
      notifyListeners();
    }
  }

  // FETCH MARKET STATS (GET /api/market/stats)
  Future<void> fetchMarketStats() async {
    _isLoadingStats = true;
    notifyListeners();

    try {
      final stats = await _apiService.getMarketStats();
      _marketStats = stats;
      _isOffline = false;
      debugPrint('[MarketProvider] Market stats loaded: Total Cap = \$${stats.totalMarketCap}, 24h Vol = \$${stats.totalVolume24h}');
    } catch (e) {
      _isOffline = true;
      debugPrint('[MarketProvider] Could not load market stats: $e. Using fallback stats.');
      // Fallback to sampleMarketStats
      _marketStats = AppConstants.sampleMarketStats;
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // WATCHLIST API INTEGRATION
  // GET /api/watchlist, POST /api/watchlist, DELETE /api/watchlist/{id}
  Future<void> fetchWatchlist() async {
    try {
      final list = await _apiService.getWatchlist();
      _watchlistedIds.clear();
      for (final coin in list) {
        _watchlistedIds.add(coin.id);
      }
      debugPrint('[MarketProvider] Watchlist synced: ${_watchlistedIds.length} items loaded.');
      notifyListeners();
    } catch (e) {
      // Maintain local watchlist state if server is offline
      debugPrint('[MarketProvider] Watchlist fetch error: $e. Keeping local items.');
    }
  }

  Future<void> toggleWatchlist(String coinId) async {
    final isCurrentlySaved = _watchlistedIds.contains(coinId);

    // UI update
    if (isCurrentlySaved) {
      _watchlistedIds.remove(coinId);
    } else {
      _watchlistedIds.add(coinId);
    }
    notifyListeners();

    try {
      if (isCurrentlySaved) {
        await _apiService.removeFromWatchlist(coinId);
        debugPrint('[MarketProvider] Removed coin $coinId from server watchlist.');
      } else {
        await _apiService.addToWatchlist(coinId);
        debugPrint('[MarketProvider] Added coin $coinId to server watchlist.');
      }
    } catch (e) {
      // If server failed, keep local change for offline-first responsiveness
      debugPrint('[MarketProvider] Failed to sync watchlist change for $coinId: $e');
    }
  }

  // -------------------------------------------------------------
  // SEARCH COINS (GET /api/coins/search?query=...)
  // -------------------------------------------------------------
  Future<void> searchCoins(String query) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      _searchResults = [];
      _isLoadingSearch = false;
      notifyListeners();
      return;
    }

    _isLoadingSearch = true;
    notifyListeners();

    try {
      final results = await _apiService.searchCoins(trimmed);
      _searchResults = results;
      debugPrint('[MarketProvider] Search returned ${results.length} results for "$trimmed".');
    } catch (e) {
      // Offline fallback: filter current coin list
      _searchResults = _coins.where((c) {
        return c.name.toLowerCase().contains(trimmed) ||
            c.symbol.toLowerCase().contains(trimmed);
      }).toList();
      debugPrint('[MarketProvider] Search API error: $e. Using local search with ${_searchResults.length} results.');
    } finally {
      _isLoadingSearch = false;
      notifyListeners();
    }
  }

  // COIN DETAIL (GET /api/coins/{id})
  Future<CryptoCoin> fetchCoinDetails(String coinId) async {
    if (_coinDetailsCache.containsKey(coinId)) {
      return _coinDetailsCache[coinId]!.copyWith(
        isWatchlisted: _watchlistedIds.contains(coinId),
      );
    }

    try {
      final coin = await _apiService.getCoinDetail(coinId);
      _coinDetailsCache[coinId] = coin;
      debugPrint('[MarketProvider] Fetched coin details for $coinId (${coin.name}).');
      return coin.copyWith(isWatchlisted: _watchlistedIds.contains(coinId));
    } catch (e) {
      debugPrint('[MarketProvider] Failed to fetch details for $coinId: $e. Using local data.');
      // Find from loaded list
      final local = _coins.firstWhere(
        (c) => c.id == coinId,
        orElse: () => AppConstants.getInitialCoins().first,
      );
      return local.copyWith(isWatchlisted: _watchlistedIds.contains(coinId));
    }
  }

  // PRICE CHART (GET /api/coins/{id}/chart?days=7)
  Future<List<PricePoint>> fetchPriceChart(String coinId, {int days = 7}) async {
    final cacheKey = '${coinId}_$days';
    if (_coinChartsCache.containsKey(cacheKey)) {
      return _coinChartsCache[cacheKey]!;
    }

    try {
      final chart = await _apiService.getPriceChart(coinId, days: days);
      if (chart.isNotEmpty) {
        _coinChartsCache[cacheKey] = chart;
        debugPrint('[MarketProvider] Fetched ${chart.length} chart points for $coinId (${days}D).');
        return chart;
      }
    } catch (e) {
      debugPrint('[MarketProvider] Failed to fetch chart data for $coinId: $e. Falling back to local points.');
    }

    // Fallback to local historical chart data
    final localCoin = _coins.firstWhere(
      (c) => c.id == coinId,
      orElse: () => AppConstants.getInitialCoins().first,
    );
    final fallbackPoints = localCoin.historicalData['${days}D'] ??
        localCoin.historicalData['7D'] ??
        [];
    return fallbackPoints;
  }
}
