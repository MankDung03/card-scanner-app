import 'package:app_scanner_card/core/widgets/app_shell/app_shell.dart';
import 'package:app_scanner_card/core/widgets/capture_fab/capture_fab_cubit.dart';
import 'package:app_scanner_card/core/widgets/capture_fab/draggable_capture_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CaptureFabCubit cubit;
  late int taps;

  setUp(() {
    cubit = CaptureFabCubit();
    taps = 0;
  });

  tearDown(() => cubit.close());

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DraggableCaptureFab(topInset: 100, onTap: () => taps++),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Finder fab() => find.byIcon(Icons.photo_camera_outlined);

  testWidgets('bấm nhẹ → mở camera', (tester) async {
    await pump(tester);
    await tester.tap(fab());
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('kéo → không mở camera, thả bên trái thì hút về mép trái', (tester) async {
    await pump(tester);
    final start = tester.getCenter(fab());
    expect(start.dx, greaterThan(200)); // mặc định bám mép phải

    await tester.drag(fab(), const Offset(-300, -200));
    await tester.pumpAndSettle();

    expect(taps, 0);
    expect(cubit.state.anchor.onRight, isFalse);
    // Hút sát mép trái (lề 12 + nửa vùng chạm 64/2)
    expect(tester.getCenter(fab()).dx, closeTo(12 + 32, 1));
  });

  testWidgets('kéo lên quá cao vẫn dừng dưới header', (tester) async {
    await pump(tester);
    await tester.drag(fab(), const Offset(0, -2000));
    await tester.pumpAndSettle();
    final top = tester.getTopLeft(find.byType(DraggableCaptureFab).first);
    expect(cubit.state.anchor.y, 0);
    // Đỉnh vùng chạm = topInset 100 + lề 8
    expect(tester.getRect(find.byIcon(Icons.photo_camera_outlined)).top, greaterThan(top.dy + 100));
  });

  testWidgets('nhấn giữ → "Ẩn nút này" → ẩn', (tester) async {
    await pump(tester);
    await tester.longPress(fab());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ẩn nút này'));
    await tester.pumpAndSettle();
    expect(cubit.state.visible, isFalse);
    expect(taps, 0);
  });

  group('AppShell', () {
    test('tab theo màn hiện tại', () {
      expect(AppShell.tabIndexOf('/'), 0);
      expect(AppShell.tabIndexOf('/cards'), 1);
      expect(AppShell.tabIndexOf('/cards/abc'), 1);
      expect(AppShell.tabIndexOf('/cards/abc/edit'), 1);
      expect(AppShell.tabIndexOf('/settings'), 2);
      expect(AppShell.tabIndexOf('/crop'), -1);
    });

    test('nút chụp chỉ ở Danh sách và Chi tiết', () {
      expect(AppShell.showsCaptureFab('/cards'), isTrue);
      expect(AppShell.showsCaptureFab('/cards/abc'), isTrue);
      expect(AppShell.showsCaptureFab('/cards/abc/edit'), isFalse);
      expect(AppShell.showsCaptureFab('/'), isFalse);
      expect(AppShell.showsCaptureFab('/settings'), isFalse);
    });
  });
}
