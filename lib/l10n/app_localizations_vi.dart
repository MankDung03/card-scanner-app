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
  String get offlineBadge => '100% On-device · Offline';

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

  @override
  String get frontSide => 'Mặt trước';

  @override
  String get backSide => 'Mặt sau';

  @override
  String get alignCardTitle => 'Đặt danh thiếp vừa khung';

  @override
  String get alignCardSubtitle =>
      'Khung tỉ lệ 91 × 55 mm · giữ máy song song với thẻ';

  @override
  String get stepFront => '1 - Mặt trước';

  @override
  String get stepBackOptional => '2 - Mặt sau (tuỳ chọn)';

  @override
  String get gallery => 'Thư viện';

  @override
  String get cropAction => 'Cắt ảnh';

  @override
  String get cropTitle => 'Căn chỉnh ảnh';

  @override
  String get changePhoto => 'Đổi ảnh';

  @override
  String get autoDetectedSuccess =>
      'Đã tự nhận khung thẻ · kéo 4 góc nếu chưa khớp';

  @override
  String get rotate => 'Xoay';

  @override
  String get autoAlign => 'Tự động';

  @override
  String get addBackSide => 'Thêm mặt sau';

  @override
  String get recognizeText => 'Nhận dạng chữ';

  @override
  String get cameraPermissionRequired =>
      'Cần cấp quyền truy cập máy ảnh để chụp danh thiếp';

  @override
  String get grantPermission => 'Cấp quyền';

  @override
  String get cameraInitError => 'Không thể khởi động camera';

  @override
  String get processing => 'Đang xử lý ảnh...';

  @override
  String get ocrProcessing => 'Đang nhận dạng chữ trên thẻ...';

  @override
  String get ocrSuccess => 'Nhận dạng chữ thành công';

  @override
  String ocrBlocksCount(Object count) {
    return '$count khối chữ';
  }

  @override
  String ocrLinesCount(Object count) {
    return '$count dòng chữ';
  }

  @override
  String get visualTab => 'Trực quan';

  @override
  String get rawTextTab => 'Văn bản thô';

  @override
  String get blocksTab => 'Khối chữ & Tọa độ';

  @override
  String get copyRawText => 'Sao chép toàn bộ text';

  @override
  String get copiedToClipboard => 'Đã sao chép vào bộ nhớ tạm';

  @override
  String get noTextDetected => 'Không nhận diện được chữ nào trong ảnh';
}
