import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/widgets/recent_card_tile.dart';
import '../../domain/entities/saved_card.dart';

/// Thumbnail ảnh thẻ hoặc Avatar chữ cái
class CardThumbnail extends StatelessWidget {
  final SavedCard card;
  final double width;
  final double height;

  const CardThumbnail({
    super.key,
    required this.card,
    this.width = 62,
    this.height = 42,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = card.frontImagePath;
    final file = imagePath != null ? File(imagePath) : null;
    final hasImage = file != null && file.existsSync();

    if (hasImage) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: AppRadius.r8,
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBorder
                : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => SavedCardAvatar(
            card: card,
            size: height,
          ),
        ),
      );
    }

    return SavedCardAvatar(
      card: card,
      size: height,
    );
  }
}

/// Item thẻ danh thiếp trong màn danh sách đầy đủ
class CardListItem extends StatelessWidget {
  final SavedCard card;
  final VoidCallback? onTap;
  final VoidCallback? onEditNote;
  final VoidCallback? onDelete;

  const CardListItem({
    super.key,
    required this.card,
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
    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    final title = card.displayName ?? l10n?.unnamedCard ?? '(Chưa có tên)';
    final subtitle = card.subtitle;
    final primaryPhone = card.mobile ?? card.phone;
    final email = card.email;
    final note = card.note?.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.r16,
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Thumbnail, Name & Subtitle, Popup Action
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardThumbnail(card: card),
                    AppSpacing.gapW14,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.5,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              AppSpacing.gapW6,
                              Text(
                                RecentCardTile.timeLabel(context, card.createdAt),
                                style: TextStyle(
                                  color: textTertiary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: textTertiary,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.r12),
                      color: cardBg,
                      elevation: 4,
                      onSelected: (val) {
                        switch (val) {
                          case 'note':
                            onEditNote?.call();
                            break;
                          case 'copy_phone':
                            if (primaryPhone != null) {
                              _copyToClipboard(
                                context,
                                primaryPhone,
                                l10n?.copiedPhone ?? 'Đã sao chép số điện thoại',
                              );
                            }
                            break;
                          case 'copy_email':
                            if (email != null) {
                              _copyToClipboard(
                                context,
                                email,
                                l10n?.copiedEmail ?? 'Đã sao chép email',
                              );
                            }
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'note',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_note_rounded, size: 18),
                              AppSpacing.gapW10,
                              Text(l10n?.editNote ?? 'Sửa ghi chú', style: const TextStyle(fontSize: 13.5)),
                            ],
                          ),
                        ),
                        if (primaryPhone != null)
                          PopupMenuItem(
                            value: 'copy_phone',
                            child: Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 18),
                                AppSpacing.gapW10,
                                Text(primaryPhone, style: const TextStyle(fontSize: 13.5)),
                              ],
                            ),
                          ),
                        if (email != null)
                          PopupMenuItem(
                            value: 'copy_email',
                            child: Row(
                              children: [
                                const Icon(Icons.mail_outline_rounded, size: 18),
                                AppSpacing.gapW10,
                                Text(email, style: const TextStyle(fontSize: 13.5)),
                              ],
                            ),
                          ),
                        const PopupMenuDivider(height: 8),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                              AppSpacing.gapW10,
                              Text(
                                l10n?.delete ?? 'Xoá',
                                style: const TextStyle(fontSize: 13.5, color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Quick contact chips: phone & email (nếu có)
                if (primaryPhone != null || email != null) ...[
                  AppSpacing.gapH10,
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
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

                // Note chip (nếu có note)
                if (note != null && note.isNotEmpty) ...[
                  AppSpacing.gapH8,
                  InkWell(
                    onTap: onEditNote,
                    borderRadius: AppRadius.r8,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.blue.withValues(alpha: 0.12)
                            : const Color(0xFFF0F7FF),
                        borderRadius: AppRadius.r8,
                        border: Border.all(
                          color: isDark
                              ? Colors.blue.withValues(alpha: 0.25)
                              : const Color(0xFFBFDBFE),
                          width: 0.9,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sticky_note_2_outlined,
                            size: 14,
                            color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                          ),
                          AppSpacing.gapW6,
                          Expanded(
                            child: Text(
                              note,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFFDBEAFE) : const Color(0xFF1E40AF),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AppSpacing.gapW4,
                          Icon(
                            Icons.edit_outlined,
                            size: 13,
                            color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ContactPill({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9);
    final fg = isDark ? AppColors.darkTextSecondary : const Color(0xFF475569);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.r8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.r8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
