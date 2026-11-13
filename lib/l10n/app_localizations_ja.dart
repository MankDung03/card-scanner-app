// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get closeAction => '閉じる';

  @override
  String get backAction => '戻る';

  @override
  String get navCards => '名刺一覧';

  @override
  String get captureFabLabel => '撮影';

  @override
  String get fabHide => '非表示にする';

  @override
  String get fabHiddenMsg => '撮影ボタンを非表示にしました。設定からいつでも戻せます。';

  @override
  String get sectionDisplay => '表示';

  @override
  String get showCaptureFab => '撮影ボタンを表示';

  @override
  String get showCaptureFabDesc => '名刺一覧・名刺の詳細に表示。ドラッグで移動、長押しで非表示にできます。';

  @override
  String get resetFabPosition => 'ボタンの位置をリセット';

  @override
  String get fabPositionReset => 'ボタンを右下に戻しました';

  @override
  String get settingsPageTitle => '設定';

  @override
  String get homeAction => 'ホーム';

  @override
  String get sectionPrivacyData => 'プライバシーとデータ';

  @override
  String get localOnlyTitle => '端末内のみに保存・アカウント不要';

  @override
  String get localOnlyBody => '名刺データはサーバーに送信されません';

  @override
  String get backupTitle => 'バックアップ';

  @override
  String get backupDesc => '最終バックアップ：未実施（データと画像を.zipで保存）';

  @override
  String get restoreTitle => 'バックアップから復元';

  @override
  String get restoreDesc => '保存した.zipファイルを選択';

  @override
  String get csvBulkTitle => 'CSVで一括出力';

  @override
  String cardsCountLong(int count) {
    return '$count件の名刺';
  }

  @override
  String get duplicateCheckTitle => '保存時に重複をチェック';

  @override
  String get duplicateCheckDesc => '氏名・会社名・メールで照合します';

  @override
  String get deleteAllTitle => 'すべてのデータを削除';

  @override
  String get deleteAllDesc => '削除前に確認が表示されます';

  @override
  String get deleteAllConfirmTitle => 'すべての名刺を削除しますか？';

  @override
  String deleteAllConfirmBody(int count) {
    return '$count件の名刺と画像がこの端末から完全に削除されます。元に戻せません。';
  }

  @override
  String get deleteAllDone => 'すべてのデータを削除しました';

  @override
  String get deleteAllFailed => '一部の名刺を削除できませんでした。もう一度お試しください。';

  @override
  String get displayLanguage => '表示言語';

  @override
  String get systemDefault => '端末の設定';

  @override
  String get ocrLanguageTitle => '優先する読み取り言語';

  @override
  String get ocrLangAuto => '自動';

  @override
  String get ocrLangJa => '日本語';

  @override
  String get ocrLangLatin => 'English・Việt';

  @override
  String get sectionOther => 'その他';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get rateApp => 'アプリを評価する';

  @override
  String get versionLabel => 'バージョン';

  @override
  String get comingSoonTag => '準備中';

  @override
  String get zoomHint => 'ピンチで拡大・縮小、ダブルタップで元のサイズ';

  @override
  String get saveImage => '画像を保存';

  @override
  String get imageSaved => '画像を写真に保存しました';

  @override
  String get imageSaveFailed => '画像を保存できませんでした';

  @override
  String get galleryPermissionDenied => '写真への保存が許可されていません';

  @override
  String get shareSheetTitle => 'エクスポート・共有';

  @override
  String thisCardSection(String name) {
    return 'この名刺（$name）';
  }

  @override
  String get saveToContactsDesc => '連絡先アプリで内容を確認して保存します';

  @override
  String get shareVcard => 'vCard（.vcf）で共有';

  @override
  String get shareVcardDesc => 'LINE・メール・ニアバイシェア など';

  @override
  String get storageInfoTitle => '保存先について';

  @override
  String get storageInfoBody =>
      'ファイルは端末内で作成され、共有メニューで保存先（ファイル・Google ドライブ・メールなど）を選べます。サーバーには送信されません。';

  @override
  String get exportCsv => 'CSV出力';

  @override
  String get csvDialogTitle => 'CSVファイルを出力しますか？';

  @override
  String get csvTarget => '対象';

  @override
  String csvTargetValue(int count) {
    return '$count件の名刺（すべて）';
  }

  @override
  String get csvFormat => '形式';

  @override
  String get csvFormatValue => 'CSV（UTF-8・Excel対応）';

  @override
  String get csvFileName => 'ファイル名';

  @override
  String get csvDestination => '保存先';

  @override
  String get csvDestinationValue => '出力後に表示される共有メニューで選択';

  @override
  String get csvPrivacyWarning => '個人情報が含まれます。共有先にご注意ください。';

  @override
  String get exportAction => '出力する';

  @override
  String get exportFailed => 'ファイルを出力できませんでした';

  @override
  String get csvCreatedAt => '登録日';

  @override
  String get tapToZoom => 'タップで拡大';

  @override
  String cardsCount(int count) {
    return '$count枚の名刺';
  }

  @override
  String get savedComplete => '保存完了';

  @override
  String get viewDetails => '詳細';

  @override
  String get addTagAction => 'タグを追加';

  @override
  String get sectionName => '氏名';

  @override
  String get sectionCompany => '会社情報';

  @override
  String get sectionContact => '連絡先';

  @override
  String stepProgress(int current, int total) {
    return 'ステップ $current/$total';
  }

  @override
  String get backSideOptional => '裏面（任意）';

  @override
  String get cameraHint => '明るい場所で、名刺を枠に合わせてください';

  @override
  String get appName => '名刺スキャン';

  @override
  String get addCardTitle => '名刺を登録する';

  @override
  String get addCardSubtitle => '撮影または写真を選ぶだけで、文字を自動で読み取ります。';

  @override
  String get captureCardTitle => 'カメラで撮影';

  @override
  String get captureCardSubtitle => '名刺を枠に合わせて撮影します';

  @override
  String get galleryCardTitle => '写真から選ぶ';

  @override
  String get galleryCardSubtitle => '保存済みの名刺画像を使います';

  @override
  String get recentlySaved => '最近登録した名刺';

  @override
  String viewAll(int count) {
    return 'すべて見る（$count件）';
  }

  @override
  String get offlineBadge => 'データはこの端末内にのみ保存されます';

  @override
  String get today => '今日';

  @override
  String get featureComingSoon => '次のステップで機能が有効化されます';

  @override
  String get settingsTitle => '設定＆オプション';

  @override
  String get themeTitle => '外観テーマ';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム連動';

  @override
  String get languageTitle => '言語';

  @override
  String get langVi => 'Tiếng Việt 🇻🇳';

  @override
  String get langJa => '日本語 🇯🇵';

  @override
  String get langEn => 'English 🇬🇧';

  @override
  String get frontSide => '表面';

  @override
  String get backSide => '裏面';

  @override
  String get alignCardTitle => '枠内に名刺を合わせてください';

  @override
  String get alignCardSubtitle => '規格サイズ 91 × 55 mm · カメラを水平に保持';

  @override
  String get stepFront => '1 - 表面';

  @override
  String get stepBackOptional => '2 - 裏面（任意）';

  @override
  String get gallery => '写真';

  @override
  String get cropAction => 'トリミング';

  @override
  String get cropTitle => '範囲を調整';

  @override
  String get changePhoto => '写真を変更';

  @override
  String get autoDetectedSuccess =>
      '名刺の範囲を自動で検出しました。ずれている場合は、四隅の丸をドラッグして調整してください。';

  @override
  String get rotate => '回転';

  @override
  String get autoAlign => '自動補正';

  @override
  String get addBackSide => '裏面を追加';

  @override
  String get recognizeText => '文字を読み取る';

  @override
  String get cameraPermissionRequired => '名刺撮影のためカメラ権限を許可してください';

  @override
  String get grantPermission => '権限を許可';

  @override
  String get cameraInitError => 'カメラの起動に失敗しました';

  @override
  String get processing => '画像を処理中...';

  @override
  String get ocrProcessing => '名刺の文字を認識中...';

  @override
  String get ocrSuccess => '文字認識が完了しました';

  @override
  String ocrBlocksCount(Object count) {
    return '$count テキストブロック';
  }

  @override
  String ocrLinesCount(Object count) {
    return '$count 行';
  }

  @override
  String get visualTab => '視覚的';

  @override
  String get rawTextTab => 'テキスト';

  @override
  String get blocksTab => 'ブロック';

  @override
  String get copyRawText => 'テキストを全コピー';

  @override
  String get copiedToClipboard => 'クリップボードにコピーしました';

  @override
  String get noTextDetected => '画像からテキストを検出できませんでした';

  @override
  String get verificationTitle => '内容の確認';

  @override
  String get retake => '撮り直す';

  @override
  String detectedFieldsCount(int count) {
    return '$count項目を読み取りました';
  }

  @override
  String needsReviewCount(int count) {
    return '$count項目は確認してください';
  }

  @override
  String get allClear => 'すべて明確に認識';

  @override
  String get byFieldsTab => '項目別';

  @override
  String get originalTextTab => '元テキスト';

  @override
  String get fullName => '氏名';

  @override
  String get furigana => 'ふりがな';

  @override
  String get needsReviewTag => '要確認';

  @override
  String get jobTitle => '役職';

  @override
  String get company => '会社名';

  @override
  String get department => '部署';

  @override
  String get phone => '電話';

  @override
  String get mobile => '携帯';

  @override
  String get fax => 'FAX';

  @override
  String get email => 'メール';

  @override
  String get address => '住所';

  @override
  String get website => 'ウェブサイト';

  @override
  String get notOnCardPlaceholder => '未入力';

  @override
  String get saveCard => 'この内容で保存する';

  @override
  String get editField => '項目を編集';

  @override
  String get cancel => 'キャンセル';

  @override
  String get done => '完了';

  @override
  String get cardSavedSuccess => '名刺を保存しました';

  @override
  String get cardSavedTitle => '名刺を保存しました';

  @override
  String get cardSavedSubtitle => 'この端末内にのみ保存されています。';

  @override
  String get cardSaveFailed => '名刺を保存できませんでした。もう一度お試しください';

  @override
  String get optionalActions => 'あわせて行う（任意）';

  @override
  String get saveToContacts => '端末の連絡先に保存';

  @override
  String get addMeetingNote => '出会った場所をメモ';

  @override
  String get meetingNoteHint => '例：11/12 東京のセミナーで';

  @override
  String get save => '保存';

  @override
  String get noteSaved => 'メモを保存しました';

  @override
  String get scanAnotherCard => '続けてスキャンする';

  @override
  String get backToHome => 'ホームに戻る';

  @override
  String get unnamedCard => '（名前なし）';

  @override
  String get noSavedCards => 'まだ名刺がありません。最初の1枚をスキャンしましょう！';

  @override
  String get savedCardsTitle => '名刺一覧';

  @override
  String get deleteCardTitle => 'この名刺を削除しますか？';

  @override
  String get deleteCardMessage => '名刺と画像がこの端末から削除されます。';

  @override
  String get delete => '削除';

  @override
  String get cardDeleted => '名刺を削除しました';

  @override
  String get searchCardPlaceholder => '名前、会社、電話番号、メモで検索...';

  @override
  String get filterAll => 'すべて';

  @override
  String get sortNewest => '最新順';

  @override
  String get sortOldest => '古い順';

  @override
  String get sortNameAZ => '名前順 (A-Z)';

  @override
  String get filterHasNote => 'メモあり';

  @override
  String get noSearchResults => '名刺が見つかりません';

  @override
  String get noSearchResultsDesc => 'キーワードを変更するか、フィルターを解除してください';

  @override
  String get clearSearch => '検索をクリア';

  @override
  String get scanCardAction => '新しい名刺をスキャン';

  @override
  String showingCardsCount(int filtered, int total) {
    return '$total枚中 $filtered枚を表示';
  }

  @override
  String get copiedPhone => '電話番号をコピーしました';

  @override
  String get copiedEmail => 'メールアドレスをコピーしました';

  @override
  String get editNote => 'メモを編集';

  @override
  String get cardDetailTitle => '名刺の詳細';

  @override
  String get edit => '編集';

  @override
  String get call => '電話';

  @override
  String get map => '地図';

  @override
  String get export => '共有';

  @override
  String get meetingSectionTitle => '交換情報・メモ';

  @override
  String get meetingEmptyPrompt => '日付・場所・メモを追加して思い出しやすくしましょう';

  @override
  String get metDateLabel => '名刺交換日';

  @override
  String get metPlaceLabel => '交換場所';

  @override
  String get metPlaceHint => '例：ITエキスポ 東京';

  @override
  String get noteLabel => 'メモ';

  @override
  String get addTag => 'タグ';

  @override
  String get tagHint => 'タグ名（例：顧客）';

  @override
  String get removeTag => 'タグを削除';

  @override
  String addedOnLocal(String date) {
    return '$date に追加 · この端末のみに保存';
  }

  @override
  String get noImageForSide => 'この面の画像はありません';

  @override
  String get addPhoto => '画像を追加';

  @override
  String get cannotOpenApp => '対応するアプリを開けません';

  @override
  String get choosePhoneNumber => '発信する番号を選択';

  @override
  String get copied => 'コピーしました';

  @override
  String get postalCode => '郵便番号';

  @override
  String get editCardTitle => '名刺を編集';

  @override
  String get cardUpdated => '名刺を更新しました';

  @override
  String get cardNotFound => '名刺が見つかりません';

  @override
  String get deleteCard => '名刺を削除';

  @override
  String ocrProcessingSide(String side, int index, int total) {
    return '$sideを認識中（$index/$total）...';
  }

  @override
  String ocrSideFailed(String side) {
    return '$sideを認識できませんでした。もう一方の面の情報のみ使用します';
  }

  @override
  String get assignLineTitle => '割り当てる項目：';

  @override
  String unmappedLinesCount(int count) {
    return '未割り当ての行（$count）';
  }

  @override
  String get assignTo => '割り当て...';

  @override
  String get noCardImage => '名刺の画像がありません';

  @override
  String get ocrFailed => '文字を認識できませんでした。もう一度お試しください';

  @override
  String enterFieldHint(String field) {
    return '$fieldを入力...';
  }

  @override
  String get sortBy => '並べ替え';

  @override
  String get sortCompanyAZ => '会社名順';

  @override
  String get noCompanyGroup => '会社名なし';

  @override
  String get clearFilters => '絞り込みを解除';

  @override
  String get onImageTab => '画像で確認';

  @override
  String get tapLinesHint => '画像の文字行をタップして選択し（複数可）、項目に割り当てます';

  @override
  String get lineAssigned => '入力済み';

  @override
  String get lineUnassigned => '未使用';

  @override
  String selectedLinesCount(int count) {
    return '$count行を選択中';
  }

  @override
  String get clearSelection => '選択解除';

  @override
  String get assignTextLabel => '割り当てるテキスト';

  @override
  String get replaceValue => '置き換え';

  @override
  String get appendValue => '追記';

  @override
  String get assign => '割り当て';

  @override
  String assignedToField(String field) {
    return '$fieldに割り当てました';
  }

  @override
  String get undo => '元に戻す';

  @override
  String get emptyValue => '（空）';
}
