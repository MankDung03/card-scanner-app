import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/widgets/recent_card_tile.dart';
import '../../../scan/presentation/cubit/scan_cubit.dart';
import '../../domain/entities/saved_card.dart';
import '../cubit/saved_cards_cubit.dart';
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

  void _saveToContacts(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.featureComingSoon ?? 'Chức năng sẽ được kích hoạt ở bước tiếp theo'),
        duration: const Duration(seconds: 2),
      ),
    );
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
    final textSecondary = isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B);

    return PopScope(
      // Back cứng của hệ thống: dọn trạng thái scan rồi quay về Home
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) context.read<ScanCubit>().reset();
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF3F5F9),
        body: SafeArea(
          child: BlocBuilder<SavedCardsCubit, SavedCardsState>(
            builder: (context, state) {
              final card = cardId != null
                  ? state.findById(cardId!)
                  : (state.cards.isNotEmpty ? state.cards.first : null);

              return Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 56),
                            const Center(child: _SuccessBadge()),
                            AppSpacing.gapH20,
                            Text(
                              l10n?.cardSavedTitle ?? 'Đã lưu danh thiếp',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            AppSpacing.gapH8,
                            Text(
                              l10n?.cardSavedSubtitle ?? 'Đã lưu vào app trên máy này.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            AppSpacing.gapH24,
                            if (card != null)
                              RecentCardTile(
                                card: card,
                                margin: EdgeInsets.zero,
                                onTap: () => context.push(AppRoutes.cardDetailPath(card.id)),
                                trailing: Icon(Icons.chevron_right_rounded, color: textSecondary),
                              ),
                            AppSpacing.gapH20,
                            Text(
                              l10n?.optionalActions ?? 'Làm thêm (không bắt buộc)',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            AppSpacing.gapH10,
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _OptionalActionCard(
                                      icon: Icons.person_add_alt_1_outlined,
                                      iconColor: const Color(0xFF2563EB),
                                      iconBg: const Color(0xFFDBEAFE),
                                      label: l10n?.saveToContacts ?? 'Lưu vào Danh bạ',
                                      onTap: card == null ? null : () => _saveToContacts(context),
                                    ),
                                  ),
                                  AppSpacing.gapW10,
                                  Expanded(
                                    child: _OptionalActionCard(
                                      icon: Icons.chat_bubble_outline_rounded,
                                      iconColor: const Color(0xFFD97706),
                                      iconBg: const Color(0xFFFEF3C7),
                                      label: l10n?.addMeetingNote ?? 'Ghi chú gặp ở đâu',
                                      detail: card?.note,
                                      onTap: card == null ? null : () => _editNote(context, card),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.gapH16,
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _scanAnother(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueCardStart,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.r14),
                        ),
                        icon: const Icon(Icons.photo_camera_outlined, size: 20),
                        label: Text(
                          l10n?.scanAnotherCard ?? 'Scan danh thiếp khác',
                          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    AppSpacing.gapH6,
                    TextButton(
                      onPressed: () => _backToHome(context),
                      child: Text(
                        l10n?.backToHome ?? 'Về trang chủ',
                        style: const TextStyle(
                          color: AppColors.linkColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
      width: 84,
      height: 84,
      decoration: const BoxDecoration(color: Color(0xFFD9F2E6), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(color: Color(0xFF16805A), shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}

class _OptionalActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String? detail;
  final VoidCallback? onTap;

  const _OptionalActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    this.detail,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasDetail = detail != null && detail!.trim().isNotEmpty;

    return Material(
      color: isDark ? AppColors.darkSurface : Colors.white,
      borderRadius: AppRadius.r16,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.r16,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withValues(alpha: 0.18) : iconBg,
                  borderRadius: AppRadius.r10,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              AppSpacing.gapH20,
              Text(
                label,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasDetail) ...[
                AppSpacing.gapH4,
                Text(
                  detail!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
