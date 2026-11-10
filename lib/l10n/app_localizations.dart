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
  /// **'Xử lý ngay trên máy · không cần mạng'**
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
