import '../entities/saved_card.dart';

/// Chuyển danh thiếp sang vCard / CSV (Dart thuần, không phụ thuộc UI hay plugin).
class CardExport {
  CardExport._();

  // ───────────────────────── vCard 3.0 ─────────────────────────

  /// vCard 3.0 cho một danh thiếp. Tên kiểu Nhật "山田 太郎" → họ "山田", tên "太郎".
  static String toVCard(SavedCard card) {
    final lines = <String>['BEGIN:VCARD', 'VERSION:3.0'];

    final (family, given) = _splitName(card.name);
    final fullName = card.name ?? card.company ?? card.email ?? '';
    lines.add('N:${_esc(family)};${_esc(given)};;;');
    lines.add('FN:${_esc(fullName)}');

    final (phoneticFamily, phoneticGiven) = _splitName(card.furigana);
    if (phoneticFamily.isNotEmpty) lines.add('X-PHONETIC-LAST-NAME:${_esc(phoneticFamily)}');
    if (phoneticGiven.isNotEmpty) lines.add('X-PHONETIC-FIRST-NAME:${_esc(phoneticGiven)}');

    if (card.company != null || card.department != null) {
      lines.add('ORG:${_esc(card.company ?? '')}${card.department != null ? ';${_esc(card.department!)}' : ''}');
    }
    if (card.jobTitle != null) lines.add('TITLE:${_esc(card.jobTitle!)}');
    if (card.phone != null) lines.add('TEL;TYPE=WORK,VOICE:${_esc(card.phone!)}');
    if (card.mobile != null) lines.add('TEL;TYPE=CELL:${_esc(card.mobile!)}');
    if (card.fax != null) lines.add('TEL;TYPE=WORK,FAX:${_esc(card.fax!)}');
    if (card.email != null) lines.add('EMAIL;TYPE=INTERNET,WORK:${_esc(card.email!)}');
    if (card.website != null) lines.add('URL:${_esc(card.website!)}');
    if (card.address != null || card.postalCode != null) {
      final zip = card.postalCode?.replaceFirst('〒', '').trim() ?? '';
      // ADR: hộp thư;mở rộng;đường;thành phố;vùng;mã bưu chính;quốc gia
      lines.add('ADR;TYPE=WORK:;;${_esc(card.address ?? '')};;;${_esc(zip)};');
    }
    final note = card.note?.trim();
    if (note != null && note.isNotEmpty) lines.add('NOTE:${_esc(note)}');

    lines.add('END:VCARD');
    return '${lines.map(_fold).join('\r\n')}\r\n';
  }

  /// Tên file .vcf an toàn cho hệ thống file, vd. "山田太郎.vcf".
  static String vCardFileName(SavedCard card) {
    final base = (card.displayName ?? 'card').replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '');
    return '${base.isEmpty ? 'card' : base}.vcf';
  }

  /// "山田 太郎" → ("山田", "太郎"); không có khoảng trắng → (toàn bộ, "").
  static (String, String) _splitName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return ('', '');
    final parts = v.split(RegExp(r'[\s　]+'));
    if (parts.length == 1) return (parts.first, '');
    return (parts.first, parts.sublist(1).join(' '));
  }

  static String _esc(String v) => v
      .replaceAll(r'\', r'\\')
      .replaceAll('\r\n', r'\n')
      .replaceAll('\n', r'\n')
      .replaceAll(',', r'\,')
      .replaceAll(';', r'\;');

  /// Gập dòng dài theo RFC 2425 (tối đa 75 ký tự, dòng tiếp bắt đầu bằng khoảng trắng).
  static String _fold(String line) {
    if (line.length <= 75) return line;
    final buf = StringBuffer();
    var i = 0;
    while (i < line.length) {
      final end = (i + 75).clamp(0, line.length);
      if (i > 0) buf.write('\r\n ');
      buf.write(line.substring(i, end));
      i = end;
    }
    return buf.toString();
  }

  // ───────────────────────── CSV ─────────────────────────

  /// CSV UTF-8 có BOM để Excel (kể cả bản tiếng Nhật) mở đúng font.
  /// [headers] là tiêu đề cột đã dịch, đúng thứ tự [csvColumns].
  static String toCsv(List<SavedCard> cards, List<String> headers, {String Function(DateTime)? formatDate}) {
    assert(headers.length == csvColumnCount);
    String date(DateTime? d) => d == null ? '' : (formatDate?.call(d) ?? d.toIso8601String());

    final rows = <List<String>>[
      headers,
      for (final c in cards)
        [
          c.name ?? '',
          c.furigana ?? '',
          c.company ?? '',
          c.department ?? '',
          c.jobTitle ?? '',
          c.phone ?? '',
          c.mobile ?? '',
          c.fax ?? '',
          c.email ?? '',
          c.website ?? '',
          c.postalCode ?? '',
          c.address ?? '',
          date(c.metAt),
          c.metPlace ?? '',
          c.note ?? '',
          c.tags.join(' / '),
          date(c.createdAt),
        ],
    ];
    return '﻿${rows.map((r) => r.map(_csvCell).join(',')).join('\r\n')}\r\n';
  }

  /// Số cột của [toCsv]: Họ tên, Furigana, Công ty, Phòng ban, Chức vụ, Điện thoại, Di động,
  /// FAX, Email, Website, Mã bưu chính, Địa chỉ, Ngày gặp, Nơi gặp, Ghi chú, Tag, Ngày thêm.
  static const int csvColumnCount = 17;

  /// "meishi_20261112.csv"
  static String csvFileName(DateTime now) =>
      'meishi_${now.year}${_two(now.month)}${_two(now.day)}.csv';

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _csvCell(String v) {
    // Chặn CSV injection khi mở bằng Excel: ô bắt đầu bằng = + - @ bị coi là công thức.
    // Giữ nguyên số điện thoại dạng "+81 ..." (chỉ chứa chữ số / khoảng trắng / - ( )).
    var value = v;
    if (value.isNotEmpty &&
        '=+-@'.contains(value[0]) &&
        !RegExp(r'^\+?[\d\s\-()]+$').hasMatch(value)) {
      value = "'$value";
    }
    final needsQuote = value.contains(RegExp(r'[",\r\n]'));
    final escaped = value.replaceAll('"', '""');
    return needsQuote ? '"$escaped"' : escaped;
  }
}
