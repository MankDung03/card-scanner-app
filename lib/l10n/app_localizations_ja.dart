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
  String get offlineBadge => '端末内で安全に処理 · ネット不要';

  @override
  String get today => '今日';

  @override
  String get featureComingSoon => 'この機能は次のステップで有効化されます';

  @override
  String get settingsTitle => '設定と環境設定';

  @override
  String get themeTitle => 'テーマ';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム';

  @override
  String get languageTitle => '言語';

  @override
  String get langVi => 'Tiếng Việt 🇻🇳';

  @override
  String get langJa => '日本語 🇯🇵';

  @override
  String get langEn => 'English 🇬🇧';
}
