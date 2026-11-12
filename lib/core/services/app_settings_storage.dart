import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lưu các cài đặt giao diện trên máy (giữ nguyên sau khi tắt app).
///
/// - Giao diện: light / dark / system (mặc định: system)
/// - Ngôn ngữ app: vi / en / ja; không có giá trị = theo ngôn ngữ máy (mặc định lần đầu)
class AppSettingsStorage {
  static const _themeKey = 'settings.theme_mode';
  static const _localeKey = 'settings.locale';

  final SharedPreferences _prefs;

  AppSettingsStorage(this._prefs);

  /// Đọc trước `runApp` để màn hình đầu tiên hiện đúng giao diện / ngôn ngữ, không bị nháy.
  static Future<AppSettingsStorage> load() async =>
      AppSettingsStorage(await SharedPreferences.getInstance());

  ThemeMode get themeMode => switch (_prefs.getString(_themeKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> setThemeMode(ThemeMode mode) => _prefs.setString(_themeKey, mode.name);

  /// `null` = theo ngôn ngữ của máy
  Locale? get locale {
    final code = _prefs.getString(_localeKey);
    return (code == null || code.isEmpty) ? null : Locale(code);
  }

  Future<void> setLocale(Locale? locale) => locale == null
      ? _prefs.remove(_localeKey)
      : _prefs.setString(_localeKey, locale.languageCode);
}
