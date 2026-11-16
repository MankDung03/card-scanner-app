import 'package:app_scanner_card/core/cubits/app_locale_cubit.dart';
import 'package:app_scanner_card/core/cubits/app_theme_cubit.dart';
import 'package:app_scanner_card/core/cubits/ocr_language_cubit.dart';
import 'package:app_scanner_card/core/routes/app_router.dart';
import 'package:app_scanner_card/core/routes/app_routes.dart';
import 'package:app_scanner_card/core/widgets/capture_fab/capture_fab_cubit.dart';
import 'package:app_scanner_card/features/cards/presentation/cubit/backup_cubit.dart';
import 'package:app_scanner_card/features/cards/presentation/cubit/card_sort_cubit.dart';
import 'package:app_scanner_card/features/cards/presentation/cubit/saved_cards_cubit.dart';
import 'package:app_scanner_card/features/scan/domain/entities/business_card_info.dart';
import 'package:app_scanner_card/features/scan/domain/entities/card_ocr_result.dart';
import 'package:app_scanner_card/features/scan/domain/entities/custom_field.dart';
import 'package:app_scanner_card/features/scan/domain/entities/ocr_model.dart';
import 'package:app_scanner_card/features/scan/presentation/cubit/scan_cubit.dart';
import 'package:app_scanner_card/features/scan/presentation/cubit/scan_state.dart';
import 'package:app_scanner_card/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../helpers/memory_card_repository.dart';

OcrLine _line(String id, String text, double top) =>
    OcrLine(id: id, text: text, normalizedText: text, boundingBox: Rect.fromLTWH(10, top, 300, 24));

/// Luồng: Lưu khi còn dòng chưa gán → hỏi gọn → Quay lại gán (dòng tick sẵn) → Tạo trường mới → Lưu.
void main() {
  setUp(() => PackageInfo.setMockInitialValues(
        appName: 'app',
        packageName: 'app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      ));

  Future<(ScanCubit, SavedCardsCubit)> pumpApp(WidgetTester tester, BusinessCardInfo info) async {
    final repo = MemoryCardRepository([]);
    final saved = SavedCardsCubit(repository: repo);
    final scan = ScanCubit();
    // ignore: invalid_use_of_protected_member
    scan.emit(ScanState(
      currentCardInfo: info,
      frontOcrResult: const CardOcrResult(fullText: 'Taro\n一級建築士\n宅地建物取引士\n・', imageWidth: 400, imageHeight: 240, blocks: []),
    ));
    addTearDown(saved.close);
    addTearDown(scan.close);

    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider.value(value: saved),
        BlocProvider.value(value: scan),
        BlocProvider(create: (_) => AppThemeCubit()),
        BlocProvider(create: (_) => AppLocaleCubit()),
        BlocProvider(create: (_) => OcrLanguageCubit()),
        BlocProvider(create: (_) => CaptureFabCubit()),
        BlocProvider(create: (_) => CardSortCubit()),
        BlocProvider(create: (_) => BackupCubit()),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.create(initialLocation: AppRoutes.ocrReview),
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    return (scan, saved);
  }

  Future<void> pumpFor(WidgetTester tester, [int ms = 600]) async {
    for (var i = 0; i < ms ~/ 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('dòng rác không hỏi; còn dòng thật → hỏi → Quay lại gán → trường mới → lưu', (tester) async {
    final (scan, saved) = await pumpApp(
      tester,
      BusinessCardInfo(name: 'Taro', unmappedLines: [
        _line('f_2', '宅地建物取引士', 60),
        _line('f_1', '一級建築士', 20),
        _line('f_3', '・', 100), // rác: không hỏi
      ]),
    );

    // 1. Bấm Lưu → hộp hỏi chỉ liệt kê 2 dòng thật, theo thứ tự đọc, tick sẵn
    await tester.tap(find.text('Lưu danh thiếp'));
    await pumpFor(tester);
    expect(find.text('Còn 2 dòng chưa gán'), findsOneWidget);
    expect(find.byKey(const ValueKey('unassigned-f_3')), findsNothing);
    final tiles = tester.widgetList<CheckboxListTile>(find.byType(CheckboxListTile)).toList();
    expect(tiles.map((t) => (t.title as Text).data), ['一級建築士', '宅地建物取引士']);
    expect(tiles.every((t) => t.value == true), isTrue);

    // 2. Quay lại gán → mở luôn sheet gán với 2 dòng đã tick
    await tester.tap(find.text('Quay lại gán'));
    await pumpFor(tester);
    expect(find.text('Gán văn bản vào mục:'), findsOneWidget);

    // Tạo trường mới → nội dung nối xuống dòng, chọn chip 資格
    await tester.tap(find.widgetWithText(RadioListTile<String>, 'Tạo trường mới'));
    await pumpFor(tester, 300);
    final text = tester.widget<TextField>(find.byKey(const ValueKey('assign-text'))).controller!.text;
    expect(text, '一級建築士\n宅地建物取引士');
    await tester.tap(find.widgetWithText(ChoiceChip, '資格'));
    await pumpFor(tester, 300);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Gán'));
    await pumpFor(tester);

    final info = scan.state.currentCardInfo!;
    expect(info.customFields, [const CustomField(label: '資格', value: '一級建築士\n宅地建物取引士')]);
    expect(info.unmappedLines.map((l) => l.id), ['f_3']);
    expect(saved.state.cards, isEmpty, reason: 'chưa lưu cho tới khi bấm Lưu lại');

    // 3. Lưu lại: chỉ còn dòng rác → lưu luôn, không hỏi
    await tester.tap(find.text('Lưu danh thiếp'));
    await pumpFor(tester);
    expect(find.textContaining('dòng chưa gán'), findsNothing);
    expect(saved.state.cards, hasLength(1));
    final card = saved.state.cards.single;
    expect(card.customFields.single.label, '資格');
    expect(card.ocrTextFront, contains('宅地建物取引士'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bỏ qua → lưu ngay, dòng không gán vào đâu nhưng còn trong chữ OCR', (tester) async {
    final (_, saved) = await pumpApp(
      tester,
      BusinessCardInfo(name: 'Taro', note: 'memo', unmappedLines: [_line('f_1', '一級建築士', 20)]),
    );

    await tester.tap(find.text('Lưu danh thiếp'));
    await pumpFor(tester);
    expect(find.text('Còn 1 dòng chưa gán'), findsOneWidget);
    await tester.tap(find.text('Bỏ qua'));
    await pumpFor(tester);

    final card = saved.state.cards.single;
    expect(card.customFields, isEmpty);
    expect(card.note, 'memo', reason: 'Bỏ qua không tự thêm dòng vào ghi chú');
    expect(card.ocrTextFront, contains('一級建築士'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('đóng hộp hỏi (bấm ra ngoài) → không lưu', (tester) async {
    final (_, saved) = await pumpApp(
      tester,
      BusinessCardInfo(name: 'Taro', unmappedLines: [_line('f_1', '一級建築士', 20)]),
    );
    await tester.tap(find.text('Lưu danh thiếp'));
    await pumpFor(tester);
    await tester.tapAt(const Offset(5, 5));
    await pumpFor(tester);
    expect(find.text('Còn 1 dòng chưa gán'), findsNothing);
    expect(saved.state.cards, isEmpty);
  });
}
