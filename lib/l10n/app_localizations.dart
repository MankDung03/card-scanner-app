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

  /// No description provided for @rawTextTab.
  ///
  /// In vi, this message translates to:
  /// **'Văn bản thô'**
  String get rawTextTab;

  /// No description provided for @blocksTab.
  ///
  /// In vi, this message translates to:
  /// **'Khối chữ & Tọa độ'**
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
