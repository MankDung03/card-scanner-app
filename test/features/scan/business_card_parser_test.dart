import 'package:app_scanner_card/features/scan/domain/entities/business_card_info.dart';
import 'package:app_scanner_card/features/scan/domain/entities/card_ocr_result.dart';
import 'package:app_scanner_card/features/scan/domain/services/business_card_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BusinessCardParser Tests', () {
    test('Parse typical Japanese Business Card (名刺)', () {
      final mockLines = [
        const CardTextLine(
          text: '株式会社サンプル商事',
          boundingBox: Rect.fromLTWH(50, 40, 200, 22),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: '営業部',
          boundingBox: Rect.fromLTWH(50, 70, 80, 16),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: '部長',
          boundingBox: Rect.fromLTWH(140, 70, 50, 16),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: 'やまだ たろう',
          boundingBox: Rect.fromLTWH(50, 100, 90, 12),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: '山田 太郎',
          boundingBox: Rect.fromLTWH(50, 115, 120, 28),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: '〒100-0001 東京都千代田区千代田1-1',
          boundingBox: Rect.fromLTWH(50, 180, 260, 16),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: 'TEL: 03-1234-5678',
          boundingBox: Rect.fromLTWH(50, 210, 140, 16),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: 'FAX: 03-1234-5679',
          boundingBox: Rect.fromLTWH(50, 230, 140, 16),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: 'taro.yamada@sample-shoji.example',
          boundingBox: Rect.fromLTWH(50, 255, 200, 16),
          cornerPoints: [],
          elements: [],
        ),
      ];

      final blocks = [
        CardTextBlock(
          text: mockLines.map((l) => l.text).join('\n'),
          boundingBox: const Rect.fromLTWH(50, 40, 260, 230),
          cornerPoints: const [],
          lines: mockLines,
        ),
      ];

      final ocrResult = CardOcrResult(
        fullText: mockLines.map((l) => l.text).join('\n'),
        imageWidth: 600,
        imageHeight: 380,
        blocks: blocks,
      );

      final cardInfo = BusinessCardParser.parse(ocrResult);

      expect(cardInfo.company, equals('株式会社サンプル商事'));
      expect(cardInfo.department, equals('営業部'));
      expect(cardInfo.jobTitle, equals('部長'));
      expect(cardInfo.name, equals('山田 太郎'));
      expect(cardInfo.furigana, equals('やまだ たろう'));
      expect(cardInfo.postalCode, equals('〒100-0001'));
      expect(cardInfo.address, contains('東京都千代田区千代田1-1'));
      expect(cardInfo.phone, equals('03-1234-5678'));
      expect(cardInfo.fax, equals('03-1234-5679'));
      expect(cardInfo.email, equals('taro.yamada@sample-shoji.example'));
      expect(cardInfo.recognizedCount, greaterThanOrEqualTo(8));
    });

    test('Company Name has BIGGEST font: Does NOT mistake company as person name', () {
      final mockLines = [
        // Dòng Công ty có font chữ to nhất (height = 42)
        const CardTextLine(
          text: '株式会社テックイノベーション',
          boundingBox: Rect.fromLTWH(40, 30, 300, 42),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: '部長',
          boundingBox: Rect.fromLTWH(40, 90, 60, 18),
          cornerPoints: [],
          elements: [],
        ),
        // Dòng Tên người font nhỏ hơn công ty (height = 26)
        const CardTextLine(
          text: '山田 太郎',
          boundingBox: Rect.fromLTWH(40, 115, 130, 26),
          cornerPoints: [],
          elements: [],
        ),
      ];

      final blocks = [
        CardTextBlock(
          text: mockLines.map((l) => l.text).join('\n'),
          boundingBox: const Rect.fromLTWH(40, 30, 300, 120),
          cornerPoints: const [],
          lines: mockLines,
        ),
      ];

      final ocrResult = CardOcrResult(
        fullText: mockLines.map((l) => l.text).join('\n'),
        imageWidth: 600,
        imageHeight: 380,
        blocks: blocks,
      );

      final cardInfo = BusinessCardParser.parse(ocrResult);

      expect(cardInfo.company, equals('株式会社テックイノベーション'));
      expect(cardInfo.name, equals('山田 太郎'));
      expect(cardInfo.jobTitle, equals('部長'));
    });

    test('Parse typical Vietnamese Business Card', () {
      final mockLines = [
        const CardTextLine(
          text: 'Công ty TNHH Giải Pháp Công Nghệ Số',
          boundingBox: Rect.fromLTWH(30, 30, 280, 20),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: 'Nguyễn Văn An',
          boundingBox: Rect.fromLTWH(30, 70, 150, 32),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: 'Giám đốc Điều hành',
          boundingBox: Rect.fromLTWH(30, 110, 120, 18),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: 'Phòng Kinh Doanh',
          boundingBox: Rect.fromLTWH(30, 135, 120, 16),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: 'Hotline: 0901 234 567',
          boundingBox: Rect.fromLTWH(30, 165, 150, 16),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: 'an.nguyen@techsolutions.vn',
          boundingBox: Rect.fromLTWH(30, 190, 180, 16),
          cornerPoints: [],
          elements: [],
        ),
        const CardTextLine(
          text: 'Tòa nhà Keangnam, Mễ Trì, Nam Từ Liêm, Hà Nội',
          boundingBox: Rect.fromLTWH(30, 220, 280, 16),
          cornerPoints: [],
          elements: [],
        ),
      ];

      final blocks = [
        CardTextBlock(
          text: mockLines.map((l) => l.text).join('\n'),
          boundingBox: const Rect.fromLTWH(30, 30, 280, 220),
          cornerPoints: const [],
          lines: mockLines,
        ),
      ];

      final ocrResult = CardOcrResult(
        fullText: mockLines.map((l) => l.text).join('\n'),
        imageWidth: 600,
        imageHeight: 380,
        blocks: blocks,
      );

      final cardInfo = BusinessCardParser.parse(ocrResult);

      expect(cardInfo.company, contains('Công ty TNHH'));
      expect(cardInfo.name, equals('Nguyễn Văn An'));
      expect(cardInfo.jobTitle, equals('Giám đốc Điều hành'));
      expect(cardInfo.mobile, contains('0901'));
      expect(cardInfo.email, equals('an.nguyen@techsolutions.vn'));
      expect(cardInfo.address, contains('Hà Nội'));
    });

    test('Dynamic count and reviewNeededCount check', () {
      // Danh thiếp chỉ có 3 thông tin và địa chỉ bị quá ngắn (cần review)
      const cardInfo = BusinessCardInfo(
        name: '山田 太郎',
        phone: '03-1234-5678',
        address: '東京都', // Quá ngắn -> cần review
        reviewFlags: {'address': true},
      );

      expect(cardInfo.recognizedCount, equals(3));
      expect(cardInfo.reviewNeededCount, equals(1));
      expect(cardInfo.isFieldNeedsReview('address'), isTrue);
      expect(cardInfo.isFieldNeedsReview('name'), isFalse);
    });
  });
}
