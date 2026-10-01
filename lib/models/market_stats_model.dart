class MarketStats {
  final double totalMarketCap;
  final double marketCapChange24h;
  final double totalVolume24h;
  final double btcDominance;
  final double ethDominance;
  final int activeCryptocurrencies;
  final int activeMarkets;
  final List<double> marketCapHistory;

  const MarketStats({
    required this.totalMarketCap,
    required this.marketCapChange24h,
    required this.totalVolume24h,
    required this.btcDominance,
    required this.ethDominance,
    required this.activeCryptocurrencies,
    required this.activeMarkets,
    required this.marketCapHistory,
  });

  bool get isBullish => marketCapChange24h >= 0;

  factory MarketStats.fromJson(Map<String, dynamic> json) {
    List<double> history = [];
    final rawHistory = json['market_cap_history'] ?? json['marketCapHistory'] ?? json['history'];
    if (rawHistory is List) {
      history = rawHistory.map((e) => _parseDouble(e)).where((e) => e > 0).toList();
    }

    return MarketStats(
      totalMarketCap: _parseDouble(
        json['total_market_cap'] ?? json['totalMarketCap'] ?? json['market_cap'],
      ),
      marketCapChange24h: _parseDouble(
        json['market_cap_change_percentage_24h_usd'] ??
            json['market_cap_change_24h'] ??
            json['market_cap_change_percentage_24h'] ??
            json['change_24h'],
      ),
      totalVolume24h: _parseDouble(
        json['total_volume_24h'] ?? json['total_volume'] ?? json['totalVolume24h'],
      ),
      btcDominance: _parseDouble(
        json['btc_dominance'] ?? json['market_cap_percentage_btc'] ?? json['btcDominance'] ?? 54.2,
      ),
      ethDominance: _parseDouble(
        json['eth_dominance'] ?? json['market_cap_percentage_eth'] ?? json['ethDominance'] ?? 16.8,
      ),
      activeCryptocurrencies: _parseInt(
        json['active_cryptocurrencies'] ?? json['activeCryptocurrencies'] ?? 14280,
      ),
      activeMarkets: _parseInt(
        json['active_markets'] ?? json['activeMarkets'] ?? 980,
      ),
      marketCapHistory: history.isNotEmpty
          ? history
          : [2.35, 2.38, 2.36, 2.41, 2.44, 2.48, 2.51],
    );
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }
}
