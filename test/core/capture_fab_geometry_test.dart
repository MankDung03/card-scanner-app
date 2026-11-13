import 'dart:ui';

import 'package:app_scanner_card/core/widgets/capture_fab/capture_fab_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Vùng cho phép 12..348 x 100..600, nút 60x76 → góc trên-trái nằm trong 12..288 x 100..524
  final geo = FabGeometry(bounds: const Rect.fromLTRB(12, 100, 348, 600), size: const Size(60, 76));

  test('vùng góc trên-trái đã trừ kích thước nút', () {
    expect(geo.area, const Rect.fromLTRB(12, 100, 288, 524));
  });

  test('anchor ↔ offset', () {
    expect(geo.offsetOf(FabAnchor.initial), const Offset(288, 524));
    expect(geo.offsetOf(const FabAnchor(onRight: false, y: 0)), const Offset(12, 100));
    expect(geo.offsetOf(const FabAnchor(onRight: true, y: 0.5)), const Offset(288, 312));
  });

  test('kéo ra ngoài bị giữ trong vùng (không đè header / menu dưới)', () {
    expect(geo.clamp(const Offset(-50, 0)), const Offset(12, 100));
    expect(geo.clamp(const Offset(999, 999)), const Offset(288, 524));
  });

  test('thả tay hút về mép gần nhất, giữ vị trí dọc', () {
    expect(geo.snap(const Offset(100, 312)), const FabAnchor(onRight: false, y: 0.5));
    expect(geo.snap(const Offset(200, 100)), const FabAnchor(onRight: true, y: 0));
  });

  test('vuốt nhanh đi theo hướng vuốt', () {
    expect(geo.snap(const Offset(100, 312), velocity: const Offset(1200, 0)).onRight, isTrue);
    expect(geo.snap(const Offset(250, 312), velocity: const Offset(-1200, 0)).onRight, isFalse);
    // Vuốt chậm thì vẫn theo mép gần nhất
    expect(geo.snap(const Offset(250, 312), velocity: const Offset(-300, 0)).onRight, isTrue);
  });

  test('vị trí ngoài vùng khi thả bị kẹp, tỉ lệ y trong 0..1', () {
    final a = geo.snap(const Offset(0, 2000));
    expect(a.y, 1);
    expect(const FabAnchor(onRight: true, y: -3).y, 0);
  });

  test('vùng quá nhỏ không làm toạ độ âm', () {
    final tiny = FabGeometry(bounds: const Rect.fromLTRB(0, 0, 40, 40), size: const Size(60, 76));
    expect(tiny.area, const Rect.fromLTRB(0, 0, 0, 0));
    expect(tiny.snap(const Offset(10, 10)).y, 0);
  });
}
