import 'dart:io';

import 'package:app_scanner_card/features/cards/data/repositories/local_card_repository.dart';
import 'package:app_scanner_card/features/cards/presentation/cubit/saved_cards_cubit.dart';
import 'package:app_scanner_card/features/scan/domain/entities/business_card_info.dart';
import 'package:app_scanner_card/features/scan/domain/entities/card_ocr_result.dart';
import 'package:app_scanner_card/features/scan/domain/repositories/ocr_repository.dart';
import 'package:app_scanner_card/features/scan/presentation/cubit/scan_cubit.dart';
import 'package:app_scanner_card/features/scan/presentation/cubit/scan_state.dart';
import 'package:app_scanner_card/features/scan/presentation/pages/card_verification_page.dart';
import 'package:app_scanner_card/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class _NoopOcr implements OcrRepository {
  @override
  Future<CardOcrResult> recognizeText(
    String imagePath, {
    TextRecognitionScript script = TextRecognitionScript.japanese,
    bool useDualScript = true,
    OcrLanguageMode languageMode = OcrLanguageMode.auto,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> dispose() async {}
}

CardTextLine _line(String text, double top) => CardTextLine(
      text: text,
      boundingBox: Rect.fromLTWH(40, top, 400, 40),
    );

void main() {
  testWidgets('select lines on the photo → assign (edit text, append) → undo', (tester) async {
    final dir = Directory.systemTemp.createTempSync('verify_assign_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final imagePath = '${dir.path}/processed.jpg';
    File(imagePath).writeAsBytesSync(img.encodeJpg(img.Image(width: 600, height: 360)));

    final lines = [
      _line('東京都千代田区', 60),
      _line('千代田1-1-1', 120),
      _line('TEL www.sample.co.jp', 220),
    ];
    final ocr = CardOcrResult(
      fullText: lines.map((l) => l.text).join('\n'),
      imageWidth: 600,
      imageHeight: 360,
      blocks: [
        CardTextBlock(text: '', boundingBox: const Rect.fromLTWH(0, 0, 600, 360), lines: lines),
      ],
    );

    final scan = ScanCubit(ocrRepository: _NoopOcr());
    // ignore: invalid_use_of_protected_member
    scan.emit(ScanState(
      frontImagePath: imagePath,
      currentImagePath: imagePath,
      frontProcessedImagePath: imagePath,
      frontOcrResult: ocr,
      currentCardInfo: const BusinessCardInfo(name: 'Taro', address: '東京都千代田区'),
    ));
    final cards = SavedCardsCubit(repository: LocalCardRepository(baseDirProvider: () async => dir));
    addTearDown(scan.close);
    addTearDown(cards.close);

    await tester.binding.setSurfaceSize(const Size(420, 1000));
    await tester.pumpWidget(MultiBlocProvider(
      providers: [BlocProvider.value(value: scan), BlocProvider.value(value: cards)],
      child: const MaterialApp(
        locale: Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CardVerificationPage(),
      ),
    ));
    await tester.pumpAndSettle();

    // Danh sách trường trong sheet chỉ dựng phần đang hiện → cuộn tới trước khi chạm
    Future<void> scrollSheetTo(String label) => tester.scrollUntilVisible(
          find.widgetWithText(RadioListTile<String>, label),
          80,
          scrollable: find.descendant(of: find.byType(BottomSheet), matching: find.byType(Scrollable)).last,
        );

    await tester.tap(find.text('Trên ảnh'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ocr-line-0')), findsOneWidget);

    // 1. Chọn dòng "TEL www.sample.co.jp", sửa text bỏ "TEL", gán vào Website
    await tester.tap(find.byKey(const ValueKey('ocr-line-2')));
    await tester.pumpAndSettle();
    expect(find.text('Đã chọn 1 dòng'), findsOneWidget);

    await tester.tap(find.text('Gán vào...').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('assign-text')), 'www.sample.co.jp');
    await scrollSheetTo('Website');
    await tester.tap(find.widgetWithText(RadioListTile<String>, 'Website'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Gán'));
    await tester.pumpAndSettle();

    expect(scan.state.currentCardInfo!.website, 'www.sample.co.jp');
    expect(find.text('Đã chọn 1 dòng'), findsNothing, reason: 'bỏ chọn sau khi gán');

    // 2. Chọn dòng địa chỉ thứ 2 → Địa chỉ đã có giá trị → mặc định Nối thêm
    await tester.tap(find.byKey(const ValueKey('ocr-line-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gán vào...').last);
    await tester.pumpAndSettle();
    await scrollSheetTo('Địa chỉ');
    await tester.tap(find.widgetWithText(RadioListTile<String>, 'Địa chỉ'));
    await tester.pumpAndSettle();
    expect(find.text('Nối thêm'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Gán'));
    await tester.pumpAndSettle();

    expect(scan.state.currentCardInfo!.address, '東京都千代田区 千代田1-1-1');

    // 3. Hoàn tác → địa chỉ trở lại như trước lần gán vừa rồi
    await tester.tap(find.text('Hoàn tác'));
    await tester.pumpAndSettle();
    expect(scan.state.currentCardInfo!.address, '東京都千代田区');
    expect(scan.state.currentCardInfo!.website, 'www.sample.co.jp', reason: 'chỉ hoàn tác lần gán cuối');

    expect(tester.takeException(), isNull);
  });
}
