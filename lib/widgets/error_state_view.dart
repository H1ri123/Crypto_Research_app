import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_theme.dart';

class ErrorStateView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final bool isNetworkError;

  const ErrorStateView({
    super.key,
    this.title = 'Unable to load market data',
    this.message = 'We encountered an issue connecting to the market data feed. Please check your internet connection and try again.',
    required this.onRetry,
    this.isNetworkError = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bearishSurface,
                border: Border.all(
                  color: AppColors.bearish.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.bearish.withValues(alpha: 0.15),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: HugeIcon(
                  icon: isNetworkError
                      ? HugeIcons.strokeRoundedWifiDisconnected01
                      : HugeIcons.strokeRoundedAlertCircle,
                  size: 38,
                  color: AppColors.bearish,
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

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedRefresh,
                size: 18,
                color: AppColors.textPrimary,
              ),
              label: const Text(
                'Retry Connection',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.borderLight, width: 1),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
