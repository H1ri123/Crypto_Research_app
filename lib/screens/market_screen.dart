import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/coin_model.dart';
import '../models/market_stats_model.dart';
import '../providers/market_provider.dart';
import '../widgets/coin_card.dart';
import '../widgets/error_state_view.dart';
import '../widgets/filter_sort_sheet.dart';
import '../widgets/market_summary_card.dart';
import '../widgets/shimmer_loading.dart';
import 'coin_details_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class MarketScreen extends StatefulWidget {
  final List<CryptoCoin> coins;
  final MarketStats marketStats;
  final Function(String coinId) onToggleWatchlist;

  const MarketScreen({
    super.key,
    required this.coins,
    required this.marketStats,
    required this.onToggleWatchlist,
  });

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  MarketCategory _selectedCategory = MarketCategory.all;
  FilterSortSettings _filterSettings = const FilterSortSettings();

  bool _isLoading = false;
  bool _hasError = false;

  List<CryptoCoin> get _processedCoins {
    List<CryptoCoin> list = List.from(widget.coins);

    // Apply category filter
    final cat = _filterSettings.category != MarketCategory.all
        ? _filterSettings.category
        : _selectedCategory;

    switch (cat) {
      case MarketCategory.trending:
        list = list.where((c) => c.marketCapRank <= 5 || c.priceChangePercentage24h > 4.0).toList();
        break;
      case MarketCategory.topGainers:
        list = list.where((c) => c.priceChangePercentage24h > 0).toList();
        list.sort((a, b) => b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
        return list;
      case MarketCategory.topLosers:
        list = list.where((c) => c.priceChangePercentage24h < 0).toList();
        list.sort((a, b) => a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h));
        return list;
      case MarketCategory.all:
        break;
    }

    // Apply sorting
    switch (_filterSettings.sortBy) {
      case SortCriteria.marketCap:
        list.sort((a, b) => _filterSettings.sortOrder == SortOrder.descending
            ? b.marketCap.compareTo(a.marketCap)
            : a.marketCap.compareTo(b.marketCap));
        break;
      case SortCriteria.price:
        list.sort((a, b) => _filterSettings.sortOrder == SortOrder.descending
            ? b.currentPrice.compareTo(a.currentPrice)
            : a.currentPrice.compareTo(b.currentPrice));
        break;
      case SortCriteria.change24h:
        list.sort((a, b) => _filterSettings.sortOrder == SortOrder.descending
            ? b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h)
            : a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h));
        break;
      case SortCriteria.volume:
        list.sort((a, b) => _filterSettings.sortOrder == SortOrder.descending
            ? b.totalVolume24h.compareTo(a.totalVolume24h)
            : a.totalVolume24h.compareTo(b.totalVolume24h));
        break;
    }

    return list;
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      await Future.wait([
        context.read<MarketProvider>().fetchCoins(refresh: true),
        context.read<MarketProvider>().fetchMarketStats(),
        context.read<MarketProvider>().fetchWatchlist(),
      ]);
    } catch (e) {
      debugPrint('[MarketScreen] Refresh error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openFilterSort() {
    FilterSortBottomSheet.show(
      context,
      currentSettings: _filterSettings,
      onApply: (newSettings) {
        setState(() {
          _filterSettings = newSettings;
          _selectedCategory = newSettings.category;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Crypto Research',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Track the crypto market',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.card,
                border: Border.all(color: AppColors.border, width: 1.2),
              ),
              child: const Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedUserCircle,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _hasError
          ? ErrorStateView(
              onRetry: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (mounted) setState(() => _isLoading = false);
                });
              },
            )
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // SEARCH BAR AND FILTER/SORT BUTTONS
                  Row(
                    children: [
                      // Search Bar Trigger
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchScreen(
                                  allCoins: widget.coins,
                                  onToggleWatchlist: widget.onToggleWatchlist,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border, width: 1),
                            ),
                            child: Row(
                              children: const [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedSearch01,
                                  color: AppColors.textMuted,
                                  size: 19,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Search coins or symbols...',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Filter & Sort Button
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: IconButton(
                          onPressed: _openFilterSort,
                          icon: const HugeIcon(
                            icon: HugeIcons.strokeRoundedFilterHorizontal,
                            size: 19,
                            color: AppColors.textPrimary,
                          ),
                          tooltip: 'Filter & Sort',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // MARKET SUMMARY CARDS
                  if (_isLoading)
                    const MarketSummarySkeleton()
                  else
                    MarketSummaryRow(stats: widget.marketStats),

                  const SizedBox(height: 20),

                  // CATEGORY FILTER CHIPS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('All', MarketCategory.all),
                        const SizedBox(width: 8),
                        _buildFilterChip('Trending', MarketCategory.trending),
                        const SizedBox(width: 8),
                        _buildFilterChip('Top Gainers', MarketCategory.topGainers),
                        const SizedBox(width: 8),
                        _buildFilterChip('Top Losers', MarketCategory.topLosers),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // COIN LIST CARDS OR LOADING SKELETON
                  if (_isLoading) ...[
                    ...List.generate(6, (index) => const CoinCardSkeleton()),
                  ] else ...[
                    ..._processedCoins.map((coin) {
                      return CoinCard(
                        coin: coin,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CoinDetailsScreen(
                                coin: coin,
                                onWatchlistChanged: (isWatchlisted) {
                                  widget.onToggleWatchlist(coin.id);
                                },
                              ),
                            ),
                          );
                        },
                        onWatchlistToggle: () {
                          widget.onToggleWatchlist(coin.id);
                        },
                      );
                    }),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterChip(String label, MarketCategory category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _filterSettings = _filterSettings.copyWith(category: category);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
