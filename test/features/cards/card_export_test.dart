import 'package:app_scanner_card/features/cards/domain/entities/saved_card.dart';
import 'package:app_scanner_card/features/cards/domain/services/card_export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final created = DateTime(2026, 11, 10);

  SavedCard card({
    String? name = '山田 太郎',
    String? note,
    String? phone = '03-1234-5678',
    List<String> tags = const [],
  }) =>
      SavedCard(
        id: '1',
        name: name,
        furigana: 'やまだ たろう',
        company: '株式会社サンプル商事',
        department: '営業部',
        jobTitle: '部長',
        phone: phone,
        mobile: '090-1111-2222',
        email: 'taro@sample.example',
        postalCode: '100-0001',
        address: '東京都千代田区千代田1-1-1',
        note: note,
        tags: tags,
        createdAt: created,
        updatedAt: created,
      );

  group('toVCard', () {
    test('tách họ/tên kiểu Nhật và có đủ trường chính', () {
      final v = CardExport.toVCard(card());
      expect(v, startsWith('BEGIN:VCARD\r\nVERSION:3.0\r\n'));
      expect(v, contains('N:山田;太郎;;;'));
      expect(v, contains('FN:山田 太郎'));
      expect(v, contains('X-PHONETIC-LAST-NAME:やまだ'));
      expect(v, contains('ORG:株式会社サンプル商事;営業部'));
      expect(v, contains('TITLE:部長'));
      expect(v, contains('TEL;TYPE=WORK,VOICE:03-1234-5678'));
      expect(v, contains('TEL;TYPE=CELL:090-1111-2222'));
      expect(v, contains('ADR;TYPE=WORK:;;東京都千代田区千代田1-1-1;;;100-0001;'));
      expect(v, endsWith('END:VCARD\r\n'));
    });

    test('escape ký tự đặc biệt trong ghi chú', () {
      final v = CardExport.toVCard(card(note: 'a,b;c\nd'));
      expect(v, contains(r'NOTE:a\,b\;c\nd'));
    });

    test('tên file bỏ khoảng trắng và ký tự cấm', () {
      expect(CardExport.vCardFileName(card()), '山田太郎.vcf');
      expect(CardExport.vCardFileName(card(name: 'a/b')), 'ab.vcf');
    });
  });

  group('toCsv', () {
    final headers = List.generate(CardExport.csvColumnCount, (i) => 'h$i');

    test('có BOM, dòng tiêu đề và đúng số cột', () {
      final csv = CardExport.toCsv([card()], headers);
      expect(csv, startsWith('﻿h0,h1,'));
      final lines = csv.substring(1).trim().split('\r\n');
      expect(lines, hasLength(2));
      expect(lines[1].split(',').length, CardExport.csvColumnCount);
    });

    test('bọc ngoặc kép khi có dấu phẩy / xuống dòng / ngoặc kép', () {
      final csv = CardExport.toCsv([card(note: 'x, "y"\nz')], headers);
      expect(csv, contains('"x, ""y""\nz"'));
    });

    test('chặn công thức Excel nhưng giữ số điện thoại', () {
      final csv = CardExport.toCsv([card(note: '=HYPERLINK("x")', phone: '+81 3-1234-5678')], headers);
      expect(csv, contains("'=HYPERLINK"));
      expect(csv, contains(',+81 3-1234-5678,'));
    });

    test('tên file theo ngày', () {
      expect(CardExport.csvFileName(DateTime(2026, 11, 2)), 'meishi_20261102.csv');
    });
  });
}
