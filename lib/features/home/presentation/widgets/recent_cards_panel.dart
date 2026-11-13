import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cards/domain/entities/saved_card.dart';
import 'recent_card_tile.dart';

/// Panel "Đã lưu gần đây" kiểu Nhật: một khối trắng, header + danh sách có đường kẻ mảnh.
class RecentCardsPanel extends StatelessWidget {
  final String title;
  final String? viewAllLabel;
  final VoidCallback? onViewAll;
  final List<SavedCard> cards;
  final ValueChanged<SavedCard> onCardTap;

  /// Nội dung thay thế khi chưa có danh thiếp (loading / empty).
  final Widget? placeholder;

  const RecentCardsPanel({
    super.key,
    required this.title,
    required this.cards,
    required this.onCardTap,
    this.viewAllLabel,
    this.onViewAll,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.divider;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final link = isDark ? const Color(0xFF93B4E0) : AppColors.navy;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.r10,
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.xxl, AppSpacing.md, AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                if (viewAllLabel != null && onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    style: TextButton.styleFrom(
                      foregroundColor: link,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    child: Text(viewAllLabel!),
                  ),
              ],
            ),
          ),
          if (cards.isEmpty && placeholder != null)
            placeholder!
          else
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) Divider(height: 1, thickness: 1, indent: AppSpacing.s16, endIndent: AppSpacing.s16, color: divider),
              _RecentCardRow(card: cards[i], onTap: () => onCardTap(cards[i])),
            ],
          AppSpacing.gapH4,
        ],
      ),
    );
  }
}

class _RecentCardRow extends StatelessWidget {
  final SavedCard card;
  final VoidCallback onTap;

  const _RecentCardRow({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    final name = card.displayName ?? l10n?.unnamedCard ?? '(Chưa có tên)';
    final subtitle = card.subtitle;

    return Semantics(
      button: true,
      label: subtitle.isEmpty ? name : '$name, $subtitle',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.xl, AppSpacing.md, AppSpacing.xl),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              AppSpacing.gapW8,
              Text(
                RecentCardTile.timeLabel(context, card.createdAt),
                style: TextStyle(color: muted, fontSize: 12, fontFeatures: const [FontFeature.tabularFigures()]),
              ),
              Icon(Icons.chevron_right_rounded, color: muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
