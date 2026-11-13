import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/app_settings_storage.dart';

/// Thời điểm sao lưu gần nhất (hiện ở Cài đặt → バックアップ); null = chưa sao lưu lần nào.
class BackupCubit extends Cubit<DateTime?> {
  final AppSettingsStorage? _storage;

  BackupCubit({AppSettingsStorage? storage})
      : _storage = storage,
        super(storage?.lastBackupAt);

  Future<void> markBackedUp(DateTime at) async {
    emit(at);
    try {
      await _storage?.setLastBackupAt(at);
    } catch (e) {
      debugPrint('BackupCubit: cannot save: $e');
    }
  }
}
