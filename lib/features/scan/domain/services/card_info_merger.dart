import '../entities/business_card_info.dart';

/// Gộp thông tin bóc tách từ 2 mặt danh thiếp.
///
/// Mỗi mặt được OCR + parse riêng (parser dựa vào cỡ chữ / vị trí dòng nên không
/// ghép text 2 ảnh lại rồi mới parse). Quy tắc gộp theo từng trường:
/// - Chỉ một mặt có giá trị → lấy giá trị đó (kèm cờ "Kiểm tra lại" của mặt đó).
/// - Cả hai có và giống nhau (sau chuẩn hoá) → lấy mặt trước.
/// - Cả hai có và khác nhau → mặt trước làm giá trị chính, giá trị mặt sau
///   đưa vào `alternatives` để hiện thành gợi ý khi sửa trường.
/// - Dòng chưa gán của hai mặt được gộp lại, id thêm tiền tố `f_` / `b_` để không trùng.
class CardInfoMerger {
  const CardInfoMerger._();

  static const fieldKeys = [
    'name',
    'furigana',
    'jobTitle',
    'company',
    'department',
    'phone',
    'mobile',
    'fax',
    'email',
    'website',
    'address',
    'postalCode',
  ];

  static const _phoneKeys = {'phone', 'mobile', 'fax', 'postalCode'};

  static BusinessCardInfo merge(BusinessCardInfo? front, BusinessCardInfo? back) {
    if (front == null && back == null) return const BusinessCardInfo();
    if (back == null) return _prefixLines(front!, 'f_');
    if (front == null) return _prefixLines(back, 'b_');

    final values = <String, String?>{};
    final flags = <String, bool>{};
    final alternatives = <String, List<String>>{};

    for (final key in fieldKeys) {
      final f = _clean(valueOf(front, key));
      final b = _clean(valueOf(back, key));
      final alts = <String>[];

      if (f != null) {
        values[key] = f;
        if (front.isFieldNeedsReview(key)) flags[key] = true;
        alts.addAll(front.alternatives[key] ?? const []);
        if (b != null && !_same(key, f, b)) alts.add(b);
      } else if (b != null) {
        values[key] = b;
        if (back.isFieldNeedsReview(key)) flags[key] = true;
      }
      alts.addAll(back.alternatives[key] ?? const []);

      final chosen = values[key];
      final unique = <String>[];
      for (final a in alts) {
        final ca = _clean(a);
        if (ca == null || (chosen != null && _same(key, chosen, ca))) continue;
        if (unique.any((u) => _same(key, u, ca))) continue;
        unique.add(ca);
      }
      if (unique.isNotEmpty) alternatives[key] = unique;
    }

    return BusinessCardInfo(
      name: values['name'],
      furigana: values['furigana'],
      jobTitle: values['jobTitle'],
      company: values['company'],
      department: values['department'],
      phone: values['phone'],
      mobile: values['mobile'],
      fax: values['fax'],
      email: values['email'],
      website: values['website'],
      address: values['address'],
      postalCode: values['postalCode'],
      reviewFlags: flags,
      alternatives: alternatives,
      unmappedLines: [
        ...front.unmappedLines.map((l) => l.copyWith(id: 'f_${l.id}')),
        ...back.unmappedLines.map((l) => l.copyWith(id: 'b_${l.id}')),
      ],
    );
  }

  static String? valueOf(BusinessCardInfo info, String key) => info.fieldValue(key);

  static BusinessCardInfo _prefixLines(BusinessCardInfo info, String prefix) => info.copyWith(
        unmappedLines: info.unmappedLines.map((l) => l.copyWith(id: '$prefix${l.id}')).toList(),
      );

  static String? _clean(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  /// So sánh "cùng một giá trị": số → chỉ so chữ số; email/web → bỏ hoa thường;
  /// còn lại → bỏ khoảng trắng + hoa thường.
  static bool _same(String key, String a, String b) {
    if (_phoneKeys.contains(key)) {
      final da = a.replaceAll(RegExp(r'\D'), '');
      final db = b.replaceAll(RegExp(r'\D'), '');
      if (da.isNotEmpty && db.isNotEmpty) return _stripCountryCode(da) == _stripCountryCode(db);
    }
    if (key == 'website') {
      String norm(String s) => s
          .toLowerCase()
          .replaceFirst(RegExp(r'^https?://'), '')
          .replaceFirst(RegExp(r'^www\.'), '')
          .replaceFirst(RegExp(r'/$'), '');
      return norm(a) == norm(b);
    }
    String norm(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    return norm(a) == norm(b);
  }

  /// "+81 3-1234-5678" và "03-1234-5678" là cùng một số.
  static String _stripCountryCode(String digits) {
    for (final cc in const ['81', '84']) {
      if (digits.startsWith(cc) && digits.length >= 10) {
        final national = digits.substring(cc.length);
        // "+81 (0)3-…" → bỏ số 0 thừa
        return national.startsWith('0') ? national : '0$national';
      }
    }
    return digits;
  }
}
