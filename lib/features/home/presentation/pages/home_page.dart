import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/trust_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../scan/presentation/cubit/scan_cubit.dart';
import '../../../cards/presentation/cubit/saved_cards_cubit.dart';
import '../../../cards/presentation/pages/saved_cards_page.dart';
import '../widgets/camera_action_card.dart';
import '../widgets/gallery_action_card.dart';
import '../widgets/recent_cards_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Số danh thiếp gần đây hiển thị trên Home (tối đa 3 danh thiếp mới nhất)
  static const int _recentLimit = 3;

  void _onCaptureCard(BuildContext context) {
    // Bắt đầu scan mới: xoá ảnh / kết quả OCR còn sót của lần trước
    context.read<ScanCubit>().startNewScan();
    context.push(AppRoutes.scanCamera);
  }

  Future<void> _onPickFromGallery(BuildContext context) async {
    final scanCubit = context.read<ScanCubit>()..startNewScan();
    final picked = await scanCubit.pickFromGallery();
    if (picked != null && context.mounted) {
      context.push(AppRoutes.scanCrop);
    }
  }

  /// Chuyển sang tab Danh thiếp (giống bấm menu dưới)
  void _onViewAllCards(BuildContext context) {
    context.go(AppRoutes.savedCards);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Header navy → icon status bar màu trắng ở cả 2 theme
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            // 1. Header bar navy tràn viền (kể cả vùng status bar)
            _HomeHeader(title: l10n?.appName ?? 'Scan Danh Thiếp'),

            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s24, AppSpacing.s16, 0),
                    sliver: SliverList.list(
                      children: [
                        // 2. Tiêu đề & mô tả
                        Text(
                          l10n?.addCardTitle ?? 'Thêm danh thiếp',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        AppSpacing.gapH6,
                        Text(
                          l10n?.addCardSubtitle ?? 'Chọn cách lấy ảnh danh thiếp của bạn',
                          style: TextStyle(color: textMuted, fontSize: 13, height: 1.5),
                        ),

                        AppSpacing.gapH20,

                        // 3. Hành động chính: chụp ảnh
                        CameraActionCard(
                          title: l10n?.captureCardTitle ?? 'Chụp ảnh',
                          subtitle: l10n?.captureCardSubtitle ?? 'Mở camera, tự căn khung thẻ',
                          onTap: () => _onCaptureCard(context),
                        ),

                        AppSpacing.gapH12,

                        // 4. Hành động phụ: chọn từ thư viện
                        GalleryActionCard(
                          title: l10n?.galleryCardTitle ?? 'Chọn từ thư viện',
                          subtitle: l10n?.galleryCardSubtitle ?? 'Dùng ảnh danh thiếp có sẵn trong máy',
                          onTap: () => _onPickFromGallery(context),
                        ),

                        AppSpacing.gapH24,

                        // 5. Danh thiếp gần đây (dữ liệu thật đã lưu trên máy)
                        BlocBuilder<SavedCardsCubit, SavedCardsState>(
                          builder: (context, cardsState) {
                            final cards = cardsState.cards;
                            return RecentCardsPanel(
                              title: l10n?.recentlySaved ?? 'Đã lưu gần đây',
                              cards: cards.take(_recentLimit).toList(),
                              viewAllLabel: cards.isEmpty
                                  ? null
                                  : (l10n?.viewAll(cards.length) ?? 'Xem tất cả (${cards.length})'),
                              onViewAll: () => _onViewAllCards(context),
                              onCardTap: (card) => context.push(AppRoutes.cardDetailPath(card.id)),
                              placeholder: cardsState.isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(AppSpacing.s20),
                                      child: Center(child: CircularProgressIndicator()),
                                    )
                                  : SavedCardsEmptyView(
                                      message: l10n?.noSavedCards,
                                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s20),
                                    ),
                            );
                          },
                        ),

                        AppSpacing.gapH24,
                      ],
                    ),
                  ),

                  // 6. Footer: nằm sát đáy màn hình, cuộn theo khi nội dung dài
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(
                        top: false,
                        minimum: const EdgeInsets.only(bottom: AppSpacing.s16),
                        child: TrustBadge(
                          text: l10n?.offlineBadge ?? 'Xử lý ngay trên máy · không cần mạng',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header bar navy kiểu Nhật: logo "名" + tên app (Cài đặt nằm ở menu dưới).
class _HomeHeader extends StatelessWidget {
  final String title;

  const _HomeHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkNavy : AppColors.navy;

    return Material(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.s16, right: AppSpacing.xs),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: AppRadius.r4),
                  alignment: Alignment.center,
                  child: Text(
                    '名',
                    style: TextStyle(color: bg, fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
                AppSpacing.gapW10,
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
