import 'package:app_scanner_card/features/scan/presentation/widgets/camera_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('thanh điều khiển nằm sát đáy màn hình, không trôi lên giữa', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: CameraBottomBar(
            galleryLabel: 'Thư viện',
            autoCaptureLabel: 'Tự động chụp',
            shutterLabel: 'Chụp',
            onShutter: () {},
            onGallery: () {},
            onAutoCapture: () {},
          ),
        ),
      ),
    ));

    final bar = tester.getRect(find.byType(CameraBottomBar));
    expect(bar.height, lessThan(150));
    expect(bar.bottom, 800);
    for (final label in ['Thư viện', 'Tự động chụp']) {
      expect(tester.getRect(find.text(label)).bottom, greaterThan(700));
    }
  });
}
