import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/models/lot_model.dart';
import 'data/models/settings_model.dart';
import 'data/repositories/lots_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'providers/lots_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(LotModelAdapter());
  Hive.registerAdapter(SettingsModelAdapter());

  await Hive.openBox<LotModel>('lots');
  await Hive.openBox<SettingsModel>('settings');

  final lotsRepository = LotsRepository();
  final settingsRepository = SettingsRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsRepository),
        ),
        ChangeNotifierProvider(create: (_) => LotsProvider(lotsRepository)),
      ],
      child: const AutoAuctionsApp(),
    ),
  );
}
