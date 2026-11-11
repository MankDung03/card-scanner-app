import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/business_card_info.dart';

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

    final int recognized = cardInfo.recognizedCount;
    final int needsReview = cardInfo.reviewNeededCount;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: AppRadius.r16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 1. Ảnh thẻ thu nhỏ
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 90,
              height: 56,
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              child: imagePath != null && File(imagePath!).existsSync()
                  ? Image.file(
                      File(imagePath!),
                      fit: BoxFit.cover,
                      cacheWidth: 300,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.credit_card_rounded, color: Colors.grey),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.credit_card_rounded, color: Colors.grey),
                    ),
            ),
          ),
          AppSpacing.gapW14,

          // 2. Thông tin số lượng nhận diện & cảnh báo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dòng trạng thái tích xanh
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF16A34A),
                      size: 18,
                    ),
                    AppSpacing.gapW6,
                    Expanded(
                      child: Text(
                        l10n?.detectedFieldsCount(recognized) ?? 'Đã nhận dạng $recognized mục',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Dòng cảnh báo kiểm tra lại (nếu có mục nghi ngờ)
                if (needsReview > 0)
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD97706),
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpacing.gapW6,
                      Expanded(
                        child: Text(
                          l10n?.needsReviewCount(needsReview) ?? '$needsReview mục nên kiểm tra lại',
                          style: const TextStyle(
                            color: Color(0xFFD97706),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpacing.gapW6,
                      Expanded(
                        child: Text(
                          l10n?.allClear ?? 'Mọi thông tin đều rõ ràng',
                          style: const TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
