import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/app_settings_storage.dart';

class AppLocaleCubit extends Cubit<Locale?> {
  final AppSettingsStorage? _storage;

  /// State `null` = theo ngôn ngữ của máy (mặc định lần đầu mở app).
  /// Máy dùng ngôn ngữ app chưa hỗ trợ → Flutter chọn ngôn ngữ đầu tiên trong
  /// `supportedLocales` (English).
  AppLocaleCubit({AppSettingsStorage? storage})
      : _storage = storage,
        super(storage?.locale);

  Future<void> setLocale(Locale? locale) async {
    emit(locale);
    try {
      await _storage?.setLocale(locale);
    } catch (e) {
      debugPrint('AppLocaleCubit: cannot save locale: $e');
    }
  }
}
