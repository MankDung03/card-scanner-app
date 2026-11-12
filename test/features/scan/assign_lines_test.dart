import 'dart:ui';

import 'package:app_scanner_card/features/scan/domain/entities/business_card_info.dart';
import 'package:app_scanner_card/features/scan/domain/entities/ocr_model.dart';
import 'package:app_scanner_card/features/scan/domain/services/ocr_line_field_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

OcrLine _line(String id, String text) => OcrLine(
      id: id,
      text: text,
      normalizedText: text,
      boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
    );

void main() {
  group('BusinessCardInfo.assignText', () {
    final info = BusinessCardInfo(
      name: 'Taro',
      address: '東京都千代田区',
      reviewFlags: const {'address': true, 'name': true},
      unmappedLines: [_line('a', '千代田1-1-1'), _line('b', 'www.sample.co.jp')],
    );

    test('replace sets value, clears review flag, removes consumed unmapped lines', () {
      final r = info.assignText('website', ' www.sample.co.jp ', consumedLineTexts: ['www.sample.co.jp']);
      expect(r.website, 'www.sample.co.jp');
      expect(r.isFieldNeedsReview('website'), isFalse);
      expect(r.unmappedLines.map((l) => l.id), ['a']);
      expect(r.name, 'Taro', reason: 'trường khác không đổi');
    });

    test('append joins with a space and clears the review flag', () {
      final r = info.assignText('address', '千代田1-1-1', append: true, consumedLineTexts: ['千代田1-1-1']);
      expect(r.address, '東京都千代田区 千代田1-1-1');
      expect(r.isFieldNeedsReview('address'), isFalse);
      expect(r.isFieldNeedsReview('name'), isTrue);
      expect(r.unmappedLines.map((l) => l.id), ['b']);
    });

    test('append on empty field behaves like replace', () {
      expect(info.assignText('email', 'a@b.jp', append: true).email, 'a@b.jp');
    });

    test('empty text or unknown field is a no-op', () {
      expect(identical(info.assignText('email', '   '), info), isTrue);
      expect(identical(info.assignText('bogus', 'x'), info), isTrue);
    });

    test('fieldValue covers every field key', () {
      const full = BusinessCardInfo(
        name: '1', furigana: '2', jobTitle: '3', department: '4', company: '5', phone: '6',
        mobile: '7', fax: '8', email: '9', website: '10', postalCode: '11', address: '12',
      );
      expect(BusinessCardInfo.fieldKeys.map(full.fieldValue), List.generate(12, (i) => '${i + 1}'));
    });
  });

  group('OcrLineFieldMatcher', () {
    const info = BusinessCardInfo(
      name: '山田 太郎',
      company: '株式会社サンプル商事',
      phone: '03-1234-5678',
      email: 'taro@sample.co.jp',
      address: '東京都千代田区千代田1-1-1',
    );

    test('phone line with label and different formatting matches by digits', () {
      expect(OcrLineFieldMatcher.fieldOf(info, 'TEL: (03) 1234 5678'), 'phone');
    });

    test('line containing a field value with a label matches', () {
      expect(OcrLineFieldMatcher.fieldOf(info, 'E-mail taro@sample.co.jp'), 'email');
    });

    test('line that is part of a longer field (multi-line address) matches', () {
      expect(OcrLineFieldMatcher.fieldOf(info, '千代田1-1-1'), 'address');
      expect(OcrLineFieldMatcher.fieldOf(info, '山田太郎'), 'name', reason: 'bỏ qua khoảng trắng');
    });

    test('unused line and single characters are not matched', () {
      expect(OcrLineFieldMatcher.fieldOf(info, 'www.sample.co.jp'), isNull);
      expect(OcrLineFieldMatcher.fieldOf(info, '田'), isNull);
      expect(OcrLineFieldMatcher.fieldOf(info, '   '), isNull);
    });
  });
}
