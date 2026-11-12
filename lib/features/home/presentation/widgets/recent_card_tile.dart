import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cards/domain/entities/saved_card.dart';

/// Avatar chữ cái đầu của danh thiếp, màu cố định theo id.
class SavedCardAvatar extends StatelessWidget {
  final SavedCard card;
  final double size;

  const SavedCardAvatar({super.key, required this.card, this.size = 42});

  static const _palette = [
    (AppColors.avatarPurpleBg, AppColors.avatarPurpleText),
    (AppColors.avatarAmberBg, AppColors.avatarAmberText),
    (AppColors.avatarTealBg, AppColors.avatarTealText),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _palette[card.id.hashCode.abs() % _palette.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: colors.$1, borderRadius: AppRadius.r12),
      child: Center(
        child: Text(
          card.avatarChar,
          style: TextStyle(color: colors.$2, fontWeight: FontWeight.bold, fontSize: size * 0.38),
        ),
      ),
    );
  }
}

class RecentCardTile extends StatelessWidget {
  final SavedCard card;
  final VoidCallback? onTap;

  /// Widget bên phải. Mặc định hiển thị thời gian lưu ("Hôm nay" / dd/MM).
  final Widget? trailing;
  final EdgeInsetsGeometry margin;

  const RecentCardTile({
    super.key,
    required this.card,
    this.onTap,
    this.trailing,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.lg),
  });

  static String timeLabel(BuildContext context, DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return AppLocalizations.of(context)?.today ?? 'Hôm nay';
    }
    return DateFormat(date.year == now.year ? 'dd/MM' : 'dd/MM/yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    final title = card.displayName ?? l10n?.unnamedCard ?? '(Chưa có tên)';
    final subtitle = card.subtitle;

    return Semantics(
      button: onTap != null,
      label: subtitle.isEmpty ? title : '$title, $subtitle',
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.r16,
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.r16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xl),
              child: Row(
                children: [
                  SavedCardAvatar(card: card),
                  AppSpacing.gapW12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  AppSpacing.gapW8,
                  trailing ??
                      Text(
                        timeLabel(context, card.createdAt),
                        style: TextStyle(
                          color: textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
