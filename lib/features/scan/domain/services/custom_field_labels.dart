import '../entities/custom_field.dart';

/// Tên trường tuỳ chỉnh: chip gợi ý + chuẩn hoá về một dạng.
///
/// Chuẩn hoá ([normalize]):
/// 1. Bỏ khoảng trắng thừa, chữ/số full-width → half-width ("ＬＩＮＥ" → "LINE").
/// 2. Tên phổ biến có nhiều cách viết → một dạng chuẩn ("Line", "LINE ID", "ライン" → "LINE").
/// 3. Còn lại: nếu trùng (không phân biệt hoa thường / khoảng trắng) với tên đã dùng
///    → dùng lại cách viết đã có, để không thành "Skype" và "skype".
class CustomFieldLabels {
  const CustomFieldLabels._();

  /// Chip gợi ý cố định (theo thứ tự hiển thị)
  static const presets = ['LINE', 'X', 'Instagram', 'LinkedIn', 'Facebook', '内線', '資格'];

  /// key đã gấp ([_key]) → tên chuẩn
  static const Map<String, String> _aliases = {
    'line': 'LINE',
    'lineid': 'LINE',
    'ライン': 'LINE',
    'ラインid': 'LINE',
    'x': 'X',
    'twitter': 'X',
    'xtwitter': 'X',
    'twitterx': 'X',
    'ツイッター': 'X',
    'instagram': 'Instagram',
    'insta': 'Instagram',
    'ig': 'Instagram',
    'インスタ': 'Instagram',
    'インスタグラム': 'Instagram',
    'linkedin': 'LinkedIn',
    'リンクトイン': 'LinkedIn',
    'facebook': 'Facebook',
    'fb': 'Facebook',
    'フェイスブック': 'Facebook',
    '内線': '内線',
    'ext': '内線',
    'extension': '内線',
    'extn': '内線',
    '資格': '資格',
  };

  /// Nhãn mạng xã hội (dùng cho X-SOCIALPROFILE khi xuất vCard): tên chuẩn → type
  static const socialTypes = {
    'X': 'twitter',
    'Instagram': 'instagram',
    'LinkedIn': 'linkedin',
    'Facebook': 'facebook',
    'LINE': 'line',
  };

  /// Chuẩn hoá [raw]. [existing] = các tên đã dùng (để giữ cùng một cách viết).
  /// Trả về chuỗi rỗng nếu [raw] rỗng.
  static String normalize(String raw, {Iterable<String> existing = const []}) {
    final cleaned = _halfWidth(raw).replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return '';
    final key = _key(cleaned);
    final alias = _aliases[key];
    if (alias != null) return alias;
    for (final e in existing) {
      if (_key(e) == key) return e;
    }
    return cleaned;
  }

  /// Hai tên có được coi là cùng một trường không
  static bool same(String a, String b) => normalize(a) == normalize(b) || _key(a) == _key(b);

  /// Gợi ý: tên đã dùng (dùng nhiều trước) rồi tới [presets] còn lại, không lặp.
  static List<String> suggestions(Iterable<List<CustomField>> fieldLists) {
    final counts = <String, int>{};
    final order = <String>[];
    for (final fields in fieldLists) {
      for (final f in fields) {
        final label = normalize(f.label, existing: order);
        if (label.isEmpty) continue;
        if (!counts.containsKey(label)) order.add(label);
        counts[label] = (counts[label] ?? 0) + 1;
      }
    }
    final used = [...order]..sort((a, b) {
        final c = counts[b]!.compareTo(counts[a]!);
        return c != 0 ? c : order.indexOf(a).compareTo(order.indexOf(b));
      });
    return [
      ...used,
      for (final p in presets)
        if (!used.any((u) => _key(u) == _key(p))) p,
    ];
  }

  /// Gộp trường tuỳ chỉnh của nhiều nguồn, bỏ mục trùng cả tên lẫn giá trị.
  static List<CustomField> union(List<CustomField> a, List<CustomField> b) {
    final out = <CustomField>[];
    for (final f in [...a, ...b]) {
      final label = normalize(f.label, existing: out.map((e) => e.label));
      final value = f.value.trim();
      if (label.isEmpty || value.isEmpty) continue;
      if (out.any((e) => e.label == label && _valueKey(e.value) == _valueKey(value))) continue;
      out.add(CustomField(label: label, value: value));
    }
    return out;
  }

  static String _valueKey(String v) => _halfWidth(v).toLowerCase().replaceAll(RegExp(r'\s+'), '');

  /// Khoá so sánh: half-width, chữ thường, bỏ khoảng trắng / . _ - : ・
  static String _key(String s) =>
      _halfWidth(s).toLowerCase().replaceAll(RegExp(r'[\s._\-:：・]+'), '');

  static String _halfWidth(String s) {
    final buf = StringBuffer();
    for (final r in s.runes) {
      if (r >= 0xFF01 && r <= 0xFF5E) {
        buf.writeCharCode(r - 0xFEE0);
      } else if (r == 0x3000) {
        buf.writeCharCode(0x20);
      } else {
        buf.writeCharCode(r);
      }
    }
    return buf.toString();
  }
}
