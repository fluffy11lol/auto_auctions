import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/network/network_info.dart';
import 'core/services/currency_service.dart';
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

  final networkInfo = NetworkInfoImpl(Connectivity());
  final currencyService = CurrencyService();
  final settingsRepository = SettingsRepository();
  final lotsRepository = LotsRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsRepository, currencyService, networkInfo),
        ),
        ChangeNotifierProvider(create: (_) => LotsProvider(lotsRepository)),
        StreamProvider<ConnectivityResult>(
          create: (_) => Connectivity().onConnectivityChanged,
          initialData: ConnectivityResult.wifi,
          lazy: false,
        ),
      ],
      child: const AutoAuctionsApp(),
    ),
  );
}
