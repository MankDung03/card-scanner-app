import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import 'gallery_grid_cell.dart';

class GalleryActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const GalleryActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkGreenCardBg : AppColors.greenCardBg;
    final titleColor = isDark ? AppColors.darkGreenCardText : AppColors.greenCardText;
    final subtitleColor = isDark ? AppColors.darkGreenCardSubtext : AppColors.greenCardSubtext;
    final gridColor = isDark ? AppColors.darkGreenCardGrid : AppColors.greenCardGrid;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.greenCardGrid.withValues(alpha: 0.4);

    return Semantics(
      button: true,
      label: '$title, $subtitle',
      child: Container(
        height: 105,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.r24,
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.r24,
            splashColor: titleColor.withValues(alpha: 0.12),
            highlightColor: titleColor.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s18),
              child: Row(
                children: [
                  // Left Gallery Icon
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: AppRadius.r16,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: titleColor,
                      size: 24,
                    ),
                  ),
                  AppSpacing.gapW14,

                  // Middle Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right Grid Illustration (2x3 cells)
                  SizedBox(
                    width: 58,
                    height: 40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GalleryGridCell(color: gridColor),
                            GalleryGridCell(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderColor: titleColor,
                            ),
                            GalleryGridCell(color: gridColor),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GalleryGridCell(color: gridColor),
                            GalleryGridCell(color: gridColor),
                            GalleryGridCell(color: gridColor),
                          ],
                        ),
                      ],
                    ),
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
