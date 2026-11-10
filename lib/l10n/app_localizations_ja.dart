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
  String get visualTab => '視覚的オーバーレイ';

  @override
  String get rawTextTab => '抽出テキスト';

  @override
  String get blocksTab => 'ブロックと座標';

  @override
  String get copyRawText => 'テキストを全コピー';

  @override
  String get copiedToClipboard => 'クリップボードにコピーしました';

  @override
  String get noTextDetected => '画像からテキストを検出できませんでした';
}
