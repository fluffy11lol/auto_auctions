import 'package:fuzzy/fuzzy.dart';
import '../../../data/models/lot_model.dart';

class FuzzySearchHelper {
  static List<LotModel> search(List<LotModel> lots, String query) {
    if (query.isEmpty) return lots;

    final options = FuzzyOptions(
      findAllMatches: true,
      threshold: 0.4,
      keys: [
        WeightedKey(
          name: 'make',
          getter: (LotModel lot) => lot.make,
          weight: 1.0,
        ),
        WeightedKey(
          name: 'model',
          getter: (LotModel lot) => lot.model,
          weight: 0.8,
        ),
        WeightedKey(
          name: 'lotNumber',
          getter: (LotModel lot) => lot.lotNumber,
          weight: 0.5,
        ),
      ],
    );

    final fuse = Fuzzy<LotModel>(lots, options: options);
    final results = fuse.search(query);

    return results.map((r) => r.item).toList();
  }
}