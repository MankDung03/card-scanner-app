import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/business_card_info.dart';
import 'verification_field_tile.dart';

/// Tóm tắt kết quả: ảnh thu nhỏ + "✓ Đã đọc N mục" + "⚠ M mục cần kiểm tra".
class VerificationHeaderCard extends StatelessWidget {
  final BusinessCardInfo cardInfo;
  final String? imagePath;

  const VerificationHeaderCard({
    super.key,
    required this.cardInfo,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final recognized = cardInfo.recognizedCount;
    final needsReview = cardInfo.reviewNeededCount;
    const ok = Color(0xFF15803D);
    const okDark = Color(0xFF4ADE80);
    final hasImage = imagePath != null && File(imagePath!).existsSync();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppRadius.r10,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
      ),
      child: Row(
        children: [
          // 1. Ảnh thẻ thu nhỏ (tỉ lệ 91:55)
          Container(
            width: 91,
            height: 55,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
              borderRadius: AppRadius.r4,
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                    errorBuilder: (_, __, ___) => const Icon(Icons.credit_card_rounded, color: Colors.grey),
                  )
                : const Icon(Icons.credit_card_rounded, color: Colors.grey),
          ),
          AppSpacing.gapW14,

          // 2. Trạng thái
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusLine(
                  icon: Icons.check_circle_outline_rounded,
                  color: isDark ? okDark : ok,
                  text: l10n?.detectedFieldsCount(recognized) ?? 'Đã nhận dạng $recognized mục',
                  bold: true,
                ),
                AppSpacing.gapH6,
                needsReview > 0
                    ? _StatusLine(
                        icon: Icons.warning_amber_rounded,
                        color: isDark ? ReviewColors.darkFg : ReviewColors.fg,
                        text: l10n?.needsReviewCount(needsReview) ?? '$needsReview mục nên kiểm tra lại',
                      )
                    : _StatusLine(
                        icon: Icons.verified_outlined,
                        color: isDark ? okDark : ok,
                        text: l10n?.allClear ?? 'Mọi thông tin đều rõ ràng',
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final bool bold;

  const _StatusLine({required this.icon, required this.color, required this.text, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        AppSpacing.gapW6,
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
