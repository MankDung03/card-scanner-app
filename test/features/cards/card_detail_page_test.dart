import 'dart:io';

import 'package:app_scanner_card/features/cards/data/repositories/local_card_repository.dart';
import 'package:app_scanner_card/features/cards/presentation/cubit/saved_cards_cubit.dart';
import 'package:app_scanner_card/features/cards/presentation/pages/card_detail_page.dart';
import 'package:app_scanner_card/features/scan/domain/entities/business_card_info.dart';
import 'package:app_scanner_card/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CardDetailPage renders info, actions and meeting section', (tester) async {
    final dir = Directory.systemTemp.createTempSync('cards_widget_');
    addTearDown(() => dir.deleteSync(recursive: true));

    late SavedCardsCubit cubit;
    late String id;
    await tester.runAsync(() async {
      cubit = SavedCardsCubit(repository: LocalCardRepository(baseDirProvider: () async => dir));
      final saved = await cubit.saveFromScan(const BusinessCardInfo(
        name: '山田 太郎',
        furigana: 'やまだ たろう',
        jobTitle: '部長',
        department: '営業部',
        company: '株式会社サンプル商事',
        phone: '03-1234-5678',
        fax: '03-1234-5679',
        email: 'taro.yamada@sample-shoji.example',
        address: '東京都千代田区千代田1-1-1',
        postalCode: '100-0001',
      ));
      id = saved!.id;
      await cubit.updateCard(saved.copyWith(
        metAt: DateTime(2026, 11, 10),
        metPlace: 'Triển lãm IT, Tokyo',
        note: 'Quan tâm giải pháp OCR',
        tags: ['Khách hàng', 'Sự kiện'],
      ));
    });

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CardDetailPage(cardId: id),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Danh thiếp'), findsOneWidget);
    expect(find.text('Gọi'), findsOneWidget);
    expect(find.text('Bản đồ'), findsOneWidget);
    expect(find.text('03-1234-5678'), findsWidgets);

    await tester.scrollUntilVisible(find.text('Khách hàng'), 200);
    expect(find.text('Triển lãm IT, Tokyo'), findsOneWidget);
    expect(find.text('+ Tag'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, 3000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mặt sau'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có ảnh mặt này'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
