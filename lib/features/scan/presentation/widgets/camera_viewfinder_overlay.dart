import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CameraViewfinderOverlay extends StatelessWidget {
  /// Dòng hướng dẫn ngắn bên dưới khung ngắm.
  final String hint;
  final Function(Rect cardRect)? onRectCalculated;

  const CameraViewfinderOverlay({
    super.key,
    required this.hint,
    this.onRectCalculated,
  });

  /// Lưu ý: ScanCubit.captureAndCrop dùng đúng rect này để cắt ảnh,
  /// đổi công thức ở đây sẽ đổi vùng được cắt.
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
            // 1. Phủ tối vùng ngoài khung + 4 góc khung ngắm
            CustomPaint(
              size: size,
              painter: _ViewfinderPainter(cardRect: cardRect),
            ),

            // 2. Hướng dẫn bên dưới khung ngắm
            Positioned(
              top: cardRect.bottom + 24,
              left: 24,
              right: 24,
              child: Text(
                hint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  height: 1.5,
                ),
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
    const double cornerRadius = 8.0;
    const double bracketLength = 28.0;
    const double bracketWidth = 3.0;
    // Góc vẽ lệch ra ngoài thẻ một chút để không che mép danh thiếp
    const double inset = -6.0;

    final RRect cardRRect = RRect.fromRectAndRadius(cardRect, const Radius.circular(4));

    // 1. Phủ tối vùng ngoài khung
    final Path overlayPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRRect(cardRRect),
    );
    canvas.drawPath(overlayPath, Paint()..color = AppColors.scanChrome.withValues(alpha: 0.72));

    // 2. 4 góc màu nhấn
    final Paint cornerPaint = Paint()
      ..color = AppColors.scanAccent
      ..strokeWidth = bracketWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Rect r = cardRect.inflate(-inset);
    const radius = Radius.circular(cornerRadius);

    // Top-Left
    canvas.drawPath(
      Path()
        ..moveTo(r.left, r.top + bracketLength)
        ..lineTo(r.left, r.top + cornerRadius)
        ..arcToPoint(Offset(r.left + cornerRadius, r.top), radius: radius)
        ..lineTo(r.left + bracketLength, r.top),
      cornerPaint,
    );
    // Top-Right
    canvas.drawPath(
      Path()
        ..moveTo(r.right - bracketLength, r.top)
        ..lineTo(r.right - cornerRadius, r.top)
        ..arcToPoint(Offset(r.right, r.top + cornerRadius), radius: radius)
        ..lineTo(r.right, r.top + bracketLength),
      cornerPaint,
    );
    // Bottom-Right
    canvas.drawPath(
      Path()
        ..moveTo(r.right, r.bottom - bracketLength)
        ..lineTo(r.right, r.bottom - cornerRadius)
        ..arcToPoint(Offset(r.right - cornerRadius, r.bottom), radius: radius)
        ..lineTo(r.right - bracketLength, r.bottom),
      cornerPaint,
    );
    // Bottom-Left
    canvas.drawPath(
      Path()
        ..moveTo(r.left + bracketLength, r.bottom)
        ..lineTo(r.left + cornerRadius, r.bottom)
        ..arcToPoint(Offset(r.left, r.bottom - cornerRadius), radius: radius)
        ..lineTo(r.left, r.bottom - bracketLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter oldDelegate) => oldDelegate.cardRect != cardRect;
}
