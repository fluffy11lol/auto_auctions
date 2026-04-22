import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../providers/lots_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('settings'))),
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
                      title: Text(l10n.t('theme_light')),
                      secondary: const Icon(Icons.light_mode),
                      value: 'light',
                      groupValue: _getThemeValue(settings.themeMode),
                      onChanged: (v) => settings.setThemeMode(v!),
                    ),
                    RadioListTile<String>(
                      title: Text(l10n.t('theme_dark')),
                      secondary: const Icon(Icons.dark_mode),
                      value: 'dark',
                      groupValue: _getThemeValue(settings.themeMode),
                      onChanged: (v) => settings.setThemeMode(v!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildSectionTitle(context, l10n.t('currency')),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('USD → RUB'),
                      trailing: Text('₽ ${settings.usdRate.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ListTile(
                      title: const Text('EUR → RUB'),
                      trailing: Text('₽ ${settings.eurRate.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: settings.isUpdatingRates
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.sync),
                      title: const Text('Sync Exchange Rates'),
                      onTap: settings.isUpdatingRates ? null : () => settings.updateRates(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildSectionTitle(context, 'Account'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(FirebaseAuth.instance.currentUser?.email ?? 'User'),
                      subtitle: const Text('Logged in via Firebase'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          context.go('/');
                        }
                      },
                    ),
                  ],
                ),
              ),
              _buildSectionTitle(context, l10n.t('data')),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cloud_upload, color: Colors.blue),
                      title: const Text('Seed Firebase Database'),
                      subtitle: const Text('Add mock cars to Cloud Firestore'),
                      onTap: () async {
                        await context.read<LotsProvider>().seedDatabase();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Firebase Database Seeded!')),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: Text(l10n.t('clear_data'), style: const TextStyle(color: Colors.red)),
                      onTap: () => _confirmClear(context, l10n),
                    ),
                  ],
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
      child: Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
    );
  }

  String _getThemeValue(ThemeMode mode) => mode.toString().split('.').last;

  void _confirmClear(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('delete_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.t('cancel'))),
          TextButton(
            onPressed: () {
              context.read<LotsProvider>().clearAll();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}