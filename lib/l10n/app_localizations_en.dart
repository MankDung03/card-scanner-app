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
  String get offlineBadge => '100% On-device · Offline';

  @override
  String get today => 'Today';

  @override
  String get featureComingSoon => 'Feature will be enabled in next step';

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

  @override
  String get frontSide => 'Front side';

  @override
  String get backSide => 'Back side';

  @override
  String get alignCardTitle => 'Fit business card in frame';

  @override
  String get alignCardSubtitle =>
      'Ratio 91 × 55 mm · keep phone parallel to card';

  @override
  String get stepFront => '1 - Front';

  @override
  String get stepBackOptional => '2 - Back (optional)';

  @override
  String get gallery => 'Gallery';

  @override
  String get cropAction => 'Crop';

  @override
  String get cropTitle => 'Adjust Card';

  @override
  String get changePhoto => 'Change';

  @override
  String get autoDetectedSuccess =>
      'Auto-fit applied · drag 4 corners if needed';

  @override
  String get rotate => 'Rotate';

  @override
  String get autoAlign => 'Auto';

  @override
  String get addBackSide => 'Add back';

  @override
  String get recognizeText => 'Recognize text';

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required to scan cards';

  @override
  String get grantPermission => 'Grant permission';

  @override
  String get cameraInitError => 'Could not initialize camera';

  @override
  String get processing => 'Processing image...';

  @override
  String get ocrProcessing => 'Recognizing text on card...';

  @override
  String get ocrSuccess => 'Text recognized successfully';

  @override
  String ocrBlocksCount(Object count) {
    return '$count text blocks';
  }

  @override
  String ocrLinesCount(Object count) {
    return '$count lines';
  }

  @override
  String get visualTab => 'Visual';

  @override
  String get rawTextTab => 'Raw text';

  @override
  String get blocksTab => 'Blocks & Coordinates';

  @override
  String get copyRawText => 'Copy full text';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get noTextDetected => 'No text detected in the image';
}
