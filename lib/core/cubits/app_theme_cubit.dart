import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/app_settings_storage.dart';

class AppThemeCubit extends Cubit<ThemeMode> {
  final AppSettingsStorage? _storage;

  /// [storage] = null → chỉ giữ trong bộ nhớ (dùng cho test / preview)
  AppThemeCubit({AppSettingsStorage? storage})
      : _storage = storage,
        super(storage?.themeMode ?? ThemeMode.system);

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    try {
      await _storage?.setThemeMode(mode);
    } catch (e) {
      debugPrint('AppThemeCubit: cannot save theme: $e');
    }
  }
}
