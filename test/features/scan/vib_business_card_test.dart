import 'dart:ui';
import 'package:app_scanner_card/features/scan/domain/entities/card_ocr_result.dart';
import 'package:app_scanner_card/features/scan/domain/services/business_card_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VIB Real Business Card Parser Test', () {
    test('Correctly extracts all fields from VIB card (Ngô Tiến Công)', () {
      // Giả lập danh thiếp thực tế của Ngô Tiến Công - VIB
      const ocrResult = CardOcrResult(
        fullText: '''
Ngô Tiến Công
Quản lý khách hàng
VIB Trung Yên
VIB
Ngân hàng Quốc Tế
16 Lô 2C Phố Trung Hòa, Khu ĐTM Trung Yên, Cầu Giấy, Hà Nội
Điện thoại: (+84 4) 3783 4250, số lẻ 115
Di động: 0911 932 886
Email: cong.ngotien10@gmail.com
Website: www.vib.com. vn
''',
        imageWidth: 1000,
        imageHeight: 600,
        blocks: [
          // Block 1: Họ tên & Chức vụ (Nửa trên bên trái)
          CardTextBlock(
            text: 'Ngô Tiến Công\nQuản lý khách hàng',
            boundingBox: Rect.fromLTWH(50, 60, 300, 80),
            lines: [
              CardTextLine(
                text: 'Ngô Tiến Công',
                boundingBox: Rect.fromLTWH(50, 60, 250, 42),
              ),
              CardTextLine(
                text: 'Quản lý khách hàng',
                boundingBox: Rect.fromLTWH(50, 110, 200, 24),
              ),
            ],
          ),
          // Block 2: Logo VIB & Tên Ngân hàng (Nửa trên bên phải)
          CardTextBlock(
            text: 'VIB\nNgân hàng Quốc Tế',
            boundingBox: Rect.fromLTWH(550, 50, 350, 90),
            lines: [
              CardTextLine(
                text: 'VIB',
                boundingBox: Rect.fromLTWH(550, 50, 120, 48),
              ),
              CardTextLine(
                text: 'Ngân hàng Quốc Tế',
                boundingBox: Rect.fromLTWH(550, 105, 300, 30),
              ),
            ],
          ),
          // Block 3: Chi nhánh / Phòng ban & Địa chỉ & Liên hệ (Nửa dưới)
          CardTextBlock(
            text: '''VIB Trung Yên
16 Lô 2C Phố Trung Hòa, Khu ĐTM Trung Yên, Cầu Giấy, Hà Nội
Điện thoại: (+84 4) 3783 4250, số lẻ 115
Di động: 0911 932 886
Email: cong.ngotien10@gmail.com
Website: www.vib.com. vn''',
            boundingBox: Rect.fromLTWH(50, 220, 800, 300),
            lines: [
              CardTextLine(
                text: 'VIB Trung Yên',
                boundingBox: Rect.fromLTWH(50, 220, 200, 25),
              ),
              CardTextLine(
                text: '16 Lô 2C Phố Trung Hòa, Khu ĐTM Trung Yên, Cầu Giấy, Hà Nội',
                boundingBox: Rect.fromLTWH(50, 255, 650, 24),
              ),
              CardTextLine(
                text: 'Điện thoại: (+84 4) 3783 4250, số lẻ 115',
                boundingBox: Rect.fromLTWH(50, 290, 400, 24),
              ),
              CardTextLine(
                text: 'Di động: 0911 932 886',
                boundingBox: Rect.fromLTWH(50, 325, 300, 24),
              ),
              CardTextLine(
                text: 'Email: cong.ngotien10@gmail.com',
                boundingBox: Rect.fromLTWH(50, 360, 450, 24),
              ),
              CardTextLine(
                text: 'Website: www.vib.com. vn',
                boundingBox: Rect.fromLTWH(50, 395, 350, 24),
              ),
            ],
          ),
        ],
      );

      final card = BusinessCardParser.parse(ocrResult);

      // Kiểm tra Họ tên
      expect(card.name, 'Ngô Tiến Công');

      // Kiểm tra Chức vụ
      expect(card.jobTitle, 'Quản lý khách hàng');

      // Kiểm tra Công ty (Gộp Ngân hàng Quốc Tế + VIB)
      expect(card.company?.contains('Ngân hàng Quốc Tế'), isTrue);
      expect(card.company?.contains('VIB'), isTrue);

      // Kiểm tra Phòng ban / Chi nhánh
      expect(card.department, 'VIB Trung Yên');

      // Kiểm tra Địa chỉ
      expect(card.address?.contains('16 Lô 2C Phố Trung Hòa'), isTrue);
      expect(card.address?.contains('Cầu Giấy, Hà Nội'), isTrue);

      // Kiểm tra Số điện thoại bàn
      expect(card.phone?.contains('3783 4250'), isTrue);

      // Kiểm tra Di động
      expect(card.mobile?.contains('0911 932 886'), isTrue);

      // Kiểm tra Email
      expect(card.email, 'cong.ngotien10@gmail.com');

      // Kiểm tra Website
      expect(card.website, 'www.vib.com.vn');

      // Đã nhận dạng đầy đủ các trường
      expect(card.recognizedCount, greaterThanOrEqualTo(8));
    });
  });
}
