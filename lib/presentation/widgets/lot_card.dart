import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/lot_model.dart';
import 'lot_image.dart';

class LotCard extends StatelessWidget {
  final LotModel lot;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onCalculator;

  const LotCard({
    super.key,
    required this.lot,
    this.onTap,
    this.onFavoriteToggle,
    this.onCalculator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: lot.photos.isNotEmpty
                        ? LotImage(imagePath: lot.photos[0])
                        : Icon(Icons.directions_car, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lot.fullName,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${l10n.t('lot_number')}${lot.lotNumber}',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      lot.isFavorite ? Icons.star : Icons.star_border,
                      color: lot.isFavorite ? Colors.amber : Colors.grey,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    lot.location,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getAuctionColor(lot.auction).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      lot.auction,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getAuctionColor(lot.auction),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.t('current_bid'), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(
                          '\$${_formatNumber(lot.currentBid)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (lot.mileage != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.t('mileage'), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.speed, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${_formatNumber(lot.mileage!.toDouble())} ${l10n.t('miles')}',
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: lot.runsDrives ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          lot.runsDrives ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: lot.runsDrives ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lot.runsDrives ? l10n.t('runs') : l10n.t('not_run'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: lot.runsDrives ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      lot.primaryDamage,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.orange),
                    ),
                  ],
                ),
              ),

              // --- КНОПКА КАЛЬКУЛЯТОРА ---
              if (onCalculator != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onCalculator,
                    icon: const Icon(Icons.calculate, size: 18),
                    label: Text(l10n.t('calculate_cost')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getAuctionColor(String auction) {
    switch (auction.toLowerCase()) {
      case 'copart': return const Color(0xFF2563EB);
      case 'iaai': return const Color(0xFF059669);
      case 'manheim': return const Color(0xFF7C3AED);
      default: return Colors.grey;
    }
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }
}