// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Card Scanner';

  @override
  String get addCardTitle => 'Add Card';

  @override
  String get addCardSubtitle => 'Choose how to import your business card';

  @override
  String get captureCardTitle => 'Take Photo';

  @override
  String get captureCardSubtitle => 'Open camera with auto-fit frame';

  @override
  String get galleryCardTitle => 'Choose from Gallery';

  @override
  String get galleryCardSubtitle => 'Use card image saved on device';

  @override
  String get recentlySaved => 'Recently Saved';

  @override
  String viewAll(int count) {
    return 'View all ($count)';
  }

  @override
  String get offlineBadge => 'Processed on-device · No network needed';

  @override
  String get today => 'Today';

  @override
  String get featureComingSoon => 'Feature will be enabled in the next step';

  @override
  String get settingsTitle => 'Settings & Preferences';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get languageTitle => 'Language';

  @override
  String get langVi => 'Tiếng Việt 🇻🇳';

  @override
  String get langJa => '日本語 🇯🇵';

  @override
  String get langEn => 'English 🇬🇧';
}
