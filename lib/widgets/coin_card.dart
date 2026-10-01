import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../models/coin_model.dart';
import 'sparkline_chart.dart';

class CoinCard extends StatelessWidget {
  final CryptoCoin coin;
  final VoidCallback onTap;
  final VoidCallback onWatchlistToggle;

  const CoinCard({
    super.key,
    required this.coin,
    required this.onTap,
    required this.onWatchlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.cardHighlight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Coin Avatar Badge with Brand color
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: coin.brandColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: coin.brandColor.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    coin.symbol.length > 3 ? coin.symbol.substring(0, 3) : coin.symbol,
                    style: TextStyle(
                      color: coin.brandColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Name, Symbol & Rank
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              coin.name,
                              style: AppTypography.title.copyWith(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.border, width: 0.8),
                            ),
                            child: Text(
                              '#${coin.marketCapRank}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: coin.symbol,
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextSpan(
                              text: '  •  MCap ${Formatters.formatCompact(coin.marketCap)}',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),

                // Sparkline Chart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SparklineChart(
                    data: coin.sparkline,
                    isBullish: coin.isBullish,
                    width: 58,
                    height: 28,
                  ),
                ),

                // Price & 24h Percentage
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Formatters.formatCurrency(coin.currentPrice),
                        style: AppTypography.numberMedium.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: coin.isBullish
                              ? AppColors.bullishSurface
                              : AppColors.bearishSurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: coin.isBullish
                                  ? HugeIcons.strokeRoundedArrowUp01
                                  : HugeIcons.strokeRoundedArrowDown01,
                              size: 13,
                              color: coin.isBullish ? AppColors.bullish : AppColors.bearish,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                Formatters.formatPercentage(coin.priceChangePercentage24h),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: coin.isBullish ? AppColors.bullish : AppColors.bearish,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),

                // Star Watchlist Button
                IconButton(
                  onPressed: onWatchlistToggle,
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedStar,
                    color: coin.isWatchlisted ? const Color(0xFFFFB800) : AppColors.textMuted,
                    size: 20,
                  ),
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
