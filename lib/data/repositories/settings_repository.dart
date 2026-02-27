import 'package:hive/hive.dart';
import '../models/settings_model.dart';

class SettingsRepository {
  static const String _key = 'app_settings';

  Box<SettingsModel> get _box => Hive.box<SettingsModel>('settings');

  SettingsModel get settings {
    return _box.get(_key) ?? SettingsModel();
  }

  Future<void> save(SettingsModel settings) async {
    await _box.put(_key, settings);
  }
}