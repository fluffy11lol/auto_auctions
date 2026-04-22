import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/services/notification_service.dart';
import '../data/models/lot_model.dart';
import '../data/repositories/lots_repository.dart';
import '../core/utils/fuzzy_search_helper.dart';

enum LotSortOption { dateNewest, priceAsc, priceDesc, yearNewest }

class LotsProvider extends ChangeNotifier {
  final LotsRepository _repository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  List<LotModel> _lots = [];
  bool _isLoading = false;
  StreamSubscription? _lotsSubscription;

  String _searchQuery = '';
  bool _showFavoritesOnly = false;
  LotSortOption _sortOption = LotSortOption.dateNewest;
  double? _minPrice;
  double? _maxPrice;
  int? _selectedYear;
  String? _selectedMake;

  LotsProvider(this._repository) {
    _loadLocalCache();
    _startFirestoreListening();
  }

  void _startFirestoreListening() {
    _lotsSubscription?.cancel();
    _lotsSubscription = _firestore
        .collection('lots')
        .snapshots()
        .listen((snapshot) async {

      List<LotModel> remoteLots = snapshot.docs.map((doc) {
        final data = doc.data();
        final localVersion = getLotById(doc.id);

        return _mapFirestoreToLot(data, doc.id, localVersion?.isFavorite ?? false);
      }).toList();

      await _repository.deleteAll();
      for (var lot in remoteLots) {
        await _repository.add(lot);
      }

      _lots = remoteLots;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Firestore Stream Error: $error');
    });
  }

  List<LotModel> get lots {
    Iterable<LotModel> filtered = _lots.where((lot) {
      final matchFavorite = !_showFavoritesOnly || lot.isFavorite;
      final matchPriceMin = _minPrice == null || lot.currentBid >= _minPrice!;
      final matchPriceMax = _maxPrice == null || lot.currentBid <= _maxPrice!;
      final matchYear = _selectedYear == null || lot.year == _selectedYear!;
      final matchMake = _selectedMake == null || lot.make == _selectedMake!;

      return matchFavorite && matchPriceMin && matchPriceMax && matchYear && matchMake;
    });

    List<LotModel> resultList = filtered.toList();

    switch (_sortOption) {
      case LotSortOption.dateNewest:
        resultList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case LotSortOption.priceAsc:
        resultList.sort((a, b) => a.currentBid.compareTo(b.currentBid));
        break;
      case LotSortOption.priceDesc:
        resultList.sort((a, b) => b.currentBid.compareTo(a.currentBid));
        break;
      case LotSortOption.yearNewest:
        resultList.sort((a, b) => b.year.compareTo(a.year));
        break;
    }

    if (_searchQuery.isNotEmpty) {
      resultList = FuzzySearchHelper.search(resultList, _searchQuery);
    }

    return resultList;
  }

  bool get isLoading => _isLoading;
  bool get showFavoritesOnly => _showFavoritesOnly;
  String get searchQuery => _searchQuery;
  LotSortOption get sortOption => _sortOption;
  int get totalCount => _lots.length;
  int get favoritesCount => _lots.where((l) => l.isFavorite).length;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  int? get selectedYear => _selectedYear;
  String? get selectedMake => _selectedMake;

  void setSearchQuery(String query) { _searchQuery = query; notifyListeners(); }
  void setSortOption(LotSortOption opt) { _sortOption = opt; notifyListeners(); }
  void setShowFavoritesOnly(bool val) { _showFavoritesOnly = val; notifyListeners(); }
  void setPriceRange(double? min, double? max) { _minPrice = min; _maxPrice = max; notifyListeners(); }
  void setFilters({int? year, String? make}) {
    if (year != null) _selectedYear = year;
    if (make != null) _selectedMake = make;
    notifyListeners();
  }
  void resetFilters() {
    _minPrice = null; _maxPrice = null; _selectedYear = null; _selectedMake = null;
    _searchQuery = ''; _showFavoritesOnly = false; _sortOption = LotSortOption.dateNewest;
    notifyListeners();
  }


  Future<void> addLot(LotModel lot, {List<File>? localFiles}) async {
    _isLoading = true;
    notifyListeners();

    final id = _uuid.v4();
    List<String> photos = lot.photos;

    try {
      if (localFiles != null && localFiles.isNotEmpty) {
        photos = await _processImagesToBase64(localFiles);
      }

      final newLot = lot.copyWith(
        id: id,
        photos: photos,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('lots').doc(id).set(_lotToMap(newLot));
    } catch (e) {
      debugPrint('Error adding lot to Firestore: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLot(LotModel lot) async {
    await _firestore.collection('lots').doc(lot.id).update(_lotToMap(lot.copyWith(updatedAt: DateTime.now())));
  }

  Future<void> deleteLot(String id) async {
    await _firestore.collection('lots').doc(id).delete();
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

  Future<void> clearAll() async {
    final snapshots = await _firestore.collection('lots').get();
    final batch = _firestore.batch();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    await _repository.deleteAll();
    _lots = [];
    notifyListeners();
  }

  Future<List<String>> _processImagesToBase64(List<File> files) async {
    List<String> base64Strings = [];
    for (var file in files) {
      try {
        final bytes = await file.readAsBytes();
        String base64String = base64Encode(bytes);
        base64Strings.add("data:image/jpeg;base64,$base64String");
      } catch (e) {
        debugPrint('Error encoding image: $e');
      }
    }
    return base64Strings;
  }

  Future<void> _loadLocalCache() async {
    _lots = _repository.getAll();
    notifyListeners();
  }

  Future<void> refreshData() async {
    _startFirestoreListening();
  }

  final NotificationService _notificationService = NotificationService();

  Future<void> setAuctionReminder(String lotId) async {
    final lot = getLotById(lotId);
    if (lot != null) {
      await _notificationService.scheduleAuctionReminder(lot);
      await _notificationService.showImmediateNotification();
      notifyListeners();
    }
  }

  Future<void> removeAuctionReminder(String lotId) async {
    await _notificationService.cancelReminder(lotId);
    notifyListeners();
  }

  LotModel _mapFirestoreToLot(Map<String, dynamic> json, String id, bool isFav) {
    return LotModel(
      id: id,
      lotNumber: json['lotNumber'] ?? '',
      auction: json['auction'] ?? '',
      url: json['url'],
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      vin: json['vin'],
      currentBid: (json['currentBid'] as num).toDouble(),
      buyNowPrice: json['buyNowPrice'] != null ? (json['buyNowPrice'] as num).toDouble() : null,
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      primaryDamage: json['primaryDamage'] ?? '',
      titleType: json['titleType'] ?? '',
      photos: List<String>.from(json['photos'] ?? []),
      notes: json['notes'],
      saleDate: json['saleDate'] != null ? (json['saleDate'] as Timestamp).toDate() : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      isFavorite: isFav,
    );
  }

  Map<String, dynamic> _lotToMap(LotModel lot) {
    return {
      'lotNumber': lot.lotNumber,
      'auction': lot.auction,
      'url': lot.url,
      'make': lot.make,
      'model': lot.model,
      'year': lot.year,
      'vin': lot.vin,
      'currentBid': lot.currentBid,
      'buyNowPrice': lot.buyNowPrice,
      'state': lot.state,
      'city': lot.city,
      'primaryDamage': lot.primaryDamage,
      'titleType': lot.titleType,
      'photos': lot.photos,
      'saleDate': lot.saleDate != null ? Timestamp.fromDate(lot.saleDate!) : null,
      'createdAt': Timestamp.fromDate(lot.createdAt),
      'updatedAt': Timestamp.fromDate(lot.updatedAt),
    };
  }

  Future<void> seedDatabase() async {
    _isLoading = true;
    notifyListeners();

    final List<Map<String, dynamic>> mockData = [
      {
        'lotNumber': '54328761',
        'auction': 'Copart',
        'make': 'BMW',
        'model': 'X5 xDrive40i',
        'year': 2021,
        'currentBid': 15400.0,
        'buyNowPrice': 25000.0,
        'state': 'TX',
        'city': 'Dallas',
        'primaryDamage': 'Front End',
        'titleType': 'Salvage',
        'photos': ['https://images.unsplash.com/photo-1555215695-3004980ad54e?q=80&w=1000'],
        'saleDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 2))),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'lotNumber': '11223344',
        'auction': 'IAAI',
        'make': 'Mercedes-Benz',
        'model': 'E350 4MATIC',
        'year': 2020,
        'currentBid': 18500.0,
        'state': 'FL',
        'city': 'Miami',
        'primaryDamage': 'Side',
        'titleType': 'Salvage',
        'photos': ['https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?q=80&w=1000'],
        'saleDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'lotNumber': '88776655',
        'auction': 'Copart',
        'make': 'Audi',
        'model': 'Q7 Prestige',
        'year': 2019,
        'currentBid': 12000.0,
        'buyNowPrice': 19000.0,
        'state': 'NY',
        'city': 'Long Island',
        'primaryDamage': 'Water/Flood',
        'titleType': 'Flood Title',
        'photos': ['https://images.unsplash.com/photo-1541348263662-e0c86433610a?q=80&w=1000'],
        'saleDate': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 18))),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'lotNumber': '44332211',
        'auction': 'IAAI',
        'make': 'Tesla',
        'model': 'Model 3 Long Range',
        'year': 2022,
        'currentBid': 21000.0,
        'state': 'CA',
        'city': 'Los Angeles',
        'primaryDamage': 'Rear End',
        'titleType': 'Clean Title',
        'photos': ['https://images.unsplash.com/photo-1560958089-b8a1929cea89?q=80&w=1000'],
        'saleDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'lotNumber': '99001122',
        'auction': 'Copart',
        'make': 'Ford',
        'model': 'F-150 XLT',
        'year': 2023,
        'currentBid': 28000.0,
        'state': 'GA',
        'city': 'Atlanta',
        'primaryDamage': 'Hail',
        'titleType': 'Clean Title',
        'photos': ['https://images.unsplash.com/photo-1583121274602-3e2820c69888?q=80&w=1000'],
        'saleDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'lotNumber': '77665544',
        'auction': 'IAAI',
        'make': 'Porsche',
        'model': '911 Carrera S',
        'year': 2021,
        'currentBid': 65000.0,
        'buyNowPrice': 85000.0,
        'state': 'NV',
        'city': 'Las Vegas',
        'primaryDamage': 'Minor Dents',
        'titleType': 'Clean Title',
        'photos': ['https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=1000'],
        'saleDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 4, hours: 2))),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      }
    ];

    try {
      final batch = _firestore.batch();
      for (var data in mockData) {
        final docRef = _firestore.collection('lots').doc();
        batch.set(docRef, data);
      }
      await batch.commit();
      debugPrint('Database seeded successfully with ${mockData.length} cars!');
    } catch (e) {
      debugPrint('Seed error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  LotModel? getLotById(String id) {
    try { return _lots.firstWhere((lot) => lot.id == id); } catch (e) { return null; }
  }

  @override
  void dispose() {
    _lotsSubscription?.cancel();
    super.dispose();
  }
}