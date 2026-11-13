import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';

/// 3 nút công cụ: Xoay · Tự động · Thêm mặt sau — ô trắng viền mảnh, icon navy.
class CropBottomToolbar extends StatelessWidget {
  final String rotateLabel;
  final String autoLabel;
  final String addBackLabel;
  final VoidCallback onRotate;
  final VoidCallback onAuto;
  final VoidCallback onAddBack;

  const CropBottomToolbar({
    super.key,
    required this.rotateLabel,
    required this.autoLabel,
    required this.addBackLabel,
    required this.onRotate,
    required this.onAuto,
    required this.onAddBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToolButton(icon: Icons.rotate_right_rounded, label: rotateLabel, onTap: onRotate),
        AppSpacing.gapW8,
        _ToolButton(icon: Icons.auto_fix_high_outlined, label: autoLabel, onTap: onAuto),
        AppSpacing.gapW8,
        _ToolButton(icon: Icons.add_rounded, label: addBackLabel, onTap: onAddBack),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.darkTextPrimary : AppColors.navy;

    return Expanded(
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r10,
          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: fg, size: 20),
                AppSpacing.gapH4,
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
