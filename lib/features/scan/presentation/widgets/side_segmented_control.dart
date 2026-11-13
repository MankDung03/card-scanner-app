import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../cubit/scan_state.dart';

/// Segmented [ 表面 | 裏面（任意） ] kiểu Nhật: khung tối bo nhẹ, ô chọn nền trắng.
class SideSegmentedControl extends StatelessWidget {
  final CardSide currentSide;
  final String frontLabel;
  final String backLabel;
  final ValueChanged<CardSide> onSideChanged;

  /// true khi đặt trên nền sáng (màn cắt ảnh light theme).
  final bool onLightBackground;

  const SideSegmentedControl({
    super.key,
    required this.currentSide,
    required this.frontLabel,
    required this.backLabel,
    required this.onSideChanged,
    this.onLightBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: onLightBackground ? AppColors.divider : AppColors.scanControlBg,
        borderRadius: AppRadius.r10,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: frontLabel,
            isSelected: currentSide == CardSide.front,
            onLight: onLightBackground,
            onTap: () => onSideChanged(CardSide.front),
          ),
          _Segment(
            label: backLabel,
            isSelected: currentSide == CardSide.back,
            onLight: onLightBackground,
            onTap: () => onSideChanged(CardSide.back),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool onLight;
  final VoidCallback onTap;

  const _Segment({required this.label, required this.isSelected, required this.onLight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          constraints: const BoxConstraints(minWidth: 88, minHeight: 34),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: AppRadius.r8,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.textPrimary
                  : (onLight ? AppColors.textMuted : Colors.white.withValues(alpha: 0.8)),
            ),
          ),
        ),
      ),
    );
  }
}
