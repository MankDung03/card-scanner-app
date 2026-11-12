import 'dart:ui';

import 'package:app_scanner_card/features/scan/domain/entities/business_card_info.dart';
import 'package:app_scanner_card/features/scan/domain/entities/ocr_model.dart';
import 'package:app_scanner_card/features/scan/domain/services/card_info_merger.dart';
import 'package:flutter_test/flutter_test.dart';

OcrLine _line(String id, String text) => OcrLine(
      id: id,
      text: text,
      normalizedText: text,
      boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
    );

void main() {
  group('CardInfoMerger', () {
    test('only one side → returned as-is with prefixed line ids', () {
      final front = BusinessCardInfo(name: '山田 太郎', unmappedLines: [_line('l1', 'x')]);
      final merged = CardInfoMerger.merge(front, null);
      expect(merged.name, '山田 太郎');
      expect(merged.unmappedLines.single.id, 'f_l1');

      final backOnly = CardInfoMerger.merge(null, const BusinessCardInfo(email: 'a@b.jp'));
      expect(backOnly.email, 'a@b.jp');

      expect(CardInfoMerger.merge(null, null).recognizedCount, 0);
    });

    test('Japanese front + English back: front wins, back values become suggestions', () {
      const front = BusinessCardInfo(
        name: '山田 太郎',
        furigana: 'やまだ たろう',
        jobTitle: '部長',
        company: '株式会社サンプル商事',
        phone: '03-1234-5678',
        address: '東京都千代田区千代田1-1-1',
      );
      const back = BusinessCardInfo(
        name: 'Taro Yamada',
        jobTitle: 'General Manager',
        company: 'Sample Trading Co., Ltd.',
        phone: '+81-3-1234-5678', // cùng số, khác định dạng
        mobile: '+81-90-1234-5678', // chỉ mặt sau có
        email: 'taro.yamada@sample.example',
      );

      final merged = CardInfoMerger.merge(front, back);

      expect(merged.name, '山田 太郎');
      expect(merged.alternatives['name'], ['Taro Yamada']);
      expect(merged.jobTitle, '部長');
      expect(merged.alternatives['jobTitle'], ['General Manager']);
      expect(merged.company, '株式会社サンプル商事');
      expect(merged.alternatives['company'], ['Sample Trading Co., Ltd.']);

      // Cùng số điện thoại → không thành gợi ý trùng
      expect(merged.phone, '03-1234-5678');
      expect(merged.alternatives['phone'], isNull);

      // Trường chỉ có ở mặt sau được điền vào
      expect(merged.mobile, '+81-90-1234-5678');
      expect(merged.email, 'taro.yamada@sample.example');
      expect(merged.furigana, 'やまだ たろう');
      expect(merged.address, '東京都千代田区千代田1-1-1');
    });

    test('equal values after normalisation are not duplicated', () {
      const front = BusinessCardInfo(email: 'Taro@Sample.JP', website: 'https://www.sample.jp/');
      const back = BusinessCardInfo(email: 'taro@sample.jp', website: 'sample.jp');
      final merged = CardInfoMerger.merge(front, back);
      expect(merged.email, 'Taro@Sample.JP');
      expect(merged.alternatives, isEmpty);
    });

    test('review flags follow the side the value came from', () {
      const front = BusinessCardInfo(
        name: '山田 太郎',
        reviewFlags: {'name': true, 'company': true}, // company rỗng ở mặt trước
      );
      const back = BusinessCardInfo(
        name: 'Taro Yamada',
        company: 'Sample Co.',
        email: 'a@b.jp',
        reviewFlags: {'email': true},
      );
      final merged = CardInfoMerger.merge(front, back);
      expect(merged.isFieldNeedsReview('name'), isTrue);
      expect(merged.isFieldNeedsReview('company'), isFalse, reason: 'company lấy từ mặt sau, mặt sau không gắn cờ');
      expect(merged.isFieldNeedsReview('email'), isTrue);
      expect(merged.reviewNeededCount, 2);
    });

    test('existing alternatives of both sides are kept without duplicates', () {
      const front = BusinessCardInfo(
        company: 'A社',
        alternatives: {'company': ['B社']},
      );
      const back = BusinessCardInfo(
        company: 'B社',
        alternatives: {'company': ['C Inc.', 'A社']},
      );
      final merged = CardInfoMerger.merge(front, back);
      expect(merged.company, 'A社');
      expect(merged.alternatives['company'], ['B社', 'C Inc.']);
    });

    test('unmapped lines of both sides are merged with unique ids', () {
      final front = BusinessCardInfo(unmappedLines: [_line('l1', 'front text')]);
      final back = BusinessCardInfo(unmappedLines: [_line('l1', 'back text')]);
      final merged = CardInfoMerger.merge(front, back);
      expect(merged.unmappedLines.map((l) => l.id), ['f_l1', 'b_l1']);
      expect(merged.unmappedLines.map((l) => l.text), ['front text', 'back text']);

      // Gán một dòng chỉ xoá đúng dòng đó
      final assigned = merged.assignUnmappedLine(merged.unmappedLines.last, 'department');
      expect(assigned.department, 'back text');
      expect(assigned.unmappedLines.single.text, 'front text');
    });
  });
}
