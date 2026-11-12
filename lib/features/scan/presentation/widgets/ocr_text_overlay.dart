import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../domain/entities/card_ocr_result.dart';

/// Màu trạng thái của khung dòng chữ
class OcrOverlayColors {
  static const assigned = Color(0xFF16A34A); // đã có trong form
  static const unassigned = Color(0xFFEA580C); // chưa dùng
  static const selected = Color(0xFF2563EB); // đang chọn
}

/// Ảnh thẻ (ảnh đã xử lý dùng cho OCR) + khung từng DÒNG chữ, chạm để chọn / bỏ chọn.
/// Phóng to / kéo được vì chữ trên danh thiếp nhỏ.
///
/// [lines] phải là `ocr.allLines` (cùng thứ tự) — chỉ số dòng dùng làm định danh.
class OcrTextOverlay extends StatelessWidget {
  final String imagePath;
  final CardOcrResult ocr;
  final List<CardTextLine> lines;
  final Set<int> selected;

  /// `true` nếu dòng [index] đã nằm trong một trường của form
  final bool Function(int index) isAssigned;
  final ValueChanged<int> onTapLine;

  const OcrTextOverlay({
    super.key,
    required this.imagePath,
    required this.ocr,
    required this.lines,
    required this.selected,
    required this.isAssigned,
    required this.onTapLine,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
    final hasSize = ocr.imageWidth > 0 && ocr.imageHeight > 0;
    final aspect = hasSize ? ocr.imageWidth / ocr.imageHeight : 91 / 55;
    final imageSize = Size(ocr.imageWidth.toDouble(), ocr.imageHeight.toDouble());

    return ClipRRect(
      borderRadius: AppRadius.r12,
      child: ColoredBox(
        color: Colors.black12,
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: AspectRatio(
            aspectRatio: aspect,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.file(
                        file,
                        fit: BoxFit.fill,
                        cacheWidth: 1400,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    if (hasSize)
                      for (var i = 0; i < lines.length; i++)
                        _buildBox(i, lines[i].normalizedRect(imageSize), w, h),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBox(int index, Rect norm, double w, double h) {
    // Nới vùng chạm ra vài px để dễ bấm trên điện thoại
    const pad = 3.0;
    final isSelected = selected.contains(index);
    final color = isSelected
        ? OcrOverlayColors.selected
        : (isAssigned(index) ? OcrOverlayColors.assigned : OcrOverlayColors.unassigned);

    return Positioned(
      key: ValueKey('ocr-line-$index'),
      left: (norm.left * w - pad).clamp(0.0, w),
      top: (norm.top * h - pad).clamp(0.0, h),
      width: norm.width * w + pad * 2,
      height: norm.height * h + pad * 2,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: lines[index].text,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTapLine(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isSelected ? 0.28 : 0.10),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: color, width: isSelected ? 2 : 1.2),
            ),
          ),
        ),
      ),
    );
  }
}
