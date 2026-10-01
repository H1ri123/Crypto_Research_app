import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../models/market_stats_model.dart';

class MarketSummaryRow extends StatelessWidget {
  final MarketStats stats;

  const MarketSummaryRow({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildCard(
            title: 'Market Cap',
            value: Formatters.formatCompact(stats.totalMarketCap),
            badge: Formatters.formatPercentage(stats.marketCapChange24h),
            isBullish: stats.isBullish,
            icon: HugeIcons.strokeRoundedPieChart,
          ),
          const SizedBox(width: 10),
          _buildCard(
            title: '24h Volume',
            value: Formatters.formatCompact(stats.totalVolume24h),
            badge: 'Global',
            isBullish: null,
            icon: HugeIcons.strokeRoundedChartHistogram,
          ),
          const SizedBox(width: 10),
          _buildCard(
            title: 'BTC Dominance',
            value: '${stats.btcDominance}%',
            badge: 'ETH ${stats.ethDominance}%',
            isBullish: null,
            icon: HugeIcons.strokeRoundedBitcoin,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required String badge,
    required bool? isBullish,
    required List<List<dynamic>> icon,
  }) {
    return Container(
      width: 155,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              HugeIcon(icon: icon, size: 15, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isBullish == null
                  ? AppColors.cardHighlight
                  : (isBullish ? AppColors.bullishSurface : AppColors.bearishSurface),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isBullish == null
                    ? AppColors.textSecondary
                    : (isBullish ? AppColors.bullish : AppColors.bearish),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
