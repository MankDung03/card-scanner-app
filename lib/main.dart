import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/services/app_settings_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Chỉ dùng màn dọc: khung ngắm 91×55 + phép cắt ảnh camera và toàn bộ layout được thiết kế cho màn dọc.
  // (Android còn khoá trong AndroidManifest: screenOrientation="portrait" — tránh nháy xoay lúc mở app.)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
