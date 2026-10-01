import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_theme.dart';

enum SortCriteria { marketCap, price, change24h, volume }
enum SortOrder { descending, ascending }
enum MarketCategory { all, trending, topGainers, topLosers }

class FilterSortSettings {
  final SortCriteria sortBy;
  final SortOrder sortOrder;
  final MarketCategory category;

  const FilterSortSettings({
    this.sortBy = SortCriteria.marketCap,
    this.sortOrder = SortOrder.descending,
    this.category = MarketCategory.all,
  });

  FilterSortSettings copyWith({
    SortCriteria? sortBy,
    SortOrder? sortOrder,
    MarketCategory? category,
  }) {
    return FilterSortSettings(
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      category: category ?? this.category,
    );
  }
}

class FilterSortBottomSheet extends StatefulWidget {
  final FilterSortSettings currentSettings;
  final Function(FilterSortSettings) onApply;

  const FilterSortBottomSheet({
    super.key,
    required this.currentSettings,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required FilterSortSettings currentSettings,
    required Function(FilterSortSettings) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterSortBottomSheet(
        currentSettings: currentSettings,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterSortBottomSheet> createState() => _FilterSortBottomSheetState();
}

class _FilterSortBottomSheetState extends State<FilterSortBottomSheet> {
  late SortCriteria _sortBy;
  late SortOrder _sortOrder;
  late MarketCategory _category;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.currentSettings.sortBy;
    _sortOrder = widget.currentSettings.sortOrder;
    _category = widget.currentSettings.category;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1.2),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort',
                style: AppTypography.headline.copyWith(fontSize: 18),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SORT BY SECTION
          const Text(
            'SORT BY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip(
                label: 'Market Cap',
                isSelected: _sortBy == SortCriteria.marketCap,
                onSelected: () => setState(() => _sortBy = SortCriteria.marketCap),
              ),
              _buildChoiceChip(
                label: 'Price',
                isSelected: _sortBy == SortCriteria.price,
                onSelected: () => setState(() => _sortBy = SortCriteria.price),
              ),
              _buildChoiceChip(
                label: '24h Change',
                isSelected: _sortBy == SortCriteria.change24h,
                onSelected: () => setState(() => _sortBy = SortCriteria.change24h),
              ),
              _buildChoiceChip(
                label: 'Volume',
                isSelected: _sortBy == SortCriteria.volume,
                onSelected: () => setState(() => _sortBy = SortCriteria.volume),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // DIRECTION (Ascending / Descending)
          const Text(
            'ORDER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildOrderOption(
                  label: 'Descending (High to Low)',
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  isSelected: _sortOrder == SortOrder.descending,
                  onTap: () => setState(() => _sortOrder = SortOrder.descending),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOrderOption(
                  label: 'Ascending (Low to High)',
                  icon: HugeIcons.strokeRoundedArrowUp01,
                  isSelected: _sortOrder == SortOrder.ascending,
                  onTap: () => setState(() => _sortOrder = SortOrder.ascending),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // FILTER BY CATEGORY
          const Text(
            'FILTER BY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip(
                label: 'All Coins',
                isSelected: _category == MarketCategory.all,
                onSelected: () => setState(() => _category = MarketCategory.all),
              ),
              _buildChoiceChip(
                label: 'Trending',
                isSelected: _category == MarketCategory.trending,
                onSelected: () => setState(() => _category = MarketCategory.trending),
              ),
              _buildChoiceChip(
                label: 'Top Gainers',
                isSelected: _category == MarketCategory.topGainers,
                onSelected: () => setState(() => _category = MarketCategory.topGainers),
              ),
              _buildChoiceChip(
                label: 'Top Losers',
                isSelected: _category == MarketCategory.topLosers,
                onSelected: () => setState(() => _category = MarketCategory.topLosers),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // BUTTONS: RESET & APPLY
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _sortBy = SortCriteria.marketCap;
                      _sortOrder = SortOrder.descending;
                      _category = MarketCategory.all;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderLight),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(
                      FilterSortSettings(
                        sortBy: _sortBy,
                        sortOrder: _sortOrder,
                        category: _category,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderOption({
    required String label,
    required List<List<dynamic>> icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: icon,
              size: 15,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label.contains('(') ? label.split(' ')[0] : label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
