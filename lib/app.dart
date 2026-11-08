import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'data/models/app_settings.dart';
import 'l10n/generated/app_localizations.dart';
import 'router.dart';
import 'shared/providers.dart';

class FileStudioApp extends ConsumerWidget {
  const FileStudioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    // Determine Theme
    ThemeData theme = AppTheme.lightTheme;
    ThemeData darkTheme = AppTheme.darkTheme;
    ThemeMode themeMode = ThemeMode.system;

    switch (settings.themeMode) {
      case AppThemeType.system:
        themeMode = ThemeMode.system;
        break;
      case AppThemeType.light:
        themeMode = ThemeMode.light;
        break;
      case AppThemeType.dark:
        themeMode = ThemeMode.dark;
        break;
      case AppThemeType.amoled:
        themeMode = ThemeMode.dark;
        darkTheme = AppTheme.amoledTheme;
        break;
    }

    return MaterialApp.router(
      title: 'फ़ाइल स्टूडियो (File Studio)',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: Locale(settings.locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
