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

  /// No description provided for @closeAction.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get closeAction;

  /// No description provided for @backAction.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get backAction;

  /// No description provided for @backupNoCards.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có danh thiếp nào để sao lưu'**
  String get backupNoCards;

  /// No description provided for @backupCreating.
  ///
  /// In vi, this message translates to:
  /// **'Đang tạo bản sao lưu…'**
  String get backupCreating;

  /// No description provided for @backupFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không tạo được bản sao lưu'**
  String get backupFailed;

  /// No description provided for @backupLastAt.
  ///
  /// In vi, this message translates to:
  /// **'Lần gần nhất: {date} (dữ liệu và ảnh, file .zip)'**
  String backupLastAt(String date);

  /// No description provided for @restoreReading.
  ///
  /// In vi, this message translates to:
  /// **'Đang đọc bản sao lưu…'**
  String get restoreReading;

  /// No description provided for @restoreRunning.
  ///
  /// In vi, this message translates to:
  /// **'Đang khôi phục…'**
  String get restoreRunning;

  /// No description provided for @restoreErrNotBackup.
  ///
  /// In vi, this message translates to:
  /// **'File này không phải bản sao lưu của ứng dụng.'**
  String get restoreErrNotBackup;

  /// No description provided for @restoreErrVersion.
  ///
  /// In vi, this message translates to:
  /// **'Bản sao lưu được tạo bằng phiên bản mới hơn. Hãy cập nhật ứng dụng rồi thử lại.'**
  String get restoreErrVersion;

  /// No description provided for @restoreErrCorrupted.
  ///
  /// In vi, this message translates to:
  /// **'File sao lưu bị hỏng hoặc không đọc được.'**
  String get restoreErrCorrupted;

  /// No description provided for @restoreFailed.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục thất bại, vui lòng thử lại.'**
  String get restoreFailed;

  /// No description provided for @restoreBackupInfo.
  ///
  /// In vi, this message translates to:
  /// **'Bản sao lưu ngày {date} · {count} danh thiếp'**
  String restoreBackupInfo(String date, int count);

  /// No description provided for @restoreModeMerge.
  ///
  /// In vi, this message translates to:
  /// **'Gộp với dữ liệu hiện có'**
  String get restoreModeMerge;

  /// No description provided for @restoreModeMergeDesc.
  ///
  /// In vi, this message translates to:
  /// **'Giữ danh thiếp trên máy và thêm thẻ từ bản sao lưu. Thẻ có thể trùng sẽ được đánh dấu để bạn xem lại.'**
  String get restoreModeMergeDesc;

  /// No description provided for @restoreModeReplace.
  ///
  /// In vi, this message translates to:
  /// **'Thay thế toàn bộ'**
  String get restoreModeReplace;

  /// No description provided for @restoreModeReplaceDesc.
  ///
  /// In vi, this message translates to:
  /// **'Xoá toàn bộ danh thiếp trên máy, dùng nguyên bản sao lưu.'**
  String get restoreModeReplaceDesc;

  /// No description provided for @recommended.
  ///
  /// In vi, this message translates to:
  /// **'Khuyên dùng'**
  String get recommended;

  /// No description provided for @restoreAction.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục'**
  String get restoreAction;

  /// No description provided for @replaceConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thay thế toàn bộ dữ liệu?'**
  String get replaceConfirmTitle;

  /// No description provided for @replaceConfirmBody.
  ///
  /// In vi, this message translates to:
  /// **'{current} danh thiếp trên máy sẽ bị xoá và thay bằng {incoming} danh thiếp trong bản sao lưu. Không thể hoàn tác.'**
  String replaceConfirmBody(int current, int incoming);

  /// No description provided for @replaceAction.
  ///
  /// In vi, this message translates to:
  /// **'Thay thế'**
  String get replaceAction;

  /// No description provided for @restoreDoneTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã khôi phục'**
  String get restoreDoneTitle;

  /// No description provided for @summaryAdded.
  ///
  /// In vi, this message translates to:
  /// **'Thêm mới'**
  String get summaryAdded;

  /// No description provided for @summaryUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật'**
  String get summaryUpdated;

  /// No description provided for @summaryKeptLocal.
  ///
  /// In vi, this message translates to:
  /// **'Giữ bản trên máy (mới hơn)'**
  String get summaryKeptLocal;

  /// No description provided for @summarySkipped.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua vì giống hệt'**
  String get summarySkipped;

  /// No description provided for @summaryFlagged.
  ///
  /// In vi, this message translates to:
  /// **'Có thể trùng'**
  String get summaryFlagged;

  /// No description provided for @reviewNow.
  ///
  /// In vi, this message translates to:
  /// **'Xem lại'**
  String get reviewNow;

  /// No description provided for @duplicatesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh thiếp có thể trùng'**
  String get duplicatesTitle;

  /// No description provided for @duplicatesEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Không còn danh thiếp nào cần xem lại'**
  String get duplicatesEmpty;

  /// No description provided for @dupExisting.
  ///
  /// In vi, this message translates to:
  /// **'Đã có trên máy'**
  String get dupExisting;

  /// No description provided for @dupNew.
  ///
  /// In vi, this message translates to:
  /// **'Thẻ mới thêm'**
  String get dupNew;

  /// No description provided for @dupReasonEmail.
  ///
  /// In vi, this message translates to:
  /// **'Trùng email'**
  String get dupReasonEmail;

  /// No description provided for @dupReasonMobile.
  ///
  /// In vi, this message translates to:
  /// **'Trùng số di động'**
  String get dupReasonMobile;

  /// No description provided for @dupReasonNameCompany.
  ///
  /// In vi, this message translates to:
  /// **'Trùng họ tên và công ty'**
  String get dupReasonNameCompany;

  /// No description provided for @dupReasonNamePhone.
  ///
  /// In vi, this message translates to:
  /// **'Trùng họ tên và số điện thoại'**
  String get dupReasonNamePhone;

  /// No description provided for @dupReasonUnknown.
  ///
  /// In vi, this message translates to:
  /// **'Có thể là cùng một người'**
  String get dupReasonUnknown;

  /// No description provided for @keepBoth.
  ///
  /// In vi, this message translates to:
  /// **'Giữ cả hai'**
  String get keepBoth;

  /// No description provided for @compareMerge.
  ///
  /// In vi, this message translates to:
  /// **'So sánh và gộp'**
  String get compareMerge;

  /// No description provided for @keptBothMsg.
  ///
  /// In vi, this message translates to:
  /// **'Đã giữ cả hai danh thiếp'**
  String get keptBothMsg;

  /// No description provided for @mergeHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn nội dung muốn giữ cho từng mục. Danh thiếp còn lại sẽ bị xoá.'**
  String get mergeHint;

  /// No description provided for @mergeSameFields.
  ///
  /// In vi, this message translates to:
  /// **'{count} mục giống nhau ở cả hai'**
  String mergeSameFields(int count);

  /// No description provided for @mergeTagsNote.
  ///
  /// In vi, this message translates to:
  /// **'Tag của cả hai danh thiếp đều được giữ'**
  String get mergeTagsNote;

  /// No description provided for @mergeSave.
  ///
  /// In vi, this message translates to:
  /// **'Gộp và lưu'**
  String get mergeSave;

  /// No description provided for @mergedMsg.
  ///
  /// In vi, this message translates to:
  /// **'Đã gộp danh thiếp'**
  String get mergedMsg;

  /// No description provided for @mergeFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không gộp được, vui lòng thử lại'**
  String get mergeFailed;

  /// No description provided for @dupBanner.
  ///
  /// In vi, this message translates to:
  /// **'Có {count} danh thiếp có thể bị trùng'**
  String dupBanner(int count);

  /// No description provided for @dupTag.
  ///
  /// In vi, this message translates to:
  /// **'Có thể trùng'**
  String get dupTag;

  /// No description provided for @navCards.
  ///
  /// In vi, this message translates to:
  /// **'Danh thiếp'**
  String get navCards;

  /// No description provided for @captureFabLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chụp'**
  String get captureFabLabel;

  /// No description provided for @fabHide.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn nút này'**
  String get fabHide;

  /// No description provided for @fabHiddenMsg.
  ///
  /// In vi, this message translates to:
  /// **'Đã ẩn nút chụp. Có thể bật lại trong Cài đặt.'**
  String get fabHiddenMsg;

  /// No description provided for @sectionDisplay.
  ///
  /// In vi, this message translates to:
  /// **'Hiển thị'**
  String get sectionDisplay;

  /// No description provided for @showCaptureFab.
  ///
  /// In vi, this message translates to:
  /// **'Hiện nút chụp nổi'**
  String get showCaptureFab;

  /// No description provided for @showCaptureFabDesc.
  ///
  /// In vi, this message translates to:
  /// **'Ở danh sách và chi tiết danh thiếp. Kéo để đổi vị trí, nhấn giữ để ẩn.'**
  String get showCaptureFabDesc;

  /// No description provided for @resetFabPosition.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại vị trí nút'**
  String get resetFabPosition;

  /// No description provided for @fabPositionReset.
  ///
  /// In vi, this message translates to:
  /// **'Đã đưa nút về góc phải dưới'**
  String get fabPositionReset;

  /// No description provided for @settingsPageTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsPageTitle;

  /// No description provided for @homeAction.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get homeAction;

  /// No description provided for @sectionPrivacyData.
  ///
  /// In vi, this message translates to:
  /// **'Quyền riêng tư & dữ liệu'**
  String get sectionPrivacyData;

  /// No description provided for @localOnlyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ lưu trên máy · Không cần tài khoản'**
  String get localOnlyTitle;

  /// No description provided for @localOnlyBody.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu danh thiếp không được gửi lên máy chủ'**
  String get localOnlyBody;

  /// No description provided for @backupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sao lưu'**
  String get backupTitle;

  /// No description provided for @backupDesc.
  ///
  /// In vi, this message translates to:
  /// **'Lần gần nhất: chưa có (lưu dữ liệu và ảnh thành file .zip)'**
  String get backupDesc;

  /// No description provided for @restoreTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục từ bản sao lưu'**
  String get restoreTitle;

  /// No description provided for @restoreDesc.
  ///
  /// In vi, this message translates to:
  /// **'Chọn file .zip đã sao lưu'**
  String get restoreDesc;

  /// No description provided for @csvBulkTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xuất CSV toàn bộ'**
  String get csvBulkTitle;

  /// No description provided for @cardsCountLong.
  ///
  /// In vi, this message translates to:
  /// **'{count} danh thiếp'**
  String cardsCountLong(int count);

  /// No description provided for @duplicateCheckTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra trùng khi lưu'**
  String get duplicateCheckTitle;

  /// No description provided for @duplicateCheckDesc.
  ///
  /// In vi, this message translates to:
  /// **'So khớp theo họ tên, công ty, email'**
  String get duplicateCheckDesc;

  /// No description provided for @deleteAllTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xoá toàn bộ dữ liệu'**
  String get deleteAllTitle;

  /// No description provided for @deleteAllDesc.
  ///
  /// In vi, this message translates to:
  /// **'Sẽ hỏi xác nhận trước khi xoá'**
  String get deleteAllDesc;

  /// No description provided for @deleteAllConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xoá toàn bộ danh thiếp?'**
  String get deleteAllConfirmTitle;

  /// No description provided for @deleteAllConfirmBody.
  ///
  /// In vi, this message translates to:
  /// **'{count} danh thiếp và ảnh sẽ bị xoá vĩnh viễn khỏi máy này. Không thể hoàn tác.'**
  String deleteAllConfirmBody(int count);

  /// No description provided for @deleteAllDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã xoá toàn bộ dữ liệu'**
  String get deleteAllDone;

  /// No description provided for @deleteAllFailed.
  ///
  /// In vi, this message translates to:
  /// **'Có danh thiếp chưa xoá được, vui lòng thử lại'**
  String get deleteAllFailed;

  /// No description provided for @displayLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ hiển thị'**
  String get displayLanguage;

  /// No description provided for @systemDefault.
  ///
  /// In vi, this message translates to:
  /// **'Theo máy'**
  String get systemDefault;

  /// No description provided for @ocrLanguageTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ ưu tiên khi đọc chữ'**
  String get ocrLanguageTitle;

  /// No description provided for @ocrLangAuto.
  ///
  /// In vi, this message translates to:
  /// **'Tự động'**
  String get ocrLangAuto;

  /// No description provided for @ocrLangJa.
  ///
  /// In vi, this message translates to:
  /// **'日本語'**
  String get ocrLangJa;

  /// No description provided for @ocrLangLatin.
  ///
  /// In vi, this message translates to:
  /// **'English・Việt'**
  String get ocrLangLatin;

  /// No description provided for @sectionOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get sectionOther;

  /// No description provided for @privacyPolicy.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách bảo mật'**
  String get privacyPolicy;

  /// No description provided for @rateApp.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá ứng dụng'**
  String get rateApp;

  /// No description provided for @versionLabel.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản'**
  String get versionLabel;

  /// No description provided for @comingSoonTag.
  ///
  /// In vi, this message translates to:
  /// **'Sắp có'**
  String get comingSoonTag;

  /// No description provided for @zoomHint.
  ///
  /// In vi, this message translates to:
  /// **'Chụm 2 ngón để phóng to/thu nhỏ, chạm đúp để về kích thước gốc'**
  String get zoomHint;

  /// No description provided for @saveImage.
  ///
  /// In vi, this message translates to:
  /// **'Lưu ảnh'**
  String get saveImage;

  /// No description provided for @imageSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu ảnh vào thư viện ảnh'**
  String get imageSaved;

  /// No description provided for @imageSaveFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không lưu được ảnh'**
  String get imageSaveFailed;

  /// No description provided for @galleryPermissionDenied.
  ///
  /// In vi, this message translates to:
  /// **'Chưa được cấp quyền lưu ảnh'**
  String get galleryPermissionDenied;

  /// No description provided for @shareSheetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xuất · Chia sẻ'**
  String get shareSheetTitle;

  /// No description provided for @thisCardSection.
  ///
  /// In vi, this message translates to:
  /// **'Danh thiếp này ({name})'**
  String thisCardSection(String name);

  /// No description provided for @saveToContactsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Mở ứng dụng Danh bạ để kiểm tra rồi lưu'**
  String get saveToContactsDesc;

  /// No description provided for @shareVcard.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ dạng vCard (.vcf)'**
  String get shareVcard;

  /// No description provided for @shareVcardDesc.
  ///
  /// In vi, this message translates to:
  /// **'LINE, Zalo, email…'**
  String get shareVcardDesc;

  /// No description provided for @storageInfoTitle.
  ///
  /// In vi, this message translates to:
  /// **'Về nơi lưu file'**
  String get storageInfoTitle;

  /// No description provided for @storageInfoBody.
  ///
  /// In vi, this message translates to:
  /// **'File được tạo ngay trên máy. Bạn chọn nơi lưu (Tệp, Google Drive, email…) trong menu chia sẻ. Không gửi lên máy chủ nào.'**
  String get storageInfoBody;

  /// No description provided for @exportCsv.
  ///
  /// In vi, this message translates to:
  /// **'Xuất CSV'**
  String get exportCsv;

  /// No description provided for @csvDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xuất file CSV?'**
  String get csvDialogTitle;

  /// No description provided for @csvTarget.
  ///
  /// In vi, this message translates to:
  /// **'Đối tượng'**
  String get csvTarget;

  /// No description provided for @csvTargetValue.
  ///
  /// In vi, this message translates to:
  /// **'{count} danh thiếp (tất cả)'**
  String csvTargetValue(int count);

  /// No description provided for @csvFormat.
  ///
  /// In vi, this message translates to:
  /// **'Định dạng'**
  String get csvFormat;

  /// No description provided for @csvFormatValue.
  ///
  /// In vi, this message translates to:
  /// **'CSV (UTF-8 · mở được bằng Excel)'**
  String get csvFormatValue;

  /// No description provided for @csvFileName.
  ///
  /// In vi, this message translates to:
  /// **'Tên file'**
  String get csvFileName;

  /// No description provided for @csvDestination.
  ///
  /// In vi, this message translates to:
  /// **'Nơi lưu'**
  String get csvDestination;

  /// No description provided for @csvDestinationValue.
  ///
  /// In vi, this message translates to:
  /// **'Chọn trong menu chia sẻ sau khi xuất'**
  String get csvDestinationValue;

  /// No description provided for @csvPrivacyWarning.
  ///
  /// In vi, this message translates to:
  /// **'File chứa thông tin cá nhân. Hãy cẩn thận khi chia sẻ.'**
  String get csvPrivacyWarning;

  /// No description provided for @exportAction.
  ///
  /// In vi, this message translates to:
  /// **'Xuất'**
  String get exportAction;

  /// No description provided for @exportFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không xuất được file'**
  String get exportFailed;

  /// No description provided for @csvCreatedAt.
  ///
  /// In vi, this message translates to:
  /// **'Ngày thêm'**
  String get csvCreatedAt;

  /// No description provided for @tapToZoom.
  ///
  /// In vi, this message translates to:
  /// **'Chạm để phóng to'**
  String get tapToZoom;

  /// No description provided for @cardsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} danh thiếp'**
  String cardsCount(int count);

  /// No description provided for @savedComplete.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu'**
  String get savedComplete;

  /// No description provided for @viewDetails.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết'**
  String get viewDetails;

  /// No description provided for @addTagAction.
  ///
  /// In vi, this message translates to:
  /// **'Thêm tag'**
  String get addTagAction;

  /// No description provided for @sectionName.
  ///
  /// In vi, this message translates to:
  /// **'Họ tên'**
  String get sectionName;

  /// No description provided for @sectionCompany.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin công ty'**
  String get sectionCompany;

  /// No description provided for @sectionContact.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ'**
  String get sectionContact;

  /// No description provided for @stepProgress.
  ///
  /// In vi, this message translates to:
  /// **'Bước {current}/{total}'**
  String stepProgress(int current, int total);

  /// No description provided for @backSideOptional.
  ///
  /// In vi, this message translates to:
  /// **'Mặt sau (tuỳ chọn)'**
  String get backSideOptional;

  /// No description provided for @cameraHint.
  ///
  /// In vi, this message translates to:
  /// **'Đặt danh thiếp vừa khung, ở nơi đủ sáng'**
  String get cameraHint;

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
  /// **'Đã tự nhận khung danh thiếp. Nếu chưa khớp, kéo các chấm ở 4 góc để chỉnh lại.'**
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
