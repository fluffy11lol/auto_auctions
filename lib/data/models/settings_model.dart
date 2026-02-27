import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 1)
class SettingsModel extends HiveObject {
  @HiveField(0)
  final String themeMode; // 'light', 'dark', 'system'

  @HiveField(1)
  final String languageCode; // 'en', 'ru'

  @HiveField(2)
  final double usdRate;

  @HiveField(3)
  final double eurRate;

  @HiveField(4)
  final String defaultPort;

  @HiveField(5)
  final double oceanShippingCost;

  @HiveField(6)
  final double portFees;

  SettingsModel({
    this.themeMode = 'system',
    this.languageCode = 'en',
    this.usdRate = 92.0,
    this.eurRate = 100.0,
    this.defaultPort = 'Vladivostok',
    this.oceanShippingCost = 2100,
    this.portFees = 300,
  });

  SettingsModel copyWith({
    String? themeMode,
    String? languageCode,
    double? usdRate,
    double? eurRate,
    String? defaultPort,
    double? oceanShippingCost,
    double? portFees,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      usdRate: usdRate ?? this.usdRate,
      eurRate: eurRate ?? this.eurRate,
      defaultPort: defaultPort ?? this.defaultPort,
      oceanShippingCost: oceanShippingCost ?? this.oceanShippingCost,
      portFees: portFees ?? this.portFees,
    );
  }
}