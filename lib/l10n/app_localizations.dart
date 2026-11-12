import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('vi')
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'Scan Danh Thiếp'**
  String get appName;

  /// No description provided for @addCardTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm danh thiếp'**
  String get addCardTitle;

  /// No description provided for @addCardSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn cách lấy ảnh danh thiếp của bạn'**
  String get addCardSubtitle;

  /// No description provided for @captureCardTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh'**
  String get captureCardTitle;

  /// No description provided for @captureCardSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Mở camera, tự căn khung thẻ'**
  String get captureCardSubtitle;

  /// No description provided for @galleryCardTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn từ thư viện'**
  String get galleryCardTitle;

  /// No description provided for @galleryCardSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Dùng ảnh danh thiếp có sẵn trong máy'**
  String get galleryCardSubtitle;

  /// No description provided for @recentlySaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu gần đây'**
  String get recentlySaved;

  /// No description provided for @viewAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả ({count})'**
  String viewAll(int count);

  /// No description provided for @offlineBadge.
  ///
  /// In vi, this message translates to:
  /// **'100% On-device · Offline'**
  String get offlineBadge;

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// No description provided for @featureComingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Chức năng sẽ được kích hoạt ở bước tiếp theo'**
  String get featureComingSoon;

  /// No description provided for @settingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt & Tùy chọn'**
  String get settingsTitle;

  /// No description provided for @themeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get themeTitle;

  /// No description provided for @themeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Hệ thống'**
  String get themeSystem;

  /// No description provided for @languageTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get languageTitle;

  /// No description provided for @langVi.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt 🇻🇳'**
  String get langVi;

  /// No description provided for @langJa.
  ///
  /// In vi, this message translates to:
  /// **'日本語 🇯🇵'**
  String get langJa;

  /// No description provided for @langEn.
  ///
  /// In vi, this message translates to:
  /// **'English 🇬🇧'**
  String get langEn;

  /// No description provided for @frontSide.
  ///
  /// In vi, this message translates to:
  /// **'Mặt trước'**
  String get frontSide;

  /// No description provided for @backSide.
  ///
  /// In vi, this message translates to:
  /// **'Mặt sau'**
  String get backSide;

  /// No description provided for @alignCardTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt danh thiếp vừa khung'**
  String get alignCardTitle;

  /// No description provided for @alignCardSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Khung tỉ lệ 91 × 55 mm · giữ máy song song với thẻ'**
  String get alignCardSubtitle;

  /// No description provided for @stepFront.
  ///
  /// In vi, this message translates to:
  /// **'1 - Mặt trước'**
  String get stepFront;

  /// No description provided for @stepBackOptional.
  ///
  /// In vi, this message translates to:
  /// **'2 - Mặt sau (tuỳ chọn)'**
  String get stepBackOptional;

  /// No description provided for @gallery.
  ///
  /// In vi, this message translates to:
  /// **'Thư viện'**
  String get gallery;

  /// No description provided for @cropAction.
  ///
  /// In vi, this message translates to:
  /// **'Cắt ảnh'**
  String get cropAction;

  /// No description provided for @cropTitle.
  ///
  /// In vi, this message translates to:
  /// **'Căn chỉnh ảnh'**
  String get cropTitle;

  /// No description provided for @changePhoto.
  ///
  /// In vi, this message translates to:
  /// **'Đổi ảnh'**
  String get changePhoto;

  /// No description provided for @autoDetectedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã tự nhận khung thẻ · kéo 4 góc nếu chưa khớp'**
  String get autoDetectedSuccess;

  /// No description provided for @rotate.
  ///
  /// In vi, this message translates to:
  /// **'Xoay'**
  String get rotate;

  /// No description provided for @autoAlign.
  ///
  /// In vi, this message translates to:
  /// **'Tự động'**
  String get autoAlign;

  /// No description provided for @addBackSide.
  ///
  /// In vi, this message translates to:
  /// **'Thêm mặt sau'**
  String get addBackSide;

  /// No description provided for @recognizeText.
  ///
  /// In vi, this message translates to:
  /// **'Nhận dạng chữ'**
  String get recognizeText;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In vi, this message translates to:
  /// **'Cần cấp quyền truy cập máy ảnh để chụp danh thiếp'**
  String get cameraPermissionRequired;

  /// No description provided for @grantPermission.
  ///
  /// In vi, this message translates to:
  /// **'Cấp quyền'**
  String get grantPermission;

  /// No description provided for @cameraInitError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể khởi động camera'**
  String get cameraInitError;

  /// No description provided for @processing.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý ảnh...'**
  String get processing;

  /// No description provided for @ocrProcessing.
  ///
  /// In vi, this message translates to:
  /// **'Đang nhận dạng chữ trên thẻ...'**
  String get ocrProcessing;

  /// No description provided for @ocrSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Nhận dạng chữ thành công'**
  String get ocrSuccess;

  /// No description provided for @ocrBlocksCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} khối chữ'**
  String ocrBlocksCount(Object count);

  /// No description provided for @ocrLinesCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} dòng chữ'**
  String ocrLinesCount(Object count);

  /// No description provided for @visualTab.
  ///
  /// In vi, this message translates to:
  /// **'Trực quan'**
  String get visualTab;

  /// No description provided for @rawTextTab.
  ///
  /// In vi, this message translates to:
  /// **'Văn bản'**
  String get rawTextTab;

  /// No description provided for @blocksTab.
  ///
  /// In vi, this message translates to:
  /// **'Khối chữ'**
  String get blocksTab;

  /// No description provided for @copyRawText.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép toàn bộ text'**
  String get copyRawText;

  /// No description provided for @copiedToClipboard.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép vào bộ nhớ tạm'**
  String get copiedToClipboard;

  /// No description provided for @noTextDetected.
  ///
  /// In vi, this message translates to:
  /// **'Không nhận diện được chữ nào trong ảnh'**
  String get noTextDetected;

  /// No description provided for @verificationTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra thông tin'**
  String get verificationTitle;

  /// No description provided for @retake.
  ///
  /// In vi, this message translates to:
  /// **'Chụp lại'**
  String get retake;

  /// No description provided for @detectedFieldsCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận dạng {count} mục'**
  String detectedFieldsCount(int count);

  /// No description provided for @needsReviewCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} mục nên kiểm tra lại'**
  String needsReviewCount(int count);

  /// No description provided for @allClear.
  ///
  /// In vi, this message translates to:
  /// **'Mọi thông tin đều rõ ràng'**
  String get allClear;

  /// No description provided for @byFieldsTab.
  ///
  /// In vi, this message translates to:
  /// **'Theo mục'**
  String get byFieldsTab;

  /// No description provided for @originalTextTab.
  ///
  /// In vi, this message translates to:
  /// **'Văn bản gốc'**
  String get originalTextTab;

  /// No description provided for @fullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ tên'**
  String get fullName;

  /// No description provided for @furigana.
  ///
  /// In vi, this message translates to:
  /// **'Furigana'**
  String get furigana;

  /// No description provided for @needsReviewTag.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra lại'**
  String get needsReviewTag;

  /// No description provided for @jobTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chức vụ'**
  String get jobTitle;

  /// No description provided for @company.
  ///
  /// In vi, this message translates to:
  /// **'Công ty'**
  String get company;

  /// No description provided for @department.
  ///
  /// In vi, this message translates to:
  /// **'Phòng ban'**
  String get department;

  /// No description provided for @phone.
  ///
  /// In vi, this message translates to:
  /// **'Điện thoại'**
  String get phone;

  /// No description provided for @mobile.
  ///
  /// In vi, this message translates to:
  /// **'Di động'**
  String get mobile;

  /// No description provided for @fax.
  ///
  /// In vi, this message translates to:
  /// **'FAX'**
  String get fax;

  /// No description provided for @email.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ'**
  String get address;

  /// No description provided for @website.
  ///
  /// In vi, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @notOnCardPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Không có trên thẻ — nhập nếu cần'**
  String get notOnCardPlaceholder;

  /// No description provided for @saveCard.
  ///
  /// In vi, this message translates to:
  /// **'Lưu danh thiếp'**
  String get saveCard;

  /// No description provided for @editField.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa thông tin'**
  String get editField;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In vi, this message translates to:
  /// **'Xong'**
  String get done;

  /// No description provided for @cardSavedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu danh thiếp thành công'**
  String get cardSavedSuccess;

  /// No description provided for @cardSavedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu danh thiếp'**
  String get cardSavedTitle;

  /// No description provided for @cardSavedSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu vào app trên máy này.'**
  String get cardSavedSubtitle;

  /// No description provided for @cardSaveFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể lưu danh thiếp, vui lòng thử lại'**
  String get cardSaveFailed;

  /// No description provided for @optionalActions.
  ///
  /// In vi, this message translates to:
  /// **'Làm thêm (không bắt buộc)'**
  String get optionalActions;

  /// No description provided for @saveToContacts.
  ///
  /// In vi, this message translates to:
  /// **'Lưu vào Danh bạ'**
  String get saveToContacts;

  /// No description provided for @addMeetingNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú gặp ở đâu'**
  String get addMeetingNote;

  /// No description provided for @meetingNoteHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Gặp ở hội thảo tại Tokyo, 12/11'**
  String get meetingNoteHint;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @noteSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu ghi chú'**
  String get noteSaved;

  /// No description provided for @scanAnotherCard.
  ///
  /// In vi, this message translates to:
  /// **'Scan danh thiếp khác'**
  String get scanAnotherCard;

  /// No description provided for @backToHome.
  ///
  /// In vi, this message translates to:
  /// **'Về trang chủ'**
  String get backToHome;

  /// No description provided for @unnamedCard.
  ///
  /// In vi, this message translates to:
  /// **'(Chưa có tên)'**
  String get unnamedCard;

  /// No description provided for @noSavedCards.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có danh thiếp nào. Hãy scan tấm đầu tiên!'**
  String get noSavedCards;

  /// No description provided for @savedCardsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh thiếp đã lưu'**
  String get savedCardsTitle;

  /// No description provided for @deleteCardTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xoá danh thiếp?'**
  String get deleteCardTitle;

  /// No description provided for @deleteCardMessage.
  ///
  /// In vi, this message translates to:
  /// **'Danh thiếp và ảnh sẽ bị xoá khỏi máy này.'**
  String get deleteCardMessage;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xoá'**
  String get delete;

  /// No description provided for @cardDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xoá danh thiếp'**
  String get cardDeleted;

  /// No description provided for @searchCardPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tìm tên, công ty, SĐT, ghi chú...'**
  String get searchCardPlaceholder;

  /// No description provided for @filterAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get filterAll;

  /// No description provided for @sortNewest.
  ///
  /// In vi, this message translates to:
  /// **'Mới nhất'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In vi, this message translates to:
  /// **'Cũ nhất'**
  String get sortOldest;

  /// No description provided for @sortNameAZ.
  ///
  /// In vi, this message translates to:
  /// **'Tên A-Z'**
  String get sortNameAZ;

  /// No description provided for @filterHasNote.
  ///
  /// In vi, this message translates to:
  /// **'Có ghi chú'**
  String get filterHasNote;

  /// No description provided for @noSearchResults.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy danh thiếp nào'**
  String get noSearchResults;

  /// No description provided for @noSearchResultsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Thử tìm với từ khoá khác hoặc xoá bộ lọc'**
  String get noSearchResultsDesc;

  /// No description provided for @clearSearch.
  ///
  /// In vi, this message translates to:
  /// **'Xoá tìm kiếm'**
  String get clearSearch;

  /// No description provided for @scanCardAction.
  ///
  /// In vi, this message translates to:
  /// **'Quét thẻ mới'**
  String get scanCardAction;

  /// No description provided for @cardsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} danh thiếp'**
  String cardsCount(int count);

  /// No description provided for @showingCardsCount.
  ///
  /// In vi, this message translates to:
  /// **'Hiển thị {filtered} / {total} danh thiếp'**
  String showingCardsCount(int filtered, int total);

  /// No description provided for @copiedPhone.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép số điện thoại'**
  String get copiedPhone;

  /// No description provided for @copiedEmail.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép địa chỉ email'**
  String get copiedEmail;

  /// No description provided for @editNote.
  ///
  /// In vi, this message translates to:
  /// **'Sửa ghi chú'**
  String get editNote;

  /// No description provided for @cardDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh thiếp'**
  String get cardDetailTitle;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get edit;

  /// No description provided for @call.
  ///
  /// In vi, this message translates to:
  /// **'Gọi'**
  String get call;

  /// No description provided for @map.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ'**
  String get map;

  /// No description provided for @export.
  ///
  /// In vi, this message translates to:
  /// **'Xuất'**
  String get export;

  /// No description provided for @meetingSectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Gặp ở đâu, khi nào'**
  String get meetingSectionTitle;

  /// No description provided for @meetingEmptyPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ngày gặp, nơi gặp hoặc ghi chú để dễ nhớ hơn'**
  String get meetingEmptyPrompt;

  /// No description provided for @metDateLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày gặp'**
  String get metDateLabel;

  /// No description provided for @metPlaceLabel.
  ///
  /// In vi, this message translates to:
  /// **'Nơi gặp'**
  String get metPlaceLabel;

  /// No description provided for @metPlaceHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Triển lãm IT, Tokyo'**
  String get metPlaceHint;

  /// No description provided for @noteLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get noteLabel;

  /// No description provided for @addTag.
  ///
  /// In vi, this message translates to:
  /// **'Tag'**
  String get addTag;

  /// No description provided for @tagHint.
  ///
  /// In vi, this message translates to:
  /// **'Tên tag, VD: Khách hàng'**
  String get tagHint;

  /// No description provided for @removeTag.
  ///
  /// In vi, this message translates to:
  /// **'Xoá tag'**
  String get removeTag;

  /// No description provided for @addedOnLocal.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm {date} · Chỉ lưu trên máy này'**
  String addedOnLocal(String date);

  /// No description provided for @noImageForSide.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ảnh mặt này'**
  String get noImageForSide;

  /// No description provided for @addPhoto.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ảnh'**
  String get addPhoto;

  /// No description provided for @cannotOpenApp.
  ///
  /// In vi, this message translates to:
  /// **'Không mở được ứng dụng phù hợp trên máy'**
  String get cannotOpenApp;

  /// No description provided for @choosePhoneNumber.
  ///
  /// In vi, this message translates to:
  /// **'Chọn số để gọi'**
  String get choosePhoneNumber;

  /// No description provided for @copied.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép'**
  String get copied;

  /// No description provided for @postalCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã bưu chính'**
  String get postalCode;

  /// No description provided for @editCardTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sửa danh thiếp'**
  String get editCardTitle;

  /// No description provided for @cardUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật danh thiếp'**
  String get cardUpdated;

  /// No description provided for @cardNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy danh thiếp'**
  String get cardNotFound;

  /// No description provided for @deleteCard.
  ///
  /// In vi, this message translates to:
  /// **'Xoá danh thiếp'**
  String get deleteCard;

  /// No description provided for @ocrProcessingSide.
  ///
  /// In vi, this message translates to:
  /// **'Đang nhận dạng {side} ({index}/{total})...'**
  String ocrProcessingSide(String side, int index, int total);

  /// No description provided for @ocrSideFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không nhận dạng được {side}, chỉ dùng thông tin mặt còn lại'**
  String ocrSideFailed(String side);

  /// No description provided for @assignLineTitle.
  ///
  /// In vi, this message translates to:
  /// **'Gán văn bản vào mục:'**
  String get assignLineTitle;

  /// No description provided for @unmappedLinesCount.
  ///
  /// In vi, this message translates to:
  /// **'Dòng chưa gán ({count})'**
  String unmappedLinesCount(int count);

  /// No description provided for @assignTo.
  ///
  /// In vi, this message translates to:
  /// **'Gán vào...'**
  String get assignTo;

  /// No description provided for @noCardImage.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ảnh danh thiếp'**
  String get noCardImage;

  /// No description provided for @ocrFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không nhận dạng được chữ trên ảnh, vui lòng thử lại'**
  String get ocrFailed;

  /// No description provided for @enterFieldHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập {field}...'**
  String enterFieldHint(String field);

  /// No description provided for @sortBy.
  ///
  /// In vi, this message translates to:
  /// **'Sắp xếp theo'**
  String get sortBy;

  /// No description provided for @sortCompanyAZ.
  ///
  /// In vi, this message translates to:
  /// **'Công ty A-Z'**
  String get sortCompanyAZ;

  /// No description provided for @noCompanyGroup.
  ///
  /// In vi, this message translates to:
  /// **'Không có công ty'**
  String get noCompanyGroup;

  /// No description provided for @clearFilters.
  ///
  /// In vi, this message translates to:
  /// **'Xoá bộ lọc'**
  String get clearFilters;

  /// No description provided for @onImageTab.
  ///
  /// In vi, this message translates to:
  /// **'Trên ảnh'**
  String get onImageTab;

  /// No description provided for @tapLinesHint.
  ///
  /// In vi, this message translates to:
  /// **'Chạm vào dòng chữ trên ảnh để chọn (chọn được nhiều dòng), rồi gán vào mục'**
  String get tapLinesHint;

  /// No description provided for @lineAssigned.
  ///
  /// In vi, this message translates to:
  /// **'Đã có trong form'**
  String get lineAssigned;

  /// No description provided for @lineUnassigned.
  ///
  /// In vi, this message translates to:
  /// **'Chưa dùng'**
  String get lineUnassigned;

  /// No description provided for @selectedLinesCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã chọn {count} dòng'**
  String selectedLinesCount(int count);

  /// No description provided for @clearSelection.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ chọn'**
  String get clearSelection;

  /// No description provided for @assignTextLabel.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung sẽ gán'**
  String get assignTextLabel;

  /// No description provided for @replaceValue.
  ///
  /// In vi, this message translates to:
  /// **'Thay thế'**
  String get replaceValue;

  /// No description provided for @appendValue.
  ///
  /// In vi, this message translates to:
  /// **'Nối thêm'**
  String get appendValue;

  /// No description provided for @assign.
  ///
  /// In vi, this message translates to:
  /// **'Gán'**
  String get assign;

  /// No description provided for @assignedToField.
  ///
  /// In vi, this message translates to:
  /// **'Đã gán vào {field}'**
  String assignedToField(String field);

  /// No description provided for @undo.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tác'**
  String get undo;

  /// No description provided for @emptyValue.
  ///
  /// In vi, this message translates to:
  /// **'(trống)'**
  String get emptyValue;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
