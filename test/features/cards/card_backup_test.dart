import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:app_scanner_card/features/cards/data/repositories/local_card_repository.dart';
import 'package:app_scanner_card/features/cards/data/services/card_backup_service.dart';
import 'package:app_scanner_card/features/cards/domain/entities/saved_card.dart';
import 'package:app_scanner_card/features/cards/domain/services/restore_planner.dart';
import 'package:app_scanner_card/features/cards/presentation/cubit/saved_cards_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tmp;

  setUp(() async => tmp = await Directory.systemTemp.createTemp('backup_test_'));
  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  Future<File> image(String name, String content) async {
    final f = File('${tmp.path}/src/$name');
    await f.parent.create(recursive: true);
    return f.writeAsString(content);
  }

  SavedCard card(String id, {String? name, String? mobile, String? front, String? back, DateTime? updated}) {
    final t = DateTime(2026, 1, 1);
    return SavedCard(
      id: id,
      name: name,
      mobile: mobile,
      frontImagePath: front,
      backImagePath: back,
      createdAt: t,
      updatedAt: updated ?? t,
    );
  }

  Directory dir(String name) => Directory('${tmp.path}/$name');

  test('sao lưu → đọc lại: đủ thẻ, đủ ảnh, ảnh thiếu thì bỏ qua', () async {
    final front = await image('1_front.jpg', 'FRONT');
    final cards = [
      card('1', name: '山田 太郎', front: front.path, back: '${tmp.path}/src/missing.jpg'),
      card('2', name: '佐藤 健'),
    ];

    final zip = await CardBackupService.createBackup(
      cards: cards,
      outDir: dir('out'),
      appVersion: '1.0.0',
      now: DateTime(2026, 11, 13, 15, 30),
    );
    expect(zip.path, endsWith('meishi_backup_20261113_1530.zip'));

    final contents = await CardBackupService.readBackup(zip.path, workDir: dir('work'));
    expect(contents.manifest.cardCount, 2);
    expect(contents.manifest.appVersion, '1.0.0');
    expect(contents.cards.map((c) => c.name), ['山田 太郎', '佐藤 健']);
    final restored = contents.cards.first;
    expect(await File(restored.frontImagePath!).readAsString(), 'FRONT');
    expect(restored.backImagePath, isNull);

    await contents.dispose();
    expect(await contents.extractDir.exists(), isFalse);
  });

  test('file không phải bản sao lưu → notABackup; phiên bản mới hơn → unsupportedVersion', () async {
    Future<String> zipWith(Map<String, String> files) async {
      final path = '${tmp.path}/${files.hashCode}.zip';
      final archive = Archive();
      files.forEach((name, content) => archive.addFile(ArchiveFile.string(name, content)));
      await File(path).writeAsBytes(ZipEncoder().encode(archive));
      return path;
    }

    Future<BackupError?> errorOf(String path) async {
      try {
        await CardBackupService.readBackup(path, workDir: dir('work'));
        return null;
      } on BackupException catch (e) {
        return e.error;
      }
    }

    expect(await errorOf(await zipWith({'hello.txt': 'x'})), BackupError.notABackup);
    expect(
      await errorOf(await zipWith({
        'manifest.json': jsonEncode({'format': 'meishi-backup', 'version': 99}),
        'cards.json': '[]',
      })),
      BackupError.unsupportedVersion,
    );
    final notZip = File('${tmp.path}/x.zip')..writeAsStringSync('not a zip');
    expect(await errorOf(notZip.path), isNotNull);
    // Thư mục tạm của lần đọc lỗi đã được dọn
    expect(dir('work').listSync(), isEmpty);
  });

  test('chặn zip-slip: mục có ".." / đường dẫn tuyệt đối bị bỏ qua', () {
    expect(CardBackupService.safeEntryName('images/a.jpg'), 'images/a.jpg');
    expect(CardBackupService.safeEntryName('images/../../evil.sh'), isNull);
    expect(CardBackupService.safeEntryName('../cards.json'), isNull);
    expect(CardBackupService.safeEntryName('/etc/passwd'), isNull);
    expect(CardBackupService.safeEntryName('images/sub/a.jpg'), isNull);
    expect(CardBackupService.safeEntryName(r'images\..\x'), isNull);
  });

  group('khôi phục vào repository', () {
    late LocalCardRepository repo;
    late SavedCardsCubit cubit;

    setUp(() async {
      repo = LocalCardRepository(baseDirProvider: () async => dir('app'));
      cubit = SavedCardsCubit(repository: repo);
    });
    tearDown(() => cubit.close());

    Future<List<SavedCard>> backupThenRead(List<SavedCard> cards) async {
      final zip = await CardBackupService.createBackup(cards: cards, outDir: dir('out'));
      return (await CardBackupService.readBackup(zip.path, workDir: dir('work'))).cards;
    }

    test('Thay thế toàn bộ: dữ liệu cũ và ảnh cũ bị xoá, ảnh mới được copy vào app', () async {
      // Máy đang có 1 thẻ kèm ảnh
      final oldImg = await image('old.jpg', 'OLD');
      await repo.upsertAll([card('old', name: 'Cũ', front: oldImg.path)]);
      await cubit.load();
      final oldStored = cubit.state.cards.single.frontImagePath!;
      expect(File(oldStored).existsSync(), isTrue);

      final newImg = await image('new.jpg', 'NEW');
      final incoming = await backupThenRead([card('new', name: 'Mới', front: newImg.path)]);
      final summary = await cubit.restore(incoming, RestoreMode.replaceAll);

      expect(summary.added, 1);
      expect(cubit.state.cards.map((c) => c.id), ['new']);
      expect(File(oldStored).existsSync(), isFalse);
      final stored = cubit.state.cards.single.frontImagePath!;
      expect(stored, contains('/app/cards/images/'));
      expect(await File(stored).readAsString(), 'NEW');

      // Ghi xuống đĩa: mở lại repository vẫn thấy
      final reopened = await LocalCardRepository(baseDirProvider: () async => dir('app')).getAll();
      expect(reopened.map((c) => c.id), ['new']);
    });

    test('Gộp: cập nhật / thêm / bỏ qua / gắn cờ đúng, ảnh sống sót sau khi xoá thư mục tạm', () async {
      await repo.upsertAll([
        card('1', name: 'Một', updated: DateTime(2026, 1, 1)),
        card('2', name: '山田 太郎', mobile: '090-1111-2222'),
      ]);
      await cubit.load();

      final img = await image('9.jpg', 'IMG9');
      final zip = await CardBackupService.createBackup(cards: [
        card('1', name: 'Một (mới)', updated: DateTime(2026, 6, 1)), // cập nhật
        card('3', name: '山田太郎', mobile: '09011112222'), // giống hệt thẻ 2 → bỏ qua
        card('9', name: 'Yamada', mobile: '090-1111-2222', front: img.path), // trùng di động → gắn cờ
        card('5', name: 'Mới tinh'), // thêm
      ], outDir: dir('out'));
      final contents = await CardBackupService.readBackup(zip.path, workDir: dir('work'));
      final summary = await cubit.restore(contents.cards, RestoreMode.merge);
      await contents.dispose();

      expect(summary.updated, 1);
      expect(summary.skippedIdentical, 1);
      expect(summary.added, 2);
      expect(summary.flagged, 1);
      expect(cubit.state.findById('1')!.name, 'Một (mới)');
      expect(cubit.state.findById('3'), isNull);
      expect(cubit.state.findById('9')!.duplicateOf, '2');
      expect(await File(cubit.state.findById('9')!.frontImagePath!).readAsString(), 'IMG9');
      expect(cubit.state.duplicatePairs.map((p) => (p.$1.id, p.$2.id)), [('9', '2')]);
    });

    test('Gộp 2 thẻ: ảnh lấy từ thẻ bị xoá vẫn còn; giữ cả hai thì bỏ cờ', () async {
      final a = await image('a.jpg', 'A');
      final b = await image('b.jpg', 'B');
      await repo.upsertAll([
        card('keep', name: 'Giữ', front: a.path),
        card('dup', name: 'Trùng', front: b.path),
      ]);
      await cubit.load();
      final keep = cubit.state.findById('keep')!;
      final dup = cubit.state.findById('dup')!;
      final keptImageOfA = keep.frontImagePath!;

      // Chọn ảnh mặt trước của thẻ bị xoá
      final ok = await cubit.mergeCards(
        merged: keep.copyWith(name: 'Trùng', frontImagePath: dup.frontImagePath),
        removeId: 'dup',
      );
      expect(ok, isTrue);
      final merged = cubit.state.cards.single;
      expect(merged.id, 'keep');
      expect(merged.name, 'Trùng');
      expect(await File(merged.frontImagePath!).readAsString(), 'B');
      // Ảnh của thẻ bị xoá đang được thẻ gộp dùng → KHÔNG bị xoá;
      // ảnh cũ của thẻ giữ lại không còn ai dùng → được dọn.
      expect(File(dup.frontImagePath!).existsSync(), isTrue);
      expect(File(keptImageOfA).existsSync(), isFalse);

      // Giữ cả hai
      await repo.upsertAll([card('x', name: 'X'), card('y', name: 'Y').copyWith(duplicateOf: 'x')]);
      await cubit.load();
      expect(cubit.state.duplicatePairs, hasLength(1));
      await cubit.keepBoth('y');
      expect(cubit.state.duplicatePairs, isEmpty);
    });
  });
}
