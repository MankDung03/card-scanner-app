import 'package:app_scanner_card/features/scan/domain/services/text_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextNormalizer Tests', () {
    test('Normalize full-width numbers and Latin letters to half-width ASCII', () {
      const input = '０３－１２３４－５６７８　ＡＢＣ　ｘｙｚ';
      final output = TextNormalizer.normalize(input);
      expect(output, '03-1234-5678 ABC xyz');
    });

    test('Normalize full-width symbols (@, :, ., /) to ASCII', () {
      const input = 'ｅｍａｉｌ：ｔｅｓｔ＠ｅｘａｍｐｌｅ．ｃｏｍ／ｈｏｍｅ';
      final output = TextNormalizer.normalize(input);
      expect(output, 'email:test@example.com/home');
    });

    test('Preserves Katakana vowel lengthener (ー) and normalizes dash variants', () {
      const input = '株式会社テックイノベーション　TEL: 03−1234‐5678';
      final output = TextNormalizer.normalize(input);
      expect(output.contains('イノベーション'), isTrue);
      expect(output.contains('03-1234-5678'), isTrue);
    });

    test('Detects CJK characters accurately', () {
      expect(TextNormalizer.containsCjk('山田 太郎'), isTrue);
      expect(TextNormalizer.containsCjk('やまだたろう'), isTrue);
      expect(TextNormalizer.containsCjk('イノベーション'), isTrue);
      expect(TextNormalizer.containsCjk('Ngô Tiến Công'), isFalse);
      expect(TextNormalizer.containsCjk('Quản lý khách hàng'), isFalse);
      expect(TextNormalizer.containsCjk('VIB Trung Yên'), isFalse);
    });

    test('cleanUrl removes spaces inside domain and fixes missing dot', () {
      expect(TextNormalizer.cleanUrl('www.vib.com. vn'), 'www.vib.com.vn');
      expect(TextNormalizer.cleanUrl('www.vib.com vn'), 'www.vib.com.vn');
      expect(TextNormalizer.cleanUrl('https://example.com/ path'), 'https://example.com/path');
    });

    test('cleanEmail strips prefixes and repairs missing com and spaces', () {
      expect(
        TextNormalizer.cleanEmail('Email: cong.ngotien10@gmail.com'),
        'cong.ngotien10@gmail.com',
      );
      expect(
        TextNormalizer.cleanEmail('Email. cong ngotien10@gmail.'),
        'cong.ngotien10@gmail.com',
      );
    });

    test('repairVietnameseOcrText fixes common OCR misreads and diacritic drops', () {
      final repaired = TextNormalizer.repairVietnameseOcrText(
        'Quản ý khách hàng, 16 LO 2C Phố Trung Hoà, Cảu Giáy, sỐ Iề 115, Quốc Té',
      );
      expect(repaired.contains('Quản lý khách hàng'), isTrue);
      expect(repaired.contains('16 Lô 2C'), isTrue);
      expect(repaired.contains('Phố Trung Hòa'), isTrue);
      expect(repaired.contains('Cầu Giấy'), isTrue);
      expect(repaired.contains('số lẻ 115'), isTrue);
      expect(repaired.contains('Quốc Tế'), isTrue);
    });

    test('repairPhoneNumberNoise fixes OCR noise in phone numbers', () {
      expect(TextNormalizer.repairPhoneNumberNoise('0911 932 88%'), '0911 932 886');
      expect(TextNormalizer.repairPhoneNumberNoise('(+84 4) 3783 425o'), '(+84 4) 3783 4250');
    });

    test('countKanji and countVietnameseDiacritics detect accurately', () {
      expect(TextNormalizer.countKanji('東京エンジニアリング株式会社 代表取締役社長'), 13);
      expect(TextNormalizer.countKanji('Ngô Tiến Công Quản lý khách hàng'), 0);
      expect(TextNormalizer.countKanji('Quản lý のudny s5る'), 0); // Hiragana không phải Kanji

      expect(TextNormalizer.countVietnameseDiacritics('Ngô Tiến Công Quản lý khách hàng'), 7);
      expect(TextNormalizer.countVietnameseDiacritics('Tokyo Engineering'), 0);
    });

    test('isVietnameseCard correctly diagnoses Vietnamese card despite Japanese AI hallucinations', () {
      // Giả lập kết quả thực tế trên thẻ VIB:
      // - Latin OCR đọc đúng: "Ngô Tiến Công Quản lý khách hàng VIB Trung Yên"
      // - Japanese OCR ép dấu mờ thành Hiragana: "Ngo Tien Cong のudny hoch hang s5る"
      const latinText = '''
Ngô Tiến Công
Quản lý khách hàng
VIB Trung Yên
16 Lô 2C Phố Trung Hòa, Cầu Giấy, Hà Nội
Điện thoại: (+84 4) 3783 4250, số lẻ 115
''';
      const japaneseHallucinatedText = '''
Ngo Tien Cong
のudny hoch hang
VIB Trung Yen
16 Lo 2C Pho Trung Hoa
Dn thogit (+844) 3783 4250.s5る 115
''';

      final isVi = TextNormalizer.isVietnameseCard(latinText, japaneseHallucinatedText);
      expect(isVi, isTrue, reason: 'Thẻ VIB chứa nhiều dấu tiếng Việt và 0 Kanji -> Bắt buộc là thẻ tiếng Việt');
    });

    test('isVietnameseCard correctly diagnoses genuine Japanese card', () {
      const latinText = 'TOKYO ENGINEERING (03) 1055-8141';
      const japaneseText = '''
東京エンジニアリング株式会社
代表取締役社長
田中 宏
〒103-2044 東京都朝日区2-1-29
PHONE (03) 1055-8141(代)
FAX (03) 1055-8149
''';

      final isVi = TextNormalizer.isVietnameseCard(latinText, japaneseText);
      expect(isVi, isFalse, reason: 'Thẻ chứa nhiều Kanji và mã 〒 -> Bắt buộc là thẻ tiếng Nhật');
    });
  });
}
