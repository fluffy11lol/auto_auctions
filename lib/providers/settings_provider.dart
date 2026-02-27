import 'package:flutter/material.dart';
import '../data/models/settings_model.dart';
import '../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  late SettingsModel _settings;

  SettingsProvider(this._repository) {
    _settings = _repository.settings;
  }

  ThemeMode get themeMode {
    switch (_settings.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Locale get locale => Locale(_settings.languageCode);
  double get usdRate => _settings.usdRate;
  double get eurRate => _settings.eurRate;

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

  Future<void> setUsdRate(double rate) async {
    _settings = _settings.copyWith(usdRate: rate);
    await _repository.save(_settings);
    notifyListeners();
  }

  Future<void> setEurRate(double rate) async {
    _settings = _settings.copyWith(eurRate: rate);
    await _repository.save(_settings);
    notifyListeners();
  }
}