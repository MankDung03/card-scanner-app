import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/widgets/recent_card_tile.dart';
import '../../domain/entities/saved_card.dart';

/// Ảnh thu nhỏ mặt trước theo tỉ lệ danh thiếp 91:55.
/// Không có ảnh → ô xám với chữ cái đầu.
class CardThumbnail extends StatelessWidget {
  final SavedCard card;
  final double width;

  const CardThumbnail({super.key, required this.card, this.width = 64});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = width * 55 / 91;
    final imagePath = card.frontImagePath;
    final file = imagePath != null ? File(imagePath) : null;
    final hasImage = file != null && file.existsSync();

    final placeholder = Center(
      child: Text(
        card.avatarChar,
        style: TextStyle(
          color: isDark ? AppColors.darkTextMuted : AppColors.navy,
          fontSize: height * 0.42,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : AppColors.navyTint,
        borderRadius: AppRadius.r4,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.file(
              file,
              fit: BoxFit.cover,
              cacheWidth: (width * 3).round(),
              errorBuilder: (_, __, ___) => placeholder,
            )
          : placeholder,
    );
  }
}

/// Một dòng trong danh sách danh thiếp. Các dòng liền nhau ghép thành một khối trắng
/// có viền mảnh: [isFirst] bo góc trên, [isLast] bo góc dưới, giữa các dòng là đường kẻ.
class CardListItem extends StatelessWidget {
  final SavedCard card;
  final bool isFirst;
  final bool isLast;

  /// Hiện nhãn "Có thể trùng" (thẻ có cờ trùng còn hiệu lực)
  final bool possibleDuplicate;
  final VoidCallback? onTap;
  final VoidCallback? onEditNote;
  final VoidCallback? onDelete;

  const CardListItem({
    super.key,
    required this.card,
    this.isFirst = true,
    this.isLast = true,
    this.possibleDuplicate = false,
    this.onTap,
    this.onEditNote,
    this.onDelete,
  });

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.divider;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final accent = isDark ? const Color(0xFF93B4E0) : AppColors.navy;

    final title = card.displayName ?? l10n?.unnamedCard ?? '(Chưa có tên)';
    final furigana = card.furigana?.trim();
    final subtitle = card.subtitle;
    final primaryPhone = card.mobile ?? card.phone;
    final email = card.email;
    final note = card.note?.trim();

    const r = Radius.circular(AppRadius.md);
    final outerRadius = BorderRadius.vertical(top: isFirst ? r : Radius.zero, bottom: isLast ? r : Radius.zero);
    const innerR = Radius.circular(AppRadius.md - 1);
    final innerRadius =
        BorderRadius.vertical(top: isFirst ? innerR : Radius.zero, bottom: isLast ? innerR : Radius.zero);

    // Viền mảnh dựng bằng lớp ngoài màu viền + lớp trong màu nền
    // (Border không đều cạnh không đi được với borderRadius).
    return Container(
      padding: EdgeInsets.only(left: 1, right: 1, top: isFirst ? 1 : 0, bottom: isLast ? 1 : 0),
      decoration: BoxDecoration(color: border, borderRadius: outerRadius),
      child: Material(
        color: bg,
        borderRadius: innerRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isFirst) Divider(height: 1, thickness: 1, indent: AppSpacing.s16, endIndent: AppSpacing.s16, color: border),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.xl, AppSpacing.xs, AppSpacing.xl),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: CardThumbnail(card: card),
                    ),
                    AppSpacing.gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (furigana != null && furigana.isNotEmpty)
                            Text(
                              furigana,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: textMuted, fontSize: 10.5),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              if (possibleDuplicate) ...[
                                AppSpacing.gapW6,
                                _DuplicateTag(l10n?.dupTag ?? 'Có thể trùng'),
                              ],
                              AppSpacing.gapW6,
                              Text(
                                RecentCardTile.timeLabel(context, card.createdAt),
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 11.5,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: textMuted, fontSize: 12.5),
                            ),
                          ],

                          // Liên hệ nhanh: chạm để sao chép
                          if (primaryPhone != null || email != null) ...[
                            AppSpacing.gapH6,
                            Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.xs,
                              children: [
                                if (primaryPhone != null)
                                  _ContactPill(
                                    icon: Icons.phone_outlined,
                                    text: primaryPhone,
                                    onTap: () => _copyToClipboard(
                                      context,
                                      primaryPhone,
                                      l10n?.copiedPhone ?? 'Đã sao chép số điện thoại',
                                    ),
                                  ),
                                if (email != null)
                                  _ContactPill(
                                    icon: Icons.mail_outline_rounded,
                                    text: email,
                                    onTap: () => _copyToClipboard(
                                      context,
                                      email,
                                      l10n?.copiedEmail ?? 'Đã sao chép email',
                                    ),
                                  ),
                              ],
                            ),
                          ],

                          // Ghi chú
                          if (note != null && note.isNotEmpty) ...[
                            AppSpacing.gapH6,
                            InkWell(
                              onTap: onEditNote,
                              borderRadius: AppRadius.r4,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurfaceMuted : AppColors.navyTint,
                                  borderRadius: AppRadius.r4,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_note_rounded, size: 15, color: accent),
                                    AppSpacing.gapW6,
                                    Expanded(
                                      child: Text(
                                        note,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _MoreMenu(
                      color: textMuted,
                      menuBg: bg,
                      primaryPhone: primaryPhone,
                      email: email,
                      onSelected: (val) {
                        switch (val) {
                          case 'note':
                            onEditNote?.call();
                          case 'copy_phone':
                            _copyToClipboard(context, primaryPhone!, l10n?.copiedPhone ?? 'Đã sao chép số điện thoại');
                          case 'copy_email':
                            _copyToClipboard(context, email!, l10n?.copiedEmail ?? 'Đã sao chép email');
                          case 'delete':
                            onDelete?.call();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  final Color color;
  final Color menuBg;
  final String? primaryPhone;
  final String? email;
  final ValueChanged<String> onSelected;

  const _MoreMenu({
    required this.color,
    required this.menuBg,
    required this.primaryPhone,
    required this.email,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const danger = Color(0xFFDC2626);

    return PopupMenuButton<String>(
      useRootNavigator: true,
      icon: Icon(Icons.more_vert_rounded, color: color, size: 20),
      padding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
      color: menuBg,
      elevation: 3,
      onSelected: onSelected,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'note',
          child: _MenuRow(icon: Icons.edit_note_rounded, text: l10n?.editNote ?? 'Sửa ghi chú'),
        ),
        if (primaryPhone != null)
          PopupMenuItem(value: 'copy_phone', child: _MenuRow(icon: Icons.phone_outlined, text: primaryPhone!)),
        if (email != null)
          PopupMenuItem(value: 'copy_email', child: _MenuRow(icon: Icons.mail_outline_rounded, text: email!)),
        const PopupMenuDivider(height: 8),
        PopupMenuItem(
          value: 'delete',
          child: _MenuRow(icon: Icons.delete_outline_rounded, text: l10n?.delete ?? 'Xoá', color: danger),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _MenuRow({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        AppSpacing.gapW10,
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13.5, color: color, fontWeight: color != null ? FontWeight.w600 : null),
          ),
        ),
      ],
    );
  }
}

/// Số điện thoại / email dạng chữ nhỏ có icon, chạm để sao chép.
class _ContactPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ContactPill({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.darkTextSecondary : AppColors.textTertiary;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.r4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nhãn nhỏ màu cam "Có thể trùng".
class _DuplicateTag extends StatelessWidget {
  final String text;

  const _DuplicateTag(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E2210) : const Color(0xFFFEF3C7),
        borderRadius: AppRadius.r4,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
