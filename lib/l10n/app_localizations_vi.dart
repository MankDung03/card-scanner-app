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
  String get rawTextTab => 'Văn bản';

  @override
  String get blocksTab => 'Khối chữ';

  @override
  String get copyRawText => 'Sao chép toàn bộ text';

  @override
  String get copiedToClipboard => 'Đã sao chép vào bộ nhớ tạm';

  @override
  String get noTextDetected => 'Không nhận diện được chữ nào trong ảnh';

  @override
  String get verificationTitle => 'Kiểm tra thông tin';

  @override
  String get retake => 'Chụp lại';

  @override
  String detectedFieldsCount(int count) {
    return 'Đã nhận dạng $count mục';
  }

  @override
  String needsReviewCount(int count) {
    return '$count mục nên kiểm tra lại';
  }

  @override
  String get allClear => 'Mọi thông tin đều rõ ràng';

  @override
  String get byFieldsTab => 'Theo mục';

  @override
  String get originalTextTab => 'Văn bản gốc';

  @override
  String get fullName => 'Họ tên';

  @override
  String get furigana => 'Furigana';

  @override
  String get needsReviewTag => 'Kiểm tra lại';

  @override
  String get jobTitle => 'Chức vụ';

  @override
  String get company => 'Công ty';

  @override
  String get department => 'Phòng ban';

  @override
  String get phone => 'Điện thoại';

  @override
  String get mobile => 'Di động';

  @override
  String get fax => 'FAX';

  @override
  String get email => 'Email';

  @override
  String get address => 'Địa chỉ';

  @override
  String get website => 'Website';

  @override
  String get notOnCardPlaceholder => 'Không có trên thẻ — nhập nếu cần';

  @override
  String get saveCard => 'Lưu danh thiếp';

  @override
  String get editField => 'Chỉnh sửa thông tin';

  @override
  String get cancel => 'Hủy';

  @override
  String get done => 'Xong';

  @override
  String get cardSavedSuccess => 'Đã lưu danh thiếp thành công';

  @override
  String get cardSavedTitle => 'Đã lưu danh thiếp';

  @override
  String get cardSavedSubtitle => 'Đã lưu vào app trên máy này.';

  @override
  String get cardSaveFailed => 'Không thể lưu danh thiếp, vui lòng thử lại';

  @override
  String get optionalActions => 'Làm thêm (không bắt buộc)';

  @override
  String get saveToContacts => 'Lưu vào Danh bạ';

  @override
  String get addMeetingNote => 'Ghi chú gặp ở đâu';

  @override
  String get meetingNoteHint => 'VD: Gặp ở hội thảo tại Tokyo, 12/11';

  @override
  String get save => 'Lưu';

  @override
  String get noteSaved => 'Đã lưu ghi chú';

  @override
  String get scanAnotherCard => 'Scan danh thiếp khác';

  @override
  String get backToHome => 'Về trang chủ';

  @override
  String get unnamedCard => '(Chưa có tên)';

  @override
  String get noSavedCards => 'Chưa có danh thiếp nào. Hãy scan tấm đầu tiên!';

  @override
  String get savedCardsTitle => 'Danh thiếp đã lưu';

  @override
  String get deleteCardTitle => 'Xoá danh thiếp?';

  @override
  String get deleteCardMessage => 'Danh thiếp và ảnh sẽ bị xoá khỏi máy này.';

  @override
  String get delete => 'Xoá';

  @override
  String get cardDeleted => 'Đã xoá danh thiếp';

  @override
  String get searchCardPlaceholder => 'Tìm tên, công ty, SĐT, ghi chú...';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get sortNewest => 'Mới nhất';

  @override
  String get sortOldest => 'Cũ nhất';

  @override
  String get sortNameAZ => 'Tên A-Z';

  @override
  String get filterHasNote => 'Có ghi chú';

  @override
  String get noSearchResults => 'Không tìm thấy danh thiếp nào';

  @override
  String get noSearchResultsDesc => 'Thử tìm với từ khoá khác hoặc xoá bộ lọc';

  @override
  String get clearSearch => 'Xoá tìm kiếm';

  @override
  String get scanCardAction => 'Quét thẻ mới';

  @override
  String cardsCount(int count) {
    return '$count danh thiếp';
  }

  @override
  String showingCardsCount(int filtered, int total) {
    return 'Hiển thị $filtered / $total danh thiếp';
  }

  @override
  String get copiedPhone => 'Đã sao chép số điện thoại';

  @override
  String get copiedEmail => 'Đã sao chép địa chỉ email';

  @override
  String get editNote => 'Sửa ghi chú';
}
