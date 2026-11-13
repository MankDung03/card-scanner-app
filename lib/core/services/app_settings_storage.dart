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

  /// Cách sắp xếp danh sách danh thiếp (tên enum); `null` = chưa chọn
  String? get cardSortOrder => _prefs.getString(_cardSortKey);

  Future<void> setCardSortOrder(String value) => _prefs.setString(_cardSortKey, value);

  static const _cardSortKey = 'settings.card_sort_order';

  /// Ngôn ngữ ưu tiên khi đọc chữ (tên enum OcrLanguageMode); `null` = tự động
  String? get ocrLanguage => _prefs.getString(_ocrLanguageKey);

  Future<void> setOcrLanguage(String value) => _prefs.setString(_ocrLanguageKey, value);

  static const _ocrLanguageKey = 'settings.ocr_language';

  // ── Sao lưu ──
  static const _lastBackupKey = 'settings.last_backup_at';

  DateTime? get lastBackupAt => DateTime.tryParse(_prefs.getString(_lastBackupKey) ?? '');

  Future<void> setLastBackupAt(DateTime value) => _prefs.setString(_lastBackupKey, value.toIso8601String());

  // ── Nút chụp nổi (kéo thả) ──
  static const _captureFabVisibleKey = 'settings.capture_fab.visible';
  static const _captureFabRightKey = 'settings.capture_fab.right';
  static const _captureFabYKey = 'settings.capture_fab.y';

  /// Mặc định hiện
  bool get captureFabVisible => _prefs.getBool(_captureFabVisibleKey) ?? true;

  Future<void> setCaptureFabVisible(bool value) => _prefs.setBool(_captureFabVisibleKey, value);

  /// Mép đang bám: true = phải (mặc định)
  bool get captureFabOnRight => _prefs.getBool(_captureFabRightKey) ?? true;

  /// Vị trí dọc theo tỉ lệ 0 (trên cùng vùng cho phép) → 1 (dưới cùng); mặc định 1
  double get captureFabY => _prefs.getDouble(_captureFabYKey) ?? 1.0;

  Future<void> setCaptureFabPosition({required bool onRight, required double y}) async {
    await _prefs.setBool(_captureFabRightKey, onRight);
    await _prefs.setDouble(_captureFabYKey, y);
  }

  Future<void> resetCaptureFabPosition() async {
    await _prefs.remove(_captureFabRightKey);
    await _prefs.remove(_captureFabYKey);
  }
}
