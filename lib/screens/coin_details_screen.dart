import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../models/coin_model.dart';
import '../providers/market_provider.dart';
import '../widgets/interactive_chart.dart';

class CoinDetailsScreen extends StatefulWidget {
  final CryptoCoin coin;
  final Function(bool isWatchlisted) onWatchlistChanged;

  const CoinDetailsScreen({
    super.key,
    required this.coin,
    required this.onWatchlistChanged,
  });

  @override
  State<CoinDetailsScreen> createState() => _CoinDetailsScreenState();
}

class _CoinDetailsScreenState extends State<CoinDetailsScreen> {
  late bool _isWatchlisted;
  double? _scrubbedPrice;
  DateTime? _scrubbedTime;
  Map<String, List<PricePoint>> _historicalData = {};
  bool _isLoadingChart = false;

  @override
  void initState() {
    super.initState();
    _isWatchlisted = widget.coin.isWatchlisted;
    _historicalData = Map.from(widget.coin.historicalData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MarketProvider>().fetchCoinDetails(widget.coin.id);
        _loadChartForRange('7D');
      }
    });
  }

  Future<void> _loadChartForRange(String range) async {
    int days = 7;
    switch (range) {
      case '1D':
        days = 1;
        break;
      case '7D':
        days = 7;
        break;
      case '30D':
        days = 30;
        break;
      case '1Y':
        days = 365;
        break;
    }

    if (mounted) setState(() => _isLoadingChart = true);

    try {
      final points = await context.read<MarketProvider>().fetchPriceChart(widget.coin.id, days: days);
      if (mounted && points.isNotEmpty) {
        setState(() {
          _historicalData[range] = points;
          _isLoadingChart = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('[CoinDetailsScreen] Error loading chart points for ${widget.coin.id}: $e');
    }

    if (mounted) {
      setState(() => _isLoadingChart = false);
    }
  }

  void _toggleWatchlist() {
    setState(() {
      _isWatchlisted = !_isWatchlisted;
    });
    widget.onWatchlistChanged(_isWatchlisted);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedStar,
              color: _isWatchlisted ? const Color(0xFFFFB800) : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              _isWatchlisted
                  ? '${widget.coin.name} added to Watchlist'
                  : '${widget.coin.name} removed from Watchlist',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedPrice = _scrubbedPrice ?? widget.coin.currentPrice;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: widget.coin.brandColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: widget.coin.brandColor, width: 1.2),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.coin.symbol.length > 3
                    ? widget.coin.symbol.substring(0, 3)
                    : widget.coin.symbol,
                style: TextStyle(
                  color: widget.coin.brandColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.coin.name,
              style: AppTypography.title.copyWith(fontSize: 17),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Text(
                '#${widget.coin.marketCapRank}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _toggleWatchlist,
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedStar,
              color: _isWatchlisted ? const Color(0xFFFFB800) : AppColors.textSecondary,
              size: 22,
            ),
            tooltip: _isWatchlisted ? 'Remove from Watchlist' : 'Add to Watchlist',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRICE & 24H CHANGE
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.formatCurrency(displayedPrice),
                  style: AppTypography.numberLarge.copyWith(fontSize: 32),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.coin.isBullish
                          ? AppColors.bullishSurface
                          : AppColors.bearishSurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: widget.coin.isBullish
                              ? HugeIcons.strokeRoundedArrowUp01
                              : HugeIcons.strokeRoundedArrowDown01,
                          size: 14,
                          color: widget.coin.isBullish
                              ? AppColors.bullish
                              : AppColors.bearish,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          Formatters.formatPercentage(
                              widget.coin.priceChangePercentage24h),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: widget.coin.isBullish
                                ? AppColors.bullish
                                : AppColors.bearish,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (_scrubbedTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Inspecting: ${_scrubbedTime!.toLocal().toString().split('.')[0]}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // INTERACTIVE CHART
            InteractivePriceChart(
              historicalData: _historicalData,
              isBullish: widget.coin.isBullish,
              isLoading: _isLoadingChart,
              onTimeframeChanged: _loadChartForRange,
              onSelectedPointChanged: (point) {
                setState(() {
                  _scrubbedPrice = point?.price;
                  _scrubbedTime = point?.timestamp;
                });
              },
            ),

            const SizedBox(height: 28),

            // STATISTICS SECTION HEADER
            Text(
              'Market Statistics',
              style: AppTypography.headline.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),

            // KEY STATS GRID
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    'Market Capitalization',
                    Formatters.formatCurrency(widget.coin.marketCap, forcedDecimals: 0),
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  _buildStatRow(
                    '24h Trading Volume',
                    Formatters.formatCurrency(widget.coin.totalVolume24h, forcedDecimals: 0),
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  _buildStatRow(
                    'Circulating Supply',
                    '${Formatters.formatNumber(widget.coin.circulatingSupply)} ${widget.coin.symbol}',
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  _buildStatRow(
                    'Total Supply',
                    widget.coin.totalSupply != null
                        ? '${Formatters.formatNumber(widget.coin.totalSupply!)} ${widget.coin.symbol}'
                        : 'Infinite',
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  _buildStatRow(
                    'Max Supply',
                    widget.coin.maxSupply != null
                        ? '${Formatters.formatNumber(widget.coin.maxSupply!)} ${widget.coin.symbol}'
                        : 'No Max',
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  _buildStatRow(
                    'All-Time High (ATH)',
                    Formatters.formatCurrency(widget.coin.allTimeHigh),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ABOUT COIN SECTION
            Text(
              'About ${widget.coin.name}',
              style: AppTypography.headline.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Text(
                widget.coin.about,
                style: AppTypography.body.copyWith(fontSize: 13.5, height: 1.6),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.numberMedium.copyWith(fontSize: 13.5),
        ),
      ],
    );
  }
}
