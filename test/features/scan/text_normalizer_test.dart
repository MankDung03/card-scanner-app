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

    test('cleanUrl removes spaces inside domain', () {
      expect(TextNormalizer.cleanUrl('www.vib.com. vn'), 'www.vib.com.vn');
      expect(TextNormalizer.cleanUrl('https://example.com/ path'), 'https://example.com/path');
    });

    test('cleanEmail strips prefixes and spaces', () {
      expect(
        TextNormalizer.cleanEmail('Email: cong.ngotien10@gmail.com'),
        'cong.ngotien10@gmail.com',
      );
    });
  });
}
