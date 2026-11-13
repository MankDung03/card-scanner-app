import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/scan/domain/entities/ocr_language_mode.dart';
import '../services/app_settings_storage.dart';

/// Ngôn ngữ ưu tiên khi đọc chữ trên danh thiếp (Cài đặt → 優先する読み取り言語).
/// Mặc định [OcrLanguageMode.auto]; được lưu lại sau khi tắt app.
class OcrLanguageCubit extends Cubit<OcrLanguageMode> {
  final AppSettingsStorage? _storage;

  OcrLanguageCubit({AppSettingsStorage? storage})
      : _storage = storage,
        super(_read(storage));

  static OcrLanguageMode _read(AppSettingsStorage? storage) {
    final name = storage?.ocrLanguage;
    return OcrLanguageMode.values.firstWhere((m) => m.name == name, orElse: () => OcrLanguageMode.auto);
  }

  Future<void> setMode(OcrLanguageMode mode) async {
    emit(mode);
    try {
      await _storage?.setOcrLanguage(mode.name);
    } catch (e) {
      debugPrint('OcrLanguageCubit: cannot save: $e');
    }
  }
}
