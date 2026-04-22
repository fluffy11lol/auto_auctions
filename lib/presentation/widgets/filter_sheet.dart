import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lots_provider.dart';
import '../../core/constants/auction_data.dart';

class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LotsProvider>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: theme.textTheme.titleLarge),
              TextButton(
                onPressed: () => provider.resetFilters(),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: LotSortOption.values.map((opt) {
              return ChoiceChip(
                label: Text(_sortLabel(opt)),
                selected: provider.sortOption == opt,
                onSelected: (_) => provider.setSortOption(opt),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          const Text('Make', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            isExpanded: true,
            value: provider.selectedMake,
            hint: const Text('Select Make'),
            items: AuctionData.popularMakes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (val) => provider.setFilters(make: val, year: provider.selectedYear),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            onPressed: () => Navigator.pop(context),
            child: const Text('Show Results'),
          ),
        ],
      ),
    );
  }

  String _sortLabel(LotSortOption opt) {
    switch (opt) {
      case LotSortOption.dateNewest: return 'Newest';
      case LotSortOption.priceAsc: return 'Price: Low to High';
      case LotSortOption.priceDesc: return 'Price: High to Low';
      case LotSortOption.yearNewest: return 'Car Year';
    }
  }
}