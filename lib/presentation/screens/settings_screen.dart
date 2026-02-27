import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../providers/lots_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('settings')),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            children: [
              const SizedBox(height: 16),

              _buildSectionTitle(context, l10n.t('theme')),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          const Icon(Icons.light_mode),
                          const SizedBox(width: 12),
                          Text(l10n.t('theme_light')),
                        ],
                      ),
                      value: 'light',
                      groupValue: _getThemeValue(settings.themeMode),
                      onChanged: (v) => settings.setThemeMode(v!),
                    ),
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          const Icon(Icons.dark_mode),
                          const SizedBox(width: 12),
                          Text(l10n.t('theme_dark')),
                        ],
                      ),
                      value: 'dark',
                      groupValue: _getThemeValue(settings.themeMode),
                      onChanged: (v) => settings.setThemeMode(v!),
                    ),
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          const Icon(Icons.settings_brightness),
                          const SizedBox(width: 12),
                          Text(l10n.t('theme_system')),
                        ],
                      ),
                      value: 'system',
                      groupValue: _getThemeValue(settings.themeMode),
                      onChanged: (v) => settings.setThemeMode(v!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildSectionTitle(context, l10n.t('language')),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Row(
                        children: [
                          Text('🇺🇸', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 12),
                          Text('English'),
                        ],
                      ),
                      value: 'en',
                      groupValue: settings.locale.languageCode,
                      onChanged: (v) => settings.setLanguage(v!),
                    ),
                    RadioListTile<String>(
                      title: const Row(
                        children: [
                          Text('🇷🇺', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 12),
                          Text('Русский'),
                        ],
                      ),
                      value: 'ru',
                      groupValue: settings.locale.languageCode,
                      onChanged: (v) => settings.setLanguage(v!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildSectionTitle(context, l10n.t('currency')),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Text('USD → RUB'),
                          ),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              initialValue: settings.usdRate.toStringAsFixed(2),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                prefixText: '₽ ',
                                isDense: true,
                              ),
                              onChanged: (v) {
                                final rate = double.tryParse(v);
                                if (rate != null && rate > 0) {
                                  settings.setUsdRate(rate);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Text('EUR → RUB'),
                          ),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              initialValue: settings.eurRate.toStringAsFixed(2),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                prefixText: '₽ ',
                                isDense: true,
                              ),
                              onChanged: (v) {
                                final rate = double.tryParse(v);
                                if (rate != null && rate > 0) {
                                  settings.setEurRate(rate);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildSectionTitle(context, l10n.t('data')),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.refresh),
                      title: Text(l10n.t('reload_mock')),
                      subtitle: Text(l10n.t('reload_mock_desc')),
                      onTap: () => _confirmReload(context, l10n),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: Text(
                        l10n.t('clear_data'),
                        style: const TextStyle(color: Colors.red),
                      ),
                      subtitle: Text(l10n.t('delete_all_lots')),
                      onTap: () => _confirmClear(context, l10n),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildSectionTitle(context, l10n.t('about')),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.directions_car,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.t('app_title'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.t('version')} 1.0.0',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.t('made_with'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }

  String _getThemeValue(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  void _confirmReload(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('reload_confirm')),
        content: Text(l10n.t('reload_confirm_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.t('cancel')),
          ),
          TextButton(
            onPressed: () {
              context.read<LotsProvider>().reloadMockData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.t('data_reloaded'))),
              );
            },
            child: Text(l10n.t('reload')),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('delete_confirm')),
        content: Text(l10n.t('delete_confirm_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.t('cancel')),
          ),
          TextButton(
            onPressed: () {
              context.read<LotsProvider>().clearAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.t('data_cleared'))),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.t('delete')),
          ),
        ],
      ),
    );
  }
}