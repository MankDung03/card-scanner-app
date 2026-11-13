import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/saved_card.dart';
import '../utils/card_share_service.dart';

/// Bảng "Xuất · Chia sẻ" cho một danh thiếp: lưu vào Danh bạ máy, chia sẻ vCard.
class CardShareSheet extends StatelessWidget {
  final SavedCard card;

  const CardShareSheet({super.key, required this.card});

  static Future<void> show(BuildContext context, SavedCard card) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBackground : AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => CardShareSheet(card: card),
    );
  }

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    try {
      await action();
    } catch (e) {
      debugPrint('Share action failed: $e');
      messenger.showSnackBar(SnackBar(
        content: Text(l10n?.cannotOpenApp ?? 'Không mở được ứng dụng phù hợp trên máy'),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final name = card.displayName ?? l10n?.unnamedCard ?? '';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tiêu đề + nút đóng
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n?.shareSheetTitle ?? 'Xuất · Chia sẻ',
                    style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textPrimary,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.divider),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: Text(l10n?.closeAction ?? 'Đóng'),
                ),
              ],
            ),
            AppSpacing.gapH16,

            // Danh thiếp này
            Text(
              l10n?.thisCardSection(name) ?? 'Danh thiếp này ($name)',
              style: TextStyle(color: muted, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            AppSpacing.gapH8,
            _OptionGroup(
              children: [
                _OptionRow(
                  icon: Icons.person_add_alt_outlined,
                  title: l10n?.saveToContacts ?? 'Lưu vào Danh bạ',
                  subtitle: l10n?.saveToContactsDesc ?? 'Mở ứng dụng Danh bạ để kiểm tra rồi lưu',
                  onTap: () => _run(context, () => CardShareService.openContactCreator(card)),
                ),
                _OptionRow(
                  icon: Icons.contact_page_outlined,
                  title: l10n?.shareVcard ?? 'Chia sẻ dạng vCard (.vcf)',
                  subtitle: l10n?.shareVcardDesc ?? 'LINE, Zalo, email…',
                  onTap: () => _run(context, () => CardShareService.shareVCard(card)),
                ),
              ],
            ),
            AppSpacing.gapH16,

            // Ghi chú nơi lưu
            StorageInfoNote(
              title: l10n?.storageInfoTitle ?? 'Về nơi lưu file',
              body: l10n?.storageInfoBody ??
                  'File được tạo ngay trên máy. Bạn chọn nơi lưu trong menu chia sẻ. Không gửi lên máy chủ nào.',
            ),
          ],
        ),
      ),
    );
  }
}

/// Khối trắng chứa các dòng lựa chọn, kẻ mảnh giữa các dòng.
class _OptionGroup extends StatelessWidget {
  final List<Widget> children;

  const _OptionGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.divider;
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.r10, side: BorderSide(color: border)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, indent: AppSpacing.s16, endIndent: AppSpacing.s16, color: border),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionRow({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isDark ? AppColors.darkTextSecondary : AppColors.navy),
            AppSpacing.gapW14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: muted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: muted, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Ô ghi chú "Về nơi lưu file" (icon thư mục, nền xanh nhạt).
class StorageInfoNote extends StatelessWidget {
  final String title;
  final String body;

  const StorageInfoNote({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : AppColors.navyTint,
        borderRadius: AppRadius.r8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.folder_outlined, size: 18, color: isDark ? AppColors.darkTextMuted : AppColors.navy),
          AppSpacing.gapW8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(body, style: TextStyle(color: fg, fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
