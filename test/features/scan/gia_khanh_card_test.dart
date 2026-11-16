import 'package:app_scanner_card/features/scan/domain/entities/card_ocr_result.dart';
import 'package:app_scanner_card/features/scan/domain/services/business_card_parser.dart';
import 'package:app_scanner_card/features/scan/domain/services/vietnamese_unicode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dấu tổ hợp (combining mark) theo mã: m(0x0301) = dấu sắc rời.
String m(int code) => String.fromCharCode(code);

/// "Giám đốc Kinh doanh" như ML Kit trả về: dấu ở dạng TỔ HỢP (NFD) — "a" + sắc, "o" + mũ + sắc.
final _titleNfd = 'Gia${m(0x0301)}m đo${m(0x0302)}${m(0x0301)}c Kinh doanh';

CardTextLine _l(String text, double left, double top, double width, double height) =>
    CardTextLine(text: text, boundingBox: Rect.fromLTWH(left, top, width, height));

/// Thẻ "Công ty TNHH Phát triển & Đầu tư Gia Khánh" (ảnh chụp thật, toạ độ xấp xỉ, ảnh 1000×560).
CardOcrResult _card({String? title, String name = 'NGUYỄN MINH KHANG'}) {
  title ??= _titleNfd;
  final lines = [
    _l('CÔNG TY TNHH PHÁT TRIỂN', 230, 40, 300, 30),
    _l('& ĐẦU TƯ GIA KHÁNH', 230, 74, 250, 30),
    _l(name, 120, 170, 640, 62),
    _l(title, 120, 236, 300, 34),
    _l('0912 345 678', 640, 290, 160, 26),
    _l('khang.nguyen@giakhanh.vn', 640, 322, 280, 26),
    _l('www.giakhanh.vn', 640, 354, 200, 26),
    _l('Tầng 12, Tòa nhà Landmark,', 640, 386, 300, 26),
    _l('72 Đường Trần Hưng Đạo,', 640, 418, 300, 26),
    _l('Quận 1, TP. Hồ Chí Minh, Việt Nam', 640, 450, 340, 26),
  ];
  return CardOcrResult(
    fullText: lines.map((l) => l.text).join('\n'),
    imageWidth: 1000,
    imageHeight: 560,
    blocks: [CardTextBlock(text: '', boundingBox: const Rect.fromLTWH(0, 0, 1000, 560), lines: lines)],
  );
}

void main() {
  group('VietnameseUnicode.compose (NFD → NFC)', () {
    test('ghép chữ + dấu rời về ký tự dựng sẵn', () {
      expect(VietnameseUnicode.compose(_titleNfd), 'Giám đốc Kinh doanh');
      expect(VietnameseUnicode.compose('Nguye${m(0x0302)}${m(0x0303)}n'), 'Nguyễn');
      expect(VietnameseUnicode.compose('NGUYE${m(0x0302)}${m(0x0303)}N'), 'NGUYỄN');
      expect(VietnameseUnicode.compose('Tru${m(0x031B)}o${m(0x031B)}${m(0x0300)}ng'), 'Trường');
      expect(VietnameseUnicode.compose('a${m(0x0306)}${m(0x0323)}'), 'ặ');
    });

    test('thứ tự dấu không chuẩn / chữ đã có sẵn một phần dấu', () {
      expect(VietnameseUnicode.compose('o${m(0x0301)}${m(0x0302)}'), 'ố', reason: 'sắc trước mũ');
      expect(VietnameseUnicode.compose('ô${m(0x0301)}'), 'ố', reason: 'ô dựng sẵn + sắc rời');
      expect(VietnameseUnicode.compose('ơ${m(0x0323)}'), 'ợ');
    });

    test('chuỗi đã chuẩn / không phải tiếng Việt giữ nguyên', () {
      expect(VietnameseUnicode.compose('Giám đốc'), 'Giám đốc');
      expect(VietnameseUnicode.compose('名刺スキャン'), '名刺スキャン');
      expect(VietnameseUnicode.compose('n${m(0x0303)}'), 'n${m(0x0303)}', reason: 'ñ dạng tổ hợp không phải chữ Việt → không đụng tới');
      expect(VietnameseUnicode.compose('a${m(0x0301)}${m(0x0300)}'), 'a${m(0x0301)}${m(0x0300)}', reason: 'hai dấu thanh → không hợp lệ');
    });

    test('stripDiacritics', () {
      expect(VietnameseUnicode.stripDiacritics('Giám Đốc Kinh doanh'), 'Giam Doc Kinh doanh');
      expect(VietnameseUnicode.stripDiacritics(_titleNfd), 'Giam doc Kinh doanh');
    });
  });

  group('Thẻ Gia Khánh', () {
    test('chức vụ dạng dấu tổ hợp vẫn được nhận; công ty 2 dòng được gộp; địa chỉ không có ",,"', () {
      final info = BusinessCardParser.parse(_card());

      expect(info.jobTitle, 'Giám đốc Kinh doanh');
      expect(info.company, 'CÔNG TY TNHH PHÁT TRIỂN & ĐẦU TƯ GIA KHÁNH');
      expect(info.name, 'NGUYỄN MINH KHANG');
      expect(info.address, isNot(contains(',,')));
      expect(info.address, contains('Tầng 12, Tòa nhà Landmark, 72 Đường Trần Hưng Đạo, Quận 1'));
      expect(info.email, 'khang.nguyen@giakhanh.vn');
      expect(info.unmappedLines.map((l) => l.text), isEmpty);
    });

    test('OCR làm mất dấu chức vụ ("Giam doc Kinh doanh") vẫn nhận là chức vụ', () {
      final info = BusinessCardParser.parse(_card(title: 'Giam doc Kinh doanh'));
      expect(info.jobTitle, 'Giam doc Kinh doanh');
    });

    test('chữ hiển thị cũng được ghép dấu (dòng chưa gán / văn bản gốc không lệch dấu)', () {
      final info = BusinessCardParser.parse(_card(title: '${_titleNfd}xyz zzz 12345678'));
      // dù không vào trường nào, text vẫn ở dạng dựng sẵn
      for (final l in info.unmappedLines) {
        expect(l.text, VietnameseUnicode.compose(l.text));
      }
    });
  });

  group('Không gộp nhầm dòng dưới vào tên công ty', () {
    CardOcrResult two(String company, String below, {double belowHeight = 30}) {
      final lines = [
        _l(company, 100, 40, 400, 30),
        _l(below, 100, 74, 300, belowHeight),
        _l('Nguyễn Văn An', 100, 200, 300, 50),
      ];
      return CardOcrResult(
        fullText: lines.map((l) => l.text).join('\n'),
        imageWidth: 1000,
        imageHeight: 560,
        blocks: [CardTextBlock(text: '', boundingBox: const Rect.fromLTWH(0, 0, 1000, 560), lines: lines)],
      );
    }

    test('phòng ban viết hoa ngay dưới', () {
      final info = BusinessCardParser.parse(two('CÔNG TY CỔ PHẦN ABC', 'PHÒNG KINH DOANH'));
      expect(info.company, 'CÔNG TY CỔ PHẦN ABC');
      expect(info.department, 'PHÒNG KINH DOANH');
    });

    test('dòng thường (không dấu hiệu nối, không viết hoa)', () {
      final info = BusinessCardParser.parse(two('Công ty TNHH ABC', 'Uy tín tạo nên thương hiệu'));
      expect(info.company, 'Công ty TNHH ABC');
    });

    test('dòng chữ to hơn hẳn (tên người)', () {
      final info = BusinessCardParser.parse(two('CÔNG TY TNHH ABC', 'LÊ MINH TÂM', belowHeight: 55));
      expect(info.company, 'CÔNG TY TNHH ABC');
    });
  });
}
