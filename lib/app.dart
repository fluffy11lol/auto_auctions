import 'package:auto_auctions/core/l10n/app_localizations.dart';
import 'package:auto_auctions/core/theme/app_theme.dart';
import 'package:auto_auctions/presentation/screens/add_edit_lot_screen.dart';
import 'package:auto_auctions/presentation/screens/calculator_screen.dart';
import 'package:auto_auctions/presentation/screens/lot_details_screen.dart';
import 'package:auto_auctions/presentation/screens/lots_catalog_screen.dart';
import 'package:auto_auctions/presentation/screens/settings_screen.dart';
import 'package:auto_auctions/presentation/screens/splash_screen.dart';
import 'package:auto_auctions/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AutoAuctionsApp extends StatelessWidget {
  const AutoAuctionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp.router(
          title: 'Auto Auctions',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: const [Locale('en'), Locale('ru')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
        );
      },
    );
  }

  static final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/catalog',
        builder: (context, state) => const LotsCatalogScreen(),
      ),
      GoRoute(
        path: '/lot/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LotDetailsScreen(lotId: id);
        },
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddEditLotScreen(),
      ),
      GoRoute(
        path: '/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AddEditLotScreen(lotId: id);
        },
      ),
      GoRoute(
        path: '/calculator/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CalculatorScreen(lotId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
