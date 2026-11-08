enum AppThemeType {
  system,
  light,
  dark,
  amoled,
}

class AppSettings {
  final AppThemeType themeMode;
  final String locale; // 'hi' or 'en'
  final bool autoSave;
  final int autoSaveIntervalSeconds;
  final double fontSize;

  const AppSettings({
    this.themeMode = AppThemeType.system,
    this.locale = 'hi',
    this.autoSave = false,
    this.autoSaveIntervalSeconds = 30,
    this.fontSize = 14.0,
  });

  AppSettings copyWith({
    AppThemeType? themeMode,
    String? locale,
    bool? autoSave,
    int? autoSaveIntervalSeconds,
    double? fontSize,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      autoSave: autoSave ?? this.autoSave,
      autoSaveIntervalSeconds: autoSaveIntervalSeconds ?? this.autoSaveIntervalSeconds,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'locale': locale,
        'autoSave': autoSave,
        'autoSaveIntervalSeconds': autoSaveIntervalSeconds,
        'fontSize': fontSize,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        themeMode: AppThemeType.values.firstWhere(
          (m) => m.name == json['themeMode'],
          orElse: () => AppThemeType.system,
        ),
        locale: json['locale'] as String? ?? 'hi',
        autoSave: json['autoSave'] as bool? ?? false,
        autoSaveIntervalSeconds: json['autoSaveIntervalSeconds'] as int? ?? 30,
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      );
}

