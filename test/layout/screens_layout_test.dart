import 'package:app_scanner_card/core/cubits/app_locale_cubit.dart';
import 'package:app_scanner_card/core/cubits/app_theme_cubit.dart';
import 'package:app_scanner_card/core/cubits/ocr_language_cubit.dart';
import 'package:app_scanner_card/core/routes/app_router.dart';
import 'package:app_scanner_card/core/routes/app_routes.dart';
import 'package:app_scanner_card/core/theme/app_theme.dart';
import 'package:app_scanner_card/core/widgets/capture_fab/capture_fab_cubit.dart';
import 'package:app_scanner_card/features/cards/domain/entities/saved_card.dart';
import 'package:app_scanner_card/features/cards/presentation/cubit/backup_cubit.dart';
import 'package:app_scanner_card/features/cards/presentation/cubit/card_sort_cubit.dart';
import 'package:app_scanner_card/features/cards/presentation/cubit/saved_cards_cubit.dart';
import 'package:app_scanner_card/features/cards/presentation/widgets/card_share_sheet.dart';
import 'package:app_scanner_card/features/cards/presentation/widgets/csv_export_dialog.dart';
import 'package:app_scanner_card/features/scan/domain/entities/business_card_info.dart';
import 'package:app_scanner_card/features/scan/domain/entities/custom_field.dart';
import 'package:app_scanner_card/features/scan/domain/entities/ocr_model.dart';
import 'package:app_scanner_card/features/scan/presentation/widgets/assign_lines_bottom_sheet.dart';
import 'package:app_scanner_card/features/scan/presentation/widgets/camera_problem_panel.dart';
import 'package:app_scanner_card/features/scan/presentation/widgets/custom_field_editor_sheet.dart';
import 'package:app_scanner_card/features/scan/presentation/widgets/unassigned_lines_dialog.dart';
import 'package:app_scanner_card/features/scan/presentation/cubit/scan_cubit.dart';
import 'package:app_scanner_card/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/layout_guard.dart';
import '../helpers/memory_card_repository.dart';

/// Mọi màn chính không được tràn layout ở bất kỳ tổ hợp cỡ chữ hệ thống × ngôn ngữ × kích thước màn
/// nào (xem kGuard* trong layout_guard.dart). Màn được dựng qua router thật nên có đủ
/// header, menu dưới và nút chụp nổi như khi chạy app.
///
/// Fail → thông báo liệt kê từng tổ hợp lỗi kèm `lib/…dart:dòng`. Quy tắc sửa: xem CLAUDE.md
/// mục "Quy tắc layout".
void main() {
  // Dữ liệu "khó": tên / công ty / email dài, có ghi chú, tag, cặp nghi trùng
  final t = DateTime(2026, 11, 1);
  // Dòng OCR chưa gán: dài, nhiều mặt, có cả dòng rác
  OcrLine line(String id, String text, double top) =>
      OcrLine(id: id, text: text, normalizedText: text, boundingBox: Rect.fromLTWH(10, top, 300, 24));
  final unmapped = [
    line('f_1', 'Innovation for a connected world — trusted partner since 1987', 10),
    line('f_2', '一級建築士', 40),
    line('f_3', '宅地建物取引士 第123456号 東京都知事登録', 70),
    line('f_4', '・', 100),
    line('b_1', 'LINE ID: kentaro.hasegawa.global-technology-solutions', 10),
  ];

  final cards = [
    SavedCard(
      id: 'long',
      name: '長谷川 健太郎',
      furigana: 'はせがわ けんたろう',
      company: '株式会社グローバル・テクノロジー・ソリューションズ・ジャパン',
      department: '第一営業本部 エンタープライズ営業部',
      jobTitle: 'シニアアカウントエグゼクティブ',
      phone: '03-1234-5678',
      mobile: '090-1234-5678',
      fax: '03-1234-5679',
      email: 'kentaro.hasegawa.enterprise-sales@global-technology-solutions.example.co.jp',
      website: 'https://www.global-technology-solutions.example.co.jp/ja/enterprise',
      postalCode: '100-0001',
      address: '東京都千代田区千代田1-1-1 グローバルタワー 25階',
      note: 'IT展示会で名刺交換。来月のデモ日程を調整。資料を送付済み。',
      metPlace: 'Japan IT Week 東京ビッグサイト',
      metAt: t,
      tags: ['顧客', '展示会', 'Khách hàng tiềm năng'],
      customFields: const [
        CustomField(label: 'LINE', value: 'kentaro.hasegawa.global-technology-solutions'),
        CustomField(label: '資格', value: '一級建築士\n宅地建物取引士\nプロジェクトマネージャ試験 合格'),
        CustomField(label: 'Mã số thuế doanh nghiệp đăng ký tại Việt Nam', value: '0101234567-001'),
      ],
      ocrTextFront: '長谷川 健太郎\n株式会社グローバル・テクノロジー・ソリューションズ・ジャパン\nInnovation for a connected world',
      ocrTextBack: 'Kentaro Hasegawa\nGlobal Technology Solutions Japan Inc.',
      createdAt: t,
      updatedAt: t,
    ),
    SavedCard(
      id: 'vi',
      name: 'Nguyễn Thị Phương Thảo',
      company: 'Công ty Cổ phần Công nghệ Thông tin và Truyền thông Việt Nam',
      jobTitle: 'Giám đốc Phát triển Kinh doanh Khu vực',
      mobile: '+84 912 345 678',
      email: 'phuongthao.nguyen@congnghe-vietnam.example.vn',
      createdAt: t,
      updatedAt: t,
    ),
    SavedCard(
      id: 'dup',
      name: '長谷川 健太郎',
      mobile: '09012345678',
      duplicateOf: 'long',
      createdAt: t.add(const Duration(days: 1)),
      updatedAt: t.add(const Duration(days: 1)),
    ),
  ];

  setUp(() => PackageInfo.setMockInitialValues(
        appName: 'app',
        packageName: 'app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      ));

  /// App đầy đủ provider + router thật, mở ở [location].
  Future<Widget Function(LayoutCase)> appAt(String location, {Object? extra}) async {
    final saved = SavedCardsCubit(repository: MemoryCardRepository(cards));
    await saved.load();
    final scan = ScanCubit()
      ..updateCardInfo(BusinessCardInfo(
        name: '長谷川 健太郎',
        furigana: 'はせがわ けんたろう',
        company: '株式会社グローバル・テクノロジー・ソリューションズ・ジャパン',
        department: '第一営業本部',
        jobTitle: 'シニアアカウントエグゼクティブ',
        email: 'kentaro.hasegawa.enterprise-sales@global-technology-solutions.example.co.jp',
        address: '東京都千代田区千代田1-1-1 グローバルタワー 25階',
        reviewFlags: const {'furigana': true, 'address': true},
        note: 'IT展示会で名刺交換。来月のデモ日程を調整。資料を送付済み。',
        customFields: const [
          CustomField(label: '資格', value: '一級建築士\n宅地建物取引士'),
          CustomField(label: 'Mã số thuế doanh nghiệp đăng ký tại Việt Nam', value: '0101234567-001'),
        ],
        unmappedLines: unmapped,
      ));
    addTearDown(saved.close);
    addTearDown(scan.close);

    return (c) => MultiBlocProvider(
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
            routerConfig: AppRouter.create(initialLocation: location, initialExtra: extra),
            theme: AppTheme.lightTheme,
            locale: c.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => withTextScale(context, child, c.textScale),
          ),
        );
  }

  final screens = <String, (String, Object?)>{
    'Home': (AppRoutes.home, null),
    'Danh sách danh thiếp': (AppRoutes.savedCards, null),
    'Chi tiết danh thiếp': (AppRoutes.cardDetailPath('long'), null),
    'Chi tiết thẻ nghi trùng': (AppRoutes.cardDetailPath('dup'), null),
    'Sửa danh thiếp': (AppRoutes.cardEditPath('long'), null),
    'Cài đặt': (AppRoutes.settings, null),
    'Camera': (AppRoutes.scanCamera, null),
    'Cắt ảnh': (AppRoutes.scanCrop, null),
    'Xác nhận thông tin': (AppRoutes.ocrReview, null),
    'Lưu thành công': (AppRoutes.cardSaved, 'long'),
    'Danh sách trùng': (AppRoutes.duplicates, null),
    'So sánh và gộp': (AppRoutes.mergePath('dup'), null),
  };

  for (final MapEntry(key: name, value: (location, extra)) in screens.entries) {
    testWidgets('không tràn layout: $name', (tester) async {
      final build = await appAt(location, extra: extra);
      await expectNoLayoutOverflow(tester, build: build);
    });
  }

  // Bảng trượt / hộp thoại: dựng trực tiếp trong một trang trống
  Widget host(LayoutCase c, Widget child) => MaterialApp(
        theme: AppTheme.lightTheme,
        locale: c.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => withTextScale(context, child, c.textScale),
        home: Scaffold(body: Align(alignment: Alignment.bottomCenter, child: child)),
      );

  testWidgets('không tràn layout: bảng Xuất · Chia sẻ', (tester) async {
    await expectNoLayoutOverflow(tester, build: (c) => host(c, CardShareSheet(card: cards.first)));
  });

  testWidgets('không tràn layout: hộp xác nhận xuất CSV', (tester) async {
    await expectNoLayoutOverflow(tester, build: (c) => host(c, Center(child: CsvExportDialog(cards: cards))));
  });

  // ───────── Trường tuỳ chỉnh / dòng chưa gán ─────────
  final labels = ['Mã số thuế doanh nghiệp đăng ký tại Việt Nam', 'LINE', 'X', 'Instagram', 'LinkedIn', '内線', '資格'];
  final info = BusinessCardInfo(
    name: '長谷川 健太郎',
    note: 'IT展示会で名刺交換。来月のデモ日程を調整。',
    customFields: const [CustomField(label: '資格', value: '一級建築士')],
    unmappedLines: unmapped,
  );
  final lineTexts = unmapped.take(3).map((l) => l.text).toList();

  testWidgets('không tràn layout: sheet gán dòng (chưa chọn đích)', (tester) async {
    await expectNoLayoutOverflow(
      tester,
      build: (c) => host(c, AssignLinesBottomSheet(lines: lineTexts, cardInfo: info, labelSuggestions: labels)),
    );
  });

  testWidgets('không tràn layout: sheet gán dòng → Tạo trường mới', (tester) async {
    await expectNoLayoutOverflow(
      tester,
      build: (c) => host(
        c,
        AssignLinesBottomSheet(
          lines: lineTexts,
          cardInfo: info,
          labelSuggestions: labels,
          initialTarget: AssignTarget.custom,
        ),
      ),
    );
  });

  testWidgets('không tràn layout: sheet gán dòng → Ghi chú (đã có giá trị → Thay thế / Nối thêm)', (tester) async {
    await expectNoLayoutOverflow(
      tester,
      build: (c) => host(
        c,
        AssignLinesBottomSheet(lines: lineTexts, cardInfo: info, initialTarget: AssignTarget.note),
      ),
    );
  });

  testWidgets('không tràn layout: sheet sửa trường tuỳ chỉnh', (tester) async {
    await expectNoLayoutOverflow(
      tester,
      build: (c) => host(
        c,
        CustomFieldEditorSheet(
          initial: const CustomField(label: '資格', value: '一級建築士\n宅地建物取引士\nプロジェクトマネージャ試験 合格'),
          suggestions: labels,
        ),
      ),
    );
  });

  testWidgets('không tràn layout: hộp hỏi dòng chưa gán khi lưu', (tester) async {
    await expectNoLayoutOverflow(
      tester,
      build: (c) => host(c, Center(child: UnassignedLinesDialog(lines: unmapped))),
    );
  });

  for (final problem in CameraProblem.values) {
    testWidgets('không tràn layout: thông báo camera (${problem.name})', (tester) async {
      await expectNoLayoutOverflow(
        tester,
        build: (c) => host(
          c,
          // Giống màn camera: nằm giữa header và thanh nút, cuộn được
          Padding(
            padding: const EdgeInsets.only(top: 120, bottom: 150),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CameraProblemPanel(problem: problem, onPrimary: () {}, onGallery: () {}),
              ),
            ),
          ),
        ),
      );
    });
  }
}
