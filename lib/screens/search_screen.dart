import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/coin_model.dart';
import '../providers/market_provider.dart';
import '../widgets/coin_card.dart';
import '../widgets/empty_state_view.dart';
import 'coin_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final List<CryptoCoin> allCoins;
  final Function(String coinId) onToggleWatchlist;

  const SearchScreen({
    super.key,
    required this.allCoins,
    required this.onToggleWatchlist,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = ['Bitcoin', 'Solana', 'XRP', 'Ethereum'];
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CryptoCoin> _getResults(MarketProvider provider) {
    if (_query.trim().isEmpty) return [];
    if (provider.searchResults.isNotEmpty) {
      return provider.searchResults;
    }
    final q = _query.trim().toLowerCase();
    return widget.allCoins.where((coin) {
      return coin.name.toLowerCase().contains(q) ||
          coin.symbol.toLowerCase().contains(q);
    }).toList();
  }

  void _onSearch(String term) {
    setState(() {
      _query = term;
      _searchController.text = term;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: term.length),
      );
      if (!_recentSearches.contains(term) && term.trim().isNotEmpty) {
        _recentSearches.insert(0, term);
        if (_recentSearches.length > 6) {
          _recentSearches.removeLast();
        }
      }
    });
    context.read<MarketProvider>().searchCoins(term);
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = context.watch<MarketProvider>();
    final results = _getResults(marketProvider);
    final isSearching = _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight, width: 1),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              onChanged: (val) {
                setState(() {
                  _query = val;
                });
                context.read<MarketProvider>().searchCoins(val);
              },
              decoration: InputDecoration(
                hintText: 'Search coin or symbol (e.g. BTC)...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01,
                    color: AppColors.textMuted,
                    size: 19,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCancel01,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _query = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RECENT SEARCHES (when search box is empty)
          if (!isSearching && _recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RECENT SEARCHES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _recentSearches.clear();
                      });
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recentSearches.map((term) {
                  return ActionChip(
                    label: Text(
                      term,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    onPressed: () => _onSearch(term),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // SEARCH RESULTS OR EMPTY STATE
          Expanded(
            child: !isSearching
                ? const SizedBox.shrink()
                : results.isEmpty
                    ? EmptyStateView.noSearchResults(
                        onClearSearch: () {
                          setState(() {
                            _searchController.clear();
                            _query = '';
                          });
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final coin = results[index];
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
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
