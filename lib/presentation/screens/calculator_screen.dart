import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/constants/auction_data.dart';
import '../../providers/lots_provider.dart';
import '../../providers/settings_provider.dart';
import '../../data/models/lot_model.dart';

class CalculatorScreen extends StatefulWidget {
  final String lotId;

  const CalculatorScreen({super.key, required this.lotId});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late double _bidPrice;
  double _auctionFee = 450;
  double _gateFee = 100;
  double _inlandShipping = 450;
  double _oceanShipping = 2100;
  double _portFees = 300;
  double _customsDuty = 0;
  double _recyclingFee = 860000;
  double _brokerFee = 50000;
  double _marketPrice = 0;

  String _selectedUsaPort = 'Houston, TX';
  String _selectedRuPort = 'Vladivostok';

  @override
  void initState() {
    super.initState();
    final lot = context.read<LotsProvider>().getLotById(widget.lotId);
    _bidPrice = lot?.currentBid ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final lot = context.watch<LotsProvider>().getLotById(widget.lotId);

    if (lot == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.t('calculator'))),
        body: Center(child: Text(l10n.t('no_data'))),
      );
    }

    final usdRate = settings.usdRate;

    final auctionTotal = _bidPrice + _auctionFee + _gateFee;
    final shippingTotal = _inlandShipping + _oceanShipping + _portFees;
    final totalUsd = auctionTotal + shippingTotal;

    _customsDuty = totalUsd * 0.48 * usdRate;

    final customsTotal = _customsDuty + _recyclingFee + _brokerFee;
    final totalRub = (totalUsd * usdRate) + customsTotal;

    final profit = _marketPrice - totalRub;
    final profitPercent = _marketPrice > 0 ? (profit / totalRub) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('cost_calculator')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarHeader(context, lot, l10n),

            const SizedBox(height: 24),

            _buildSection(
              context,
              title: l10n.t('auction_costs'),
              icon: Icons.gavel,
              color: theme.colorScheme.primary,
              children: [
                _buildEditableRow(
                  label: l10n.t('bid_price'),
                  value: _bidPrice,
                  prefix: '\$',
                  onChanged: (v) => setState(() => _bidPrice = v),
                ),
                _buildEditableRow(
                  label: l10n.t('auction_fee'),
                  value: _auctionFee,
                  prefix: '\$',
                  onChanged: (v) => setState(() => _auctionFee = v),
                ),
                _buildEditableRow(
                  label: l10n.t('gate_fee'),
                  value: _gateFee,
                  prefix: '\$',
                  onChanged: (v) => setState(() => _gateFee = v),
                ),
                const Divider(),
                _buildTotalRow(
                  label: l10n.t('subtotal'),
                  value: '\$${auctionTotal.toStringAsFixed(0)}',
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSection(
              context,
              title: l10n.t('shipping_costs'),
              icon: Icons.local_shipping,
              color: Colors.blue,
              children: [
                _buildDropdownRow(
                  label: l10n.t('from'),
                  value: _selectedUsaPort,
                  items: AuctionData.usaPorts,
                  onChanged: (v) => setState(() => _selectedUsaPort = v!),
                ),
                _buildDropdownRow(
                  label: l10n.t('to'),
                  value: _selectedRuPort,
                  items: AuctionData.ruPorts,
                  onChanged: (v) => setState(() => _selectedRuPort = v!),
                ),
                const Divider(),
                _buildEditableRow(
                  label: l10n.t('shipping_to_port'),
                  value: _inlandShipping,
                  prefix: '\$',
                  onChanged: (v) => setState(() => _inlandShipping = v),
                ),
                _buildEditableRow(
                  label: l10n.t('ocean_freight'),
                  value: _oceanShipping,
                  prefix: '\$',
                  onChanged: (v) => setState(() => _oceanShipping = v),
                ),
                _buildEditableRow(
                  label: l10n.t('port_fees'),
                  value: _portFees,
                  prefix: '\$',
                  onChanged: (v) => setState(() => _portFees = v),
                ),
                const Divider(),
                _buildTotalRow(
                  label: l10n.t('subtotal'),
                  value: '\$${shippingTotal.toStringAsFixed(0)}',
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSection(
              context,
              title: l10n.t('customs_costs'),
              icon: Icons.account_balance,
              color: Colors.orange,
              children: [
                _buildInfoRow(
                  l10n.t('usd_rate'),
                  '₽${usdRate.toStringAsFixed(2)}',
                ),
                const Divider(),
                _buildInfoRow(
                  l10n.t('customs_duty'),
                  '₽${_formatNumber(_customsDuty)}',
                ),
                _buildEditableRow(
                  label: l10n.t('recycling_fee'),
                  value: _recyclingFee,
                  prefix: '₽',
                  onChanged: (v) => setState(() => _recyclingFee = v),
                ),
                _buildEditableRow(
                  label: l10n.t('broker_fee'),
                  value: _brokerFee,
                  prefix: '₽',
                  onChanged: (v) => setState(() => _brokerFee = v),
                ),
                const Divider(),
                _buildTotalRow(
                  label: l10n.t('subtotal'),
                  value: '₽${_formatNumber(customsTotal)}',
                ),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.t('total_cost'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₽${_formatNumber(totalRub)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '≈ \$${_formatNumber(totalRub / usdRate)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildSection(
              context,
              title: l10n.t('potential_profit'),
              icon: Icons.trending_up,
              color: Colors.green,
              children: [
                _buildEditableRow(
                  label: l10n.t('market_price'),
                  value: _marketPrice,
                  prefix: '₽',
                  hint: l10n.t('market_price'),
                  onChanged: (v) => setState(() => _marketPrice = v),
                ),
                if (_marketPrice > 0) ...[
                  const Divider(),
                  _buildTotalRow(
                    label: l10n.t('profit'),
                    value: '₽${_formatNumber(profit)}',
                    valueColor: profit >= 0 ? Colors.green : Colors.red,
                  ),
                  _buildInfoRow(
                    l10n.t('margin'),
                    '${profitPercent.toStringAsFixed(1)}%',
                    valueStyle: TextStyle(
                      color: profit >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCarHeader(BuildContext context, LotModel lot, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.directions_car,
              color: theme.colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lot.fullName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${l10n.t('lot_number')}${lot.lotNumber} • ${lot.auction}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required List<Widget> children,
      }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
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

  Widget _buildEditableRow({
    required String label,
    required double value,
    required String prefix,
    String? hint,
    required void Function(double) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: value > 0 ? value.toStringAsFixed(0) : '',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                prefixText: prefix,
                hintText: hint ?? '0',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v) ?? 0;
                onChanged(parsed);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }

  Widget _buildTotalRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              isDense: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }
}