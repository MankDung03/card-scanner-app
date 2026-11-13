import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// Màu cảnh báo "要確認" dùng chung cho màn xác nhận.
class ReviewColors {
  static const Color fg = Color(0xFFB45309);
  static const Color bg = Color(0xFFFFF7ED);
  static const Color border = Color(0xFFF59E0B);
  static const Color darkFg = Color(0xFFFBBF24);
  static const Color darkBg = Color(0xFF2E2210);
  static const Color darkBorder = Color(0xFFB45309);
}

/// Một trường trong form xác nhận: nhãn phía trên + ô giống input (chạm để sửa).
/// Trường cần kiểm tra lại có tag "要確認" và ô viền cam.
class VerificationFieldTile extends StatelessWidget {
  final String label;
  final String? value;
  final bool isNeedsReview;
  final String placeholder;
  final VoidCallback onTap;

  const VerificationFieldTile({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.isNeedsReview = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasValue = value != null && value!.trim().isNotEmpty;

    final labelColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final valueColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final placeholderColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    final boxBg = isNeedsReview
        ? (isDark ? ReviewColors.darkBg : ReviewColors.bg)
        : (isDark ? AppColors.darkBackground : AppColors.surface);
    final boxBorder = isNeedsReview
        ? (isDark ? ReviewColors.darkBorder : ReviewColors.border)
        : (isDark ? AppColors.darkBorder : AppColors.divider);

    return Semantics(
      button: true,
      label: label,
      value: hasValue ? value : placeholder,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(label, style: TextStyle(color: labelColor, fontSize: 12, fontWeight: FontWeight.w600)),
              if (isNeedsReview) ...[
                AppSpacing.gapW6,
                _ReviewTag(text: l10n?.needsReviewTag ?? 'Kiểm tra lại'),
              ],
            ],
          ),
          AppSpacing.gapH6,
          Material(
            color: boxBg,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.r8,
              side: BorderSide(color: boxBorder, width: isNeedsReview ? 1.2 : 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      hasValue ? value! : placeholder,
                      style: TextStyle(
                        color: hasValue ? valueColor : placeholderColor,
                        fontSize: 14.5,
                        fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTag extends StatelessWidget {
  final String text;

  const _ReviewTag({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: isDark ? ReviewColors.darkBg : const Color(0xFFFEF3C7),
        borderRadius: AppRadius.r4,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? ReviewColors.darkFg : ReviewColors.fg,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Khối nhóm trường (氏名 / 会社情報 / 連絡先): nền trắng, viền mảnh, tiêu đề đậm.
class VerificationSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const VerificationSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.xxl, AppSpacing.s16, AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppRadius.r10,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          for (final child in children) ...[AppSpacing.gapH12, child],
        ],
      ),
    );
  }
}
