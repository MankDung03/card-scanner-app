import 'package:flutter/material.dart';

class CameraViewfinderOverlay extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function(Rect cardRect)? onRectCalculated;

  const CameraViewfinderOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    this.onRectCalculated,
  });

  static Rect calculateCardRect(Size size) {
    const double marginHorizontal = 24.0;
    final double cardWidth = size.width - (marginHorizontal * 2);
    // Tỉ lệ chuẩn danh thiếp Quốc tế / Nhật Bản 91x55mm
    const double cardRatio = 91.0 / 55.0;
    final double cardHeight = cardWidth / cardRatio;
    const double cardLeft = marginHorizontal;
    // Căn giữa, hơi dịch lên trên để cân đối với Bottom Bar
    final double cardTop = (size.height - cardHeight) / 2.0 - 45.0;

    return Rect.fromLTWH(cardLeft, cardTop, cardWidth, cardHeight);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final cardRect = calculateCardRect(size);

        if (onRectCalculated != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onRectCalculated!(cardRect);
          });
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Lớp phủ làm mờ viền ngoài khung ngắm
            CustomPaint(
              size: size,
              painter: _ViewfinderPainter(cardRect: cardRect),
            ),

            // 2. Text hướng dẫn bên dưới khung ngắm
            Positioned(
              top: cardRect.bottom + 22,
              left: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      shadows: [
                        Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      shadows: const [
                        Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  final Rect cardRect;

  _ViewfinderPainter({required this.cardRect});

  @override
  void paint(Canvas canvas, Size size) {
    const double cornerRadius = 12.0;
    const double bracketLength = 26.0;
    const double bracketWidth = 3.5;

    final RRect cardRRect = RRect.fromRectAndRadius(
      cardRect,
      const Radius.circular(cornerRadius),
    );

    // 1. Phủ mờ vùng ngoài khung
    final Path backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path cardPath = Path()..addRRect(cardRRect);
    final Path overlayPath = Path.combine(PathOperation.difference, backgroundPath, cardPath);

    final Paint dimPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.58)
      ..style = PaintingStyle.fill;
    canvas.drawPath(overlayPath, dimPaint);

    // 2. Viền mờ bao quanh khung thẻ
    final Paint borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(cardRRect, borderPaint);

    // 3. 4 góc viền trắng nổi bật (Corner brackets)
    final Paint cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = bracketWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double l = cardRect.left;
    final double t = cardRect.top;
    final double r = cardRect.right;
    final double b = cardRect.bottom;

    // Top-Left corner
    final Path tlPath = Path()
      ..moveTo(l, t + bracketLength)
      ..lineTo(l, t + cornerRadius)
      ..arcToPoint(Offset(l + cornerRadius, t), radius: const Radius.circular(cornerRadius))
      ..lineTo(l + bracketLength, t);
    canvas.drawPath(tlPath, cornerPaint);

    // Top-Right corner
    final Path trPath = Path()
      ..moveTo(r - bracketLength, t)
      ..lineTo(r - cornerRadius, t)
      ..arcToPoint(Offset(r, t + cornerRadius), radius: const Radius.circular(cornerRadius))
      ..lineTo(r, t + bracketLength);
    canvas.drawPath(trPath, cornerPaint);

    // Bottom-Right corner
    final Path brPath = Path()
      ..moveTo(r, b - bracketLength)
      ..lineTo(r, b - cornerRadius)
      ..arcToPoint(Offset(r - cornerRadius, b), radius: const Radius.circular(cornerRadius))
      ..lineTo(r - bracketLength, b);
    canvas.drawPath(brPath, cornerPaint);

    // Bottom-Left corner
    final Path blPath = Path()
      ..moveTo(l + bracketLength, b)
      ..lineTo(l + cornerRadius, b)
      ..arcToPoint(Offset(l, b - cornerRadius), radius: const Radius.circular(cornerRadius))
      ..lineTo(l, b - bracketLength);
    canvas.drawPath(blPath, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter oldDelegate) {
    return oldDelegate.cardRect != cardRect;
  }
}
