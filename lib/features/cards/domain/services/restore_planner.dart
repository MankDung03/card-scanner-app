import '../entities/saved_card.dart';
import 'card_duplicate_matcher.dart';

enum RestoreMode {
  /// Xoá dữ liệu hiện tại, dùng nguyên bản sao lưu
  replaceAll,

  /// Gộp với dữ liệu hiện có (mặc định)
  merge,
}

/// Kết quả khôi phục để hiện bảng tổng kết.
class RestoreSummary {
  /// Thẻ mới được thêm (gồm cả thẻ bị gắn cờ trùng)
  final int added;

  /// Thẻ cùng id, bản sao lưu mới hơn → đã cập nhật
  final int updated;

  /// Thẻ cùng id, bản trên máy mới hơn hoặc bằng → giữ bản trên máy
  final int keptLocal;

  /// Giống hệt một thẻ đang có → bỏ qua
  final int skippedIdentical;

  /// Đã thêm nhưng có thể trùng người với thẻ đang có (gắn cờ để xem sau)
  final int flagged;

  const RestoreSummary({
    this.added = 0,
    this.updated = 0,
    this.keptLocal = 0,
    this.skippedIdentical = 0,
    this.flagged = 0,
  });

  int get total => added + updated + keptLocal + skippedIdentical;
}

/// Kế hoạch ghi: các thẻ cần thêm/ghi đè (ảnh còn trỏ tới file giải nén tạm) + tổng kết.
class RestorePlan {
  final RestoreMode mode;
  final List<SavedCard> toWrite;
  final RestoreSummary summary;

  const RestorePlan({required this.mode, required this.toWrite, required this.summary});
}

/// Quy tắc khôi phục (thuần, không đụng tới file):
///
/// **Thay thế toàn bộ:** ghi nguyên bản sao lưu, bỏ cờ trùng cũ trỏ tới thẻ không còn tồn tại.
///
/// **Gộp**, xét từng thẻ trong bản sao lưu:
/// 1. Cùng id với thẻ trên máy → giữ bản có `updatedAt` mới hơn (bằng nhau → giữ bản trên máy).
/// 2. Giống hệt mọi trường với một thẻ trên máy → bỏ qua.
/// 3. Trùng người với thẻ trên máy (quy tắc Mạnh / Trung bình) → vẫn thêm, gắn cờ `duplicateOf`.
/// 4. Còn lại → thêm mới.
///
/// Chỉ so với thẻ đang có trên máy, không so các thẻ trong bản sao lưu với nhau
/// (chúng đã cùng tồn tại trước đó).
class RestorePlanner {
  RestorePlanner._();

  static RestorePlan plan({
    required List<SavedCard> existing,
    required List<SavedCard> incoming,
    required RestoreMode mode,
  }) {
    if (mode == RestoreMode.replaceAll) {
      final ids = incoming.map((c) => c.id).toSet();
      final cards = [
        for (final c in incoming)
          (c.duplicateOf != null && !ids.contains(c.duplicateOf)) ? c.copyWith(duplicateOf: null) : c,
      ];
      return RestorePlan(mode: mode, toWrite: cards, summary: RestoreSummary(added: cards.length));
    }

    final existingById = {for (final c in existing) c.id: c};
    final toWrite = <SavedCard>[];
    var added = 0, updated = 0, keptLocal = 0, identical = 0, flagged = 0;

    for (final card in incoming) {
      final local = existingById[card.id];
      if (local != null) {
        if (card.updatedAt.isAfter(local.updatedAt)) {
          toWrite.add(card);
          updated++;
        } else {
          keptLocal++;
        }
        continue;
      }

      if (existing.any((e) => CardDuplicateMatcher.isIdentical(card, e))) {
        identical++;
        continue;
      }

      final match = CardDuplicateMatcher.findDuplicate(card, existing);
      if (match != null) {
        toWrite.add(card.copyWith(duplicateOf: match.card.id));
        flagged++;
      } else {
        toWrite.add(card);
      }
      added++;
    }

    return RestorePlan(
      mode: mode,
      toWrite: toWrite,
      summary: RestoreSummary(
        added: added,
        updated: updated,
        keptLocal: keptLocal,
        skippedIdentical: identical,
        flagged: flagged,
      ),
    );
  }
}
