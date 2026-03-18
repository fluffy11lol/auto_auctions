import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/models/lot_model.dart';
import '../data/repositories/lots_repository.dart';
import '../core/api_config.dart';

class LotsProvider extends ChangeNotifier {
  final LotsRepository _repository;
  final Dio _dio = Dio();
  final _uuid = const Uuid();

  List<LotModel> _lots = [];
  String _searchQuery = '';
  bool _showFavoritesOnly = false;
  bool _isLoading = false;

  LotsProvider(this._repository) {
    _loadLots();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        debugPrint('LotsProvider: Internet restored, syncing with server...');
        _syncWithServer();
      }
    });
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
    notifyListeners();

    await _syncWithServer();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _syncWithServer() async {
    try {
      final response = await _dio.get('${ApiConfig.baseUrl}/lots').timeout(
        const Duration(seconds: 4),
      );

      if (response.statusCode == 200) {
        final List data = response.data;

        final List<LotModel> remoteLots = data.map((json) {
          final localVersion = getLotById(json['id']);

          return LotModel(
            id: json['id'],
            lotNumber: json['lotNumber'] ?? '',
            auction: json['auction'] ?? 'Unknown',
            url: json['url'],
            make: json['make'] ?? '',
            model: json['model'] ?? '',
            year: json['year'] ?? 0,
            vin: json['vin'],
            currentBid: (json['currentBid'] as num).toDouble(),
            state: json['state'] ?? '',
            city: json['city'] ?? '',
            primaryDamage: json['primaryDamage'] ?? 'None',
            runsDrives: json['runsDrives'] ?? true,
            hasKeys: json['hasKeys'] ?? true,
            titleType: json['titleType'] ?? 'Unknown',
            photos: List<String>.from(json['photos'] ?? []),
            notes: json['notes'],
            isFavorite: localVersion?.isFavorite ?? false,
            createdAt: localVersion?.createdAt ?? DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }).toList();

        await _repository.deleteAll();
        for (var lot in remoteLots) {
          await _repository.add(lot);
        }

        _lots = _repository.getAll();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Sync failed (offline or server down): $e');
    }
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

  Future<void> refreshData() async {
    await _syncWithServer();
  }

  Future<void> reloadMockData() async {
    _isLoading = true;
    notifyListeners();
    await _repository.deleteAll();
    await _syncWithServer();
    _isLoading = false;
    notifyListeners();
  }
}