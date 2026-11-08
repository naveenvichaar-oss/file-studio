import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/models/app_settings.dart';
import '../../l10n/generated/app_localizations.dart';
import 'app_lock_page.dart';
import '../../shared/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Appearance Section
          ListTile(
            title: Text(
              'दिखावट एवं थीम (Appearance)',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          RadioGroup<AppThemeType>(
            groupValue: settings.themeMode,
            onChanged: (val) {
              if (val != null) notifier.setTheme(val);
            },
            child: Column(
              children: [
                RadioListTile<AppThemeType>(
                  title: Text(l10n.systemTheme),
                  subtitle: const Text('सिस्टम के अनुसार स्वतः बदलेगा'),
                  value: AppThemeType.system,
                ),
                RadioListTile<AppThemeType>(
                  title: Text(l10n.lightTheme),
                  value: AppThemeType.light,
                ),
                RadioListTile<AppThemeType>(
                  title: Text(l10n.darkTheme),
                  value: AppThemeType.dark,
                ),
                RadioListTile<AppThemeType>(
                  title: const Text('AMOLED डार्क (Pure Black)'),
                  subtitle: const Text('बैटरी बचत के लिए गहरा काला'),
                  value: AppThemeType.amoled,
                ),
              ],
            ),
          ),

          const Divider(),

          // Language Section
          ListTile(
            title: Text(
              l10n.language,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          RadioGroup<String>(
            groupValue: settings.locale,
            onChanged: (val) {
              if (val != null) notifier.setLocale(val);
            },
            child: const Column(
              children: [
                RadioListTile<String>(
                  title: Text('हिंदी (Hindi)'),
                  value: 'hi',
                ),
                RadioListTile<String>(
                  title: Text('English (अंग्रेज़ी)'),
                  value: 'en',
                ),
              ],
            ),
          ),

          const Divider(),

          // Editor & Save Preferences
          ListTile(
            title: Text(
              'एडिटर व सुरक्षा विकल्प',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('ऑटो-सेव (Auto-save)'),
            subtitle: const Text('एडिट मोड में बदलाव स्वतः सहेजें'),
            value: settings.autoSave,
            onChanged: (val) => notifier.setAutoSave(val),
          ),
          ListTile(
            title: Text(l10n.fontSize),
            subtitle: Text('${settings.fontSize.toInt()} pt'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: settings.fontSize > 10
                      ? () => notifier.setFontSize(settings.fontSize - 1)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: settings.fontSize < 30
                      ? () => notifier.setFontSize(settings.fontSize + 1)
                      : null,
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('ऐप लॉक (PIN Security)'),
            subtitle: const Text('निजी फाइलों के लिए 4-अंकीय सुरक्षा PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AppLockPage()),
              );
            },
          ),

          const Divider(),

          // About Section
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(AppConstants.appName),
            subtitle: Text('वर्ज़न ${AppConstants.appVersion} · सुरक्षित मोबाइल फ़ाइल मैनेजर एवं एडिटर'),
          ),
        ],
      ),
    );
  }
}
