import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'home_action_tile.dart';

/// Hành động phụ: nền trắng, viền mảnh.
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
    return HomeActionTile(
      icon: Icons.image_outlined,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      borderColor: isDark ? AppColors.darkBorder : AppColors.divider,
      iconBackground: isDark ? AppColors.darkSurfaceMuted : AppColors.navyTint,
      iconColor: isDark ? AppColors.darkTextSecondary : AppColors.navy,
      titleColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      subtitleColor: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
      chevronColor: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
    );
  }
}
