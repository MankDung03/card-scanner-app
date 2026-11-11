/// Lớp chuẩn hóa văn bản OCR trước khi đưa vào các bộ lọc Regex và Heuristic
class TextNormalizer {
  /// Chuẩn hóa toàn bộ một dòng văn bản OCR
  static String normalize(String input) {
    if (input.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final code = input.codeUnitAt(i);

      // 1. Full-width numbers (０-９: 0xFF10 - 0xFF19) -> (0-9: 0x30 - 0x39)
      if (code >= 0xFF10 && code <= 0xFF19) {
        buffer.writeCharCode(code - 0xFEE0);
      }
      // 2. Full-width Latin Uppercase (Ａ-Ｚ: 0xFF21 - 0xFF3A) -> (A-Z: 0x41 - 0x5A)
      else if (code >= 0xFF21 && code <= 0xFF3A) {
        buffer.writeCharCode(code - 0xFEE0);
      }
      // 3. Full-width Latin Lowercase (ａ-ｚ: 0xFF41 - 0xFF5A) -> (a-z: 0x61 - 0x7A)
      else if (code >= 0xFF41 && code <= 0xFF5A) {
        buffer.writeCharCode(code - 0xFEE0);
      }
      // 4. Full-width Space (　: 0x3000) -> Space (0x20)
      else if (code == 0x3000) {
        buffer.write(' ');
      }
      // 5. Full-width punctuation & symbols
      else if (code == 0xFF20) {
        buffer.write('@'); // ＠ -> @
      } else if (code == 0xFF1A) {
        buffer.write(':'); // ： -> :
      } else if (code == 0xFF1B) {
        buffer.write(';'); // ； -> ;
      } else if (code == 0xFF0E) {
        buffer.write('.'); // ． -> .
      } else if (code == 0xFF0C) {
        buffer.write(','); // ， -> ,
      } else if (code == 0xFF0F) {
        buffer.write('/'); // ／ -> /
      } else if (code == 0xFF08) {
        buffer.write('('); // （ -> (
      } else if (code == 0xFF09) {
        buffer.write(')'); // ） -> )
      } else if (code == 0xFF0B) {
        buffer.write('+'); // ＋ -> +
      } else if (code == 0xFF06) {
        buffer.write('&'); // ＆ -> &
      } else if (code == 0xFF5E || code == 0x301C) {
        buffer.write('-'); // 〜, ～ -> -
      }
      // 6. Gạch ngang biến thể (－: 0xFF0D, −, ‐, ―, –, —) -> -, NHƯNG GIỮ NGUYÊN trường âm Katakana ー (0x30FC)
      else if (code == 0xFF0D ||
          code == 0x2212 ||
          code == 0x2010 ||
          code == 0x2015 ||
          code == 0x2013 ||
          code == 0x2014) {
        buffer.write('-');
      } else {
        buffer.writeCharCode(code);
      }
    }

    // 7. Gộp khoảng trắng thừa liên tiếp thành 1 dấu cách đơn và trim 2 đầu
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Kiểm tra xem chuỗi có chứa ký tự CJK (Kanji, Hiragana, Katakana) hay không
  static bool containsCjk(String text) {
    // Hiragana: \u3040-\u309F
    // Katakana: \u30A0-\u30FF
    // Kanji/CJK Unified: \u4E00-\u9FFF, \u3400-\u4DBF
    return RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF\u3400-\u4DBF]')
        .hasMatch(text);
  }

  /// Làm sạch domain/url có khoảng trắng rác do OCR sinh ra (ví dụ: "www.vib.com. vn" -> "www.vib.com.vn")
  static String cleanUrl(String rawUrl) {
    var cleaned = rawUrl.replaceAll(RegExp(r'\s+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[,\.;:]+$'), '');
    return cleaned;
  }

  /// Làm sạch email có khoảng trắng hoặc số bị thiếu do OCR (ví dụ: "cong ngotien 0@gmail.com")
  static String cleanEmail(String rawEmail) {
    // Bỏ tiền tố email: / e-mail: / e.mail: / mail:
    var cleaned = rawEmail.replaceAll(
      RegExp(r'^(?:e-?mail|mail|thư điện tử)[\s\.:]+', caseSensitive: false),
      '',
    );
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[,\.;:]+$'), '');
    return cleaned;
  }
}
