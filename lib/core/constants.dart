class AppConstants {
  static const String appName = 'File Studio';
  static const String appVersion = '1.0.0';
  
  // Storage limits
  static const int largeFileSizeThreshold = 5 * 1024 * 1024; // 5 MB
  static const int maxRecentFiles = 50;
  static const int recycleBinRetentionDays = 30;
  
  // Storage keys
  static const String keyThemeMode = 'app_theme_mode';
  static const String keyLocale = 'app_locale';
  static const String keyAutoSave = 'app_auto_save';
  static const String keyAutoSaveInterval = 'app_auto_save_interval';
  static const String keyFontSize = 'editor_font_size';
  static const String keyRecents = 'recent_files';
  static const String keyFavorites = 'favorite_files';
}

