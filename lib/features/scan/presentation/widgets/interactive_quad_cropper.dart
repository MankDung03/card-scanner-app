import 'dart:io';
import 'package:flutter/material.dart';

class InteractiveQuadCropper extends StatelessWidget {
  final String imagePath;
  final int rotationAngle;
  final List<Offset> corners; // 4 normalized points: TL (0), TR (1), BR (2), BL (3)
  final Function(int index, Offset newNormalizedOffset) onCornerChanged;
  final double? aspectRatio;

  const InteractiveQuadCropper({
    super.key,
    required this.imagePath,
    required this.rotationAngle,
    required this.corners,
    required this.onCornerChanged,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxW = constraints.maxWidth;
        final double maxH = constraints.maxHeight;

        // Tỷ lệ thực tế của ảnh (đã tính xoay), mặc định 91/55
        final double targetRatio = (aspectRatio != null && aspectRatio! > 0)
            ? aspectRatio!
            : (91.0 / 55.0);

        double width = maxW;
        double height = width / targetRatio;

        if (maxH > 0 && height > maxH) {
          height = maxH;
          width = height * targetRatio;
        }

        return Center(
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Ảnh thẻ xoay theo góc, khít 100% với container
                  RotatedBox(
                    quarterTurns: (rotationAngle ~/ 90),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.fill,
                      cacheWidth: 1080,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 48),
                      ),
                    ),
                  ),

                  // 2. Lớp phủ vẽ 4 góc tứ giác
                  CustomPaint(
                    size: Size(width, height),
                    painter: _QuadOverlayPainter(corners: corners),
                  ),

                  // 3. 4 điểm tròn xanh dương tương tác kéo thả
                  for (int i = 0; i < corners.length; i++)
                    _buildHandle(
                      index: i,
                      normalizedPos: corners[i],
                      canvasSize: Size(width, height),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle({
    required int index,
    required Offset normalizedPos,
    required Size canvasSize,
  }) {
    const double touchRadius = 26.0;
    const double visualRadius = 12.0;
    final double pixelX = normalizedPos.dx * canvasSize.width;
    final double pixelY = normalizedPos.dy * canvasSize.height;

    return Positioned(
      left: pixelX - touchRadius,
      top: pixelY - touchRadius,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          final double newX = normalizedPos.dx + (details.delta.dx / canvasSize.width);
          final double newY = normalizedPos.dy + (details.delta.dy / canvasSize.height);
          onCornerChanged(index, Offset(newX.clamp(0.0, 1.0), newY.clamp(0.0, 1.0)));
        },
        child: Container(
          width: touchRadius * 2,
          height: touchRadius * 2,
          color: Colors.transparent, // Vùng chạm rộng 52x52px, dễ tương tác trên mobile
          child: Center(
            child: Container(
              width: visualRadius * 2,
              height: visualRadius * 2,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuadOverlayPainter extends CustomPainter {
  final List<Offset> corners;

  _QuadOverlayPainter({required this.corners});

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.length < 4) return;

    final Offset p0 = Offset(corners[0].dx * size.width, corners[0].dy * size.height);
    final Offset p1 = Offset(corners[1].dx * size.width, corners[1].dy * size.height);
    final Offset p2 = Offset(corners[2].dx * size.width, corners[2].dy * size.height);
    final Offset p3 = Offset(corners[3].dx * size.width, corners[3].dy * size.height);

    final Path quadPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    // 1. Phủ tối toàn bộ vùng bên ngoài 4 góc (Dim mask làm nổi bật vùng chọn)
    final Path fullCanvas = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path outsideMask = Path.combine(PathOperation.difference, fullCanvas, quadPath);
    final Paint darkMaskPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawPath(outsideMask, darkMaskPaint);

    // 2. Viền xanh ngọc nổi bật nối 4 góc
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(quadPath, borderPaint);

    // 3. Vùng sáng nhẹ bên trong tứ giác
    final Paint fillPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawPath(quadPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _QuadOverlayPainter oldDelegate) {
    return oldDelegate.corners != corners;
  }
}
