import '../entities/saved_card.dart';

/// Cách sắp xếp danh sách danh thiếp (được ghi nhớ giữa các lần mở app)
enum CardSortOrder { newest, oldest, nameAZ, companyAZ }

/// Một nhóm khi sắp xếp theo công ty. [company] = null → nhóm "Không có công ty".
class CardGroup {
  final String? company;
  final List<SavedCard> cards;

  const CardGroup(this.company, this.cards);
}

/// Bộ lọc + sắp xếp danh sách danh thiếp (thuần Dart, không phụ thuộc UI).
///
/// - Tìm kiếm: không phân biệt hoa thường / dấu tiếng Việt / hiragana-katakana / chữ full-width.
/// - Lọc: "Có ghi chú" và tag (chọn nhiều tag → thẻ có ÍT NHẤT MỘT tag đã chọn).
/// - Sắp xếp tên: ưu tiên furigana (thứ tự あいうえお), tên tiếng Việt bỏ dấu khi so sánh.
/// - Sắp xếp công ty: bỏ hình thức pháp lý (株式会社, Co., Ltd., Công ty TNHH…),
///   thẻ không có công ty xếp cuối.
class CardListQuery {
  final String search;
  final CardSortOrder sort;
  final bool hasNoteOnly;
  final Set<String> tags;

  const CardListQuery({
    this.search = '',
    this.sort = CardSortOrder.newest,
    this.hasNoteOnly = false,
    this.tags = const {},
  });

  /// Có đang lọc (làm giảm số thẻ) hay không — sắp xếp không tính là lọc
  bool get isFiltering => search.trim().isNotEmpty || hasNoteOnly || tags.isNotEmpty;

  List<SavedCard> apply(List<SavedCard> cards) {
    final q = fold(search.trim());
    final filtered = cards.where((c) {
      if (hasNoteOnly && (c.note?.trim().isEmpty ?? true)) return false;
      if (tags.isNotEmpty && !c.tags.any(tags.contains)) return false;
      if (q.isNotEmpty && !_searchText(c).contains(q)) return false;
      return true;
    }).toList();

    switch (sort) {
      case CardSortOrder.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case CardSortOrder.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case CardSortOrder.nameAZ:
        filtered.sort(_compareByName);
      case CardSortOrder.companyAZ:
        filtered.sort((a, b) {
          final ka = companySortKey(a.company);
          final kb = companySortKey(b.company);
          if (ka == null && kb == null) return _compareByName(a, b);
          if (ka == null) return 1; // không có công ty → cuối
          if (kb == null) return -1;
          final c = ka.compareTo(kb);
          return c != 0 ? c : _compareByName(a, b);
        });
    }
    return filtered;
  }

  /// Chia danh sách ĐÃ sắp xếp theo công ty thành từng nhóm (giữ nguyên thứ tự).
  static List<CardGroup> groupByCompany(List<SavedCard> sorted) {
    final groups = <CardGroup>[];
    String? currentKey;
    for (final card in sorted) {
      final key = companySortKey(card.company);
      if (groups.isEmpty || key != currentKey) {
        groups.add(CardGroup(key == null ? null : card.company, []));
        currentKey = key;
      }
      groups.last.cards.add(card);
    }
    return groups;
  }

  /// Các tag đang có, tag dùng nhiều nhất lên đầu (bằng nhau → theo tên)
  static List<String> tagsByUsage(List<SavedCard> cards) {
    final counts = <String, int>{};
    for (final c in cards) {
      for (final t in c.tags) {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    final list = counts.keys.toList()
      ..sort((a, b) {
        final c = counts[b]!.compareTo(counts[a]!);
        return c != 0 ? c : fold(a).compareTo(fold(b));
      });
    return list;
  }

  // ───────────────────────── Khoá sắp xếp ─────────────────────────

  static int _compareByName(SavedCard a, SavedCard b) {
    final c = nameSortKey(a).compareTo(nameSortKey(b));
    return c != 0 ? c : b.createdAt.compareTo(a.createdAt);
  }

  /// Furigana nếu có (tên Nhật), không thì tên hiển thị; đã chuẩn hoá để so sánh.
  /// Thẻ không có tên dùng ký tự lớn để xếp cuối.
  static String nameSortKey(SavedCard card) {
    final source = card.furigana ?? card.displayName;
    if (source == null || source.trim().isEmpty) return '\u{FFFF}';
    return fold(source);
  }

  static final List<RegExp> _legalForms = [
    // Tiếng Nhật
    RegExp(r'株式会社|有限会社|合同会社|合資会社|合名会社|相互会社'),
    RegExp(r'[（(]\s*[株有]\s*[）)]'),
    RegExp(r'(一般|公益)(社団|財団)法人|独立行政法人|学校法人|医療法人|社会福祉法人'),
    // Tiếng Việt (so trên chuỗi đã bỏ dấu)
    RegExp(r'^\s*(tong\s+)?cong\s+ty(\s+(tnhh|co\s+phan|cp|trach\s+nhiem\s+huu\s+han))?(\s+(mtv|mot\s+thanh\s+vien|hai\s+thanh\s+vien(\s+tro\s+len)?))?\b'),
    RegExp(r'^\s*(tap\s+doan|ngan\s+hang\s+tmcp)\b'),
    // Tiếng Anh
    RegExp(r'\b(co\.?\s*,?\s*ltd\.?|company\s+limited|limited|ltd\.?|inc\.?|incorporated|corp\.?|corporation|llc|jsc|plc|k\.?\s?k\.?)(?=\W|$)'),
  ];

  /// Tên công ty đã bỏ hình thức pháp lý và chuẩn hoá; `null` nếu không có công ty.
  static String? companySortKey(String? company) {
    if (company == null || company.trim().isEmpty) return null;
    var key = fold(company);
    for (final re in _legalForms) {
      key = key.replaceAll(re, ' ');
    }
    key = key.replaceAll(RegExp(r'[\s.,、。・\-–—&]+'), ' ').trim();
    return key.isEmpty ? fold(company) : key;
  }

  // ───────────────────────── Chuẩn hoá chuỗi ─────────────────────────

  static String _searchText(SavedCard c) => fold([
        c.name,
        c.furigana,
        c.company,
        c.department,
        c.jobTitle,
        c.phone,
        c.mobile,
        c.fax,
        c.email,
        c.website,
        c.address,
        c.postalCode,
        c.note,
        c.metPlace,
        ...c.tags,
      ].whereType<String>().join('\n'));

  static const _viFrom = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
  static const _viTo = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

  /// Chuẩn hoá để so sánh / tìm kiếm:
  /// chữ thường, bỏ dấu tiếng Việt (đ→d), full-width → half-width, katakana → hiragana.
  static String fold(String input) {
    final buf = StringBuffer();
    for (final rune in input.toLowerCase().runes) {
      var r = rune;
      if (r >= 0x0300 && r <= 0x036F) continue; // dấu tổ hợp (chữ Việt dạng NFD)
      if (r >= 0xFF01 && r <= 0xFF5E) {
        r -= 0xFEE0; // Ａ１ → a1
      } else if (r == 0x3000) {
        r = 0x20; // khoảng trắng full-width
      } else if (r >= 0x30A1 && r <= 0x30F6) {
        r -= 0x60; // カタカナ → ひらがな
      }
      final ch = String.fromCharCode(r).toLowerCase();
      final i = _viFrom.indexOf(ch);
      buf.write(i == -1 ? ch : _viTo[i]);
    }
    return buf.toString();
  }
}
