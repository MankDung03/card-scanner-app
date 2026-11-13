import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/navy_header_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../scan/presentation/cubit/scan_cubit.dart';
import '../../domain/entities/saved_card.dart';
import '../cubit/saved_cards_cubit.dart';
import '../utils/card_share_service.dart';
import '../widgets/add_tag_dialog.dart';
import '../widgets/meeting_note_bottom_sheet.dart';

/// Màn hình xác nhận sau khi lưu danh thiếp thành công.
class CardSavedPage extends StatelessWidget {
  final String? cardId;

  const CardSavedPage({super.key, this.cardId});

  void _scanAnother(BuildContext context) {
    context.read<ScanCubit>().startNewScan();
    context.pushReplacement(AppRoutes.scanCamera);
  }

  void _backToHome(BuildContext context) {
    context.read<ScanCubit>().reset();
    context.go(AppRoutes.home);
  }

  /// Mở màn "Tạo liên hệ" của hệ thống với dữ liệu điền sẵn (giống bảng Chia sẻ ở màn chi tiết).
  Future<void> _saveToContacts(BuildContext context, SavedCard card) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await CardShareService.openContactCreator(card);
    } catch (e) {
      debugPrint('Open contact creator failed: $e');
      messenger.showSnackBar(SnackBar(
        content: Text(l10n?.cannotOpenApp ?? 'Không mở được ứng dụng phù hợp trên máy'),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _addTag(BuildContext context, SavedCard card) async {
    final cubit = context.read<SavedCardsCubit>();
    final suggestions = {
      for (final c in cubit.state.cards) ...c.tags,
    }.where((t) => !card.tags.contains(t)).toList();

    final tag = await AddTagDialog.show(context, suggestions: suggestions);
    final cleaned = SavedCard.clean(tag);
    if (cleaned == null) return;
    if (card.tags.any((t) => t.toLowerCase() == cleaned.toLowerCase())) return;
    await cubit.updateCard(card.copyWith(tags: [...card.tags, cleaned]));
  }

  Future<void> _editNote(BuildContext context, SavedCard card) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<SavedCardsCubit>();

    final note = await MeetingNoteBottomSheet.show(context, initialValue: card.note);
    if (note == null) return;

    final ok = await cubit.updateNote(card.id, note);
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok
            ? (l10n?.noteSaved ?? 'Đã lưu ghi chú')
            : (l10n?.cardSaveFailed ?? 'Không thể lưu danh thiếp, vui lòng thử lại')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return PopScope(
      // Back cứng của hệ thống: dọn trạng thái scan rồi quay về Home
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) context.read<ScanCubit>().reset();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: Column(
            children: [
              // 1. Header navy: Đã lưu / Bước 3/3
              NavyHeaderBar(
                title: l10n?.savedComplete ?? 'Đã lưu',
                subtitle: l10n?.stepProgress(3, 3) ?? 'Bước 3/3',
              ),

              Expanded(
                child: SafeArea(
                  top: false,
                  child: BlocBuilder<SavedCardsCubit, SavedCardsState>(
                    builder: (context, state) {
                      final card = cardId != null
                          ? state.findById(cardId!)
                          : (state.cards.isNotEmpty ? state.cards.first : null);

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 36),
                                    const Center(child: _SuccessBadge()),
                                    AppSpacing.gapH16,
                                    Text(
                                      l10n?.cardSavedTitle ?? 'Đã lưu danh thiếp',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    AppSpacing.gapH6,
                                    Text(
                                      l10n?.cardSavedSubtitle ?? 'Đã lưu vào app trên máy này.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: textMuted, fontSize: 13),
                                    ),
                                    AppSpacing.gapH24,

                                    // 2. Thẻ tóm tắt danh thiếp vừa lưu
                                    if (card != null)
                                      _SavedCardSummary(
                                        card: card,
                                        detailLabel: l10n?.viewDetails ?? 'Chi tiết',
                                        onTap: () => context.push(AppRoutes.cardDetailPath(card.id)),
                                      ),

                                    AppSpacing.gapH20,

                                    // 3. Làm thêm (không bắt buộc)
                                    Text(
                                      l10n?.optionalActions ?? 'Làm thêm (không bắt buộc)',
                                      style: TextStyle(color: textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
                                    ),
                                    AppSpacing.gapH8,
                                    _ActionRow(
                                      icon: Icons.person_add_alt_outlined,
                                      label: l10n?.saveToContacts ?? 'Lưu vào Danh bạ',
                                      onTap: card == null ? null : () => _saveToContacts(context, card),
                                    ),
                                    AppSpacing.gapH8,
                                    _ActionRow(
                                      icon: Icons.sell_outlined,
                                      label: l10n?.addTagAction ?? 'Thêm tag',
                                      detail: card == null || card.tags.isEmpty ? null : card.tags.join('、'),
                                      onTap: card == null ? null : () => _addTag(context, card),
                                    ),
                                    AppSpacing.gapH8,
                                    _ActionRow(
                                      icon: Icons.edit_note_rounded,
                                      label: l10n?.addMeetingNote ?? 'Ghi chú gặp ở đâu',
                                      detail: card?.note,
                                      onTap: card == null ? null : () => _editNote(context, card),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AppSpacing.gapH16,

                            // 4. Nút chính + phụ
                            SizedBox(
                              height: 52,
                              child: FilledButton.icon(
                                onPressed: () => _scanAnother(context),
                                style: FilledButton.styleFrom(
                                  backgroundColor: isDark ? AppColors.darkNavy : AppColors.navy,
                                  foregroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
                                  textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                                ),
                                icon: const Icon(Icons.photo_camera_outlined, size: 20),
                                label: Text(l10n?.scanAnotherCard ?? 'Scan danh thiếp khác'),
                              ),
                            ),
                            AppSpacing.gapH8,
                            SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () => _backToHome(context),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
                                  foregroundColor: textPrimary,
                                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.divider),
                                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
                                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                child: Text(l10n?.backToHome ?? 'Về trang chủ'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(color: Color(0xFF2E8B67), shape: BoxShape.circle),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 34),
    );
  }
}

/// Khối trắng: furigana · tên · công ty + chức vụ, bên phải "Chi tiết >".
class _SavedCardSummary extends StatelessWidget {
  final SavedCard card;
  final String detailLabel;
  final VoidCallback onTap;

  const _SavedCardSummary({required this.card, required this.detailLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final accent = isDark ? const Color(0xFF93B4E0) : AppColors.navy;

    final furigana = card.furigana?.trim();
    final subtitle = card.subtitle;

    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.r10,
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (furigana != null && furigana.isNotEmpty)
                      Text(furigana, style: TextStyle(color: textMuted, fontSize: 11)),
                    Text(
                      card.displayName ?? l10n?.unnamedCard ?? '(Chưa có tên)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textMuted, fontSize: 12.5),
                      ),
                    ],
                  ],
                ),
              ),
              AppSpacing.gapW8,
              Text(detailLabel, style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right_rounded, color: accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hàng hành động: icon · nhãn (· chi tiết) · chevron.
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? detail;
  final VoidCallback? onTap;

  const _ActionRow({required this.icon, required this.label, this.detail, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final hasDetail = detail != null && detail!.trim().isNotEmpty;

    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.r10,
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.lg, AppSpacing.md, AppSpacing.lg),
            child: Row(
              children: [
                Icon(icon, color: isDark ? AppColors.darkTextSecondary : AppColors.navy, size: 20),
                AppSpacing.gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                      if (hasDetail)
                        Text(
                          detail!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: textMuted, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: textMuted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
