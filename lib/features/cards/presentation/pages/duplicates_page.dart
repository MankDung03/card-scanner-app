import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/navy_header_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/services/card_duplicate_matcher.dart';
import '../cubit/saved_cards_cubit.dart';
import '../widgets/card_list_item.dart';

/// Danh sách các cặp danh thiếp có thể trùng (gắn cờ khi khôi phục kiểu Gộp).
/// Mỗi cặp: "Giữ cả hai" hoặc "So sánh và gộp".
class DuplicatesPage extends StatelessWidget {
  const DuplicatesPage({super.key});

  static String reasonLabel(AppLocalizations? l10n, DuplicateReason? reason) => switch (reason) {
        DuplicateReason.email => l10n?.dupReasonEmail ?? 'Trùng email',
        DuplicateReason.mobile => l10n?.dupReasonMobile ?? 'Trùng số di động',
        DuplicateReason.nameAndCompany => l10n?.dupReasonNameCompany ?? 'Trùng họ tên và công ty',
        DuplicateReason.nameAndPhone => l10n?.dupReasonNamePhone ?? 'Trùng họ tên và số điện thoại',
        null => l10n?.dupReasonUnknown ?? 'Có thể là cùng một người',
      };

  Future<void> _keepBoth(BuildContext context, SavedCard flagged) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<SavedCardsCubit>().keepBoth(flagged.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(ok
            ? (l10n?.keptBothMsg ?? 'Đã giữ cả hai danh thiếp')
            : (l10n?.cardSaveFailed ?? 'Không thể lưu danh thiếp, vui lòng thử lại')),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pairs = context.select((SavedCardsCubit c) => c.state.duplicatePairs);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            NavyHeaderBar(
              title: l10n?.duplicatesTitle ?? 'Danh thiếp có thể trùng',
              subtitle: pairs.isEmpty ? null : (l10n?.cardsCount(pairs.length) ?? '${pairs.length}'),
              leading: NavyHeaderTextButton(
                icon: Icons.chevron_left_rounded,
                label: l10n?.backAction ?? 'Quay lại',
                onPressed: () => context.pop(),
              ),
            ),
            Expanded(
              child: pairs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.task_alt_rounded,
                            size: 40,
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          ),
                          AppSpacing.gapH12,
                          Text(l10n?.duplicatesEmpty ?? 'Không còn danh thiếp nào cần xem lại'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      itemCount: pairs.length,
                      separatorBuilder: (_, __) => AppSpacing.gapH12,
                      itemBuilder: (context, i) {
                        final (flagged, original) = pairs[i];
                        return _PairCard(
                          flagged: flagged,
                          original: original,
                          reason: reasonLabel(l10n, CardDuplicateMatcher.matchReason(flagged, original)),
                          onKeepBoth: () => _keepBoth(context, flagged),
                          onMerge: () => context.push(AppRoutes.mergePath(flagged.id)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PairCard extends StatelessWidget {
  final SavedCard flagged;
  final SavedCard original;
  final String reason;
  final VoidCallback onKeepBoth;
  final VoidCallback onMerge;

  const _PairCard({
    required this.flagged,
    required this.original,
    required this.reason,
    required this.onKeepBoth,
    required this.onMerge,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.divider;
    final warn = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppRadius.r10,
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: warn),
              AppSpacing.gapW6,
              Expanded(
                child: Text(reason, style: TextStyle(color: warn, fontSize: 12.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          AppSpacing.gapH10,
          _MiniCard(label: l10n?.dupExisting ?? 'Đã có trên máy', card: original),
          Divider(height: 20, color: border),
          _MiniCard(label: l10n?.dupNew ?? 'Thẻ mới thêm', card: flagged),
          AppSpacing.gapH12,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onKeepBoth,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    side: BorderSide(color: border),
                    minimumSize: const Size(0, 44),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.r8),
                  ),
                  child: Text(l10n?.keepBoth ?? 'Giữ cả hai', textAlign: TextAlign.center),
                ),
              ),
              AppSpacing.gapW8,
              Expanded(
                child: FilledButton(
                  onPressed: onMerge,
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkNavy : AppColors.navy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.r8),
                  ),
                  child: Text(l10n?.compareMerge ?? 'So sánh và gộp', textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String label;
  final SavedCard card;

  const _MiniCard({required this.label, required this.card});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final contact = [card.mobile ?? card.phone, card.email].whereType<String>().join(' · ');
    final date = DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).format(card.createdAt);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardThumbnail(card: card, width: 56),
        AppSpacing.gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$label · $date', style: TextStyle(color: muted, fontSize: 11)),
              Text(
                card.displayName ?? l10n?.unnamedCard ?? '(Chưa có tên)',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (card.subtitle.isNotEmpty) Text(card.subtitle, style: TextStyle(color: muted, fontSize: 12)),
              if (contact.isNotEmpty) Text(contact, style: TextStyle(color: muted, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
