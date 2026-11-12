import 'package:app_scanner_card/core/services/app_settings_storage.dart';
import 'package:app_scanner_card/features/cards/domain/entities/saved_card.dart';
import 'package:app_scanner_card/features/cards/domain/services/card_list_query.dart';
import 'package:app_scanner_card/features/cards/presentation/cubit/card_sort_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

int _seq = 0;

SavedCard _card({
  String? name,
  String? furigana,
  String? company,
  String? note,
  List<String> tags = const [],
  String? metPlace,
  DateTime? createdAt,
}) {
  final at = createdAt ?? DateTime(2026, 1, 1).add(Duration(minutes: _seq));
  return SavedCard(
    id: '${_seq++}',
    name: name,
    furigana: furigana,
    company: company,
    note: note,
    tags: tags,
    metPlace: metPlace,
    createdAt: at,
    updatedAt: at,
  );
}

List<String?> _names(List<SavedCard> cards) => cards.map((c) => c.name).toList();

void main() {
  group('fold', () {
    test('removes Vietnamese diacritics, đ → d, lowercases', () {
      expect(CardListQuery.fold('Đặng Thị Ẩn Ữ Ỹ'), 'dang thi an u y');
      expect(CardListQuery.fold('Nguyễn Hoàng Phúc'), 'nguyen hoang phuc');
      // Dạng tổ hợp (NFD): "e" + dấu ngã
      expect(CardListQuery.fold('Nguyẽn'), 'nguyen');
    });

    test('katakana → hiragana, full-width → half-width', () {
      expect(CardListQuery.fold('ヤマダ タロウ'), 'やまだ たろう');
      expect(CardListQuery.fold('ＡＢＣ１２３'), 'abc123');
    });
  });

  group('filtering', () {
    final cards = [
      _card(name: 'Đặng Văn An', company: 'Công ty TNHH ABC', tags: ['Khách hàng']),
      _card(name: '山田 太郎', furigana: 'やまだ たろう', tags: ['Sự kiện'], note: 'Gặp ở Tokyo'),
      _card(name: 'John Smith', metPlace: 'IT Expo', tags: ['Khách hàng', 'Đối tác']),
      _card(name: 'No Tag'),
    ];

    test('search ignores diacritics and covers furigana, place, tags', () {
      expect(_names(const CardListQuery(search: 'dang van').apply(cards)), ['Đặng Văn An']);
      expect(_names(const CardListQuery(search: 'ヤマダ').apply(cards)), ['山田 太郎']);
      expect(_names(const CardListQuery(search: 'expo').apply(cards)), ['John Smith']);
      expect(_names(const CardListQuery(search: 'doi tac').apply(cards)), ['John Smith']);
    });

    test('multiple tags → cards with at least one selected tag', () {
      final result = const CardListQuery(tags: {'Sự kiện', 'Đối tác'}).apply(cards);
      expect(_names(result).toSet(), {'山田 太郎', 'John Smith'});
    });

    test('filters combine: has note + tag + search', () {
      expect(
        _names(const CardListQuery(hasNoteOnly: true, tags: {'Sự kiện'}, search: 'tokyo').apply(cards)),
        ['山田 太郎'],
      );
      expect(const CardListQuery(hasNoteOnly: true, tags: {'Khách hàng'}).apply(cards), isEmpty);
      expect(const CardListQuery().isFiltering, isFalse);
      expect(const CardListQuery(sort: CardSortOrder.companyAZ).isFiltering, isFalse);
    });

    test('tagsByUsage: most used first', () {
      expect(CardListQuery.tagsByUsage(cards), ['Khách hàng', 'Đối tác', 'Sự kiện']);
    });
  });

  group('sorting', () {
    test('name A-Z: Vietnamese without diacritics, Japanese by furigana, unnamed last', () {
      final cards = [
        _card(name: 'Trần Bình'),
        _card(name: 'Đặng An'), // "dang" → trước "tran"
        _card(name: null, company: null),
        _card(name: 'Ánh Dương'), // "anh" → đầu tiên
        _card(name: '渡辺 健', furigana: 'わたなべ けん'),
        _card(name: '青木 花子', furigana: 'あおき はなこ'),
      ];
      expect(
        _names(const CardListQuery(sort: CardSortOrder.nameAZ).apply(cards)),
        ['Ánh Dương', 'Đặng An', 'Trần Bình', '青木 花子', '渡辺 健', null],
      );
    });

    test('newest / oldest by creation time', () {
      final a = _card(name: 'A', createdAt: DateTime(2026, 1, 1));
      final b = _card(name: 'B', createdAt: DateTime(2026, 3, 1));
      expect(_names(const CardListQuery().apply([a, b])), ['B', 'A']);
      expect(_names(const CardListQuery(sort: CardSortOrder.oldest).apply([a, b])), ['A', 'B']);
    });

    test('company A-Z ignores legal forms, no company last, grouped', () {
      final cards = [
        _card(name: 'No company'),
        _card(name: 'Z', company: 'Công ty TNHH Zeta'),
        _card(name: 'Y1', company: '株式会社サンプル商事'),
        _card(name: 'A1', company: 'Alpha Co., Ltd.'),
        _card(name: 'Y2', company: '(株)サンプル商事'),
        _card(name: 'B1', company: 'Công ty Cổ phần Beta'),
      ];

      final sorted = const CardListQuery(sort: CardSortOrder.companyAZ).apply(cards);
      expect(_names(sorted), ['A1', 'B1', 'Z', 'Y1', 'Y2', 'No company']);

      final groups = CardListQuery.groupByCompany(sorted);
      expect(groups.map((g) => g.cards.length), [1, 1, 1, 2, 1]);
      expect(groups[3].company, '株式会社サンプル商事', reason: '株式会社 và (株) cùng một công ty');
      expect(groups.last.company, isNull);
    });

    test('companySortKey strips legal forms', () {
      // Khoá đã chuẩn hoá (katakana → hiragana); tiêu đề nhóm vẫn hiện tên gốc
      expect(CardListQuery.companySortKey('株式会社サンプル商事'), 'さんぷる商事');
      expect(CardListQuery.companySortKey('Công ty TNHH MTV Hoàng Long'), 'hoang long');
      expect(CardListQuery.companySortKey('Sample Trading Co., Ltd.'), 'sample trading');
      expect(CardListQuery.companySortKey('  '), isNull);
      expect(CardListQuery.companySortKey(null), isNull);
    });
  });

  group('CardSortCubit', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('remembers the chosen sort order across restarts', () async {
      final storage = await AppSettingsStorage.load();
      expect(CardSortCubit(storage: storage).state, CardSortOrder.newest);

      await CardSortCubit(storage: storage).setSort(CardSortOrder.companyAZ);

      final restarted = await AppSettingsStorage.load();
      expect(CardSortCubit(storage: restarted).state, CardSortOrder.companyAZ);
    });

    test('unknown saved value falls back to newest', () async {
      SharedPreferences.setMockInitialValues({'settings.card_sort_order': 'bogus'});
      expect(CardSortCubit(storage: await AppSettingsStorage.load()).state, CardSortOrder.newest);
    });
  });
}
