import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_theme.dart';
import '../models/coin_model.dart';
import '../widgets/coin_card.dart';
import '../widgets/empty_state_view.dart';
import 'coin_details_screen.dart';

class WatchlistScreen extends StatelessWidget {
  final List<CryptoCoin> coins;
  final Function(String coinId) onToggleWatchlist;
  final VoidCallback onExploreMarket;

  const WatchlistScreen({
    super.key,
    required this.coins,
    required this.onToggleWatchlist,
    required this.onExploreMarket,
  });

  @override
  Widget build(BuildContext context) {
    final watchlistedCoins = coins.where((c) => c.isWatchlisted).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Watchlist',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${watchlistedCoins.length} assets tracked',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: watchlistedCoins.isEmpty
          ? EmptyStateView.emptyWatchlist(
              onExplore: onExploreMarket,
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: watchlistedCoins.length,
              itemBuilder: (context, index) {
                final coin = watchlistedCoins[index];

                return Dismissible(
                  key: Key('watchlist_${coin.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: AppColors.bearishSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.bearish.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text(
                          'Remove',
                          style: TextStyle(
                            color: AppColors.bearish,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 8),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete02,
                          color: AppColors.bearish,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (direction) {
                    onToggleWatchlist(coin.id);
                  },
                  child: CoinCard(
                    coin: coin,
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
                    onWatchlistToggle: () {
                      onToggleWatchlist(coin.id);
                    },
                  ),
                );
              },
            ),
    );
  }
}
