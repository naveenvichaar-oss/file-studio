import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../data/models/app_settings.dart';
import '../data/models/file_entry.dart';
import '../data/models/recycle_item.dart';
import '../data/repositories/file_repository.dart';
import '../data/repositories/recycle_repository.dart';
import '../data/repositories/version_repository.dart';
import '../data/storage/file_gateway.dart';
import '../data/storage/local_file_gateway.dart';

// Gateways & Repositories
final fileGatewayProvider = Provider<FileGateway>((ref) {
  return LocalFileGateway();
});

final versionRepositoryProvider = Provider<VersionRepository>((ref) {
  return VersionRepository();
});

final recycleRepositoryProvider = Provider<RecycleRepository>((ref) {
  return RecycleRepository();
});

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  return FileRepository(
    ref.watch(fileGatewayProvider),
    ref.watch(versionRepositoryProvider),
    ref.watch(recycleRepositoryProvider),
  );
});

// App Settings Notifier
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(AppConstants.keyThemeMode);
    final locale = prefs.getString(AppConstants.keyLocale) ?? 'hi';
    final autoSave = prefs.getBool(AppConstants.keyAutoSave) ?? false;
    final interval = prefs.getInt(AppConstants.keyAutoSaveInterval) ?? 30;
    final fontSize = prefs.getDouble(AppConstants.keyFontSize) ?? 14.0;

    final themeMode = AppThemeType.values.firstWhere(
      (m) => m.name == themeStr,
      orElse: () => AppThemeType.system,
    );

    state = AppSettings(
      themeMode: themeMode,
      locale: locale,
      autoSave: autoSave,
      autoSaveIntervalSeconds: interval,
      fontSize: fontSize,
    );
  }

  Future<void> setTheme(AppThemeType mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyThemeMode, mode.name);
  }

  Future<void> setLocale(String localeCode) async {
    state = state.copyWith(locale: localeCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLocale, localeCode);
  }

  Future<void> setAutoSave(bool enabled) async {
    state = state.copyWith(autoSave: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyAutoSave, enabled);
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyFontSize, size);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

// Recents Provider
final recentsProvider = FutureProvider<List<FileEntry>>((ref) async {
  final repo = ref.watch(fileRepositoryProvider);
  return repo.getRecents();
});

// Recycle Bin Items Provider
final recycleBinProvider = FutureProvider<List<RecycleItem>>((ref) async {
  final repo = ref.watch(recycleRepositoryProvider);
  return repo.getItems();
});

// Favorites Provider
final favoritesProvider = FutureProvider<Set<String>>((ref) async {
  final repo = ref.watch(fileRepositoryProvider);
  return repo.getFavorites();
});
