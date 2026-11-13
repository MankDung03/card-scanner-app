import 'package:app_scanner_card/features/cards/domain/entities/saved_card.dart';
import 'package:app_scanner_card/features/cards/domain/services/restore_planner.dart';
import 'package:flutter_test/flutter_test.dart';

SavedCard card(String id, {String? name, String? mobile, String? note, DateTime? updated, String? duplicateOf}) {
  final created = DateTime(2026, 1, 1);
  return SavedCard(
    id: id,
    name: name,
    mobile: mobile,
    note: note,
    createdAt: created,
    updatedAt: updated ?? created,
    duplicateOf: duplicateOf,
  );
}

void main() {
  final older = DateTime(2026, 1, 1);
  final newer = DateTime(2026, 6, 1);

  group('Gộp', () {
    test('cùng id: bản sao lưu mới hơn → cập nhật; cũ hơn / bằng → giữ bản trên máy', () {
      final plan = RestorePlanner.plan(
        existing: [card('1', note: 'local', updated: older), card('2', note: 'local', updated: newer)],
        incoming: [card('1', note: 'backup', updated: newer), card('2', note: 'backup', updated: older)],
        mode: RestoreMode.merge,
      );
      expect(plan.toWrite.map((c) => (c.id, c.note)), [('1', 'backup')]);
      expect(plan.summary.updated, 1);
      expect(plan.summary.keptLocal, 1);
    });

    test('giống hệt thẻ trên máy (khác id) → bỏ qua', () {
      final plan = RestorePlanner.plan(
        existing: [card('1', name: '山田 太郎', mobile: '090-1111-2222')],
        incoming: [card('9', name: '山田太郎', mobile: '09011112222')],
        mode: RestoreMode.merge,
      );
      expect(plan.toWrite, isEmpty);
      expect(plan.summary.skippedIdentical, 1);
    });

    test('trùng người → vẫn thêm, gắn cờ trỏ tới thẻ trên máy', () {
      final plan = RestorePlanner.plan(
        existing: [card('1', name: '山田 太郎', mobile: '090-1111-2222', note: 'cũ')],
        incoming: [card('9', name: '山田 太郎', mobile: '09011112222', note: 'mới')],
        mode: RestoreMode.merge,
      );
      expect(plan.toWrite.single.id, '9');
      expect(plan.toWrite.single.duplicateOf, '1');
      expect(plan.summary.added, 1);
      expect(plan.summary.flagged, 1);
    });

    test('không trùng → thêm mới, không gắn cờ; các thẻ trong bản sao lưu không so với nhau', () {
      final plan = RestorePlanner.plan(
        existing: [card('1', name: 'A', mobile: '090-0000-0001')],
        incoming: [
          card('8', name: '佐藤 健', mobile: '090-5555-0000'),
          card('9', name: '佐藤 健', mobile: '090-5555-0000', note: 'x'),
        ],
        mode: RestoreMode.merge,
      );
      expect(plan.toWrite.map((c) => c.duplicateOf), [null, null]);
      expect(plan.summary.added, 2);
      expect(plan.summary.flagged, 0);
    });
  });

  test('Thay thế toàn bộ: ghi nguyên bản sao lưu, bỏ cờ trỏ tới thẻ không có trong bản sao lưu', () {
    final plan = RestorePlanner.plan(
      existing: [card('1')],
      incoming: [card('8', duplicateOf: '9'), card('9'), card('7', duplicateOf: '1')],
      mode: RestoreMode.replaceAll,
    );
    expect(plan.toWrite.map((c) => (c.id, c.duplicateOf)), [('8', '9'), ('9', null), ('7', null)]);
    expect(plan.summary.added, 3);
  });
}
