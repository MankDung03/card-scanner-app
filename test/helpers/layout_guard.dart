import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cỡ chữ hệ thống cần chịu được: bình thường, "lớn" (rất nhiều người dùng Nhật để mức này),
/// và cực đại trên Android.
const kGuardTextScales = [1.0, 1.3, 2.0];

/// Ngôn ngữ của app: tiếng Việt thường dài nhất, tiếng Nhật cao dòng nhất.
const kGuardLocales = [Locale('ja'), Locale('vi'), Locale('en')];

/// Màn nhỏ (iPhone SE / Android 5") và màn lớn phổ biến.
const kGuardScreenSizes = [Size(320, 568), Size(412, 915)];

/// Một tổ hợp cấu hình hiển thị.
class LayoutCase {
  final Locale locale;
  final double textScale;
  final Size size;

  const LayoutCase(this.locale, this.textScale, this.size);

  @override
  String toString() => '${locale.languageCode} x$textScale ${size.width.toInt()}x${size.height.toInt()}';
}

List<LayoutCase> allLayoutCases({
  List<Locale> locales = kGuardLocales,
  List<double> textScales = kGuardTextScales,
  List<Size> sizes = kGuardScreenSizes,
}) =>
    [
      for (final l in locales)
        for (final s in textScales)
          for (final z in sizes) LayoutCase(l, s, z),
    ];

/// Dựng [build] ở mọi tổ hợp [cases] và fail nếu có bất kỳ lỗi layout nào
/// ("A RenderFlex overflowed…", text tràn khung…). Báo đủ mọi tổ hợp lỗi một lần,
/// kèm `lib/…dart:dòng` của widget gây lỗi để sửa thẳng.
///
/// [build] nhận tổ hợp hiện tại và trả về widget gốc (thường là MaterialApp đã đặt
/// locale + textScaler theo tổ hợp). [settle] chạy sau khi pump (vd. mở bottom sheet).
Future<void> expectNoLayoutOverflow(
  WidgetTester tester, {
  required Widget Function(LayoutCase c) build,
  List<LayoutCase>? cases,
  Future<void> Function(WidgetTester tester)? settle,
}) async {
  final failures = <String>{};
  final original = FlutterError.onError;

  for (final c in cases ?? allLayoutCases()) {
    await tester.binding.setSurfaceSize(c.size);
    tester.view.physicalSize = c.size;
    tester.view.devicePixelRatio = 1;

    final errors = <String>[];
    FlutterError.onError = (details) {
      final text = details.toString(minLevel: DiagnosticLevel.debug);
      // Vị trí trong code (khi có --track-widget-creation), nếu không thì chuỗi widget cha
      // của widget bị tràn ("creator: Row ← Padding ← NavyHeaderBar ← …")
      final where = RegExp(r'lib/[^\s:]+\.dart:\d+').firstMatch(text)?.group(0) ??
          RegExp(r'creator: ([^\n]+)').firstMatch(text)?.group(1)?.split(' ← ').take(7).join(' ← ') ??
          '(không rõ vị trí)';
      errors.add('${details.exceptionAsString().split('\n').first} @ $where');
    };
    try {
      // Dựng lại từ đầu cho mỗi tổ hợp
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(build(c));
      // Không dùng pumpAndSettle: spinner / animation lặp vô hạn sẽ làm test treo
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      if (settle != null) await settle(tester);
    } catch (e) {
      errors.add('Exception: $e');
    } finally {
      FlutterError.onError = original;
    }
    for (final e in errors) {
      failures.add('[$c] $e');
    }
  }

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.binding.setSurfaceSize(null);
  tester.view.reset();

  if (failures.isNotEmpty) {
    fail('Lỗi layout (${failures.length}):\n${failures.join('\n')}');
  }
}

/// Bọc [child] với cỡ chữ của tổ hợp (dùng trong `MaterialApp.builder`).
Widget withTextScale(BuildContext context, Widget? child, double scale) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    );
