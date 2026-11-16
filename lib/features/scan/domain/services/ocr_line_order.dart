import 'dart:ui';

import '../entities/ocr_model.dart';

/// Thứ tự đọc, lọc rác và cách nối các dòng OCR người dùng chọn để gán.
class OcrLineOrder {
  const OcrLineOrder._();

  /// Sắp [items] theo thứ tự đọc trên ảnh của MỘT mặt thẻ:
  /// - Chữ ngang: chia hàng (dòng chồng lên nhau theo chiều dọc ≥ nửa chiều cao → cùng hàng),
  ///   hàng trên trước, trong hàng trái → phải.
  /// - Chữ dọc (縦書き): cột phải → trái, trong cột trên → dưới.
  /// - Mặt có nhiều dòng dọc hơn ngang thì đọc phần dọc trước.
  static List<T> sort<T>(
    Iterable<T> items, {
    required Rect Function(T) rect,
    bool Function(T)? isVertical,
  }) {
    final list = items.toList();
    final vertical = [for (final i in list) if (isVertical?.call(i) ?? false) i];
    final horizontal = [for (final i in list) if (!(isVertical?.call(i) ?? false)) i];

    final rows = _rows(horizontal, rect);
    final cols = [...vertical]..sort((a, b) {
        final c = rect(b).center.dx.compareTo(rect(a).center.dx);
        return c != 0 ? c : rect(a).top.compareTo(rect(b).top);
      });

    return vertical.length > horizontal.length ? [...cols, ...rows] : [...rows, ...cols];
  }

  static List<T> _rows<T>(List<T> items, Rect Function(T) rect) {
    final byTop = [...items]..sort((a, b) => rect(a).top.compareTo(rect(b).top));
    final rows = <List<T>>[];
    var rowTop = 0.0, rowBottom = 0.0;
    for (final item in byTop) {
      final r = rect(item);
      final overlap = (rowBottom < r.bottom ? rowBottom : r.bottom) - r.top;
      final minH = r.height < (rowBottom - rowTop) ? r.height : (rowBottom - rowTop);
      if (rows.isNotEmpty && overlap >= minH / 2) {
        rows.last.add(item);
        if (r.bottom > rowBottom) rowBottom = r.bottom;
      } else {
        rows.add([item]);
        rowTop = r.top;
        rowBottom = r.bottom;
      }
    }
    return [
      for (final row in rows) ...(row..sort((a, b) => rect(a).left.compareTo(rect(b).left))),
    ];
  }

  /// Dòng chưa gán (id có tiền tố `f_` / `b_` từ CardInfoMerger) theo thứ tự đọc:
  /// toàn bộ mặt trước rồi tới mặt sau.
  static List<OcrLine> sortUnmapped(Iterable<OcrLine> lines) {
    final front = lines.where((l) => !l.id.startsWith('b_'));
    final back = lines.where((l) => l.id.startsWith('b_'));
    List<OcrLine> s(Iterable<OcrLine> ls) => sort(ls, rect: (l) => l.boundingBox, isVertical: (l) => l.isVertical);
    return [...s(front), ...s(back)];
  }

  /// Dòng rác không đáng hỏi người dùng khi lưu:
  /// - dưới 2 ký tự (không tính khoảng trắng)
  /// - chỉ có ký hiệu (không có chữ / số nào)
  /// - chỉ là một con số lẻ (≤ 3 chữ số)
  static bool isJunk(String text) {
    final compact = text.replaceAll(RegExp(r'\s+'), '');
    if (compact.runes.length < 2) return true;
    if (!RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(compact)) return true;
    final digitsOnly = compact.replaceAll(RegExp(r'[\p{P}\p{S}]', unicode: true), '');
    if (RegExp(r'^[0-9０-９]{1,3}$').hasMatch(digitsOnly) &&
        !RegExp(r'\p{L}', unicode: true).hasMatch(compact)) {
      return true;
    }
    return false;
  }

  /// Nối các dòng (đã theo thứ tự đọc) cho trường đích:
  /// trường chuẩn (kể cả địa chỉ) → dấu cách; trường tuỳ chỉnh / ghi chú → xuống dòng.
  static String join(Iterable<String> texts, {required bool multiline}) => texts
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .join(multiline ? '\n' : ' ');
}
