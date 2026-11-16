import 'dart:ui';

import 'package:app_scanner_card/features/cards/domain/entities/saved_card.dart';
import 'package:app_scanner_card/features/cards/domain/services/card_duplicate_matcher.dart';
import 'package:app_scanner_card/features/cards/domain/services/card_export.dart';
import 'package:app_scanner_card/features/cards/domain/services/card_list_query.dart';
import 'package:app_scanner_card/features/scan/domain/entities/business_card_info.dart';
import 'package:app_scanner_card/features/scan/domain/entities/custom_field.dart';
import 'package:app_scanner_card/features/scan/domain/entities/ocr_model.dart';
import 'package:app_scanner_card/features/scan/domain/services/custom_field_labels.dart';
import 'package:app_scanner_card/features/scan/domain/services/ocr_line_order.dart';
import 'package:app_scanner_card/features/scan/presentation/widgets/assign_lines_bottom_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

OcrLine _line(String id, String text, Rect box, {bool? vertical}) =>
    OcrLine(id: id, text: text, normalizedText: text, boundingBox: box, isVertical: vertical);

void main() {
  group('OcrLineOrder.sort', () {
    test('chữ ngang: hàng trên trước, trong hàng trái → phải (lệch nhẹ vẫn cùng hàng)', () {
      final lines = [
        _line('c', 'C', const Rect.fromLTWH(10, 60, 80, 20)),
        _line('b', 'B', const Rect.fromLTWH(200, 14, 80, 20)), // cùng hàng với A, lệch 4px
        _line('a', 'A', const Rect.fromLTWH(10, 10, 80, 20)),
      ];
      final sorted = OcrLineOrder.sort(lines, rect: (l) => l.boundingBox, isVertical: (l) => l.isVertical);
      expect(sorted.map((l) => l.text), ['A', 'B', 'C']);
    });

    test('縦書き: cột phải → trái, trong cột trên → dưới', () {
      final lines = [
        _line('l', '左列', const Rect.fromLTWH(10, 10, 20, 200)),
        _line('r2', '右列下', const Rect.fromLTWH(100, 150, 20, 100)),
        _line('r1', '右列上', const Rect.fromLTWH(100, 10, 20, 100)),
      ];
      final sorted = OcrLineOrder.sort(lines, rect: (l) => l.boundingBox, isVertical: (l) => l.isVertical);
      expect(sorted.map((l) => l.text), ['右列上', '右列下', '左列']);
    });

    test('dòng chưa gán: toàn bộ mặt trước rồi mới tới mặt sau', () {
      final lines = [
        _line('b_1', 'back top', const Rect.fromLTWH(0, 0, 100, 20)),
        _line('f_2', 'front bottom', const Rect.fromLTWH(0, 100, 100, 20)),
        _line('f_1', 'front top', const Rect.fromLTWH(0, 10, 100, 20)),
      ];
      expect(OcrLineOrder.sortUnmapped(lines).map((l) => l.text), ['front top', 'front bottom', 'back top']);
    });
  });

  group('OcrLineOrder.isJunk', () {
    test('lọc dòng rác', () {
      for (final junk in ['a', ' ', '・', '---', '| |', '12', '1 2 3', '(7)', '★☆']) {
        expect(OcrLineOrder.isJunk(junk), isTrue, reason: junk);
      }
    });

    test('giữ dòng có nghĩa', () {
      for (final ok in ['LINE: abc', '資格', '一級建築士', 'ID 1234', '内線 123', 'Ext. 12', 'ab']) {
        expect(OcrLineOrder.isJunk(ok), isFalse, reason: ok);
      }
    });
  });

  test('OcrLineOrder.join: trường chuẩn nối dấu cách, tuỳ chỉnh / ghi chú xuống dòng', () {
    expect(OcrLineOrder.join([' 東京都 ', '', '千代田区'], multiline: false), '東京都 千代田区');
    expect(OcrLineOrder.join(['一級建築士', '宅地建物取引士'], multiline: true), '一級建築士\n宅地建物取引士');
  });

  group('CustomFieldLabels', () {
    test('chuẩn hoá tên phổ biến về một dạng', () {
      for (final raw in ['Line', 'LINE ID', 'line_id', 'ライン', 'ＬＩＮＥ', ' line ']) {
        expect(CustomFieldLabels.normalize(raw), 'LINE', reason: raw);
      }
      expect(CustomFieldLabels.normalize('twitter'), 'X');
      expect(CustomFieldLabels.normalize('insta'), 'Instagram');
      expect(CustomFieldLabels.normalize('Ext.'), '内線');
      expect(CustomFieldLabels.normalize('  '), '');
    });

    test('tên lạ giữ cách viết đã dùng trước đó', () {
      expect(CustomFieldLabels.normalize('skype', existing: ['Skype']), 'Skype');
      expect(CustomFieldLabels.normalize('Mã số thuế'), 'Mã số thuế');
    });

    test('gợi ý: tên đã dùng (nhiều trước) rồi tới preset còn lại, không lặp', () {
      final s = CustomFieldLabels.suggestions([
        [const CustomField(label: 'Skype', value: 'a'), const CustomField(label: 'line', value: 'x')],
        [const CustomField(label: 'Skype', value: 'b')],
      ]);
      expect(s.take(2), ['Skype', 'LINE']);
      expect(s.where((e) => e == 'LINE'), hasLength(1));
      expect(s, containsAll(['X', 'Instagram', 'LinkedIn', '内線', '資格']));
    });

    test('union bỏ mục trùng cả tên lẫn giá trị', () {
      final u = CustomFieldLabels.union(
        [const CustomField(label: 'LINE', value: 'abc')],
        [const CustomField(label: 'Line ID', value: ' abc '), const CustomField(label: 'LINE', value: 'xyz')],
      );
      expect(u, [const CustomField(label: 'LINE', value: 'abc'), const CustomField(label: 'LINE', value: 'xyz')]);
    });
  });

  group('BusinessCardInfo: gán vào trường tuỳ chỉnh / ghi chú', () {
    final info = BusinessCardInfo(
      name: 'Taro',
      unmappedLines: [
        _line('f_1', '一級建築士', const Rect.fromLTWH(0, 0, 100, 20)),
        _line('f_2', '宅地建物取引士', const Rect.fromLTWH(0, 30, 100, 20)),
        _line('f_3', 'Slogan', const Rect.fromLTWH(0, 60, 100, 20)),
      ],
    );

    test('tạo trường mới, bỏ dòng đã dùng theo id; cùng tên thì nối xuống dòng', () {
      final r = applyAssignResult(
        info,
        (fieldKey: AssignTarget.custom, text: '一級建築士\n宅地建物取引士', append: false, label: '資格'),
        consumedIds: ['f_1', 'f_2'],
      );
      expect(r.customFields, [const CustomField(label: '資格', value: '一級建築士\n宅地建物取引士')]);
      expect(r.unmappedLines.map((l) => l.id), ['f_3']);

      final r2 = r.addCustomField('資格', '英検1級');
      expect(r2.customFields.single.value, '一級建築士\n宅地建物取引士\n英検1級');
      expect(r.addCustomField('資格', 'X', append: false).customFields.single.value, 'X');
    });

    test('thêm vào ghi chú: nối xuống dòng', () {
      final r = applyAssignResult(
        info.copyWith(note: 'Gặp ở hội chợ'),
        (fieldKey: AssignTarget.note, text: 'Slogan', append: true, label: null),
        consumedIds: ['f_3'],
      );
      expect(r.note, 'Gặp ở hội chợ\nSlogan');
      expect(r.unmappedLines, hasLength(2));
    });

    test('sửa / xoá trường tuỳ chỉnh', () {
      final r = info.addCustomField('LINE', 'abc');
      expect(r.setCustomField(0, const CustomField(label: 'LINE', value: 'xyz')).customFields.single.value, 'xyz');
      expect(r.setCustomField(0, null).customFields, isEmpty);
    });
  });

  group('SavedCard: trường tuỳ chỉnh + chữ OCR gốc', () {
    final t = DateTime(2026, 11, 16);
    final card = SavedCard(
      id: '1',
      name: '山田 太郎',
      note: 'Ghi chú',
      customFields: const [
        CustomField(label: 'LINE', value: 'yamada_t'),
        CustomField(label: '資格', value: '一級建築士\n宅地建物取引士'),
      ],
      ocrTextFront: '山田 太郎\nSlogan bị bỏ qua',
      ocrTextBack: 'Taro Yamada',
      createdAt: t,
      updatedAt: t,
    );

    test('JSON đi-về đầy đủ; JSON cũ (không có trường mới) vẫn đọc được', () {
      final back = SavedCard.fromJson(card.toJson());
      expect(back.customFields, card.customFields);
      expect(back.ocrTextFront, card.ocrTextFront);
      expect(back.ocrTextBack, card.ocrTextBack);

      final legacy = SavedCard.fromJson({'id': 'x', 'name': 'A', 'createdAt': t.toIso8601String()});
      expect(legacy.customFields, isEmpty);
      expect(legacy.ocrText, isNull);
      expect(legacy.toJson().containsKey('customFields'), isFalse);

      // Dữ liệu hỏng trong customFields bị bỏ qua thay vì làm lỗi cả thẻ
      final broken = SavedCard.fromJson({
        'id': 'y',
        'createdAt': t.toIso8601String(),
        'customFields': [1, {'label': '', 'value': 'v'}, {'label': 'LINE', 'value': 'ok'}],
      });
      expect(broken.customFields, [const CustomField(label: 'LINE', value: 'ok')]);
    });

    test('fromCardInfo lấy trường tuỳ chỉnh, ghi chú, chữ OCR', () {
      final c = SavedCard.fromCardInfo(
        const BusinessCardInfo(
          name: 'A',
          note: '  ',
          customFields: [CustomField(label: 'LINE', value: ' abc '), CustomField(label: ' ', value: 'x')],
        ),
        id: '1',
        now: t,
        ocrTextFront: 'A\nabc',
        ocrTextBack: '  ',
      );
      expect(c.customFields, [const CustomField(label: 'LINE', value: 'abc')]);
      expect(c.note, isNull);
      expect(c.ocrTextFront, 'A\nabc');
      expect(c.ocrTextBack, isNull);
    });

    test('tìm kiếm được theo trường tuỳ chỉnh và chữ OCR gốc', () {
      List<String> find(String q) => CardListQuery(search: q).apply([card]).map((c) => c.id).toList();
      expect(find('yamada_t'), ['1']);
      expect(find('宅地建物'), ['1']);
      expect(find('slogan'), ['1'], reason: 'dòng bỏ qua vẫn tìm được qua chữ OCR');
      expect(find('không có'), isEmpty);
    });

    test('vCard: NOTE gồm ghi chú + trường tuỳ chỉnh, mạng xã hội có X-SOCIALPROFILE', () {
      final v = CardExport.toVCard(card);
      expect(v, contains(r'NOTE:Ghi chú\nLINE: yamada_t\n資格: 一級建築士\n宅地建物取引士'));
      expect(v, contains('X-SOCIALPROFILE;TYPE=line:yamada_t'));
    });

    test('CSV: một cột "Khác" cho mọi trường tuỳ chỉnh', () {
      final csv = CardExport.toCsv([card], List.generate(CardExport.csvColumnCount, (i) => 'h$i'));
      expect(csv, contains('LINE: yamada_t; 資格: 一級建築士 / 宅地建物取引士'));
    });

    test('isIdentical tính cả trường tuỳ chỉnh (không phân biệt thứ tự)', () {
      final reordered = card.copyWith(customFields: card.customFields.reversed.toList());
      expect(CardDuplicateMatcher.isIdentical(card, reordered), isTrue);
      expect(CardDuplicateMatcher.isIdentical(card, card.copyWith(customFields: const [])), isFalse);
    });
  });
}
