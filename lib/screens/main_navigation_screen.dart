import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/market_provider.dart';
import 'market_screen.dart';
import 'market_statistics_screen.dart';
import 'watchlist_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedAlert02,
                size: 22,
                color: AppColors.primary,
              ),
              SizedBox(width: 10),
              Text(
                'Exit App',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to exit Crypto Research?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'No',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Yes, Exit',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, marketProvider, child) {
        final coins = marketProvider.coins;
        final marketStats = marketProvider.marketStats;
        final watchlistedCount = marketProvider.watchlistCoins.length;

        final screens = [
          MarketScreen(
            coins: coins,
            marketStats: marketStats,
            onToggleWatchlist: (id) => marketProvider.toggleWatchlist(id),
          ),
          WatchlistScreen(
            coins: coins,
            onToggleWatchlist: (id) => marketProvider.toggleWatchlist(id),
            onExploreMarket: () {
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          MarketStatisticsScreen(
            stats: marketStats,
            coins: coins,
            onToggleWatchlist: (id) => marketProvider.toggleWatchlist(id),
          ),
        ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // If user is on another tab, return to Market home tab first
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return;
        }

        // When in home page, show exit dialog
        final shouldExit = await _showExitDialog();
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: const Border(
            top: BorderSide(color: Color(0xFF383838), width: 1.2),
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF282828), // Secondary color #282828
              Color(0xFF1C1C1C),
              Color(0xFF121212),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: HugeIcons.strokeRoundedHome01,
                    label: 'Market',
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: HugeIcons.strokeRoundedStar,
                    label: 'Watchlist',
                    badgeCount: watchlistedCount,
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: HugeIcons.strokeRoundedAnalytics01,
                    label: 'Statistics',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required List<List<dynamic>> icon,
    required String label,
    int? badgeCount,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Ambient top spotlight/glow directly above the selected active item
            if (isSelected)
              Positioned(
                top: -8,
                child: Container(
                  width: 48,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 0.85,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.28),
                        AppColors.primary.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // Vertical layout: Icon on top, Label below
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        child: HugeIcon(
                          icon: icon,
                          size: 24,
                          color: isSelected ? AppColors.primary : const Color(0xFF8E95A5),
                        ),
                      ),
                      if (badgeCount != null && badgeCount > 0)
                        Positioned(
                          top: -3,
                          right: -7,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                            alignment: Alignment.center,
                            child: Text(
                              '$badgeCount',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : const Color(0xFF8E95A5),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
