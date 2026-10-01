import 'package:flutter/material.dart';

class PricePoint {
  final DateTime timestamp;
  final double price;

  const PricePoint({
    required this.timestamp,
    required this.price,
  });

  factory PricePoint.fromJson(dynamic json) {
    if (json is List && json.length >= 2) {
      final ts = json[0] is int
          ? DateTime.fromMillisecondsSinceEpoch(json[0] as int)
          : DateTime.tryParse(json[0].toString()) ?? DateTime.now();
      final p = (json[1] is num) ? (json[1] as num).toDouble() : 0.0;
      return PricePoint(timestamp: ts, price: p);
    } else if (json is Map) {
      final rawTs = json['timestamp'] ?? json['time'] ?? json['date'];
      DateTime ts = DateTime.now();
      if (rawTs is int) {
        ts = DateTime.fromMillisecondsSinceEpoch(rawTs > 1000000000000 ? rawTs : rawTs * 1000);
      } else if (rawTs is String) {
        ts = DateTime.tryParse(rawTs) ?? DateTime.now();
      }
      final p = _parseDouble(json['price'] ?? json['value'] ?? json['close']);
      return PricePoint(timestamp: ts, price: p);
    }
    return PricePoint(timestamp: DateTime.now(), price: 0.0);
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }
}

class CryptoCoin {
  final String id;
  final String name;
  final String symbol;
  final double currentPrice;
  final double priceChangePercentage24h;
  final double marketCap;
  final double totalVolume24h;
  final int marketCapRank;
  final double circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;
  final double allTimeHigh;
  final String about;
  final Color brandColor;
  final List<double> sparkline;
  final Map<String, List<PricePoint>> historicalData;
  final bool isWatchlisted;

  const CryptoCoin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.marketCap,
    required this.totalVolume24h,
    required this.marketCapRank,
    required this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
    required this.allTimeHigh,
    required this.about,
    required this.brandColor,
    required this.sparkline,
    required this.historicalData,
    this.isWatchlisted = false,
  });

  bool get isBullish => priceChangePercentage24h >= 0;

  factory CryptoCoin.fromJson(Map<String, dynamic> json) {
    // Parse sparkline numbers
    List<double> sparklineList = [];
    final rawSparkline = json['sparkline'] ??
        json['sparkline_in_7d'] ??
        json['sparkline_price'] ??
        json['price_history'];
    if (rawSparkline is List) {
      sparklineList = rawSparkline
          .map((e) => _parseDouble(e))
          .where((e) => e > 0)
          .toList();
    } else if (rawSparkline is Map && rawSparkline['price'] is List) {
      sparklineList = (rawSparkline['price'] as List)
          .map((e) => _parseDouble(e))
          .where((e) => e > 0)
          .toList();
    }

    final coinId = json['id']?.toString() ?? 'coin';
    final coinSymbol = json['symbol']?.toString().toUpperCase() ?? 'COIN';

    return CryptoCoin(
      id: coinId,
      name: json['name']?.toString() ?? 'Cryptocurrency',
      symbol: coinSymbol,
      currentPrice: _parseDouble(json['current_price'] ?? json['price']),
      priceChangePercentage24h: _parseDouble(
        json['price_change_percentage_24h'] ??
            json['change_24h'] ??
            json['price_change_24h'],
      ),
      marketCap: _parseDouble(json['market_cap'] ?? json['marketCap']),
      totalVolume24h: _parseDouble(
        json['total_volume_24h'] ?? json['total_volume'] ?? json['volume_24h'],
      ),
      marketCapRank: _parseInt(
        json['market_cap_rank'] ?? json['rank'] ?? json['marketCapRank'],
      ),
      circulatingSupply: _parseDouble(
        json['circulating_supply'] ?? json['circulatingSupply'],
      ),
      totalSupply: json['total_supply'] != null
          ? _parseDouble(json['total_supply'])
          : null,
      maxSupply: json['max_supply'] != null
          ? _parseDouble(json['max_supply'])
          : null,
      allTimeHigh: _parseDouble(
        json['all_time_high'] ?? json['ath'] ?? json['high_24h'],
      ),
      about: json['about']?.toString() ??
          json['description']?.toString() ??
          'A leading decentralized blockchain protocol providing global cryptographic market liquidity.',
      brandColor: _getColorForSymbol(coinSymbol),
      sparkline: sparklineList.isNotEmpty
          ? sparklineList
          : _generateFallbackSparkline(_parseDouble(json['current_price'] ?? json['price']), _parseDouble(json['price_change_percentage_24h'] ?? json['change_24h'])),
      historicalData: _buildInitialHistorical(sparklineList, _parseDouble(json['current_price'] ?? json['price'])),
      isWatchlisted: json['is_watchlisted'] == true || json['isWatchlisted'] == true,
    );
  }

  static List<double> _generateFallbackSparkline(double price, double change24h) {
    if (price <= 0) return [100.0, 101.0, 100.5, 102.0, 101.5, 103.0, 102.5];
    final base = price / (1 + (change24h / 100));
    final diff = price - base;
    return [
      base,
      base + diff * 0.2,
      base + diff * 0.15,
      base + diff * 0.45,
      base + diff * 0.6,
      base + diff * 0.85,
      price,
    ];
  }

  static Map<String, List<PricePoint>> _buildInitialHistorical(List<double> sparkline, double currentPrice) {
    final Map<String, List<PricePoint>> map = {};
    final list = sparkline.isNotEmpty ? sparkline : (currentPrice > 0 ? _generateFallbackSparkline(currentPrice, 0.0) : <double>[]);
    if (list.isNotEmpty) {
      final now = DateTime.now();
      final total = list.length;
      final stepMinutes = (7 * 24 * 60 / total).round();
      map['7D'] = List.generate(total, (i) {
        final pointTime = now.subtract(Duration(minutes: stepMinutes * (total - 1 - i)));
        return PricePoint(timestamp: pointTime, price: list[i]);
      });
    }
    return map;
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

  static Color _getColorForSymbol(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return const Color(0xFFF7931A);
      case 'ETH':
        return const Color(0xFF627EEA);
      case 'SOL':
        return const Color(0xFF14F195);
      case 'BNB':
        return const Color(0xFFF3BA2F);
      case 'ADA':
        return const Color(0xFF0033AD);
      case 'AVAX':
        return const Color(0xFFE84142);
      case 'DOGE':
        return const Color(0xFFC2A633);
      case 'XRP':
        return const Color(0xFF23292F);
      case 'DOT':
        return const Color(0xFFE6007A);
      case 'MATIC':
      case 'POL':
        return const Color(0xFF8247E5);
      default:
        return const Color(0xFFB4DE01);
    }
  }

  CryptoCoin copyWith({
    String? id,
    String? name,
    String? symbol,
    double? currentPrice,
    double? priceChangePercentage24h,
    double? marketCap,
    double? totalVolume24h,
    int? marketCapRank,
    double? circulatingSupply,
    double? totalSupply,
    double? maxSupply,
    double? allTimeHigh,
    String? about,
    Color? brandColor,
    List<double>? sparkline,
    Map<String, List<PricePoint>>? historicalData,
    bool? isWatchlisted,
  }) {
    return CryptoCoin(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChangePercentage24h:
          priceChangePercentage24h ?? this.priceChangePercentage24h,
      marketCap: marketCap ?? this.marketCap,
      totalVolume24h: totalVolume24h ?? this.totalVolume24h,
      marketCapRank: marketCapRank ?? this.marketCapRank,
      circulatingSupply: circulatingSupply ?? this.circulatingSupply,
      totalSupply: totalSupply ?? this.totalSupply,
      maxSupply: maxSupply ?? this.maxSupply,
      allTimeHigh: allTimeHigh ?? this.allTimeHigh,
      about: about ?? this.about,
      brandColor: brandColor ?? this.brandColor,
      sparkline: sparkline ?? this.sparkline,
      historicalData: historicalData ?? this.historicalData,
      isWatchlisted: isWatchlisted ?? this.isWatchlisted,
    );
  }
}
