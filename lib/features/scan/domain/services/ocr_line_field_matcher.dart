import '../entities/business_card_info.dart';

/// Đoán một dòng OCR đã nằm trong trường nào của form (dùng để tô màu khung trên ảnh).
///
/// `BusinessCardInfo` không lưu dòng nào đã gán vào trường nào, nên so khớp theo nội dung:
/// - Dòng có ≥ 6 chữ số (điện thoại / FAX / mã bưu chính) → so chữ số, bỏ qua "TEL", gạch, ngoặc…
/// - Còn lại → bỏ khoảng trắng + hoa thường, khớp khi giá trị trường chứa dòng hoặc ngược lại
///   (VD: dòng "Email: a@b.jp" khớp trường email "a@b.jp"; dòng "東京都千代田区" khớp địa chỉ dài hơn).
class OcrLineFieldMatcher {
  const OcrLineFieldMatcher._();

  static const _phoneKeys = ['phone', 'mobile', 'fax', 'postalCode'];

  /// Key của trường chứa [lineText], hoặc `null` nếu dòng chưa được dùng.
  static String? fieldOf(BusinessCardInfo info, String lineText) {
    final line = _compact(lineText);
    if (line.isEmpty) return null;

    final lineDigits = _digits(lineText);
    if (lineDigits.length >= 6) {
      for (final key in _phoneKeys) {
        final d = _digits(info.fieldValue(key) ?? '');
        if (d.length >= 6 && (lineDigits.contains(d) || d.contains(lineDigits))) return key;
      }
    }

    for (final key in BusinessCardInfo.fieldKeys) {
      final value = _compact(info.fieldValue(key) ?? '');
      if (value.isEmpty) continue;
      if (value == line) return key;
      // Tránh khớp nhầm chuỗi quá ngắn (1 ký tự) vào trường dài
      if (line.length >= 2 && value.contains(line)) return key;
      if (value.length >= 3 && line.contains(value)) return key;
    }
    return null;
  }

  static String _compact(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), '');

  static String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');
}
