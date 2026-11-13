import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'home_action_tile.dart';

/// Hành động chính: nền navy đặc, chữ trắng.
class CameraActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const CameraActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return HomeActionTile(
      icon: Icons.photo_camera_outlined,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      verticalPadding: 26,
      backgroundColor: isDark ? AppColors.darkNavy : AppColors.navy,
      borderColor: isDark ? AppColors.darkBorder : null,
      iconBackground: Colors.white.withValues(alpha: 0.14),
      iconColor: Colors.white,
      titleColor: Colors.white,
      subtitleColor: Colors.white.withValues(alpha: 0.78),
      chevronColor: Colors.white.withValues(alpha: 0.85),
    );
  }
}
