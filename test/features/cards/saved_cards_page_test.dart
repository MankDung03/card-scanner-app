import 'dart:io';

import 'package:app_scanner_card/features/cards/data/repositories/local_card_repository.dart';
import 'package:app_scanner_card/features/cards/domain/services/card_list_query.dart';
import 'package:app_scanner_card/features/cards/presentation/cubit/card_sort_cubit.dart';
import 'package:app_scanner_card/features/cards/presentation/cubit/saved_cards_cubit.dart';
import 'package:app_scanner_card/features/cards/presentation/pages/saved_cards_page.dart';
import 'package:app_scanner_card/features/scan/domain/entities/business_card_info.dart';
import 'package:app_scanner_card/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('company grouping, tag filter and sort menu work', (tester) async {
    final dir = Directory.systemTemp.createTempSync('cards_list_');
    addTearDown(() => dir.deleteSync(recursive: true));

    late SavedCardsCubit cards;
    await tester.runAsync(() async {
      cards = SavedCardsCubit(repository: LocalCardRepository(baseDirProvider: () async => dir));
      final a = await cards.saveFromScan(const BusinessCardInfo(name: '山田 太郎', company: '株式会社サンプル商事'));
      final b = await cards.saveFromScan(const BusinessCardInfo(name: 'Đặng An', company: 'Công ty TNHH Alpha'));
      await cards.saveFromScan(const BusinessCardInfo(name: 'Lone Wolf'));
      await cards.updateCard(a!.copyWith(tags: ['Khách hàng']));
      await cards.updateCard(b!.copyWith(tags: ['Sự kiện']));
    });
    final sort = CardSortCubit();
    addTearDown(sort.close);

    await tester.binding.setSurfaceSize(const Size(400, 900));
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider.value(value: cards),
        BlocProvider.value(value: sort),
      ],
      child: const MaterialApp(
        locale: Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SavedCardsPage(),
      ),
    ));
    await tester.pumpAndSettle();

    // Chip sắp xếp + chip tag
    expect(find.text('Mới nhất'), findsOneWidget);
    expect(find.text('Khách hàng'), findsWidgets);
    expect(find.text('Sự kiện'), findsWidgets);

    // Chọn "Công ty A-Z" từ menu → có tiêu đề nhóm, nhóm "Không có công ty" ở cuối
    await tester.tap(find.text('Mới nhất'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckedPopupMenuItem<CardSortOrder>, 'Công ty A-Z'));
    await tester.pumpAndSettle();
    expect(sort.state, CardSortOrder.companyAZ);
    expect(find.text('Công ty TNHH Alpha'), findsWidgets);
    expect(find.text('Không có công ty'), findsOneWidget);

    // Lọc theo tag "Sự kiện" → chỉ còn Đặng An
    // Hàng chip cuộn ngang → cuộn tới chip trước khi chạm
    await tester.ensureVisible(find.text('Sự kiện').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sự kiện').first);
    await tester.pumpAndSettle();
    expect(find.text('Đặng An'), findsOneWidget);
    expect(find.text('山田 太郎'), findsNothing);
    expect(find.text('Xoá bộ lọc'), findsOneWidget);

    // Xoá bộ lọc → hiện lại đủ
    await tester.tap(find.text('Xoá bộ lọc'));
    await tester.pumpAndSettle();
    expect(find.text('山田 太郎'), findsOneWidget);
    expect(find.text('Lone Wolf'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
