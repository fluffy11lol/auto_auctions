import 'package:hive/hive.dart';
import '../models/lot_model.dart';

class LotsRepository {
  Box<LotModel> get _box => Hive.box<LotModel>('lots');

  List<LotModel> getAll() {
    return _box.values.toList();
  }

  LotModel? getById(String id) {
    try {
      return _box.values.firstWhere((lot) => lot.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> add(LotModel lot) async {
    await _box.put(lot.id, lot);
  }

  Future<void> update(LotModel lot) async {
    await _box.put(lot.id, lot);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }

  List<LotModel> search(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values.where((lot) {
      return lot.make.toLowerCase().contains(lowerQuery) ||
          lot.model.toLowerCase().contains(lowerQuery) ||
          lot.lotNumber.contains(lowerQuery);
    }).toList();
  }

  List<LotModel> getFavorites() {
    return _box.values.where((lot) => lot.isFavorite).toList();
  }
}