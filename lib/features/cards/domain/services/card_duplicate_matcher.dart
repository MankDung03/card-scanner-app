import '../entities/saved_card.dart';

/// Lý do 2 danh thiếp bị coi là cùng một người.
enum DuplicateReason {
  /// Cùng email cá nhân (không tính email chung kiểu info@, sales@…)
  email,

  /// Cùng số di động
  mobile,

  /// Cùng họ tên + cùng công ty
  nameAndCompany,

  /// Cùng họ tên + cùng số máy bàn
  nameAndPhone,
}

class DuplicateMatch {
  final SavedCard card;
  final DuplicateReason reason;

  const DuplicateMatch(this.card, this.reason);

  /// Mức "Mạnh" (email / di động) hay "Trung bình" (tên + công ty / máy bàn)
  bool get isStrong => reason == DuplicateReason.email || reason == DuplicateReason.mobile;
}

/// Quy tắc nhận biết danh thiếp trùng (dùng khi khôi phục bản sao lưu và khi kiểm tra trùng lúc lưu).
///
/// | Mức        | Điều kiện                                                    |
/// |------------|--------------------------------------------------------------|
/// | Giống hệt  | Mọi trường giống nhau sau khi chuẩn hoá → [isIdentical]       |
/// | Mạnh       | Cùng email cá nhân, hoặc cùng số di động                      |
/// | Trung bình | Cùng họ tên VÀ (cùng công ty, hoặc cùng số máy bàn)           |
/// | Không tính | Chỉ trùng tên / chỉ trùng công ty / chỉ trùng máy bàn         |
///
/// Trước khi so: chữ/số toàn góc → bán góc, bỏ khoảng trắng trong tên, email chữ thường,
/// số điện thoại chỉ giữ chữ số (+81 → 0), tên công ty bỏ 株式会社 / (株) / Co., Ltd. …
class CardDuplicateMatcher {
  CardDuplicateMatcher._();

  /// Phần trước @ của các email dùng chung cho cả phòng ban / công ty
  static const genericEmailLocalParts = {
    'info', 'information', 'sales', 'contact', 'contactus', 'support', 'office', 'admin', 'inquiry',
    'inquiries', 'mail', 'hello', 'webmaster', 'noreply', 'no-reply', 'eigyo', 'eigyou', 'soumu',
    'jinji', 'recruit', 'saiyo', 'pr', 'press', 'customer', 'service', 'help', 'otoiawase', 'toiawase',
  };

  /// Tìm danh thiếp trong [candidates] có khả năng cùng người với [card] (bỏ qua chính nó).
  /// Ưu tiên mức Mạnh; null nếu không có.
  static DuplicateMatch? findDuplicate(SavedCard card, Iterable<SavedCard> candidates) {
    DuplicateMatch? medium;
    for (final other in candidates) {
      if (other.id == card.id) continue;
      final reason = matchReason(card, other);
      if (reason == null) continue;
      final match = DuplicateMatch(other, reason);
      if (match.isStrong) return match;
      medium ??= match;
    }
    return medium;
  }

  /// Lý do [a] và [b] bị coi là cùng người, hoặc null nếu không trùng.
  static DuplicateReason? matchReason(SavedCard a, SavedCard b) {
    final emailA = personalEmail(a.email);
    if (emailA != null && emailA == personalEmail(b.email)) return DuplicateReason.email;

    final mobileA = phoneDigits(a.mobile);
    if (mobileA != null && mobileA == phoneDigits(b.mobile)) return DuplicateReason.mobile;

    final nameA = nameKey(a.name);
    if (nameA == null || nameA != nameKey(b.name)) return null;

    final companyA = companyKey(a.company);
    if (companyA != null && companyA == companyKey(b.company)) return DuplicateReason.nameAndCompany;

    final phoneA = phoneDigits(a.phone);
    if (phoneA != null && phoneA == phoneDigits(b.phone)) return DuplicateReason.nameAndPhone;

    return null;
  }

  /// Mọi trường nội dung giống nhau sau khi chuẩn hoá (không so ảnh, ngày tạo, id).
  static bool isIdentical(SavedCard a, SavedCard b) {
    String? t(String? v) => text(v);
    final sameTags = {...a.tags.map(text)}.difference({...b.tags.map(text)}).isEmpty &&
        {...b.tags.map(text)}.difference({...a.tags.map(text)}).isEmpty;
    final sameMetAt = (a.metAt == null && b.metAt == null) ||
        (a.metAt != null &&
            b.metAt != null &&
            a.metAt!.year == b.metAt!.year &&
            a.metAt!.month == b.metAt!.month &&
            a.metAt!.day == b.metAt!.day);

    return nameKey(a.name) == nameKey(b.name) &&
        nameKey(a.furigana) == nameKey(b.furigana) &&
        t(a.company) == t(b.company) &&
        t(a.department) == t(b.department) &&
        t(a.jobTitle) == t(b.jobTitle) &&
        phoneDigits(a.phone) == phoneDigits(b.phone) &&
        phoneDigits(a.mobile) == phoneDigits(b.mobile) &&
        phoneDigits(a.fax) == phoneDigits(b.fax) &&
        t(a.email)?.toLowerCase() == t(b.email)?.toLowerCase() &&
        t(a.website)?.toLowerCase() == t(b.website)?.toLowerCase() &&
        t(a.address) == t(b.address) &&
        phoneDigits(a.postalCode) == phoneDigits(b.postalCode) &&
        t(a.note) == t(b.note) &&
        t(a.metPlace) == t(b.metPlace) &&
        sameMetAt &&
        sameTags;
  }

  // ───────────────────────── Chuẩn hoá ─────────────────────────

  /// Toàn góc → bán góc (Ａ→A, ０→0, ＠→@, khoảng trắng toàn góc → thường), trim, rỗng → null.
  static String? text(String? value) {
    if (value == null) return null;
    final buf = StringBuffer();
    for (final rune in value.runes) {
      if (rune >= 0xFF01 && rune <= 0xFF5E) {
        buf.writeCharCode(rune - 0xFEE0);
      } else if (rune == 0x3000) {
        buf.write(' ');
      } else {
        buf.writeCharCode(rune);
      }
    }
    final s = buf.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
    return s.isEmpty ? null : s;
  }

  /// "山田 太郎" = "山田太郎" = "Yamada  Taro" ~ "yamadataro"
  static String? nameKey(String? name) => text(name)?.replaceAll(' ', '').toLowerCase();

  /// Email chữ thường; null nếu trống, không hợp lệ hoặc là email dùng chung (info@, sales@…).
  static String? personalEmail(String? email) {
    final e = text(email)?.toLowerCase().replaceAll(' ', '');
    if (e == null) return null;
    final at = e.indexOf('@');
    if (at <= 0 || at == e.length - 1) return null;
    if (genericEmailLocalParts.contains(e.substring(0, at))) return null;
    return e;
  }

  /// Chỉ giữ chữ số; "+81 3-1234-5678" → "0312345678". Dưới 6 chữ số coi như không có.
  static String? phoneDigits(String? phone) {
    final t = text(phone);
    if (t == null) return null;
    var digits = t.replaceAll(RegExp(r'\D'), '');
    if (t.startsWith('+81') && digits.startsWith('81')) digits = '0${digits.substring(2)}';
    return digits.length < 6 ? null : digits;
  }

  static final _companyNoise = RegExp(
    r'株式会社|有限会社|合同会社|合資会社|合名会社|一般社団法人|一般財団法人|'
    r'\(株\)|\(有\)|㈱|㈲|'
    r'co\.?\s*,?\s*ltd\.?|inc\.?|corp\.?|corporation|limited|llc|k\.k\.?|'
    r'công ty|cổ phần|tnhh|jsc',
    caseSensitive: false,
  );

  /// "株式会社サンプル商事" = "(株)サンプル商事" = "サンプル商事 株式会社"
  static String? companyKey(String? company) {
    final t = text(company)?.toLowerCase();
    if (t == null) return null;
    final key = t.replaceAll(_companyNoise, '').replaceAll(RegExp(r'[\s.,・()\-]'), '');
    return key.isEmpty ? null : key;
  }
}
