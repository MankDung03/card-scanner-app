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
  String get blocksTab => 'Blocks';

  @override
  String get copyRawText => 'Copy full text';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get noTextDetected => 'No text detected in the image';

  @override
  String get verificationTitle => 'Information Check';

  @override
  String get retake => 'Retake';

  @override
  String detectedFieldsCount(int count) {
    return '$count items recognized';
  }

  @override
  String needsReviewCount(int count) {
    return '$count items to review';
  }

  @override
  String get allClear => 'All information clear';

  @override
  String get byFieldsTab => 'By Fields';

  @override
  String get originalTextTab => 'Original Text';

  @override
  String get fullName => 'Full Name';

  @override
  String get furigana => 'Furigana';

  @override
  String get needsReviewTag => 'Review';

  @override
  String get jobTitle => 'Job Title';

  @override
  String get company => 'Company';

  @override
  String get department => 'Department';

  @override
  String get phone => 'Phone';

  @override
  String get mobile => 'Mobile';

  @override
  String get fax => 'FAX';

  @override
  String get email => 'Email';

  @override
  String get address => 'Address';

  @override
  String get website => 'Website';

  @override
  String get notOnCardPlaceholder => 'Not on card — enter if needed';

  @override
  String get saveCard => 'Save Card';

  @override
  String get editField => 'Edit Information';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get cardSavedSuccess => 'Business card saved successfully';

  @override
  String get cardSavedTitle => 'Card saved';

  @override
  String get cardSavedSubtitle => 'Saved in the app on this device.';

  @override
  String get cardSaveFailed => 'Could not save the card, please try again';

  @override
  String get optionalActions => 'More (optional)';

  @override
  String get saveToContacts => 'Save to Contacts';

  @override
  String get addMeetingNote => 'Where you met';

  @override
  String get meetingNoteHint => 'e.g. Met at a conference in Tokyo, Nov 12';

  @override
  String get save => 'Save';

  @override
  String get noteSaved => 'Note saved';

  @override
  String get scanAnotherCard => 'Scan another card';

  @override
  String get backToHome => 'Back to home';

  @override
  String get unnamedCard => '(No name)';

  @override
  String get noSavedCards => 'No cards yet. Scan your first one!';

  @override
  String get savedCardsTitle => 'Saved cards';

  @override
  String get deleteCardTitle => 'Delete this card?';

  @override
  String get deleteCardMessage =>
      'The card and its photos will be removed from this device.';

  @override
  String get delete => 'Delete';

  @override
  String get cardDeleted => 'Card deleted';

  @override
  String get searchCardPlaceholder =>
      'Search by name, company, phone, notes...';

  @override
  String get filterAll => 'All';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get sortNameAZ => 'Name A-Z';

  @override
  String get filterHasNote => 'With note';

  @override
  String get noSearchResults => 'No cards found';

  @override
  String get noSearchResultsDesc =>
      'Try searching with different keywords or clear filters';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get scanCardAction => 'Scan new card';

  @override
  String cardsCount(int count) {
    return '$count cards';
  }

  @override
  String showingCardsCount(int filtered, int total) {
    return 'Showing $filtered of $total cards';
  }

  @override
  String get copiedPhone => 'Phone number copied';

  @override
  String get copiedEmail => 'Email address copied';

  @override
  String get editNote => 'Edit note';

  @override
  String get cardDetailTitle => 'Business card';

  @override
  String get edit => 'Edit';

  @override
  String get call => 'Call';

  @override
  String get map => 'Map';

  @override
  String get export => 'Export';

  @override
  String get meetingSectionTitle => 'Where & when you met';

  @override
  String get meetingEmptyPrompt =>
      'Add the date, place or a note to remember this contact';

  @override
  String get metDateLabel => 'Date met';

  @override
  String get metPlaceLabel => 'Place';

  @override
  String get metPlaceHint => 'e.g. IT Expo, Tokyo';

  @override
  String get noteLabel => 'Note';

  @override
  String get addTag => 'Tag';

  @override
  String get tagHint => 'Tag name, e.g. Client';

  @override
  String get removeTag => 'Remove tag';

  @override
  String addedOnLocal(String date) {
    return 'Added $date · Stored on this device only';
  }

  @override
  String get noImageForSide => 'No photo for this side';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get cannotOpenApp => 'No app available to open this';

  @override
  String get choosePhoneNumber => 'Choose a number to call';

  @override
  String get copied => 'Copied';

  @override
  String get postalCode => 'Postal code';

  @override
  String get editCardTitle => 'Edit card';

  @override
  String get cardUpdated => 'Card updated';

  @override
  String get cardNotFound => 'Card not found';

  @override
  String get deleteCard => 'Delete card';

  @override
  String ocrProcessingSide(String side, int index, int total) {
    return 'Recognizing $side ($index/$total)...';
  }

  @override
  String ocrSideFailed(String side) {
    return 'Could not read the $side; using the other side only';
  }

  @override
  String get assignLineTitle => 'Assign text to field:';

  @override
  String unmappedLinesCount(int count) {
    return 'Unassigned lines ($count)';
  }

  @override
  String get assignTo => 'Assign to...';

  @override
  String get noCardImage => 'No card photo yet';

  @override
  String get ocrFailed =>
      'Could not recognize text in the photo, please try again';

  @override
  String enterFieldHint(String field) {
    return 'Enter $field...';
  }
}
