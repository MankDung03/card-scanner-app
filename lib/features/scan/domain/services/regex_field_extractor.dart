import '../entities/business_card_result.dart';
import '../entities/ocr_model.dart';
import 'text_normalizer.dart';

/// Kết quả trích xuất của bước Regex
class RegexExtractionResult {
  final List<FieldValue> emails;
  final FieldValue? zipcode;
  final List<PhoneEntry> phones;
  final FieldValue? website;

  const RegexExtractionResult({
    this.emails = const [],
    this.zipcode,
    this.phones = const [],
    this.website,
  });
}

/// Trích xuất các trường định dạng chuẩn theo Regex (Email -> Zipcode -> Phones -> Website)
class RegexFieldExtractor {
  // Regex Email chuẩn
  static final RegExp _emailRegex = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    caseSensitive: false,
  );

  // Regex Zipcode Nhật Bản (〒100-0001 hoặc 100-0001)
  static final RegExp _japanZipcodeRegex = RegExp(
    r'(?:〒\s*)?(\d{3}-\d{4})',
  );

  // Regex Website
  static final RegExp _websiteRegex = RegExp(
    r'(?:https?:\/\/)?(?:www\.)?([a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\.(?:com|vn|jp|net|org|co\.jp|gov|edu|io|ai|biz))(?:\/[^\s]*)?',
    caseSensitive: false,
  );

  /// Chạy tuần tự 4 pass Regex trên danh sách dòng OCR
  static RegexExtractionResult extract(List<OcrLine> lines) {
    final emails = <FieldValue>[];
    FieldValue? zipcode;
    final phones = <PhoneEntry>[];
    FieldValue? website;

    // =========================================================================
    // PASS 1: EMAIL (Chạy đầu tiên để không bị Website nuốt mất)
    // =========================================================================
    for (final line in lines) {
      if (line.isConsumed) continue;
      final text = line.normalizedText;

      // 1.1 Khớp trực tiếp chuẩn RFC
      final matches = _emailRegex.allMatches(text);
      if (matches.isNotEmpty) {
        for (final m in matches) {
          final matchedEmail = m.group(0)!;
          emails.add(FieldValue(
            value: matchedEmail,
            confidence: 0.98,
            sourceLineIds: [line.id],
          ));
        }
        line.isConsumed = true;
        continue;
      }

      // 1.2 Phục hồi Email bị ngắt dấu cách do OCR (ví dụ: "Email. cong ngotien 0@gmail.com")
      if (text.toLowerCase().contains('email') && text.contains('@')) {
        final cleaned = TextNormalizer.cleanEmail(text);
        final matchAfterClean = _emailRegex.firstMatch(cleaned);
        if (matchAfterClean != null) {
          emails.add(FieldValue(
            value: matchAfterClean.group(0)!,
            confidence: 0.85,
            sourceLineIds: [line.id],
          ));
          line.isConsumed = true;
          continue;
        }
      }
    }

    // =========================================================================
    // PASS 2: ZIPCODE (Chạy trước Phone để 100-0001 không bị nhầm thành SĐT)
    // =========================================================================
    for (final line in lines) {
      if (line.isConsumed) continue;
      final text = line.normalizedText;

      final match = _japanZipcodeRegex.firstMatch(text);
      if (match != null) {
        // Chỉ nhận khi có ký hiệu 〒 hoặc đứng cạnh tên tỉnh thành Nhật
        if (text.contains('〒') ||
            text.contains('東京都') ||
            text.contains('大阪府') ||
            text.contains('県')) {
          final code = match.group(1)!;
          zipcode = FieldValue(
            value: '〒$code',
            confidence: 0.95,
            sourceLineIds: [line.id],
          );

          // Nếu dòng này chỉ chứa Zipcode, đánh dấu đã dùng
          if (text.trim().length <= 12) {
            line.isConsumed = true;
          }
        }
      }
    }

    // =========================================================================
    // PASS 3: SỐ ĐIỆN THOẠI / DI ĐỘNG / FAX
    // =========================================================================
    for (final line in lines) {
      if (line.isConsumed) continue;
      final text = line.normalizedText;
      final lower = text.toLowerCase();

      // Kiểm tra tiền tố nhận diện
      final isFax = lower.contains('fax') ||
          lower.contains('ｆａｘ') ||
          lower.replaceAll(' ', '').contains('fax') ||
          lower.contains('facsimile');
      final isMobile = lower.contains('mobile') ||
          lower.contains('di động') ||
          lower.contains('dđ') ||
          lower.contains('携帯') ||
          lower.contains('cell') ||
          lower.contains('hotline');
      final isOffice = lower.contains('tel') ||
          lower.contains('điện thoại') ||
          lower.contains('phone') ||
          lower.contains('電話') ||
          lower.contains('dn thogit'); // Lỗi OCR phổ biến chữ Điện thoại

      // Trích xuất số điện thoại (chứa chữ số, +, -, (, ), .)
      final phoneMatch = RegExp(r'(\+?\(?\d[\d\s\-\(\)\.]{6,}\d(?:\s*\(代\))?)').firstMatch(text);
      if (phoneMatch != null) {
        final rawPhone = phoneMatch.group(0)!;
        // Chuỗi chỉ gồm chữ số để đếm độ dài hợp lệ (9-13 số)
        final digitsOnly = rawPhone.replaceAll(RegExp(r'\D'), '');

        if (digitsOnly.length >= 9 && digitsOnly.length <= 13) {
          // Làm sạch số hiển thị
          var cleanedPhone = rawPhone.trim().replaceAll(RegExp(r'\s+'), ' ');

          PhoneType type;
          if (isFax) {
            type = PhoneType.fax;
          } else if (isMobile) {
            type = PhoneType.mobile;
          } else if (isOffice) {
            type = PhoneType.office;
          } else {
            // Phân loại heuristic theo ngữ cảnh thẻ và đầu số
            final bool isJapanCard = lines.any((l) =>
                TextNormalizer.containsCjk(l.text) ||
                l.text.contains('〒') ||
                l.text.toLowerCase().contains('tokyo') ||
                l.text.toLowerCase().contains('japan'));

            if (isJapanCard) {
              // Ở Nhật: Mobile chỉ có 070, 080, 090
              if (digitsOnly.startsWith('070') ||
                  digitsOnly.startsWith('080') ||
                  digitsOnly.startsWith('090')) {
                type = PhoneType.mobile;
              } else {
                // Landline (03 Tokyo, 06 Osaka, ...).
                // Nếu thẻ đã có 1 số Phone/Office và chưa có Fax, số thứ 2 chính là Fax!
                final bool hasOfficeAlready =
                    phones.any((p) => p.type == PhoneType.office);
                final bool hasFaxAlready =
                    phones.any((p) => p.type == PhoneType.fax);

                if (hasOfficeAlready && !hasFaxAlready) {
                  type = PhoneType.fax;
                } else {
                  type = PhoneType.office;
                }
              }
            } else {
              // Việt Nam & Quốc tế
              if (digitsOnly.startsWith('09') ||
                  digitsOnly.startsWith('03') ||
                  digitsOnly.startsWith('07') ||
                  digitsOnly.startsWith('08') ||
                  digitsOnly.startsWith('05') ||
                  digitsOnly.startsWith('849') ||
                  digitsOnly.startsWith('843') ||
                  digitsOnly.startsWith('847') ||
                  digitsOnly.startsWith('848')) {
                type = PhoneType.mobile;
              } else {
                type = PhoneType.office;
              }
            }
          }

          phones.add(PhoneEntry(
            number: cleanedPhone,
            type: type,
            confidence: (isFax || isMobile || isOffice) ? 0.95 : 0.85,
            sourceLineIds: [line.id],
          ));

          line.isConsumed = true;
        }
      }
    }

    // =========================================================================
    // PASS 4: WEBSITE (Chạy sau Email, loại bỏ email domain trước)
    // =========================================================================
    for (final line in lines) {
      if (line.isConsumed) continue;
      var text = line.normalizedText;

      // Loại bỏ email nếu dòng này từng có email để không bắt gmail.com
      text = text.replaceAll(_emailRegex, '');

      // Làm sạch khoảng cách rác trong domain (ví dụ "www.vib.com. vn" -> "www.vib.com.vn")
      final spaceCleaned = text.replaceAll(RegExp(r'(?<=\.)\s+(?=[a-zA-Z])'), '');

      final match = _websiteRegex.firstMatch(spaceCleaned);
      if (match != null) {
        var rawUrl = match.group(0)!;
        final cleanedUrl = TextNormalizer.cleanUrl(rawUrl);

        website = FieldValue(
          value: cleanedUrl,
          confidence: 0.95,
          sourceLineIds: [line.id],
        );

        line.isConsumed = true;
      }
    }

    return RegexExtractionResult(
      emails: emails,
      zipcode: zipcode,
      phones: phones,
      website: website,
    );
  }
}
