import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_theme.dart';

class EmptyStateView extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
  });

  factory EmptyStateView.noSearchResults({VoidCallback? onClearSearch}) {
    return EmptyStateView(
      icon: HugeIcons.strokeRoundedSearch01,
      title: 'No coins found',
      message: 'We couldn\'t find any cryptocurrency matching your query. Check for typos or try searching another ticker.',
      buttonText: onClearSearch != null ? 'Clear Search' : null,
      onButtonPressed: onClearSearch,
    );
  }

  factory EmptyStateView.emptyWatchlist({VoidCallback? onExplore}) {
    return EmptyStateView(
      icon: HugeIcons.strokeRoundedStar,
      title: 'Your watchlist is empty',
      message: 'Keep track of coins you care about by tapping the star icon on any coin card in the market screen.',
      buttonText: 'Explore Market',
      onButtonPressed: onExplore,
    );
  }

  factory EmptyStateView.emptyMarket({VoidCallback? onRefresh}) {
    return EmptyStateView(
      icon: HugeIcons.strokeRoundedBitcoin,
      title: 'No market data',
      message: 'There are currently no cryptocurrency records available in this view.',
      buttonText: 'Refresh Market',
      onButtonPressed: onRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular illustration container with subtle glow
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: HugeIcon(
                  icon: icon,
                  size: 38,
                  color: AppColors.textMuted,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              style: AppTypography.headline.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              message,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
