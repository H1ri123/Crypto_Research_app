import 'package:flutter/material.dart';
import '../../models/coin_model.dart';
import '../../models/market_stats_model.dart';
// mock data
class AppConstants {
  static const String appName = 'Crypto Research';
  static const String appTagline = 'Track the crypto market';

  static const MarketStats sampleMarketStats = MarketStats(
    totalMarketCap: 2642890120000, // $2.64T
    marketCapChange24h: 2.84,
    totalVolume24h: 94820450000, // $94.8B
    btcDominance: 54.3,
    ethDominance: 16.7,
    activeCryptocurrencies: 14285,
    activeMarkets: 1142,
    marketCapHistory: [
      2.48, 2.50, 2.49, 2.53, 2.52, 2.55, 2.58, 2.57, 2.61, 2.60, 2.63, 2.64
    ],
  );

  static List<PricePoint> _generatePoints(double basePrice, List<double> multipliers, int daysInterval) {
    final now = DateTime.now();
    return List.generate(multipliers.length, (index) {
      final time = now.subtract(Duration(days: (multipliers.length - 1 - index) * daysInterval));
      return PricePoint(
        timestamp: time,
        price: basePrice * multipliers[index],
      );
    });
  }

  static List<CryptoCoin> getInitialCoins() {
    return [
      CryptoCoin(
        id: 'bitcoin',
        name: 'Bitcoin',
        symbol: 'BTC',
        currentPrice: 64825.40,
        priceChangePercentage24h: 3.42,
        marketCap: 1278540000000,
        totalVolume24h: 38240500000,
        marketCapRank: 1,
        circulatingSupply: 19782400,
        totalSupply: 19782400,
        maxSupply: 21000000,
        allTimeHigh: 73750.07,
        brandColor: const Color(0xFFF7931A),
        about:
            'Bitcoin is the world\'s first decentralized cryptocurrency, introduced in 2008 by an anonymous programmer or group under the pseudonym Satoshi Nakamoto. It operates on a peer-to-peer network secured through proof-of-work consensus.',
        sparkline: [62400, 62900, 62750, 63400, 63100, 63900, 64200, 63800, 64500, 64825],
        historicalData: {
          '1D': _generatePoints(64825, [0.97, 0.975, 0.98, 0.978, 0.985, 0.99, 0.995, 1.0], 0),
          '7D': _generatePoints(64825, [0.93, 0.94, 0.925, 0.95, 0.965, 0.98, 1.0], 1),
          '30D': _generatePoints(64825, [0.88, 0.90, 0.89, 0.92, 0.94, 0.96, 0.95, 0.98, 1.0], 3),
          '1Y': _generatePoints(64825, [0.42, 0.50, 0.58, 0.65, 0.72, 0.85, 0.92, 1.0], 45),
        },
        isWatchlisted: true,
      ),
      CryptoCoin(
        id: 'ethereum',
        name: 'Ethereum',
        symbol: 'ETH',
        currentPrice: 3482.15,
        priceChangePercentage24h: 2.18,
        marketCap: 418900000000,
        totalVolume24h: 18450200000,
        marketCapRank: 2,
        circulatingSupply: 120400000,
        totalSupply: 120400000,
        maxSupply: null,
        allTimeHigh: 4891.70,
        brandColor: const Color(0xFF627EEA),
        about:
            'Ethereum is a decentralized open-source blockchain with smart contract functionality. Ether is the native cryptocurrency of the platform, powering decentralized applications and DeFi ecosystems worldwide.',
        sparkline: [3380, 3410, 3395, 3420, 3410, 3450, 3440, 3465, 3470, 3482],
        historicalData: {
          '1D': _generatePoints(3482, [0.98, 0.982, 0.985, 0.989, 0.992, 0.995, 1.0], 0),
          '7D': _generatePoints(3482, [0.94, 0.95, 0.945, 0.97, 0.98, 0.99, 1.0], 1),
          '30D': _generatePoints(3482, [0.89, 0.91, 0.93, 0.92, 0.96, 0.98, 1.0], 3),
          '1Y': _generatePoints(3482, [0.55, 0.62, 0.70, 0.80, 0.88, 0.95, 1.0], 45),
        },
        isWatchlisted: true,
      ),
      CryptoCoin(
        id: 'solana',
        name: 'Solana',
        symbol: 'SOL',
        currentPrice: 154.60,
        priceChangePercentage24h: 7.84,
        marketCap: 72150000000,
        totalVolume24h: 6840000000,
        marketCapRank: 3,
        circulatingSupply: 466800000,
        totalSupply: 580000000,
        maxSupply: null,
        allTimeHigh: 260.06,
        brandColor: const Color(0xFF14F195),
        about:
            'Solana is a high-performance blockchain supporting builders around the world creating crypto apps that scale today. Utilizing Proof of History, it delivers sub-second finality and ultralow transaction fees.',
        sparkline: [142, 144, 143, 147, 146, 149, 151, 150, 153, 154.6],
        historicalData: {
          '1D': _generatePoints(154.6, [0.92, 0.93, 0.95, 0.96, 0.98, 0.99, 1.0], 0),
          '7D': _generatePoints(154.6, [0.84, 0.86, 0.89, 0.92, 0.95, 0.98, 1.0], 1),
          '30D': _generatePoints(154.6, [0.75, 0.78, 0.82, 0.88, 0.92, 0.96, 1.0], 3),
          '1Y': _generatePoints(154.6, [0.18, 0.25, 0.40, 0.65, 0.85, 0.92, 1.0], 45),
        },
        isWatchlisted: false,
      ),
      CryptoCoin(
        id: 'binancecoin',
        name: 'BNB',
        symbol: 'BNB',
        currentPrice: 582.40,
        priceChangePercentage24h: -1.15,
        marketCap: 89400000000,
        totalVolume24h: 1250000000,
        marketCapRank: 4,
        circulatingSupply: 153850000,
        totalSupply: 153850000,
        maxSupply: 200000000,
        allTimeHigh: 720.67,
        brandColor: const Color(0xFFF3BA2F),
        about:
            'BNB powers the BNB Chain ecosystem. As one of the world\'s most popular utility tokens, you can use BNB to pay fees on the Binance exchange and participate in token sales.',
        sparkline: [592, 590, 588, 591, 587, 585, 586, 583, 584, 582.4],
        historicalData: {
          '1D': _generatePoints(582.4, [1.02, 1.015, 1.01, 1.005, 1.002, 1.0], 0),
          '7D': _generatePoints(582.4, [1.05, 1.04, 1.03, 1.01, 1.02, 1.0], 1),
          '30D': _generatePoints(582.4, [0.92, 0.95, 0.98, 1.02, 1.01, 1.0], 3),
          '1Y': _generatePoints(582.4, [0.45, 0.55, 0.70, 0.85, 0.95, 1.0], 45),
        },
        isWatchlisted: false,
      ),
      CryptoCoin(
        id: 'ripple',
        name: 'XRP',
        symbol: 'XRP',
        currentPrice: 0.584,
        priceChangePercentage24h: 4.65,
        marketCap: 32800000000,
        totalVolume24h: 2100000000,
        marketCapRank: 5,
        circulatingSupply: 56120000000,
        totalSupply: 99980000000,
        maxSupply: 100000000000,
        allTimeHigh: 3.84,
        brandColor: const Color(0xFF23292F),
        about:
            'XRP is a digital asset built for payments. It is the native token of the XRP Ledger—an open-source, permissionless and decentralized blockchain technology that can settle transactions in 3-5 seconds.',
        sparkline: [0.552, 0.558, 0.561, 0.569, 0.565, 0.574, 0.578, 0.581, 0.584],
        historicalData: {
          '1D': _generatePoints(0.584, [0.95, 0.96, 0.97, 0.98, 0.99, 1.0], 0),
          '7D': _generatePoints(0.584, [0.91, 0.93, 0.94, 0.96, 0.98, 1.0], 1),
          '30D': _generatePoints(0.584, [0.85, 0.88, 0.92, 0.95, 1.0], 3),
          '1Y': _generatePoints(0.584, [0.72, 0.80, 0.85, 0.92, 1.0], 45),
        },
        isWatchlisted: true,
      ),
      CryptoCoin(
        id: 'cardano',
        name: 'Cardano',
        symbol: 'ADA',
        currentPrice: 0.385,
        priceChangePercentage24h: -2.40,
        marketCap: 13850000000,
        totalVolume24h: 420000000,
        marketCapRank: 6,
        circulatingSupply: 35680000000,
        totalSupply: 45000000000,
        maxSupply: 45000000000,
        allTimeHigh: 3.10,
        brandColor: const Color(0xFF0033AD),
        about:
            'Cardano is a proof-of-stake blockchain network founded on peer-reviewed research and evidence-based development methods. It combines pioneering technologies to provide unprecedented security and sustainability.',
        sparkline: [0.395, 0.394, 0.391, 0.389, 0.390, 0.387, 0.386, 0.385],
        historicalData: {
          '1D': _generatePoints(0.385, [1.03, 1.025, 1.02, 1.01, 1.0], 0),
          '7D': _generatePoints(0.385, [1.06, 1.04, 1.03, 1.02, 1.0], 1),
          '30D': _generatePoints(0.385, [0.94, 0.96, 0.98, 1.02, 1.0], 3),
          '1Y': _generatePoints(0.385, [0.65, 0.75, 0.85, 0.95, 1.0], 45),
        },
        isWatchlisted: false,
      ),
      CryptoCoin(
        id: 'dogecoin',
        name: 'Dogecoin',
        symbol: 'DOGE',
        currentPrice: 0.118,
        priceChangePercentage24h: 5.12,
        marketCap: 17200000000,
        totalVolume24h: 1150000000,
        marketCapRank: 7,
        circulatingSupply: 145900000000,
        totalSupply: 145900000000,
        maxSupply: null,
        allTimeHigh: 0.737,
        brandColor: const Color(0xFFC2A633),
        about:
            'Dogecoin is an open-source peer-to-peer cryptocurrency created as a lighthearted alternative to traditional cryptocurrencies. It features the likeness of the Shiba Inu dog from the popular "Doge" internet meme.',
        sparkline: [0.110, 0.112, 0.111, 0.114, 0.115, 0.116, 0.117, 0.118],
        historicalData: {
          '1D': _generatePoints(0.118, [0.94, 0.95, 0.97, 0.98, 1.0], 0),
          '7D': _generatePoints(0.118, [0.90, 0.92, 0.94, 0.97, 1.0], 1),
          '30D': _generatePoints(0.118, [0.82, 0.88, 0.92, 0.96, 1.0], 3),
          '1Y': _generatePoints(0.118, [0.55, 0.65, 0.80, 0.95, 1.0], 45),
        },
        isWatchlisted: false,
      ),
      CryptoCoin(
        id: 'avalanche',
        name: 'Avalanche',
        symbol: 'AVAX',
        currentPrice: 28.75,
        priceChangePercentage24h: 6.25,
        marketCap: 11450000000,
        totalVolume24h: 490000000,
        marketCapRank: 8,
        circulatingSupply: 395000000,
        totalSupply: 443000000,
        maxSupply: 720000000,
        allTimeHigh: 146.22,
        brandColor: const Color(0xFFE84142),
        about:
            'Avalanche is an umbrella platform for launching decentralized finance (DeFi) applications, financial assets, trading and other services. It aims to be a global assets exchange.',
        sparkline: [26.8, 27.1, 27.0, 27.5, 27.8, 28.1, 28.4, 28.75],
        historicalData: {
          '1D': _generatePoints(28.75, [0.93, 0.95, 0.96, 0.98, 1.0], 0),
          '7D': _generatePoints(28.75, [0.88, 0.91, 0.94, 0.97, 1.0], 1),
          '30D': _generatePoints(28.75, [0.80, 0.85, 0.90, 0.96, 1.0], 3),
          '1Y': _generatePoints(28.75, [0.35, 0.50, 0.70, 0.90, 1.0], 45),
        },
        isWatchlisted: false,
      ),
      CryptoCoin(
        id: 'chainlink',
        name: 'Chainlink',
        symbol: 'LINK',
        currentPrice: 12.35,
        priceChangePercentage24h: -0.85,
        marketCap: 7520000000,
        totalVolume24h: 280000000,
        marketCapRank: 9,
        circulatingSupply: 608000000,
        totalSupply: 1000000000,
        maxSupply: 1000000000,
        allTimeHigh: 52.88,
        brandColor: const Color(0xFF375BD2),
        about:
            'Chainlink is a blockchain abstraction layer that enables universally connected smart contracts through a decentralized oracle network, feeding real-world data to smart contracts.',
        sparkline: [12.6, 12.5, 12.45, 12.55, 12.48, 12.40, 12.38, 12.35],
        historicalData: {
          '1D': _generatePoints(12.35, [1.02, 1.015, 1.01, 1.005, 1.0], 0),
          '7D': _generatePoints(12.35, [1.04, 1.03, 1.02, 1.01, 1.0], 1),
          '30D': _generatePoints(12.35, [0.92, 0.95, 0.98, 1.0], 3),
          '1Y': _generatePoints(12.35, [0.55, 0.70, 0.85, 1.0], 45),
        },
        isWatchlisted: false,
      ),
      CryptoCoin(
        id: 'polkadot',
        name: 'Polkadot',
        symbol: 'DOT',
        currentPrice: 4.92,
        priceChangePercentage24h: 1.85,
        marketCap: 6980000000,
        totalVolume24h: 195000000,
        marketCapRank: 10,
        circulatingSupply: 1420000000,
        totalSupply: 1470000000,
        maxSupply: null,
        allTimeHigh: 55.00,
        brandColor: const Color(0xFFE6007A),
        about:
            'Polkadot is an open source sharded multichain protocol that connects and secures a network of specialized blockchains, facilitating cross-chain transfer of any data or asset types.',
        sparkline: [4.75, 4.80, 4.78, 4.84, 4.86, 4.88, 4.90, 4.92],
        historicalData: {
          '1D': _generatePoints(4.92, [0.98, 0.985, 0.99, 0.995, 1.0], 0),
          '7D': _generatePoints(4.92, [0.95, 0.96, 0.97, 0.99, 1.0], 1),
          '30D': _generatePoints(4.92, [0.90, 0.93, 0.96, 1.0], 3),
          '1Y': _generatePoints(4.92, [0.60, 0.72, 0.85, 1.0], 45),
        },
        isWatchlisted: false,
      ),
    ];
  }
}
