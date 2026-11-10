import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';

class GalleryGridCell extends StatelessWidget {
  final Color color;
  final Color? borderColor;

  const GalleryGridCell({
    super.key,
    required this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.r4,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
      ),
    );
  }
}
