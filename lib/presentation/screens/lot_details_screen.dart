import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/app_localizations.dart';
import '../../providers/lots_provider.dart';
import '../../data/models/lot_model.dart';

class LotDetailsScreen extends StatelessWidget {
  final String lotId;

  const LotDetailsScreen({super.key, required this.lotId});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Consumer<LotsProvider>(
      builder: (context, provider, _) {
        final lot = provider.getLotById(lotId);

        if (lot == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.t('error'))),
            body: Center(child: Text(l10n.t('no_data'))),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(lot.fullName),
            actions: [
              IconButton(
                icon: Icon(
                  lot.isFavorite ? Icons.star : Icons.star_border,
                  color: lot.isFavorite ? Colors.amber : null,
                ),
                onPressed: () => provider.toggleFavorite(lot.id),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/edit/${lot.id}'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, lot.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhotoSection(context, lot),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(context, lot),

                      const SizedBox(height: 24),

                      _buildSection(
                        context,
                        title: l10n.t('details'),
                        icon: Icons.directions_car,
                        children: [
                          _buildInfoRow(l10n.t('make'), lot.make),
                          _buildInfoRow(l10n.t('model'), lot.model),
                          _buildInfoRow(l10n.t('year'), lot.year.toString()),
                          if (lot.vin != null)
                            _buildInfoRow(
                              l10n.t('vin'),
                              lot.vin!,
                              onTap: () => _copyToClipboard(context, lot.vin!),
                              trailing: const Icon(Icons.copy, size: 16),
                            ),
                          if (lot.mileage != null)
                            _buildInfoRow(
                              l10n.t('mileage'),
                              '${lot.mileage} ${l10n.t('miles')}',
                            ),
                          if (lot.engine != null)
                            _buildInfoRow(l10n.t('engine'), lot.engine!),
                          if (lot.transmission != null)
                            _buildInfoRow(l10n.t('transmission'), lot.transmission!),
                          if (lot.drivetrain != null)
                            _buildInfoRow(l10n.t('drivetrain'), lot.drivetrain!),
                          if (lot.fuelType != null)
                            _buildInfoRow(l10n.t('fuel_type'), lot.fuelType!),
                          if (lot.exteriorColor != null)
                            _buildInfoRow(l10n.t('color'), lot.exteriorColor!),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildSection(
                        context,
                        title: l10n.t('auction'),
                        icon: Icons.gavel,
                        children: [
                          _buildInfoRow(l10n.t('lot_number'), lot.lotNumber),
                          _buildInfoRow(l10n.t('auction'), lot.auction),
                          _buildInfoRow(l10n.t('location'), lot.location),
                          _buildInfoRow(
                            l10n.t('current_bid'),
                            '\$${lot.currentBid.toStringAsFixed(0)}',
                            valueStyle: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (lot.buyNowPrice != null)
                            _buildInfoRow(
                              l10n.t('buy_now'),
                              '\$${lot.buyNowPrice!.toStringAsFixed(0)}',
                            ),
                          if (lot.saleDate != null)
                            _buildInfoRow(
                              l10n.t('sale_date'),
                              _formatDate(lot.saleDate!),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildSection(
                        context,
                        title: l10n.t('damage'),
                        icon: Icons.warning_amber,
                        iconColor: Colors.orange,
                        children: [
                          _buildInfoRow(l10n.t('primary_damage'), lot.primaryDamage),
                          if (lot.secondaryDamage != null)
                            _buildInfoRow(l10n.t('secondary_damage'), lot.secondaryDamage!),
                          _buildInfoRow(
                            l10n.t('has_keys'),
                            lot.hasKeys ? '✓ Yes' : '✗ No',
                            valueStyle: TextStyle(
                              color: lot.hasKeys ? Colors.green : Colors.red,
                            ),
                          ),
                          _buildInfoRow(
                            l10n.t('runs_drives'),
                            lot.runsDrives ? '✓ Yes' : '✗ No',
                            valueStyle: TextStyle(
                              color: lot.runsDrives ? Colors.green : Colors.red,
                            ),
                          ),
                          _buildInfoRow(l10n.t('title_type'), lot.titleType),
                        ],
                      ),

                      if (lot.notes != null && lot.notes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildSection(
                          context,
                          title: 'Notes',
                          icon: Icons.note,
                          children: [
                            Text(
                              lot.notes!,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      _buildActionButtons(context, lot),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoSection(BuildContext context, LotModel lot) {
    return Container(
      height: 220,
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: lot.photos.isNotEmpty
          ? PageView.builder(
        itemCount: lot.photos.length,
        itemBuilder: (context, index) {
          return Image.network(
            lot.photos[index],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPhotoPlaceholder(context),
          );
        },
      )
          : _buildPhotoPlaceholder(context),
    );
  }

  Widget _buildPhotoPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'No photos',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, LotModel lot) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lot.fullName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lot #${lot.lotNumber} • ${lot.auction}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${lot.currentBid.toStringAsFixed(0)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Current Bid',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        Color? iconColor,
        required List<Widget> children,
      }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor ?? theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label,
      String value, {
        TextStyle? valueStyle,
        VoidCallback? onTap,
        Widget? trailing,
      }) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Row(
            children: [
              Text(
                value,
                style: valueStyle ??
                    const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: row);
    }
    return row;
  }

  Widget _buildActionButtons(BuildContext context, LotModel lot) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/calculator/${lot.id}'),
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate Total Cost'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: 12),

        if (lot.url != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openUrl(lot.url!),
              icon: const Icon(Icons.open_in_new),
              label: Text('Open on ${lot.auction}'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
      ],
    );
  }


  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
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
              context.go('/catalog');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.t('delete')),
          ),
        ],
      ),
    );
  }
}