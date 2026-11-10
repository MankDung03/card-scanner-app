import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/trust_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../scan/presentation/cubit/scan_cubit.dart';
import '../../data/models/recent_card_model.dart';
import '../widgets/camera_action_card.dart';
import '../widgets/gallery_action_card.dart';
import '../widgets/recent_card_tile.dart';
import '../widgets/settings_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<RecentCardModel> _recentCards = RecentCardModel.sampleData;

  void _onCaptureCard(BuildContext context) {
    context.push(AppRoutes.scanCamera);
  }

  Future<void> _onPickFromGallery(BuildContext context) async {
    final scanCubit = context.read<ScanCubit>();
    final picked = await scanCubit.pickFromGallery();
    if (picked != null && context.mounted) {
      context.push(AppRoutes.scanCrop);
    }
  }

  void _onViewAllCards(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.recentlySaved ?? 'Danh sách danh thiếp'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    SettingsBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final headerBg = isDark ? AppColors.darkSurface : Colors.white;
    final headerBorder = isDark ? AppColors.darkBorder : AppColors.borderLight;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Brand Logo + App Name
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.brandBadgeBg,
                          borderRadius: AppRadius.r8,
                        ),
                        child: const Center(
                          child: Text(
                            '名',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.gapW8,
                      Text(
                        l10n?.appName ?? 'Scan Danh Thiếp',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  // Settings / Filter Button with Material Ripple
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openSettings(context),
                      borderRadius: AppRadius.r12,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: headerBg,
                          borderRadius: AppRadius.r12,
                          border: Border.all(
                            color: headerBorder,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.gapH24,

              // 2. Title & Subtitle
              Text(
                l10n?.addCardTitle ?? 'Thêm danh thiếp',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              AppSpacing.gapH6,
              Text(
                l10n?.addCardSubtitle ?? 'Chọn cách lấy ảnh danh thiếp của bạn',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              AppSpacing.gapH20,

              // 3. Primary Action: CameraActionCard (Clean, No L_ icon, Anti-aliased)
              CameraActionCard(
                title: l10n?.captureCardTitle ?? 'Chụp ảnh',
                subtitle: l10n?.captureCardSubtitle ?? 'Mở camera, tự căn khung thẻ',
                onTap: () => _onCaptureCard(context),
              ),

              AppSpacing.gapH14,

              // 4. Secondary Action: GalleryActionCard
              GalleryActionCard(
                title: l10n?.galleryCardTitle ?? 'Chọn từ thư viện',
                subtitle: l10n?.galleryCardSubtitle ?? 'Dùng ảnh danh thiếp có sẵn trong máy',
                onTap: () => _onPickFromGallery(context),
              ),

              AppSpacing.gapH28,

              // 5. Recent Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.recentlySaved ?? 'Đã lưu gần đây',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => _onViewAllCards(context),
                    borderRadius: AppRadius.r4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        l10n?.viewAll(24) ?? 'Xem tất cả (24)',
                        style: const TextStyle(
                          color: AppColors.linkColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.gapH12,

              // 6. Recent cards list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentCards.length,
                itemBuilder: (context, index) {
                  final card = _recentCards[index];
                  return RecentCardTile(
                    card: card,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(card.name),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),

              AppSpacing.gapH28,

              // 7. Trust Badge Footer (100% On-device USP)
              TrustBadge(
                text: l10n?.offlineBadge ?? 'Xử lý ngay trên máy · không cần mạng',
              ),

              AppSpacing.gapH16,
            ],
          ),
        ),
      ),
    );
  }
}
