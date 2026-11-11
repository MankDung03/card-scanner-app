import 'dart:ui';
import 'package:app_scanner_card/features/scan/domain/entities/business_card_result.dart';
import 'package:app_scanner_card/features/scan/domain/entities/ocr_model.dart';
import 'package:app_scanner_card/features/scan/domain/services/regex_field_extractor.dart';
import 'package:app_scanner_card/features/scan/domain/services/text_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegexFieldExtractor Tests', () {
    OcrLine createLine(String id, String text) {
      return OcrLine(
        id: id,
        text: text,
        normalizedText: TextNormalizer.normalize(text),
        boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
      );
    }

    test('Pass 1: Email extracted correctly and multiple emails supported', () {
      final lines = [
        createLine('1', 'Email: contact@company.com'),
        createLine('2', 'backup: support@company.vn'),
      ];

      final result = RegexFieldExtractor.extract(lines);

      expect(result.emails.length, 2);
      expect(result.emails[0].value, 'contact@company.com');
      expect(result.emails[1].value, 'support@company.vn');
      expect(lines[0].isConsumed, isTrue);
      expect(lines[1].isConsumed, isTrue);
    });

    test('Pass 2: Zipcode Japan (〒100-0001) is extracted and NOT confused with phone number', () {
      final lines = [
        createLine('1', '〒100-0001 東京都千代田区'),
        createLine('2', 'TEL: 03-1234-5678'),
      ];

      final result = RegexFieldExtractor.extract(lines);

      expect(result.zipcode?.value, '〒100-0001');
      expect(result.phones.length, 1);
      expect(result.phones[0].number, '03-1234-5678');
      expect(result.phones[0].type, PhoneType.office);
    });

    test('Pass 3: Distinguish Mobile vs Office phone based on prefix and dial code', () {
      final lines = [
        createLine('1', 'Điện thoại: (+84 4) 3783 4250, số lẻ 115'),
        createLine('2', 'Di động: 0911 932 886'),
        createLine('3', 'FAX: 03-1234-5679'),
      ];

      final result = RegexFieldExtractor.extract(lines);

      expect(result.phones.length, 3);
      final office = result.phones.firstWhere((p) => p.type == PhoneType.office);
      final mobile = result.phones.firstWhere((p) => p.type == PhoneType.mobile);
      final fax = result.phones.firstWhere((p) => p.type == PhoneType.fax);

      expect(office.number.contains('3783 4250'), isTrue);
      expect(mobile.number.contains('0911 932 886'), isTrue);
      expect(fax.number.contains('03-1234-5679'), isTrue);
    });

    test('Pass 4: Website extracted after email; email domain is never treated as website', () {
      final lines = [
        createLine('1', 'Email: user@gmail.com'),
        createLine('2', 'Website: www.vib.com. vn'),
      ];

      final result = RegexFieldExtractor.extract(lines);

      expect(result.emails.length, 1);
      expect(result.emails[0].value, 'user@gmail.com');
      expect(result.website?.value, 'www.vib.com.vn');
    });

    test('Japanese card: Second landline without prefix is classified as FAX', () {
      final lines = [
        createLine('1', '東京エンジニアリング株式会社'),
        createLine('2', '〒103-2044 東京都朝日区2-1-29'),
        createLine('3', 'PHONE (03) 1055-8141(代)'),
        createLine('4', '(03) 1055-8149'),
      ];

      final result = RegexFieldExtractor.extract(lines);

      expect(result.phones.length, 2);
      expect(result.phones[0].type, PhoneType.office);
      expect(result.phones[0].number, contains('1055-8141'));
      expect(result.phones[1].type, PhoneType.fax);
      expect(result.phones[1].number, '(03) 1055-8149');
    });
  });
}
