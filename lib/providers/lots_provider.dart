import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/lot_model.dart';
import '../data/repositories/lots_repository.dart';
import '../data/mock/mock_lots.dart';

class LotsProvider extends ChangeNotifier {
  final LotsRepository _repository;
  final _uuid = const Uuid();

  List<LotModel> _lots = [];
  String _searchQuery = '';
  bool _showFavoritesOnly = false;
  bool _isLoading = false;

  LotsProvider(this._repository) {
    _loadLots();
  }

  List<LotModel> get lots {
    var result = _lots;

    if (_showFavoritesOnly) {
      result = result.where((lot) => lot.isFavorite).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((lot) {
        return lot.make.toLowerCase().contains(query) ||
            lot.model.toLowerCase().contains(query) ||
            lot.lotNumber.contains(query);
      }).toList();
    }

    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return result;
  }

  bool get isLoading => _isLoading;
  bool get showFavoritesOnly => _showFavoritesOnly;
  String get searchQuery => _searchQuery;
  int get totalCount => _lots.length;
  int get favoritesCount => _lots.where((l) => l.isFavorite).length;

  Future<void> _loadLots() async {
    _isLoading = true;
    notifyListeners();

    _lots = _repository.getAll();

    if (_lots.isEmpty) {
      await _addMockData();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _addMockData() async {
    final mockLots = MockLots.generate();
    for (final lot in mockLots) {
      await _repository.add(lot);
    }
    _lots = _repository.getAll();
  }

  LotModel? getLotById(String id) {
    try {
      return _lots.firstWhere((lot) => lot.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addLot(LotModel lot) async {
    final newLot = lot.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.add(newLot);
    _lots = _repository.getAll();
    notifyListeners();
  }

  Future<void> updateLot(LotModel lot) async {
    final updatedLot = lot.copyWith(updatedAt: DateTime.now());
    await _repository.update(updatedLot);
    _lots = _repository.getAll();
    notifyListeners();
  }

  Future<void> deleteLot(String id) async {
    await _repository.delete(id);
    _lots = _repository.getAll();
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final lot = getLotById(id);
    if (lot != null) {
      final updated = lot.copyWith(isFavorite: !lot.isFavorite);
      await _repository.update(updated);
      _lots = _repository.getAll();
      notifyListeners();
    }
  }

  void setShowFavoritesOnly(bool value) {
    _showFavoritesOnly = value;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repository.deleteAll();
    _lots = [];
    notifyListeners();
  }

  Future<void> reloadMockData() async {
    await _repository.deleteAll();
    await _addMockData();
    notifyListeners();
  }
}