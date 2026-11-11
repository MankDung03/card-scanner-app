import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

class VerificationFieldTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String? value;
  final bool isNeedsReview;
  final String placeholder;
  final VoidCallback onTap;
  final bool showDivider;

  const VerificationFieldTile({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isNeedsReview = false,
    required this.placeholder,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasValue = value != null && value!.trim().isNotEmpty;

    // Nền highlight màu kem cam nếu mục cần kiểm tra lại
    final tileColor = isNeedsReview
        ? (isDark ? const Color(0xFF382714) : const Color(0xFFFFFBEB))
        : (isDark ? const Color(0xFF1E293B) : Colors.white);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(10),
          border: isNeedsReview
              ? Border.all(
                  color: isDark ? const Color(0xFFB45309) : const Color(0xFFFDE68A),
                  width: 1,
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Icon đại diện có màu nền
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? iconBgColor.withValues(alpha: 0.25) : iconBgColor,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 19,
                    ),
                  ),
                ),
                AppSpacing.gapW14,

                // 2. Nội dung Label & Giá trị
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header: Tên trường + Tag "Kiểm tra lại" nếu có
                      Row(
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isNeedsReview) ...[
                            AppSpacing.gapW6,
                            Text(
                              '· ${l10n?.needsReviewTag ?? "Kiểm tra lại"}',
                              style: const TextStyle(
                                color: Color(0xFFD97706),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Value hoặc Placeholder nếu không có
                      hasValue
                          ? Text(
                              value!,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            )
                          : Text(
                              placeholder,
                              style: TextStyle(
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ],
                  ),
                ),

                // Icon mũi tên chỉnh sửa
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
