// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => '名刺スキャン';

  @override
  String get addCardTitle => '名刺を追加';

  @override
  String get addCardSubtitle => '名刺の取り込み方法を選択してください';

  @override
  String get captureCardTitle => '撮影する';

  @override
  String get captureCardSubtitle => 'カメラを起動、名刺枠に合わせます';

  @override
  String get galleryCardTitle => 'アルバムから選択';

  @override
  String get galleryCardSubtitle => '端末内の名刺画像を使用します';

  @override
  String get recentlySaved => '最近保存した名刺';

  @override
  String viewAll(int count) {
    return 'すべて見る ($count)';
  }

  @override
  String get offlineBadge => '100% オンデバイス・完全オフライン';

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
  String get gallery => 'アルバム';

  @override
  String get cropAction => 'トリミング';

  @override
  String get cropTitle => '画像調整';

  @override
  String get changePhoto => '画像変更';

  @override
  String get autoDetectedSuccess => '枠を自動認識しました · 必要に応じて4隅を調整';

  @override
  String get rotate => '回転';

  @override
  String get autoAlign => '自動調整';

  @override
  String get addBackSide => '裏面を追加';

  @override
  String get recognizeText => '文字認識を開始';

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
  String get verificationTitle => '情報確認';

  @override
  String get retake => '撮り直す';

  @override
  String detectedFieldsCount(int count) {
    return '$count 項目を認識';
  }

  @override
  String needsReviewCount(int count) {
    return '$count 項目要確認';
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
  String get phone => '電話番号';

  @override
  String get mobile => '携帯番号';

  @override
  String get fax => 'FAX';

  @override
  String get email => 'メール';

  @override
  String get address => '住所';

  @override
  String get website => 'ウェブサイト';

  @override
  String get notOnCardPlaceholder => '記載なし — 必要に応じて入力';

  @override
  String get saveCard => '名刺を保存';

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
  String get cardSavedSubtitle => 'この端末のアプリに保存しました。';

  @override
  String get cardSaveFailed => '名刺を保存できませんでした。もう一度お試しください';

  @override
  String get optionalActions => 'その他（任意）';

  @override
  String get saveToContacts => '連絡先に保存';

  @override
  String get addMeetingNote => '出会った場所をメモ';

  @override
  String get meetingNoteHint => '例：11/12 東京のセミナーで';

  @override
  String get save => '保存';

  @override
  String get noteSaved => 'メモを保存しました';

  @override
  String get scanAnotherCard => '別の名刺をスキャン';

  @override
  String get backToHome => 'ホームに戻る';

  @override
  String get unnamedCard => '（名前なし）';

  @override
  String get noSavedCards => 'まだ名刺がありません。最初の1枚をスキャンしましょう！';

  @override
  String get savedCardsTitle => '保存した名刺';

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
  String cardsCount(int count) {
    return '$count枚の名刺';
  }

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
  String get cardDetailTitle => '名刺';

  @override
  String get edit => '編集';

  @override
  String get call => '電話';

  @override
  String get map => '地図';

  @override
  String get export => '書き出し';

  @override
  String get meetingSectionTitle => '出会った場所・日時';

  @override
  String get meetingEmptyPrompt => '日付・場所・メモを追加して思い出しやすくしましょう';

  @override
  String get metDateLabel => '日付';

  @override
  String get metPlaceLabel => '場所';

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
}
