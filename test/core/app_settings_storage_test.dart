import 'package:app_scanner_card/core/cubits/app_locale_cubit.dart';
import 'package:app_scanner_card/core/cubits/app_theme_cubit.dart';
import 'package:app_scanner_card/core/services/app_settings_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('first launch: follow system theme and device language', () async {
    final storage = await AppSettingsStorage.load();
    expect(storage.themeMode, ThemeMode.system);
    expect(storage.locale, isNull);

    expect(AppThemeCubit(storage: storage).state, ThemeMode.system);
    expect(AppLocaleCubit(storage: storage).state, isNull);
  });

  test('choices are restored after restarting the app', () async {
    final first = await AppSettingsStorage.load();
    await AppThemeCubit(storage: first).setThemeMode(ThemeMode.dark);
    await AppLocaleCubit(storage: first).setLocale(const Locale('ja'));

    // "Khởi động lại": đọc lại từ SharedPreferences
    final restarted = await AppSettingsStorage.load();
    expect(AppThemeCubit(storage: restarted).state, ThemeMode.dark);
    expect(AppLocaleCubit(storage: restarted).state, const Locale('ja'));
  });

  test('setting locale back to null returns to device language', () async {
    final storage = await AppSettingsStorage.load();
    final cubit = AppLocaleCubit(storage: storage);
    await cubit.setLocale(const Locale('en'));
    await cubit.setLocale(null);

    expect((await AppSettingsStorage.load()).locale, isNull);
  });

  test('unknown stored theme value falls back to system', () async {
    SharedPreferences.setMockInitialValues({'settings.theme_mode': 'purple'});
    expect((await AppSettingsStorage.load()).themeMode, ThemeMode.system);
  });

  test('cubits without storage still work in memory', () async {
    final theme = AppThemeCubit();
    await theme.setThemeMode(ThemeMode.light);
    expect(theme.state, ThemeMode.light);
  });
}
