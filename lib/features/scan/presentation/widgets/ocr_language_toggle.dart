import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../cubit/scan_state.dart';

/// Nút chuyển đổi nhanh ngôn ngữ OCR (Auto / Tiếng Việt / Tiếng Nhật)
class OcrLanguageToggle extends StatelessWidget {
  final OcrLanguageMode currentMode;
  final ValueChanged<OcrLanguageMode> onModeChanged;
  final bool isDark;

  const OcrLanguageToggle({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.45) : const Color(0xFF1E293B),
        borderRadius: AppRadius.r24,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPill(
            label: 'Tự động',
            icon: Icons.auto_awesome_rounded,
            isSelected: currentMode == OcrLanguageMode.auto,
            onTap: () => onModeChanged(OcrLanguageMode.auto),
          ),
          _buildPill(
            label: 'VN',
            badge: '🇻🇳',
            isSelected: currentMode == OcrLanguageMode.vietnamese,
            onTap: () => onModeChanged(OcrLanguageMode.vietnamese),
          ),
          _buildPill(
            label: 'JP',
            badge: '🇯🇵',
            isSelected: currentMode == OcrLanguageMode.japanese,
            onTap: () => onModeChanged(OcrLanguageMode.japanese),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String label,
    IconData? icon,
    String? badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0284C7) : Colors.transparent,
          borderRadius: AppRadius.r24,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : Colors.white70,
              ),
              const SizedBox(width: 4),
            ],
            if (badge != null) ...[
              Text(
                badge,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
