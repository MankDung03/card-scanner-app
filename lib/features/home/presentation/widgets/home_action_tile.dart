import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';

/// Hàng hành động kiểu Nhật: icon vuông bên trái, tiêu đề + mô tả, chevron bên phải.
/// Phẳng, bo góc nhỏ, không đổ bóng.
class HomeActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  final Color backgroundColor;
  final Color? borderColor;
  final Color iconBackground;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color chevronColor;
  final double verticalPadding;

  const HomeActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.backgroundColor,
    required this.iconBackground,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.chevronColor,
    this.borderColor,
    this.verticalPadding = AppSpacing.s20,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title, $subtitle',
      excludeSemantics: true,
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r10,
          side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: titleColor.withValues(alpha: 0.10),
          highlightColor: titleColor.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: verticalPadding),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: iconBackground, borderRadius: AppRadius.r8),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                AppSpacing.gapW14,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: subtitleColor, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapW8,
                Icon(Icons.chevron_right_rounded, color: chevronColor, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
