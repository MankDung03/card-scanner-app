// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get closeAction => 'Close';

  @override
  String get backAction => 'Back';

  @override
  String get navCards => 'Cards';

  @override
  String get captureFabLabel => 'Scan';

  @override
  String get fabHide => 'Hide this button';

  @override
  String get fabHiddenMsg =>
      'Capture button hidden. Turn it back on in Settings.';

  @override
  String get sectionDisplay => 'Display';

  @override
  String get showCaptureFab => 'Show floating capture button';

  @override
  String get showCaptureFabDesc =>
      'On the card list and card details. Drag to move, long-press to hide.';

  @override
  String get resetFabPosition => 'Reset button position';

  @override
  String get fabPositionReset => 'Button moved back to the bottom right';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get homeAction => 'Home';

  @override
  String get sectionPrivacyData => 'Privacy & data';

  @override
  String get localOnlyTitle => 'Stored on this device only · No account';

  @override
  String get localOnlyBody => 'Card data is never sent to a server';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupDesc => 'Last backup: never (saves data and images as .zip)';

  @override
  String get restoreTitle => 'Restore from backup';

  @override
  String get restoreDesc => 'Choose a saved .zip file';

  @override
  String get csvBulkTitle => 'Export all as CSV';

  @override
  String cardsCountLong(int count) {
    return '$count cards';
  }

  @override
  String get duplicateCheckTitle => 'Check for duplicates when saving';

  @override
  String get duplicateCheckDesc => 'Matches by name, company and email';

  @override
  String get deleteAllTitle => 'Delete all data';

  @override
  String get deleteAllDesc => 'You\'ll be asked to confirm first';

  @override
  String get deleteAllConfirmTitle => 'Delete all cards?';

  @override
  String deleteAllConfirmBody(int count) {
    return '$count cards and their images will be permanently deleted from this device. This can\'t be undone.';
  }

  @override
  String get deleteAllDone => 'All data deleted';

  @override
  String get deleteAllFailed =>
      'Some cards couldn\'t be deleted. Please try again.';

  @override
  String get displayLanguage => 'Display language';

  @override
  String get systemDefault => 'System default';

  @override
  String get ocrLanguageTitle => 'Preferred reading language';

  @override
  String get ocrLangAuto => 'Auto';

  @override
  String get ocrLangJa => '日本語';

  @override
  String get ocrLangLatin => 'English・Việt';

  @override
  String get sectionOther => 'Other';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get rateApp => 'Rate this app';

  @override
  String get versionLabel => 'Version';

  @override
  String get comingSoonTag => 'Soon';

  @override
  String get zoomHint => 'Pinch to zoom, double-tap to reset';

  @override
  String get saveImage => 'Save image';

  @override
  String get imageSaved => 'Image saved to your photos';

  @override
  String get imageSaveFailed => 'Couldn\'t save the image';

  @override
  String get galleryPermissionDenied => 'Permission to save photos was denied';

  @override
  String get shareSheetTitle => 'Export & Share';

  @override
  String thisCardSection(String name) {
    return 'This card ($name)';
  }

  @override
  String get saveToContactsDesc => 'Review and save in your Contacts app';

  @override
  String get shareVcard => 'Share as vCard (.vcf)';

  @override
  String get shareVcardDesc => 'LINE, email, Nearby Share, etc.';

  @override
  String get storageInfoTitle => 'About file storage';

  @override
  String get storageInfoBody =>
      'Files are created on this device. Choose where to save them (Files, Google Drive, email…) from the share menu. Nothing is sent to a server.';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get csvDialogTitle => 'Export a CSV file?';

  @override
  String get csvTarget => 'Cards';

  @override
  String csvTargetValue(int count) {
    return '$count cards (all)';
  }

  @override
  String get csvFormat => 'Format';

  @override
  String get csvFormatValue => 'CSV (UTF-8, Excel compatible)';

  @override
  String get csvFileName => 'File name';

  @override
  String get csvDestination => 'Save to';

  @override
  String get csvDestinationValue => 'Choose in the share menu after export';

  @override
  String get csvPrivacyWarning =>
      'Contains personal information. Be careful who you share it with.';

  @override
  String get exportAction => 'Export';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get csvCreatedAt => 'Added on';

  @override
  String get tapToZoom => 'Tap to zoom';

  @override
  String cardsCount(int count) {
    return '$count cards';
  }

  @override
  String get savedComplete => 'Saved';

  @override
  String get viewDetails => 'Details';

  @override
  String get addTagAction => 'Add tag';

  @override
  String get sectionName => 'Name';

  @override
  String get sectionCompany => 'Company';

  @override
  String get sectionContact => 'Contact';

  @override
  String stepProgress(int current, int total) {
    return 'Step $current/$total';
  }

  @override
  String get backSideOptional => 'Back (optional)';

  @override
  String get cameraHint => 'Fit the card in the frame, in good light';

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

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortCompanyAZ => 'Company A-Z';

  @override
  String get noCompanyGroup => 'No company';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get onImageTab => 'On photo';

  @override
  String get tapLinesHint =>
      'Tap text lines on the photo to select them (multiple allowed), then assign to a field';

  @override
  String get lineAssigned => 'In form';

  @override
  String get lineUnassigned => 'Not used';

  @override
  String selectedLinesCount(int count) {
    return '$count lines selected';
  }

  @override
  String get clearSelection => 'Clear';

  @override
  String get assignTextLabel => 'Text to assign';

  @override
  String get replaceValue => 'Replace';

  @override
  String get appendValue => 'Append';

  @override
  String get assign => 'Assign';

  @override
  String assignedToField(String field) {
    return 'Assigned to $field';
  }

  @override
  String get undo => 'Undo';

  @override
  String get emptyValue => '(empty)';
}
