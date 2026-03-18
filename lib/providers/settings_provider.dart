import 'package:flutter/material.dart';
import '../data/models/settings_model.dart';
import '../data/repositories/settings_repository.dart';
import '../core/services/currency_service.dart';
import '../core/network/network_info.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  final CurrencyService _currencyService;
  final NetworkInfo _networkInfo;

  late SettingsModel _settings;
  bool _isUpdatingRates = false;

  SettingsProvider(this._repository, this._currencyService, this._networkInfo) {
    _settings = _repository.settings;
    // При запуске пробуем обновить курсы в фоне
    updateRates();
  }

  bool get isUpdatingRates => _isUpdatingRates;
  ThemeMode get themeMode => _settings.themeMode == 'light' ? ThemeMode.light : (_settings.themeMode == 'dark' ? ThemeMode.dark : ThemeMode.system);
  Locale get locale => Locale(_settings.languageCode);
  double get usdRate => _settings.usdRate;
  double get eurRate => _settings.eurRate;

  Future<void> updateRates() async {
    if (await _networkInfo.isConnected) {
      _isUpdatingRates = true;
      notifyListeners();

      try {
        final rates = await _currencyService.getLatestRates();
        _settings = _settings.copyWith(
          usdRate: rates['USD'],
          eurRate: rates['EUR'],
        );
        await _repository.save(_settings);
      } catch (e) {
        debugPrint('Rate update failed: $e');
      } finally {
        _isUpdatingRates = false;
        notifyListeners();
      }
    }
  }

  Future<void> setThemeMode(String mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _repository.save(_settings);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _settings = _settings.copyWith(languageCode: code);
    await _repository.save(_settings);
    notifyListeners();
  }
}