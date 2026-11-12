import 'dart:io';

import 'package:app_scanner_card/features/cards/data/repositories/local_card_repository.dart';
import 'package:app_scanner_card/features/cards/presentation/cubit/saved_cards_cubit.dart';
import 'package:app_scanner_card/features/scan/domain/entities/business_card_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cards_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  LocalCardRepository newRepo() => LocalCardRepository(baseDirProvider: () async => tempDir);

  const info = BusinessCardInfo(
    name: '山田 太郎',
    jobTitle: '部長',
    department: '営業部',
    company: '株式会社サンプル商事',
    email: '  ',
    phone: '03-1234-5678',
  );

  test('saves card with copied image and persists across instances', () async {
    final image = File('${tempDir.path}/scan.jpg')..writeAsBytesSync([1, 2, 3]);

    final saved = await newRepo().saveFromScan(info, frontImagePath: image.path);

    expect(saved.name, '山田 太郎');
    expect(saved.email, isNull, reason: 'blank values are dropped');
    expect(saved.subtitle, '営業部 部長 · 株式会社サンプル商事');
    expect(saved.avatarChar, '山');
    expect(saved.frontImagePath, isNot(image.path));
    expect(File(saved.frontImagePath!).readAsBytesSync(), [1, 2, 3]);

    final reloaded = await newRepo().getAll();
    expect(reloaded, hasLength(1));
    expect(reloaded.single.id, saved.id);
    expect(reloaded.single.phone, '03-1234-5678');
  });

  test('getAll returns newest first; note update and delete persist', () async {
    final repo = newRepo();
    final first = await repo.saveFromScan(info);
    final second = await repo.saveFromScan(info.copyWith(name: 'Nguyễn Minh Anh'));

    expect((await repo.getAll()).map((c) => c.id), [second.id, first.id]);

    await repo.update(first.copyWith(note: 'Gặp ở Tokyo'));
    await repo.delete(second.id);

    final reloaded = await newRepo().getAll();
    expect(reloaded, hasLength(1));
    expect(reloaded.single.note, 'Gặp ở Tokyo');
  });

  test('SavedCardsCubit loads, saves and updates note', () async {
    final cubit = SavedCardsCubit(repository: newRepo());
    await cubit.load();
    expect(cubit.state.cards, isEmpty);

    final saved = await cubit.saveFromScan(info);
    expect(saved, isNotNull);
    expect(cubit.state.cards.first.id, saved!.id);

    expect(await cubit.updateNote(saved.id, '  Hội thảo AI  '), isTrue);
    expect(cubit.state.findById(saved.id)!.note, 'Hội thảo AI');

    await cubit.close();
  });
}
