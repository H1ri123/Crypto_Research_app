import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../models/coin_model.dart';
import '../models/market_stats_model.dart';
import '../widgets/sparkline_chart.dart';
import 'coin_details_screen.dart';

class MarketStatisticsScreen extends StatelessWidget {
  final MarketStats stats;
  final List<CryptoCoin> coins;
  final Function(String coinId) onToggleWatchlist;

  const MarketStatisticsScreen({
    super.key,
    required this.stats,
    required this.coins,
    required this.onToggleWatchlist,
  });

  @override
  Widget build(BuildContext context) {
    // Sort coins for top gainers & top losers
    final sortedByGain = List<CryptoCoin>.from(coins)
      ..sort((a, b) => b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));

    final topGainers = sortedByGain.take(3).toList();
    final topLosers = sortedByGain.reversed.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Market Statistics',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOTAL MARKET CAP HERO CARD WITH SPARKLINE
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 1),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF282828),
                    Color(0xFF1A1A1A),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Market Capitalization',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: stats.isBullish
                              ? AppColors.bullishSurface
                              : AppColors.bearishSurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          Formatters.formatPercentage(stats.marketCapChange24h),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: stats.isBullish ? AppColors.bullish : AppColors.bearish,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.formatCompact(stats.totalMarketCap),
                    style: AppTypography.numberLarge.copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: 16),

                  // Mini Market Trend sparkline
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: SparklineChart(
                      data: stats.marketCapHistory,
                      isBullish: stats.isBullish,
                      width: double.infinity,
                      height: 56,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2X2 METRIC CARDS
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: '24h Trading Vol',
                    value: Formatters.formatCompact(stats.totalVolume24h),
                    subtitle: 'Across all exchanges',
                    icon: HugeIcons.strokeRoundedChartHistogram,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Active Cryptos',
                    value: Formatters.formatNumber(stats.activeCryptocurrencies.toDouble()),
                    subtitle: '${stats.activeMarkets} markets',
                    icon: HugeIcons.strokeRoundedBitcoin,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // DOMINANCE RATIO CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Market Dominance',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'BTC ${stats.btcDominance}%  |  ETH ${stats.ethDominance}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Visual bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 10,
                      child: Row(
                        children: [
                          Expanded(
                            flex: (stats.btcDominance * 10).round(),
                            child: Container(color: const Color(0xFFF7931A)),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            flex: (stats.ethDominance * 10).round(),
                            child: Container(color: const Color(0xFF627EEA)),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            flex: ((100 - stats.btcDominance - stats.ethDominance) * 10).round(),
                            child: Container(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendDot(const Color(0xFFF7931A), 'Bitcoin (${stats.btcDominance}%)'),
                      _buildLegendDot(const Color(0xFF627EEA), 'Ethereum (${stats.ethDominance}%)'),
                      _buildLegendDot(
                        AppColors.primary,
                        'Others (${(100 - stats.btcDominance - stats.ethDominance).toStringAsFixed(1)}%)',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TOP GAINERS SECTION
            Row(
              children: const [
                HugeIcon(icon: HugeIcons.strokeRoundedArrowUp01, size: 20, color: AppColors.bullish),
                SizedBox(width: 8),
                Text(
                  'Top Gainers (24h)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...topGainers.map((coin) => _buildMiniCoinRow(context, coin)),

            const SizedBox(height: 20),

            // TOP LOSERS SECTION
            Row(
              children: const [
                HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01, size: 20, color: AppColors.bearish),
                SizedBox(width: 8),
                Text(
                  'Top Losers (24h)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...topLosers.map((coin) => _buildMiniCoinRow(context, coin)),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required List<List<dynamic>> icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              HugeIcon(icon: icon, size: 16, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildMiniCoinRow(BuildContext context, CryptoCoin coin) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoinDetailsScreen(
              coin: coin,
              onWatchlistChanged: (isWatchlisted) {
                onToggleWatchlist(coin.id);
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: coin.brandColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                coin.symbol.length > 3 ? coin.symbol.substring(0, 3) : coin.symbol,
                style: TextStyle(
                  color: coin.brandColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    coin.symbol,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.formatCurrency(coin.currentPrice),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.formatPercentage(coin.priceChangePercentage24h),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: coin.isBullish ? AppColors.bullish : AppColors.bearish,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
