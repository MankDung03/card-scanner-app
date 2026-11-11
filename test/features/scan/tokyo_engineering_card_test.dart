import 'dart:ui';
import 'package:app_scanner_card/features/scan/domain/entities/card_ocr_result.dart';
import 'package:app_scanner_card/features/scan/domain/services/business_card_parser.dart';
import 'package:app_scanner_card/features/scan/domain/services/ocr_line_reconstructor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tokyo Engineering Japanese Card Complete Pipeline Test', () {
    test('Correctly extracts all fields from Tokyo Engineering card without dropping 宏 or FAX', () {
      // Giả lập kết quả ML Kit trước khi tái tạo dòng:
      // - "TOKYO" và "ENGINEERING" bị ngắt đôi
      // - "田 中" và "宏" bị ngắt thành 2 block riêng do kerning rộng
      // - "FAX" và số fax bị tách
      const rawOcr = CardOcrResult(
        fullText: '''
TOKYO
ENGINEERING
代表取締役社長
田 中
宏
PHONE (03) 1055-8141 (代)
FAX
03-1055-8142
〒103-2044 東京都朝日区2-1-29
''',
        imageWidth: 900,
        imageHeight: 550,
        blocks: [
          // 1. Tên công ty bị tách: "TOKYO" (X=50, Y=50) & "ENGINEERING" (X=200, Y=52)
          CardTextBlock(
            text: 'TOKYO',
            boundingBox: Rect.fromLTWH(50, 50, 130, 40),
            lines: [
              CardTextLine(
                text: 'TOKYO',
                boundingBox: Rect.fromLTWH(50, 50, 130, 40),
                elements: [
                  CardTextElement(
                    text: 'TOKYO',
                    boundingBox: Rect.fromLTWH(50, 50, 130, 40),
                  ),
                ],
              ),
            ],
          ),
          CardTextBlock(
            text: 'ENGINEERING',
            boundingBox: Rect.fromLTWH(190, 52, 200, 36),
            lines: [
              CardTextLine(
                text: 'ENGINEERING',
                boundingBox: Rect.fromLTWH(190, 52, 200, 36),
                elements: [
                  CardTextElement(
                    text: 'ENGINEERING',
                    boundingBox: Rect.fromLTWH(190, 52, 200, 36),
                  ),
                ],
              ),
            ],
          ),
          // 2. Chức vụ ghép 7 ký tự: "代表取締役社長" (X=50, Y=140)
          CardTextBlock(
            text: '代表取締役社長',
            boundingBox: Rect.fromLTWH(50, 140, 220, 28),
            lines: [
              CardTextLine(
                text: '代表取締役社長',
                boundingBox: Rect.fromLTWH(50, 140, 220, 28),
                elements: [
                  CardTextElement(
                    text: '代表取締役社長',
                    boundingBox: Rect.fromLTWH(50, 140, 220, 28),
                  ),
                ],
              ),
            ],
          ),
          // 3. Tên người giãn cách xa: "田 中" (X=50, Y=180) & "宏" (X=260, Y=180)
          CardTextBlock(
            text: '田 中',
            boundingBox: Rect.fromLTWH(50, 180, 140, 50),
            lines: [
              CardTextLine(
                text: '田 中',
                boundingBox: Rect.fromLTWH(50, 180, 140, 50),
                elements: [
                  CardTextElement(
                    text: '田 中',
                    boundingBox: Rect.fromLTWH(50, 180, 140, 50),
                  ),
                ],
              ),
            ],
          ),
          CardTextBlock(
            text: '宏',
            boundingBox: Rect.fromLTWH(260, 180, 50, 50),
            lines: [
              CardTextLine(
                text: '宏',
                boundingBox: Rect.fromLTWH(260, 180, 50, 50),
                elements: [
                  CardTextElement(
                    text: '宏',
                    boundingBox: Rect.fromLTWH(260, 180, 50, 50),
                  ),
                ],
              ),
            ],
          ),
          // 4. Điện thoại: "PHONE (03) 1055-8141 (代)" (X=50, Y=300)
          CardTextBlock(
            text: 'PHONE (03) 1055-8141 (代)',
            boundingBox: Rect.fromLTWH(50, 300, 320, 24),
            lines: [
              CardTextLine(
                text: 'PHONE (03) 1055-8141 (代)',
                boundingBox: Rect.fromLTWH(50, 300, 320, 24),
                elements: [
                  CardTextElement(
                    text: 'PHONE',
                    boundingBox: Rect.fromLTWH(50, 300, 60, 24),
                  ),
                  CardTextElement(
                    text: '(03) 1055-8141 (代)',
                    boundingBox: Rect.fromLTWH(115, 300, 250, 24),
                  ),
                ],
              ),
            ],
          ),
          // 5. FAX: "FAX" (X=50, Y=335) và "03-1055-8142" (X=115, Y=335)
          CardTextBlock(
            text: 'FAX',
            boundingBox: Rect.fromLTWH(50, 335, 45, 24),
            lines: [
              CardTextLine(
                text: 'FAX',
                boundingBox: Rect.fromLTWH(50, 335, 45, 24),
                elements: [
                  CardTextElement(
                    text: 'FAX',
                    boundingBox: Rect.fromLTWH(50, 335, 45, 24),
                  ),
                ],
              ),
            ],
          ),
          CardTextBlock(
            text: '03-1055-8142',
            boundingBox: Rect.fromLTWH(105, 335, 180, 24),
            lines: [
              CardTextLine(
                text: '03-1055-8142',
                boundingBox: Rect.fromLTWH(105, 335, 180, 24),
                elements: [
                  CardTextElement(
                    text: '03-1055-8142',
                    boundingBox: Rect.fromLTWH(105, 335, 180, 24),
                  ),
                ],
              ),
            ],
          ),
          // 6. Địa chỉ & Zipcode: "〒103-2044 東京都朝日区2-1-29" (X=50, Y=380)
          CardTextBlock(
            text: '〒103-2044 東京都朝日区2-1-29',
            boundingBox: Rect.fromLTWH(50, 380, 450, 24),
            lines: [
              CardTextLine(
                text: '〒103-2044 東京都朝日区2-1-29',
                boundingBox: Rect.fromLTWH(50, 380, 450, 24),
                elements: [
                  CardTextElement(
                    text: '〒103-2044',
                    boundingBox: Rect.fromLTWH(50, 380, 110, 24),
                  ),
                  CardTextElement(
                    text: '東京都朝日区2-1-29',
                    boundingBox: Rect.fromLTWH(170, 380, 330, 24),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      // Chạy bước 1: Thuật toán Gom Box tái tạo dòng
      final reconstructed = OcrLineReconstructor.reconstruct(rawOcr);

      // Kiểm tra văn bản thô sau khi gom box
      expect(reconstructed.fullText.contains('TOKYO ENGINEERING'), isTrue);
      expect(reconstructed.fullText.contains('田 中 宏'), isTrue);
      expect(reconstructed.fullText.contains('FAX 03-1055-8142'), isTrue);

      // Chạy bước 2: Bóc tách tự động vào form
      final card = BusinessCardParser.parse(reconstructed);

      // 1. Họ tên được nhận dạng trọn vẹn cả "田 中 宏", không bị rớt chữ 宏!
      expect(card.name, '田 中 宏');

      // 2. Chức vụ nhận diện đúng "代表取締役社長", không còn bị bỏ rơi vào Unmapped!
      expect(card.jobTitle, '代表取締役社長');

      // 3. Tên công ty nhận diện trọn vẹn "TOKYO ENGINEERING"
      expect(card.company?.contains('TOKYO ENGINEERING'), isTrue);

      // 4. Số điện thoại & FAX
      expect(card.phone?.contains('1055-8141'), isTrue);
      expect(card.fax?.contains('03-1055-8142'), isTrue);

      // 5. Địa chỉ
      expect(card.address?.contains('東京都朝日区'), isTrue);
      expect(card.postalCode, '〒103-2044');

      // 6. Số lượng dòng chưa gán bằng 0 (Tất cả đã được gán vào đúng trường!)
      expect(card.unmappedLines.isEmpty, isTrue);
    });
  });
}
