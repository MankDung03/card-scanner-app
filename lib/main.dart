import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/services/app_settings_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Đọc cài đặt đã lưu trước khi vẽ màn đầu tiên (tránh nháy giao diện / ngôn ngữ)
  AppSettingsStorage? settings;
  try {
    settings = await AppSettingsStorage.load();
  } catch (e) {
    debugPrint('Cannot load settings, using defaults: $e');
  }

  // Set transparent system navigation & status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(BusinessCardScannerApp(settings: settings));
}
