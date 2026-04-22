import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/app_localizations.dart';
import '../../data/models/lot_model.dart';
import '../../providers/lots_provider.dart';
import '../widgets/lot_image.dart';

class LotDetailsScreen extends StatefulWidget {
  final String lotId;
  const LotDetailsScreen({super.key, required this.lotId});

  @override
  State<LotDetailsScreen> createState() => _LotDetailsScreenState();
}

class _LotDetailsScreenState extends State<LotDetailsScreen> {
  final GlobalKey _boundaryKey = GlobalKey();

  Future<void> _shareScreenshot(LotModel lot) async {
    try {
      RenderRepaintBoundary? boundary =
      _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/lot_${lot.lotNumber}.png').create();
      await file.writeAsBytes(pngBytes);

      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out this car: ${lot.fullName}!',
        sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      debugPrint('Error sharing screenshot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Consumer<LotsProvider>(
      builder: (context, provider, _) {
        final lot = provider.getLotById(widget.lotId);

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
                icon: const Icon(Icons.camera_alt_outlined),
                tooltip: 'Share as Image',
                onPressed: () => _shareScreenshot(lot),
              ),
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
                icon: const Icon(Icons.notifications_active_outlined),
                onPressed: () async {
                  await context.read<LotsProvider>().setAuctionReminder(lot.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Auction Reminder Set!'), backgroundColor: Colors.green),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareLot(context, lot),
              ),
            ],
          ),
          body: RepaintBoundary(
            key: _boundaryKey,
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: SingleChildScrollView(
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
                                _buildInfoRow(l10n.t('mileage'), '${lot.mileage} ${l10n.t('miles')}'),
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
                              _buildInfoRow(
                                l10n.t('current_bid'),
                                '\$${lot.currentBid.toStringAsFixed(0)}',
                                valueStyle: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              if (lot.saleDate != null)
                                _buildInfoRow(l10n.t('sale_date'), _formatDate(lot.saleDate!)),
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
                              _buildInfoRow(l10n.t('has_keys'), lot.hasKeys ? '✓ Yes' : '✗ No',
                                  valueStyle: TextStyle(color: lot.hasKeys ? Colors.green : Colors.red)),
                              _buildInfoRow(l10n.t('runs_drives'), lot.runsDrives ? '✓ Yes' : '✗ No',
                                  valueStyle: TextStyle(color: lot.runsDrives ? Colors.green : Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildActionButtons(context, lot),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: lot.photos.isNotEmpty
          ? PageView.builder(
        itemCount: lot.photos.length,
        itemBuilder: (context, index) => LotImage(imagePath: lot.photos[index]),
      )
          : const Center(child: Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey)),
    );
  }

  Widget _buildHeaderSection(BuildContext context, LotModel lot) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lot.fullName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text('Lot #${lot.lotNumber} • ${lot.auction}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            ],
          ),
        ),
        Text('\$${lot.currentBid.toStringAsFixed(0)}',
            style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, Color? iconColor, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 20, color: iconColor ?? theme.colorScheme.primary), const SizedBox(width: 8), Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle, VoidCallback? onTap, Widget? trailing}) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Row(children: [Text(value, style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w500)), if (trailing != null) ...[const SizedBox(width: 8), trailing]]),
      ]),
    );
    return onTap != null ? InkWell(onTap: onTap, child: row) : row;
  }

  Widget _buildActionButtons(BuildContext context, LotModel lot) {
    return Column(children: [
      SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => context.push('/calculator/${lot.id}'), icon: const Icon(Icons.calculate), label: const Text('Calculate Total Cost'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)))),
      const SizedBox(height: 12),
      if (lot.url != null) SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _openUrl(lot.url!), icon: const Icon(Icons.open_in_new), label: Text('Open on ${lot.auction}'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)))),
    ]);
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied: $text')));
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _formatDate(DateTime date) => '${date.day}.${date.month}.${date.year}';

  void _shareLot(BuildContext context, LotModel lot) {
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      'Check out this ${lot.fullName} at ${lot.auction}!\nBid: \$${lot.currentBid}',
      sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    );
  }
}