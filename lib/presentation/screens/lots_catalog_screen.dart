import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../providers/lots_provider.dart';
import '../widgets/lot_card.dart';

class LotsCatalogScreen extends StatefulWidget {
  const LotsCatalogScreen({super.key});

  @override
  State<LotsCatalogScreen> createState() => _LotsCatalogScreenState();
}

class _LotsCatalogScreenState extends State<LotsCatalogScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.t('search'),
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: true,
                ),
                onChanged: (value) {
                  context.read<LotsProvider>().setSearchQuery(value);
                },
              )
            : Text(l10n.t('app_title')),

        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<LotsProvider>().setSearchQuery('');
                }
              });
            },
          ),

          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),

      body: Column(
        children: [
          _buildFilters(context, l10n),

          Expanded(
            child: Consumer<LotsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final lots = provider.lots;

                if (lots.isEmpty) {
                  return _buildEmptyState(context, l10n);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await provider.reloadMockData();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: lots.length,
                    itemBuilder: (context, index) {
                      final lot = lots[index];

                      return Slidable(
                        key: Key(lot.id),

                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _confirmDelete(context, lot.id),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: l10n.t('delete'),
                            ),
                          ],
                        ),

                        startActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => provider.toggleFavorite(lot.id),
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.white,
                              icon: lot.isFavorite
                                  ? Icons.star
                                  : Icons.star_border,
                              label: l10n.t('favorites'),
                            ),
                          ],
                        ),

                        child: LotCard(
                          lot: lot,
                          onTap: () => context.push('/lot/${lot.id}'),
                          onFavoriteToggle: () =>
                              provider.toggleFavorite(lot.id),
                          onCalculator: () =>
                              context.push('/calculator/${lot.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.t('add')),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, AppLocalizations l10n) {
    return Consumer<LotsProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: Text('${l10n.t('all_lots')} (${provider.totalCount})'),
                selected: !provider.showFavoritesOnly,
                onSelected: (_) => provider.setShowFavoritesOnly(false),
              ),
              const SizedBox(width: 8),

              FilterChip(
                label: Text(
                  '${l10n.t('favorites')} (${provider.favoritesCount})',
                ),
                selected: provider.showFavoritesOnly,
                onSelected: (_) => provider.setShowFavoritesOnly(true),
                avatar: const Icon(Icons.star, size: 18),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.t('no_lots'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.t('no_lots_hint'),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String lotId) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('delete')),
        content: Text(l10n.t('confirm_delete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.t('cancel')),
          ),
          TextButton(
            onPressed: () {
              context.read<LotsProvider>().deleteLot(lotId);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.t('delete')),
          ),
        ],
      ),
    );
  }
}
