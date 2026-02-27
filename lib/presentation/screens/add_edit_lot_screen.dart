import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/auction_data.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/lot_model.dart';
import '../../providers/lots_provider.dart';

class AddEditLotScreen extends StatefulWidget {
  final String? lotId; // if null => adding new lot, else editing existing

  const AddEditLotScreen({super.key, this.lotId});

  @override
  State<AddEditLotScreen> createState() => _AddEditLotScreenState();
}

class _AddEditLotScreenState extends State<AddEditLotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _lotNumberController;
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _vinController;
  late TextEditingController _mileageController;
  late TextEditingController _engineController;
  late TextEditingController _currentBidController;
  late TextEditingController _buyNowController;
  late TextEditingController _cityController;
  late TextEditingController _notesController;

  String _selectedAuction = 'Copart';
  String _selectedState = 'TX';
  String _selectedDamage = 'Front End';
  String _selectedTitleType = 'Salvage';
  String _selectedTransmission = 'Automatic';
  String _selectedDrivetrain = 'AWD';
  String _selectedFuelType = 'Gasoline';

  bool _hasKeys = true;
  bool _runsDrives = true;

  bool get _isEditing => widget.lotId != null;

  @override
  void initState() {
    super.initState();

    _lotNumberController = TextEditingController();
    _makeController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController(text: '2022');
    _vinController = TextEditingController();
    _mileageController = TextEditingController();
    _engineController = TextEditingController();
    _currentBidController = TextEditingController();
    _buyNowController = TextEditingController();
    _cityController = TextEditingController();
    _notesController = TextEditingController();

    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadLotData();
      });
    }
  }

  void _loadLotData() {
    final lot = context.read<LotsProvider>().getLotById(widget.lotId!);
    if (lot != null) {
      setState(() {
        _lotNumberController.text = lot.lotNumber;
        _makeController.text = lot.make;
        _modelController.text = lot.model;
        _yearController.text = lot.year.toString();
        _vinController.text = lot.vin ?? '';
        _mileageController.text = lot.mileage?.toString() ?? '';
        _engineController.text = lot.engine ?? '';
        _currentBidController.text = lot.currentBid.toStringAsFixed(0);
        _buyNowController.text = lot.buyNowPrice?.toStringAsFixed(0) ?? '';
        _cityController.text = lot.city;
        _notesController.text = lot.notes ?? '';

        _selectedAuction = lot.auction;
        _selectedState = lot.state;
        _selectedDamage = lot.primaryDamage;
        _selectedTitleType = lot.titleType;
        _selectedTransmission = lot.transmission ?? 'Automatic';
        _selectedDrivetrain = lot.drivetrain ?? 'AWD';
        _selectedFuelType = lot.fuelType ?? 'Gasoline';

        _hasKeys = lot.hasKeys;
        _runsDrives = lot.runsDrives;
      });
    }
  }

  @override
  void dispose() {
    _lotNumberController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _mileageController.dispose();
    _engineController.dispose();
    _currentBidController.dispose();
    _buyNowController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.t('edit_lot') : l10n.t('add_lot')),
        actions: [
          TextButton(
            onPressed: _saveLot,
            child: Text(
              l10n.t('save'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Auction Info'),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: l10n.t('auction'),
                    value: _selectedAuction,
                    items: AuctionData.auctions,
                    onChanged: (v) => setState(() => _selectedAuction = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _lotNumberController,
                    label: l10n.t('lot_number'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Vehicle Info'),
            const SizedBox(height: 8),

            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return AuctionData.popularMakes;
                }
                return AuctionData.popularMakes.where(
                  (make) => make.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              onSelected: (selection) {
                _makeController.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                if (_makeController.text.isNotEmpty &&
                    controller.text.isEmpty) {
                  controller.text = _makeController.text;
                }
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(labelText: l10n.t('make')),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onChanged: (v) => _makeController.text = v,
                );
              },
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller: _modelController,
              label: l10n.t('model'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _yearController,
                    label: l10n.t('year'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Required';
                      final year = int.tryParse(v);
                      if (year == null || year < 1900 || year > 2030) {
                        return 'Invalid year';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _mileageController,
                    label: l10n.t('mileage'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller: _vinController,
              label: l10n.t('vin'),
              textCapitalization: TextCapitalization.characters,
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller: _engineController,
              label: l10n.t('engine'),
              hint: 'e.g. 3.0L I6 Turbo',
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: l10n.t('transmission'),
                    value: _selectedTransmission,
                    items: AuctionData.transmissionTypes,
                    onChanged: (v) =>
                        setState(() => _selectedTransmission = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    label: l10n.t('drivetrain'),
                    value: _selectedDrivetrain,
                    items: AuctionData.drivetrainTypes,
                    onChanged: (v) => setState(() => _selectedDrivetrain = v!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildDropdown(
              label: l10n.t('fuel_type'),
              value: _selectedFuelType,
              items: AuctionData.fuelTypes,
              onChanged: (v) => setState(() => _selectedFuelType = v!),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Price & Location'),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _currentBidController,
                    label: l10n.t('current_bid'),
                    keyboardType: TextInputType.number,
                    prefix: '\$ ',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _buyNowController,
                    label: l10n.t('buy_now'),
                    keyboardType: TextInputType.number,
                    prefix: '\$ ',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    label: 'State',
                    value: _selectedState,
                    items: AuctionData.usStates.keys.toList(),
                    onChanged: (v) => setState(() => _selectedState = v!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Damage & Condition'),
            const SizedBox(height: 8),

            _buildDropdown(
              label: l10n.t('primary_damage'),
              value: _selectedDamage,
              items: AuctionData.damageTypes,
              onChanged: (v) => setState(() => _selectedDamage = v!),
            ),

            const SizedBox(height: 12),

            _buildDropdown(
              label: l10n.t('title_type'),
              value: _selectedTitleType,
              items: AuctionData.titleTypes,
              onChanged: (v) => setState(() => _selectedTitleType = v!),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text(l10n.t('has_keys')),
                    value: _hasKeys,
                    onChanged: (v) => setState(() => _hasKeys = v!),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text(l10n.t('runs_drives')),
                    value: _runsDrives,
                    onChanged: (v) => setState(() => _runsDrives = v!),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Notes'),
            const SizedBox(height: 8),

            _buildTextField(
              controller: _notesController,
              label: 'Your notes',
              maxLines: 4,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveLot,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isEditing ? 'Update Lot' : 'Add Lot',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? prefix,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
      ),
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _saveLot() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final provider = context.read<LotsProvider>();

    final lot = LotModel(
      id: _isEditing ? widget.lotId! : _uuid.v4(),
      lotNumber: _lotNumberController.text,
      auction: _selectedAuction,
      make: _makeController.text,
      model: _modelController.text,
      year: int.parse(_yearController.text),
      vin: _vinController.text.isEmpty ? null : _vinController.text,
      mileage: int.tryParse(_mileageController.text),
      engine: _engineController.text.isEmpty ? null : _engineController.text,
      transmission: _selectedTransmission,
      drivetrain: _selectedDrivetrain,
      fuelType: _selectedFuelType,
      currentBid: double.parse(_currentBidController.text),
      buyNowPrice: double.tryParse(_buyNowController.text),
      state: _selectedState,
      city: _cityController.text,
      primaryDamage: _selectedDamage,
      titleType: _selectedTitleType,
      hasKeys: _hasKeys,
      runsDrives: _runsDrives,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      photos: [],
      createdAt: _isEditing
          ? provider.getLotById(widget.lotId!)?.createdAt ?? now
          : now,
      updatedAt: now,
    );

    if (_isEditing) {
      provider.updateLot(lot);
    } else {
      provider.addLot(lot);
    }

    context.go('/catalog');
  }
}
