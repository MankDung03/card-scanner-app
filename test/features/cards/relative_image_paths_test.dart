import 'dart:convert';
import 'dart:io';

import 'package:app_scanner_card/features/cards/data/repositories/local_card_repository.dart';
import 'package:app_scanner_card/features/scan/domain/entities/business_card_info.dart';
import 'package:flutter_test/flutter_test.dart';

/// Copy đệ quy một thư mục (mô phỏng iOS chuyển dữ liệu sang container mới sau khi cập nhật app)
void _copyDir(Directory from, Directory to) {
  to.createSync(recursive: true);
  for (final e in from.listSync()) {
    final name = e.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if (e is Directory) {
      _copyDir(e, Directory('${to.path}/$name'));
    } else if (e is File) {
      e.copySync('${to.path}/$name');
    }
  }
}

void main() {
  group('path conversion', () {
    const cardsDir = '/data/user/0/app/files/cards';

    test('path inside cards dir becomes relative and back', () {
      const abs = '$cardsDir/images/1_front.jpg';
      expect(LocalCardRepository.toStoredPath(abs, cardsDir), 'images/1_front.jpg');
      expect(LocalCardRepository.toRuntimePath('images/1_front.jpg', cardsDir), abs);
    });

    test('v1 path from an old iOS container is remapped to the current one', () {
      const old = '/var/mobile/Containers/Data/Application/OLD-UUID/Documents/cards/images/9_back.png';
      expect(LocalCardRepository.toStoredPath(old, cardsDir), 'images/9_back.png');
      expect(LocalCardRepository.toRuntimePath(old, cardsDir), '$cardsDir/images/9_back.png');
    });

    test('image outside app storage keeps its absolute path', () {
      const external = '/storage/emulated/0/DCIM/card.jpg';
      expect(LocalCardRepository.toStoredPath(external, cardsDir), external);
      expect(LocalCardRepository.toRuntimePath(external, cardsDir), external);
    });

    test('windows separators are normalised', () {
      expect(
        LocalCardRepository.toStoredPath(r'C:\Users\a\Documents\cards\images\1_front.jpg', r'C:\Users\a\Documents\cards'),
        'images/1_front.jpg',
      );
      expect(LocalCardRepository.toStoredPath(null, cardsDir), isNull);
    });
  });

  group('LocalCardRepository storage', () {
    late Directory root;

    setUp(() => root = Directory.systemTemp.createTempSync('cards_rel_'));
    tearDown(() {
      if (root.existsSync()) root.deleteSync(recursive: true);
    });

    test('cards.json stores relative paths (v2)', () async {
      final base = Directory('${root.path}/app')..createSync();
      final repo = LocalCardRepository(baseDirProvider: () async => base);
      final src = File('${root.path}/scan.jpg')..writeAsBytesSync([7]);

      final card = await repo.saveFromScan(const BusinessCardInfo(name: 'A'), frontImagePath: src.path);

      final json = jsonDecode(File('${base.path}/cards/cards.json').readAsStringSync()) as Map;
      expect(json['version'], LocalCardRepository.dataVersion);
      final stored = (json['cards'] as List).single as Map;
      expect(stored['frontImagePath'], 'images/${card.id}_front.jpg');
      expect(File(card.frontImagePath!).existsSync(), isTrue, reason: 'runtime path is absolute');
    });

    test('data survives the app directory moving (iOS update / restore on new device)', () async {
      final oldBase = Directory('${root.path}/old-container')..createSync();
      final src = File('${root.path}/scan.jpg')..writeAsBytesSync([1, 2, 3]);
      final saved = await LocalCardRepository(baseDirProvider: () async => oldBase)
          .saveFromScan(const BusinessCardInfo(name: 'A'), frontImagePath: src.path);

      final newBase = Directory('${root.path}/new-container');
      _copyDir(oldBase, newBase);
      oldBase.deleteSync(recursive: true);

      final card = (await LocalCardRepository(baseDirProvider: () async => newBase).getAll()).single;
      expect(card.id, saved.id);
      expect(card.frontImagePath, startsWith(newBase.path.replaceAll('\\', '/')));
      expect(File(card.frontImagePath!).readAsBytesSync(), [1, 2, 3]);
    });

    test('v1 file with absolute paths is migrated once and images still load', () async {
      final base = Directory('${root.path}/app');
      final imagesDir = Directory('${base.path}/cards/images')..createSync(recursive: true);
      File('${imagesDir.path}/42_front.jpg').writeAsBytesSync([9]);

      // Dữ liệu v1: đường dẫn tuyệt đối trỏ vào container cũ
      const oldPath = '/var/mobile/Containers/Data/Application/OLD/Documents/cards/images/42_front.jpg';
      File('${base.path}/cards/cards.json').writeAsStringSync(jsonEncode({
        'version': 1,
        'cards': [
          {
            'id': '42',
            'name': 'Old card',
            'frontImagePath': oldPath,
            'createdAt': '2026-11-01T10:00:00.000',
            'updatedAt': '2026-11-01T10:00:00.000',
          },
        ],
      }));

      final card = (await LocalCardRepository(baseDirProvider: () async => base).getAll()).single;
      expect(File(card.frontImagePath!).readAsBytesSync(), [9]);

      final json = jsonDecode(File('${base.path}/cards/cards.json').readAsStringSync()) as Map;
      expect(json['version'], 2);
      expect(((json['cards'] as List).single as Map)['frontImagePath'], 'images/42_front.jpg');
      expect(((json['cards'] as List).single as Map)['name'], 'Old card');
    });
  });
}
