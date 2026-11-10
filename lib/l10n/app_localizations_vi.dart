// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Scan Danh Thiếp';

  @override
  String get addCardTitle => 'Thêm danh thiếp';

  @override
  String get addCardSubtitle => 'Chọn cách lấy ảnh danh thiếp của bạn';

  @override
  String get captureCardTitle => 'Chụp ảnh';

  @override
  String get captureCardSubtitle => 'Mở camera, tự căn khung thẻ';

  @override
  String get galleryCardTitle => 'Chọn từ thư viện';

  @override
  String get galleryCardSubtitle => 'Dùng ảnh danh thiếp có sẵn trong máy';

  @override
  String get recentlySaved => 'Đã lưu gần đây';

  @override
  String viewAll(int count) {
    return 'Xem tất cả ($count)';
  }

  @override
  String get offlineBadge => 'Xử lý ngay trên máy · không cần mạng';

  @override
  String get today => 'Hôm nay';

  @override
  String get featureComingSoon =>
      'Chức năng sẽ được kích hoạt ở bước tiếp theo';

  @override
  String get settingsTitle => 'Cài đặt & Tùy chọn';

  @override
  String get themeTitle => 'Giao diện';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeSystem => 'Hệ thống';

  @override
  String get languageTitle => 'Ngôn ngữ';

  @override
  String get langVi => 'Tiếng Việt 🇻🇳';

  @override
  String get langJa => '日本語 🇯🇵';

  @override
  String get langEn => 'English 🇬🇧';
}
