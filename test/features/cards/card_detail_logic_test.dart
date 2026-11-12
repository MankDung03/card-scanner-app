import 'dart:io';

import 'package:app_scanner_card/features/cards/data/repositories/local_card_repository.dart';
import 'package:app_scanner_card/features/cards/domain/entities/saved_card.dart';
import 'package:app_scanner_card/features/cards/presentation/utils/contact_launcher.dart';
import 'package:app_scanner_card/features/scan/domain/entities/business_card_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SavedCard', () {
    final base = SavedCard(
      id: '1',
      name: '山田 太郎',
      address: '東京都千代田区千代田1-1-1',
      postalCode: '100-0001',
      createdAt: DateTime(2026, 11, 10),
      updatedAt: DateTime(2026, 11, 10),
    );

    test('copyWith keeps omitted fields and clears fields passed as null', () {
      final edited = base.copyWith(name: null, email: 'taro@example.com');
      expect(edited.name, isNull);
      expect(edited.email, 'taro@example.com');
      expect(edited.address, base.address);
    });

    test('meeting info and tags survive json round trip', () {
      final card = base.copyWith(
        metAt: DateTime(2026, 11, 10),
        metPlace: 'Triển lãm IT, Tokyo',
        note: 'Hẹn gửi tài liệu',
        tags: ['Khách hàng', 'Sự kiện'],
      );
      final restored = SavedCard.fromJson(card.toJson());
      expect(restored.metAt, DateTime(2026, 11, 10));
      expect(restored.metPlace, 'Triển lãm IT, Tokyo');
      expect(restored.tags, ['Khách hàng', 'Sự kiện']);
      expect(restored.hasMeetingInfo, isTrue);
    });

    test('old json without new fields still loads', () {
      final restored = SavedCard.fromJson({'id': 'x', 'createdAt': '2026-11-01T00:00:00.000'});
      expect(restored.tags, isEmpty);
      expect(restored.metAt, isNull);
    });

    test('fullAddress prefixes postal code', () {
      expect(base.fullAddress, '〒100-0001 東京都千代田区千代田1-1-1');
    });
  });

  group('ContactLauncher', () {
    test('phone uri strips formatting and extension', () {
      expect(ContactLauncher.phoneUri('03-1234-5678').toString(), 'tel:0312345678');
      expect(ContactLauncher.phoneUri('+84 (28) 3823 1234 Ext. 12').toString(), 'tel:+842838231234');
    });

    test('email, website and map uris', () {
      expect(ContactLauncher.emailUri(' taro@sample.jp ').toString(), 'mailto:taro@sample.jp');
      expect(ContactLauncher.websiteUri('sample.jp').toString(), 'https://sample.jp');
      expect(ContactLauncher.websiteUri('http://a.vn').toString(), 'http://a.vn');
      final android = ContactLauncher.mapUri('東京都千代田区', isIOS: false);
      expect(android.host, 'www.google.com');
      expect(android.queryParameters['query'], '東京都千代田区');
      expect(ContactLauncher.mapUri('Hà Nội', isIOS: true).host, 'maps.apple.com');
    });
  });

  test('LocalCardRepository.setImage replaces image file', () async {
    final dir = await Directory.systemTemp.createTemp('cards_img_');
    addTearDown(() => dir.delete(recursive: true));
    final repo = LocalCardRepository(baseDirProvider: () async => dir);

    final card = await repo.saveFromScan(const BusinessCardInfo(name: 'A'));
    final first = File('${dir.path}/b1.jpg')..writeAsBytesSync([1]);
    final second = File('${dir.path}/b2.jpg')..writeAsBytesSync([2]);

    final withBack = await repo.setImage(card, isFront: false, sourcePath: first.path);
    final oldPath = withBack.backImagePath!;
    final replaced = await repo.setImage(withBack, isFront: false, sourcePath: second.path);

    expect(File(replaced.backImagePath!).readAsBytesSync(), [2]);
    expect(File(oldPath).existsSync(), isFalse);
    expect((await LocalCardRepository(baseDirProvider: () async => dir).getAll()).single.backImagePath,
        replaced.backImagePath);
  });
}
