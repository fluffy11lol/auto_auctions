import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/auction_data.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/lot_model.dart';
import '../../providers/lots_provider.dart';

class AddEditLotScreen extends StatefulWidget {
  final String? lotId;

  const AddEditLotScreen({super.key, this.lotId});

  @override
  State<AddEditLotScreen> createState() => _AddEditLotScreenState();
}

class _AddEditLotScreenState extends State<AddEditLotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

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
    _yearController = TextEditingController(text: '2024');
    _vinController = TextEditingController();
    _mileageController = TextEditingController();
    _engineController = TextEditingController();
    _currentBidController = TextEditingController();
    _buyNowController = TextEditingController();
    _cityController = TextEditingController();
    _notesController = TextEditingController();

    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadLotData());
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

  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 30,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera not available on this device/simulator'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.t('edit_lot') : l10n.t('add_lot')),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _saveLot)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Vehicle Photos'),
            const SizedBox(height: 12),
            _buildPhotoPicker(),
            const SizedBox(height: 24),

            _buildSectionTitle('Auction Info'),
            Row(
              children: [
                Expanded(child: _buildDropdown(label: 'Auction', value: _selectedAuction, items: AuctionData.auctions, onChanged: (v) => setState(() => _selectedAuction = v!))),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(controller: _lotNumberController, label: 'Lot #', keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Vehicle Info'),
            _buildTextField(controller: _makeController, label: 'Make', validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            _buildTextField(controller: _modelController, label: 'Model', validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField(controller: _yearController, label: 'Year', keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(controller: _mileageController, label: 'Mileage', keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Price & Location'),
            Row(
              children: [
                Expanded(child: _buildTextField(controller: _currentBidController, label: 'Current Bid', prefix: '\$ ', keyboardType: TextInputType.number, validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid price' : null)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(controller: _buyNowController, label: 'Buy Now', prefix: '\$ ', keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(flex: 2, child: _buildTextField(controller: _cityController, label: 'City', validator: (v) => v!.isEmpty ? 'Required' : null)),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown(label: 'State', value: _selectedState, items: AuctionData.usStates.keys.toList(), onChanged: (v) => setState(() => _selectedState = v!))),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Damage & Condition'),
            _buildDropdown(label: 'Primary Damage', value: _selectedDamage, items: AuctionData.damageTypes, onChanged: (v) => setState(() => _selectedDamage = v!)),
            const SizedBox(height: 12),
            _buildDropdown(label: 'Title Type', value: _selectedTitleType, items: AuctionData.titleTypes, onChanged: (v) => setState(() => _selectedTitleType = v!)),
            CheckboxListTile(title: const Text('Has Keys'), value: _hasKeys, onChanged: (v) => setState(() => _hasKeys = v!)),
            CheckboxListTile(title: const Text('Runs & Drives'), value: _runsDrives, onChanged: (v) => setState(() => _runsDrives = v!)),
            const SizedBox(height: 24),

            _buildSectionTitle('Notes'),
            _buildTextField(controller: _notesController, label: 'Notes', maxLines: 3),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _saveLot,
              child: Text(_isEditing ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length + 1,
        itemBuilder: (context, index) {
          if (index == _selectedImages.length) {
            return GestureDetector(onTap: _pickImage, child: Container(width: 100, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add_a_photo)));
          }
          return Container(width: 100, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: FileImage(_selectedImages[index]), fit: BoxFit.cover)));
        },
      ),
    );
  }

  void _saveLot() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    final double bid = double.tryParse(_currentBidController.text) ?? 0.0;
    final double? buyNow = double.tryParse(_buyNowController.text);
    final int year = int.tryParse(_yearController.text) ?? 2024;
    final int? mileage = int.tryParse(_mileageController.text);

    final provider = context.read<LotsProvider>();
    final lot = LotModel(
      id: _isEditing ? widget.lotId! : '',
      lotNumber: _lotNumberController.text,
      auction: _selectedAuction,
      make: _makeController.text,
      model: _modelController.text,
      year: year,
      currentBid: bid,
      buyNowPrice: buyNow,
      mileage: mileage,
      state: _selectedState,
      city: _cityController.text,
      primaryDamage: _selectedDamage,
      titleType: _selectedTitleType,
      hasKeys: _hasKeys,
      runsDrives: _runsDrives,
      notes: _notesController.text,
      photos: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_isEditing) {
      await provider.updateLot(lot);
    } else {
      await provider.addLot(lot, localFiles: _selectedImages);
    }

    if (mounted) {
      Navigator.pop(context);
      context.go('/catalog');
    }
  }

  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
  Widget _buildTextField({required TextEditingController controller, required String label, String? prefix, int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(controller: controller, decoration: InputDecoration(labelText: label, prefixText: prefix, border: const OutlineInputBorder()), keyboardType: keyboardType, maxLines: maxLines, validator: validator);
  }
  Widget _buildDropdown({required String label, required String value, required List<String> items, required void Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(value: value, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onChanged);
  }
}