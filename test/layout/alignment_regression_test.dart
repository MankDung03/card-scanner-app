import 'package:app_scanner_card/features/home/presentation/widgets/recent_cards_panel.dart';
import 'package:app_scanner_card/features/scan/presentation/cubit/scan_state.dart';
import 'package:app_scanner_card/features/scan/presentation/widgets/side_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lỗi bố cục đã gặp (không phải tràn) — giữ để không tái diễn.
void main() {
  Widget app(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('thanh Mặt trước / Mặt sau chỉ rộng vừa chữ, không chiếm hết chiều ngang', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app(SideSegmentedControl(
      currentSide: CardSide.front,
      // Nhãn ngắn: font giả trong test rộng bằng cỡ chữ mỗi ký tự, nhãn dài sẽ che mất khác biệt
      frontLabel: 'Trước',
      backLabel: 'Sau',
      onSideChanged: (_) {},
    )));

    final width = tester.getSize(find.byType(SideSegmentedControl)).width;
    expect(width, lessThan(412 / 2), reason: 'trước đây mỗi ô giãn hết phần Flexible → cả thanh = bề ngang màn');

    // 2 ô rộng bằng nhau dù nhãn dài ngắn khác nhau
    final front = tester.getSize(find.ancestor(of: find.text('Trước'), matching: find.byType(AnimatedContainer)));
    final back = tester.getSize(find.ancestor(of: find.text('Sau'), matching: find.byType(AnimatedContainer)));
    expect(front.width, back.width, reason: 'ô Mặt trước / Mặt sau phải đồng nhất kích thước');
  });

  testWidgets('"Xem tất cả" nằm sát mép phải panel "Đã lưu gần đây"', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app(Padding(
      padding: const EdgeInsets.all(16),
      child: RecentCardsPanel(
        title: 'Đã lưu gần đây',
        viewAllLabel: 'Xem tất cả (1)',
        onViewAll: () {},
        cards: const [],
        onCardTap: (_) {},
      ),
    )));

    final panel = tester.getRect(find.byType(RecentCardsPanel));
    final button = tester.getRect(find.byType(TextButton));
    expect(panel.right - button.right, lessThan(20), reason: 'trước đây nút nằm giữa phần được chia');
  });
}
