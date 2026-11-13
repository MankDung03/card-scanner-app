import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Vị trí đã lưu của nút nổi: bám mép trái/phải + vị trí dọc theo tỉ lệ (0 = trên cùng, 1 = dưới cùng
/// của vùng cho phép). Lưu theo tỉ lệ để xoay máy / đổi cỡ màn hình vẫn đúng chỗ.
@immutable
class FabAnchor {
  final bool onRight;
  final double y;

  const FabAnchor({required this.onRight, required double y}) : y = y < 0 ? 0 : (y > 1 ? 1 : y);

  /// Mặc định: góc phải dưới
  static const initial = FabAnchor(onRight: true, y: 1);

  @override
  bool operator ==(Object other) => other is FabAnchor && other.onRight == onRight && other.y == y;

  @override
  int get hashCode => Object.hash(onRight, y);

  @override
  String toString() => 'FabAnchor(${onRight ? 'right' : 'left'}, y: ${y.toStringAsFixed(3)})';
}

/// Tính toán thuần (không phụ thuộc widget) cho nút nổi kéo thả.
///
/// [area] là vùng nút được phép nằm (đã trừ header, menu dưới và lề), tính theo
/// góc trên-trái của nút; [size] là kích thước nút.
class FabGeometry {
  final Rect area;
  final Size size;

  FabGeometry({required Rect bounds, required this.size})
      : area = Rect.fromLTRB(
          bounds.left,
          bounds.top,
          // Vùng quá nhỏ (vd. màn hình ngang rất thấp) → dồn về một điểm, không bị âm
          (bounds.right - size.width).clamp(bounds.left, double.infinity),
          (bounds.bottom - size.height).clamp(bounds.top, double.infinity),
        );

  /// Toạ độ góc trên-trái của nút ứng với [anchor].
  Offset offsetOf(FabAnchor anchor) => Offset(
        anchor.onRight ? area.right : area.left,
        area.top + area.height * anchor.y,
      );

  /// Giữ [offset] trong vùng cho phép (dùng khi đang kéo).
  Offset clamp(Offset offset) => Offset(
        offset.dx.clamp(area.left, area.right),
        offset.dy.clamp(area.top, area.bottom),
      );

  /// Thả tay: hút về mép gần nhất. Vuốt ngang đủ nhanh ([flingThreshold] px/s) thì
  /// đi theo hướng vuốt dù đang ở nửa bên kia.
  FabAnchor snap(Offset offset, {Offset velocity = Offset.zero, double flingThreshold = 800}) {
    final p = clamp(offset);
    final bool onRight;
    if (velocity.dx.abs() >= flingThreshold) {
      onRight = velocity.dx > 0;
    } else {
      // So tâm nút với tâm màn hình (area đã trừ chiều rộng nút nên so góc trái là đủ)
      onRight = p.dx >= area.center.dx;
    }
    final y = area.height <= 0 ? 0.0 : (p.dy - area.top) / area.height;
    return FabAnchor(onRight: onRight, y: y);
  }
}
