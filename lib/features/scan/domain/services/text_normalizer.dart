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
    final normalized = buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();

    // 8. Chạy qua bộ sửa lỗi chính tả ngữ cảnh OCR tiếng Việt (phục hồi dấu và chữ bị đọc nhầm)
    return repairVietnameseOcrText(normalized);
  }

  /// Bộ từ điển sửa lỗi chính tả ngữ cảnh OCR tiếng Việt thường gặp
  static String repairVietnameseOcrText(String text) {
    if (text.isEmpty) return text;
    var result = text;

    // 1. Sửa lỗi mất chữ 'l' trong Chức vụ: "Quản ý" -> "Quản lý"
    result = result.replaceAll(RegExp(r'\bquản\s+ý(?=\s|$|[.,;:])', caseSensitive: false), 'Quản lý');

    // 2. Sửa lỗi sai dấu địa danh Hà Nội: "Cảu Giáy" -> "Cầu Giấy", "Khu ĐTM Trung Yện" -> "Khu ĐTM Trung Yên"
    result = result.replaceAll(RegExp(r'\bcảu\s+giáy(?=\s|$|[.,;:])', caseSensitive: false), 'Cầu Giấy');
    result = result.replaceAll(RegExp(r'\bcầu\s+giay(?=\s|$|[.,;:])', caseSensitive: false), 'Cầu Giấy');
    result = result.replaceAll(RegExp(r'\btrung\s+yện(?=\s|$|[.,;:])', caseSensitive: false), 'Trung Yên');
    result = result.replaceAll(RegExp(r'\btrung\s+yen(?=\s|$|[.,;:])', caseSensitive: false), 'Trung Yên');
    result = result.replaceAll(RegExp(r'\bphố\s+trung\s+hoà(?=\s|$|[.,;:])', caseSensitive: false), 'Phố Trung Hòa');

    // 3. Sửa lỗi số nhà/lô: "16 LO 2C" -> "16 Lô 2C"
    result = result.replaceAllMapped(
      RegExp(r'\b(\d+)\s+lo\s+(\d+[a-zA-Z]?)(?=\s|$|[.,;:])', caseSensitive: false),
      (m) => '${m.group(1)} Lô ${m.group(2)}',
    );

    // 4. Sửa lỗi nhãn số máy lẻ: "sỐ Iề" / "số Iề" -> "số lẻ"
    result = result.replaceAll(RegExp(r'\bs[oốỐ]\s*[lI]ề(?=\s|$|[.,;:])', caseSensitive: false), 'số lẻ');

    // 5. Sửa lỗi chữ Quốc Tế: "Quốc Té" -> "Quốc Tế"
    result = result.replaceAll(RegExp(r'\bquốc\s+té(?=\s|$|[.,;:])', caseSensitive: false), 'Quốc Tế');

    return result;
  }

  /// Khôi phục các ký tự nhòe thường gặp trong chuỗi số điện thoại Việt Nam
  static String repairPhoneNumberNoise(String rawPhone) {
    if (rawPhone.isEmpty) return rawPhone;
    var result = rawPhone;

    // Thay thế ký tự '%' ở cuối số thành '6' (ví dụ: "0911 932 88%" -> "0911 932 886")
    result = result.replaceAllMapped(
      RegExp(r'(\d)\s*%(?=\s|$|[.,;:])'),
      (m) => '${m.group(1)}6',
    );

    // Thay thế ký tự '&' thành '8'
    result = result.replaceAllMapped(
      RegExp(r'(\d)\s*&\s*(\d)'),
      (m) => '${m.group(1)}8${m.group(2)}',
    );

    // Thay thế ký tự 'o' hoặc 'O' đứng cạnh chữ số thành '0'
    result = result.replaceAllMapped(
      RegExp(r'(\d)\s*[oO](?=\s|$|[.,;:\)])'),
      (m) => '${m.group(1)}0',
    );
    result = result.replaceAllMapped(
      RegExp(r'(\d)\s*[oO]\s*(\d)'),
      (m) => '${m.group(1)}0${m.group(2)}',
    );

    // Thay thế ký tự 'l' hoặc 'I' đứng giữa các chữ số thành '1'
    result = result.replaceAllMapped(
      RegExp(r'(\d)\s*[lI](?=\s|$|[.,;:\)])'),
      (m) => '${m.group(1)}1',
    );
    result = result.replaceAllMapped(
      RegExp(r'(\d)\s*[lI]\s*(\d)'),
      (m) => '${m.group(1)}1${m.group(2)}',
    );

    return result;
  }

  /// Kiểm tra xem chuỗi có chứa ký tự CJK (Kanji, Hiragana, Katakana) hay không
  static bool containsCjk(String text) {
    // Hiragana: \u3040-\u309F
    // Katakana: \u30A0-\u30FF
    // Kanji/CJK Unified: \u4E00-\u9FFF, \u3400-\u4DBF
    return RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF\u3400-\u4DBF]')
        .hasMatch(text);
  }

  /// Đếm số lượng ký tự Kanji (Hán tự) thực sự
  static int countKanji(String text) {
    return RegExp(r'[\u4E00-\u9FFF\u3400-\u4DBF]').allMatches(text).length;
  }

  /// Đếm số lượng ký tự Katakana tiếng Nhật thực sự
  static int countKatakana(String text) {
    return RegExp(r'[\u30A0-\u30FF]').allMatches(text).length;
  }

  /// Đếm số lượng ký tự có dấu tiếng Việt
  static int countVietnameseDiacritics(String text) {
    return RegExp(
      r'[àáảãạăằắẳẵặâầấẩẫậđèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬĐÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴ]',
    ).allMatches(text).length;
  }

  /// Phán đoán ngôn ngữ chính của danh thiếp:
  /// Trả về true nếu là danh thiếp tiếng Việt (hoặc không có chữ Hán Kanji nào).
  /// Giúp loại bỏ hoàn toàn hiện tượng AI ép dấu tiếng Việt thành Hiragana (ví dụ 'Quản lý' -> 'のudny', 'số lẻ' -> 's5る').
  static bool isVietnameseCard(String latinText, String japaneseText) {
    final viCount = countVietnameseDiacritics(latinText) + countVietnameseDiacritics(japaneseText);
    final kanjiCount = countKanji(japaneseText);
    final katakanaCount = countKatakana(japaneseText);
    final hasJapanZip = japaneseText.contains('〒') || latinText.contains('〒');

    // 1. Dấu hiệu danh thiếp Nhật Bản chính thống:
    // - Có ký hiệu bưu điện Nhật 〒
    // - Hoặc có từ 2 chữ Kanji trở lên
    // - Hoặc có cụm từ Katakana >= 4 ký tự (ví dụ: エンジニアリング, テック...)
    if (hasJapanZip || kanjiCount >= 2 || katakanaCount >= 4) {
      return false;
    }

    // 2. Nếu có ký tự tiếng Việt có dấu -> Chắc chắn là thẻ tiếng Việt 100%
    if (viCount >= 2) {
      return true;
    }

    // 3. Nếu không có cả Kanji lẫn dấu tiếng Việt (ví dụ thẻ thuần tiếng Anh):
    // Ưu tiên tiếng Việt / Latin để không bị model Japanese hallucinate sinh chữ lạ 'の', 'る'
    return kanjiCount == 0;
  }

  /// Làm sạch domain/url có khoảng trắng rác do OCR sinh ra (ví dụ: "www.vib.com. vn" hoặc "www.vib.com vn" -> "www.vib.com.vn")
  static String cleanUrl(String rawUrl) {
    var cleaned = rawUrl.replaceAll(
      RegExp(r'^(?:website|web|trang web)[\s\.:]+', caseSensitive: false),
      '',
    ).trim();

    // Thay thế các khoảng trắng giữa các domain (ví dụ "www.vib.com vn" -> "www.vib.com.vn")
    cleaned = cleaned.replaceAll(RegExp(r'\.com\s+vn\b', caseSensitive: false), '.com.vn');
    cleaned = cleaned.replaceAll(RegExp(r'\.edu\s+vn\b', caseSensitive: false), '.edu.vn');
    cleaned = cleaned.replaceAll(RegExp(r'\.gov\s+vn\b', caseSensitive: false), '.gov.vn');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[,\.;:]+$'), '');
    return cleaned;
  }

  /// Làm sạch email có khoảng trắng hoặc mất đuôi do OCR (ví dụ: "cong ngotien10@gmail." -> "cong.ngotien10@gmail.com")
  static String cleanEmail(String rawEmail) {
    // Bỏ tiền tố email: / e-mail: / e.mail: / mail:
    var cleaned = rawEmail.replaceAll(
      RegExp(r'^(?:e-?mail|mail|thư điện tử)[\s\.:]+', caseSensitive: false),
      '',
    ).trim();

    // Thay thế khoảng cách trong phần username của email thành dấu chấm (ví dụ "cong ngotien10" -> "cong.ngotien10")
    if (cleaned.contains('@')) {
      final parts = cleaned.split('@');
      final userPart = parts[0]
          .replaceAll(RegExp(r'\s+'), '.')
          .replaceAll(RegExp(r'\.+'), '.');
      var domainPart = parts[1].replaceAll(RegExp(r'\s+'), '');

      // Tự động hoàn thiện các đuôi mail phổ biến bị OCR cắt cụt lề
      if (domainPart.toLowerCase() == 'gmail.' || domainPart.toLowerCase() == 'gmail') {
        domainPart = 'gmail.com';
      } else if (domainPart.toLowerCase() == 'yahoo.' || domainPart.toLowerCase() == 'yahoo') {
        domainPart = 'yahoo.com';
      } else if (domainPart.endsWith('.')) {
        domainPart = '${domainPart}com';
      }

      cleaned = '$userPart@$domainPart';
    } else {
      cleaned = cleaned.replaceAll(RegExp(r'\s+'), '');
    }

    cleaned = cleaned.replaceAll(RegExp(r'[,\.;:]+$'), '');
    return cleaned;
  }
}
