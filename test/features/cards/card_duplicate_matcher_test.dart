import 'package:app_scanner_card/features/cards/domain/entities/saved_card.dart';
import 'package:app_scanner_card/features/cards/domain/services/card_duplicate_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

SavedCard card(
  String id, {
  String? name,
  String? company,
  String? phone,
  String? mobile,
  String? email,
  String? note,
  List<String> tags = const [],
}) {
  final t = DateTime(2026, 1, 1);
  return SavedCard(
    id: id,
    name: name,
    company: company,
    phone: phone,
    mobile: mobile,
    email: email,
    note: note,
    tags: tags,
    createdAt: t,
    updatedAt: t,
  );
}

void main() {
  group('chuẩn hoá', () {
    test('toàn góc → bán góc, tên bỏ khoảng trắng', () {
      expect(CardDuplicateMatcher.nameKey('山田　太郎'), CardDuplicateMatcher.nameKey('山田太郎'));
      expect(CardDuplicateMatcher.nameKey('Ｙａｍａｄａ Taro'), 'yamadataro');
    });

    test('số điện thoại: chỉ chữ số, +81 → 0, toàn góc', () {
      expect(CardDuplicateMatcher.phoneDigits('+81 3-1234-5678'), '0312345678');
      expect(CardDuplicateMatcher.phoneDigits('03(1234)5678'), '0312345678');
      expect(CardDuplicateMatcher.phoneDigits('０３－１２３４－５６７８'), '0312345678');
      expect(CardDuplicateMatcher.phoneDigits('123'), isNull); // quá ngắn
    });

    test('công ty bỏ loại hình', () {
      final k = CardDuplicateMatcher.companyKey('株式会社サンプル商事');
      expect(CardDuplicateMatcher.companyKey('(株)サンプル商事'), k);
      expect(CardDuplicateMatcher.companyKey('（株）サンプル商事'), k);
      expect(CardDuplicateMatcher.companyKey('㈱サンプル商事'), k);
      expect(CardDuplicateMatcher.companyKey('サンプル商事 株式会社'), k);
      expect(CardDuplicateMatcher.companyKey('Sample Co., Ltd.'), CardDuplicateMatcher.companyKey('SAMPLE Inc.'));
    });

    test('email chung không tính là email cá nhân', () {
      expect(CardDuplicateMatcher.personalEmail('Taro.Yamada@Sample.jp'), 'taro.yamada@sample.jp');
      expect(CardDuplicateMatcher.personalEmail('info@sample.jp'), isNull);
      expect(CardDuplicateMatcher.personalEmail('SALES@sample.jp'), isNull);
      expect(CardDuplicateMatcher.personalEmail('not-an-email'), isNull);
    });
  });

  group('quy tắc trùng', () {
    test('Mạnh: cùng email cá nhân', () {
      expect(
        CardDuplicateMatcher.matchReason(card('a', email: 'taro@x.jp'), card('b', email: 'TARO@x.jp')),
        DuplicateReason.email,
      );
    });

    test('Mạnh: cùng di động (kể cả đổi công ty)', () {
      expect(
        CardDuplicateMatcher.matchReason(
          card('a', name: '山田 太郎', company: 'A社', mobile: '090-1111-2222'),
          card('b', name: '山田 太郎', company: 'B社', mobile: '09011112222'),
        ),
        DuplicateReason.mobile,
      );
    });

    test('Trung bình: cùng tên + cùng công ty / cùng máy bàn', () {
      expect(
        CardDuplicateMatcher.matchReason(
          card('a', name: '山田 太郎', company: '株式会社サンプル'),
          card('b', name: '山田太郎', company: '(株)サンプル'),
        ),
        DuplicateReason.nameAndCompany,
      );
      expect(
        CardDuplicateMatcher.matchReason(
          card('a', name: '山田 太郎', phone: '03-1234-5678'),
          card('b', name: '山田 太郎', phone: '0312345678'),
        ),
        DuplicateReason.nameAndPhone,
      );
    });

    test('Không tính: chỉ trùng tên / công ty / máy bàn / email chung', () {
      expect(CardDuplicateMatcher.matchReason(card('a', name: '佐藤 健'), card('b', name: '佐藤 健')), isNull);
      expect(CardDuplicateMatcher.matchReason(card('a', company: 'X社'), card('b', company: 'X社')), isNull);
      expect(
        CardDuplicateMatcher.matchReason(
          card('a', name: '佐藤 健', phone: '03-1111-1111'),
          card('b', name: '田中 誠', phone: '03-1111-1111'),
        ),
        isNull,
      );
      expect(
        CardDuplicateMatcher.matchReason(card('a', email: 'info@x.jp'), card('b', email: 'info@x.jp')),
        isNull,
      );
    });

    test('findDuplicate ưu tiên mức Mạnh, bỏ qua chính nó', () {
      final target = card('t', name: '山田 太郎', company: 'X社', mobile: '090-1111-2222');
      final medium = card('m', name: '山田 太郎', company: 'X社');
      final strong = card('s', mobile: '09011112222');
      final match = CardDuplicateMatcher.findDuplicate(target, [target, medium, strong]);
      expect(match?.card.id, 's');
      expect(match?.isStrong, isTrue);
    });
  });

  group('giống hệt', () {
    test('khác định dạng nhưng cùng nội dung → giống hệt', () {
      expect(
        CardDuplicateMatcher.isIdentical(
          card('a', name: '山田 太郎', phone: '03-1234-5678', tags: ['A', 'B']),
          card('b', name: '山田太郎', phone: '０３１２３４５６７８', tags: ['B', 'A']),
        ),
        isTrue,
      );
    });

    test('khác ghi chú → không giống hệt', () {
      expect(
        CardDuplicateMatcher.isIdentical(card('a', name: 'X', note: '1'), card('b', name: 'X', note: '2')),
        isFalse,
      );
    });
  });
}
