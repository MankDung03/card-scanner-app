// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get closeAction => 'Đóng';

  @override
  String get backAction => 'Quay lại';

  @override
  String get backupNoCards => 'Chưa có danh thiếp nào để sao lưu';

  @override
  String get backupCreating => 'Đang tạo bản sao lưu…';

  @override
  String get backupFailed => 'Không tạo được bản sao lưu';

  @override
  String backupLastAt(String date) {
    return 'Lần gần nhất: $date (dữ liệu và ảnh, file .zip)';
  }

  @override
  String get restoreReading => 'Đang đọc bản sao lưu…';

  @override
  String get restoreRunning => 'Đang khôi phục…';

  @override
  String get restoreErrNotBackup =>
      'File này không phải bản sao lưu của ứng dụng.';

  @override
  String get restoreErrVersion =>
      'Bản sao lưu được tạo bằng phiên bản mới hơn. Hãy cập nhật ứng dụng rồi thử lại.';

  @override
  String get restoreErrCorrupted => 'File sao lưu bị hỏng hoặc không đọc được.';

  @override
  String get restoreFailed => 'Khôi phục thất bại, vui lòng thử lại.';

  @override
  String restoreBackupInfo(String date, int count) {
    return 'Bản sao lưu ngày $date · $count danh thiếp';
  }

  @override
  String get restoreModeMerge => 'Gộp với dữ liệu hiện có';

  @override
  String get restoreModeMergeDesc =>
      'Giữ danh thiếp trên máy và thêm thẻ từ bản sao lưu. Thẻ có thể trùng sẽ được đánh dấu để bạn xem lại.';

  @override
  String get restoreModeReplace => 'Thay thế toàn bộ';

  @override
  String get restoreModeReplaceDesc =>
      'Xoá toàn bộ danh thiếp trên máy, dùng nguyên bản sao lưu.';

  @override
  String get recommended => 'Khuyên dùng';

  @override
  String get restoreAction => 'Khôi phục';

  @override
  String get replaceConfirmTitle => 'Thay thế toàn bộ dữ liệu?';

  @override
  String replaceConfirmBody(int current, int incoming) {
    return '$current danh thiếp trên máy sẽ bị xoá và thay bằng $incoming danh thiếp trong bản sao lưu. Không thể hoàn tác.';
  }

  @override
  String get replaceAction => 'Thay thế';

  @override
  String get restoreDoneTitle => 'Đã khôi phục';

  @override
  String get summaryAdded => 'Thêm mới';

  @override
  String get summaryUpdated => 'Cập nhật';

  @override
  String get summaryKeptLocal => 'Giữ bản trên máy (mới hơn)';

  @override
  String get summarySkipped => 'Bỏ qua vì giống hệt';

  @override
  String get summaryFlagged => 'Có thể trùng';

  @override
  String get reviewNow => 'Xem lại';

  @override
  String get duplicatesTitle => 'Danh thiếp có thể trùng';

  @override
  String get duplicatesEmpty => 'Không còn danh thiếp nào cần xem lại';

  @override
  String get dupExisting => 'Đã có trên máy';

  @override
  String get dupNew => 'Thẻ mới thêm';

  @override
  String get dupReasonEmail => 'Trùng email';

  @override
  String get dupReasonMobile => 'Trùng số di động';

  @override
  String get dupReasonNameCompany => 'Trùng họ tên và công ty';

  @override
  String get dupReasonNamePhone => 'Trùng họ tên và số điện thoại';

  @override
  String get dupReasonUnknown => 'Có thể là cùng một người';

  @override
  String get keepBoth => 'Giữ cả hai';

  @override
  String get compareMerge => 'So sánh và gộp';

  @override
  String get keptBothMsg => 'Đã giữ cả hai danh thiếp';

  @override
  String get mergeHint =>
      'Chọn nội dung muốn giữ cho từng mục. Danh thiếp còn lại sẽ bị xoá.';

  @override
  String mergeSameFields(int count) {
    return '$count mục giống nhau ở cả hai';
  }

  @override
  String get mergeTagsNote => 'Tag của cả hai danh thiếp đều được giữ';

  @override
  String get mergeSave => 'Gộp và lưu';

  @override
  String get mergedMsg => 'Đã gộp danh thiếp';

  @override
  String get mergeFailed => 'Không gộp được, vui lòng thử lại';

  @override
  String dupBanner(int count) {
    return 'Có $count danh thiếp có thể bị trùng';
  }

  @override
  String get dupTag => 'Có thể trùng';

  @override
  String get navCards => 'Danh thiếp';

  @override
  String get captureFabLabel => 'Chụp';

  @override
  String get fabHide => 'Ẩn nút này';

  @override
  String get fabHiddenMsg => 'Đã ẩn nút chụp. Có thể bật lại trong Cài đặt.';

  @override
  String get sectionDisplay => 'Hiển thị';

  @override
  String get showCaptureFab => 'Hiện nút chụp nổi';

  @override
  String get showCaptureFabDesc =>
      'Ở danh sách và chi tiết danh thiếp. Kéo để đổi vị trí, nhấn giữ để ẩn.';

  @override
  String get resetFabPosition => 'Đặt lại vị trí nút';

  @override
  String get fabPositionReset => 'Đã đưa nút về góc phải dưới';

  @override
  String get settingsPageTitle => 'Cài đặt';

  @override
  String get homeAction => 'Trang chủ';

  @override
  String get sectionPrivacyData => 'Quyền riêng tư & dữ liệu';

  @override
  String get localOnlyTitle => 'Chỉ lưu trên máy · Không cần tài khoản';

  @override
  String get localOnlyBody => 'Dữ liệu danh thiếp không được gửi lên máy chủ';

  @override
  String get backupTitle => 'Sao lưu';

  @override
  String get backupDesc =>
      'Lần gần nhất: chưa có (lưu dữ liệu và ảnh thành file .zip)';

  @override
  String get restoreTitle => 'Khôi phục từ bản sao lưu';

  @override
  String get restoreDesc => 'Chọn file .zip đã sao lưu';

  @override
  String get csvBulkTitle => 'Xuất CSV toàn bộ';

  @override
  String cardsCountLong(int count) {
    return '$count danh thiếp';
  }

  @override
  String get duplicateCheckTitle => 'Kiểm tra trùng khi lưu';

  @override
  String get duplicateCheckDesc => 'So khớp theo họ tên, công ty, email';

  @override
  String get deleteAllTitle => 'Xoá toàn bộ dữ liệu';

  @override
  String get deleteAllDesc => 'Sẽ hỏi xác nhận trước khi xoá';

  @override
  String get deleteAllConfirmTitle => 'Xoá toàn bộ danh thiếp?';

  @override
  String deleteAllConfirmBody(int count) {
    return '$count danh thiếp và ảnh sẽ bị xoá vĩnh viễn khỏi máy này. Không thể hoàn tác.';
  }

  @override
  String get deleteAllDone => 'Đã xoá toàn bộ dữ liệu';

  @override
  String get deleteAllFailed => 'Có danh thiếp chưa xoá được, vui lòng thử lại';

  @override
  String get displayLanguage => 'Ngôn ngữ hiển thị';

  @override
  String get systemDefault => 'Theo máy';

  @override
  String get ocrLanguageTitle => 'Ngôn ngữ ưu tiên khi đọc chữ';

  @override
  String get ocrLangAuto => 'Tự động';

  @override
  String get ocrLangJa => '日本語';

  @override
  String get ocrLangLatin => 'English・Việt';

  @override
  String get sectionOther => 'Khác';

  @override
  String get privacyPolicy => 'Chính sách bảo mật';

  @override
  String get rateApp => 'Đánh giá ứng dụng';

  @override
  String get versionLabel => 'Phiên bản';

  @override
  String get comingSoonTag => 'Sắp có';

  @override
  String get zoomHint =>
      'Chụm 2 ngón để phóng to/thu nhỏ, chạm đúp để về kích thước gốc';

  @override
  String get saveImage => 'Lưu ảnh';

  @override
  String get imageSaved => 'Đã lưu ảnh vào thư viện ảnh';

  @override
  String get imageSaveFailed => 'Không lưu được ảnh';

  @override
  String get galleryPermissionDenied => 'Chưa được cấp quyền lưu ảnh';

  @override
  String get shareSheetTitle => 'Xuất · Chia sẻ';

  @override
  String thisCardSection(String name) {
    return 'Danh thiếp này ($name)';
  }

  @override
  String get saveToContactsDesc => 'Mở ứng dụng Danh bạ để kiểm tra rồi lưu';

  @override
  String get shareVcard => 'Chia sẻ dạng vCard (.vcf)';

  @override
  String get shareVcardDesc => 'LINE, Zalo, email…';

  @override
  String get storageInfoTitle => 'Về nơi lưu file';

  @override
  String get storageInfoBody =>
      'File được tạo ngay trên máy. Bạn chọn nơi lưu (Tệp, Google Drive, email…) trong menu chia sẻ. Không gửi lên máy chủ nào.';

  @override
  String get exportCsv => 'Xuất CSV';

  @override
  String get csvDialogTitle => 'Xuất file CSV?';

  @override
  String get csvTarget => 'Đối tượng';

  @override
  String csvTargetValue(int count) {
    return '$count danh thiếp (tất cả)';
  }

  @override
  String get csvFormat => 'Định dạng';

  @override
  String get csvFormatValue => 'CSV (UTF-8 · mở được bằng Excel)';

  @override
  String get csvFileName => 'Tên file';

  @override
  String get csvDestination => 'Nơi lưu';

  @override
  String get csvDestinationValue => 'Chọn trong menu chia sẻ sau khi xuất';

  @override
  String get csvPrivacyWarning =>
      'File chứa thông tin cá nhân. Hãy cẩn thận khi chia sẻ.';

  @override
  String get exportAction => 'Xuất';

  @override
  String get exportFailed => 'Không xuất được file';

  @override
  String get csvCreatedAt => 'Ngày thêm';

  @override
  String get tapToZoom => 'Chạm để phóng to';

  @override
  String cardsCount(int count) {
    return '$count danh thiếp';
  }

  @override
  String get savedComplete => 'Đã lưu';

  @override
  String get viewDetails => 'Chi tiết';

  @override
  String get addTagAction => 'Thêm tag';

  @override
  String get sectionName => 'Họ tên';

  @override
  String get sectionCompany => 'Thông tin công ty';

  @override
  String get sectionContact => 'Liên hệ';

  @override
  String stepProgress(int current, int total) {
    return 'Bước $current/$total';
  }

  @override
  String get backSideOptional => 'Mặt sau (tuỳ chọn)';

  @override
  String get cameraHint => 'Đặt danh thiếp vừa khung, ở nơi đủ sáng';

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
      'Đã tự nhận khung danh thiếp. Nếu chưa khớp, kéo các chấm ở 4 góc để chỉnh lại.';

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
  String showingCardsCount(int filtered, int total) {
    return 'Hiển thị $filtered / $total danh thiếp';
  }

  @override
  String get copiedPhone => 'Đã sao chép số điện thoại';

  @override
  String get copiedEmail => 'Đã sao chép địa chỉ email';

  @override
  String get editNote => 'Sửa ghi chú';

  @override
  String get cardDetailTitle => 'Danh thiếp';

  @override
  String get edit => 'Sửa';

  @override
  String get call => 'Gọi';

  @override
  String get map => 'Bản đồ';

  @override
  String get export => 'Xuất';

  @override
  String get meetingSectionTitle => 'Gặp ở đâu, khi nào';

  @override
  String get meetingEmptyPrompt =>
      'Thêm ngày gặp, nơi gặp hoặc ghi chú để dễ nhớ hơn';

  @override
  String get metDateLabel => 'Ngày gặp';

  @override
  String get metPlaceLabel => 'Nơi gặp';

  @override
  String get metPlaceHint => 'VD: Triển lãm IT, Tokyo';

  @override
  String get noteLabel => 'Ghi chú';

  @override
  String get addTag => 'Tag';

  @override
  String get tagHint => 'Tên tag, VD: Khách hàng';

  @override
  String get removeTag => 'Xoá tag';

  @override
  String addedOnLocal(String date) {
    return 'Đã thêm $date · Chỉ lưu trên máy này';
  }

  @override
  String get noImageForSide => 'Chưa có ảnh mặt này';

  @override
  String get addPhoto => 'Thêm ảnh';

  @override
  String get cannotOpenApp => 'Không mở được ứng dụng phù hợp trên máy';

  @override
  String get choosePhoneNumber => 'Chọn số để gọi';

  @override
  String get copied => 'Đã sao chép';

  @override
  String get postalCode => 'Mã bưu chính';

  @override
  String get editCardTitle => 'Sửa danh thiếp';

  @override
  String get cardUpdated => 'Đã cập nhật danh thiếp';

  @override
  String get cardNotFound => 'Không tìm thấy danh thiếp';

  @override
  String get deleteCard => 'Xoá danh thiếp';

  @override
  String ocrProcessingSide(String side, int index, int total) {
    return 'Đang nhận dạng $side ($index/$total)...';
  }

  @override
  String ocrSideFailed(String side) {
    return 'Không nhận dạng được $side, chỉ dùng thông tin mặt còn lại';
  }

  @override
  String get assignLineTitle => 'Gán văn bản vào mục:';

  @override
  String unmappedLinesCount(int count) {
    return 'Dòng chưa gán ($count)';
  }

  @override
  String get assignTo => 'Gán vào...';

  @override
  String get noCardImage => 'Chưa có ảnh danh thiếp';

  @override
  String get ocrFailed => 'Không nhận dạng được chữ trên ảnh, vui lòng thử lại';

  @override
  String enterFieldHint(String field) {
    return 'Nhập $field...';
  }

  @override
  String get sortBy => 'Sắp xếp theo';

  @override
  String get sortCompanyAZ => 'Công ty A-Z';

  @override
  String get noCompanyGroup => 'Không có công ty';

  @override
  String get clearFilters => 'Xoá bộ lọc';

  @override
  String get onImageTab => 'Trên ảnh';

  @override
  String get tapLinesHint =>
      'Chạm vào dòng chữ trên ảnh để chọn (chọn được nhiều dòng), rồi gán vào mục';

  @override
  String get lineAssigned => 'Đã có trong form';

  @override
  String get lineUnassigned => 'Chưa dùng';

  @override
  String selectedLinesCount(int count) {
    return 'Đã chọn $count dòng';
  }

  @override
  String get clearSelection => 'Bỏ chọn';

  @override
  String get assignTextLabel => 'Nội dung sẽ gán';

  @override
  String get replaceValue => 'Thay thế';

  @override
  String get appendValue => 'Nối thêm';

  @override
  String get assign => 'Gán';

  @override
  String assignedToField(String field) {
    return 'Đã gán vào $field';
  }

  @override
  String get undo => 'Hoàn tác';

  @override
  String get emptyValue => '(trống)';
}
