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
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';
import '../widgets/crop_bottom_toolbar.dart';
import '../widgets/interactive_quad_cropper.dart';
import '../widgets/side_segmented_control.dart';

class CardCropPage extends StatelessWidget {
  const CardCropPage({super.key});

  void _onChangePhoto(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scanCubit = context.read<ScanCubit>();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(l10n?.captureCardTitle ?? 'Chụp lại', style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    context.pushReplacement(AppRoutes.scanCamera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: Text(l10n?.gallery ?? 'Chọn từ thư viện', style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    await scanCubit.pickFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _sideLabel(AppLocalizations? l10n, CardSide side) => side == CardSide.front
      ? (l10n?.frontSide ?? 'Mặt trước')
      : (l10n?.backSide ?? 'Mặt sau');

  Future<void> _onRecognizeText(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final scanCubit = context.read<ScanCubit>();

    // Hiển thị loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: const Color(0xFF131B2E),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.r16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                  ),
                ),
                AppSpacing.gapW16,
                Expanded(
                  // Cập nhật tiến độ khi OCR lần lượt từng mặt
                  child: BlocBuilder<ScanCubit, ScanState>(
                    bloc: scanCubit,
                    buildWhen: (a, b) =>
                        a.ocrSideInProgress != b.ocrSideInProgress || a.ocrSideIndex != b.ocrSideIndex,
                    builder: (_, s) {
                      final side = s.ocrSideInProgress;
                      final text = (side != null && s.ocrSidesTotal > 1)
                          ? (l10n?.ocrProcessingSide(
                                _sideLabel(l10n, side).toLowerCase(),
                                s.ocrSideIndex,
                                s.ocrSidesTotal,
                              ) ??
                              'Đang nhận dạng (${s.ocrSideIndex}/${s.ocrSidesTotal})...')
                          : (l10n?.ocrProcessing ?? 'Đang nhận dạng chữ trên thẻ...');
                      return Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final result = await scanCubit.processOcr();

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // Đóng loading dialog

      if (result != null) {
        // Một mặt lỗi nhưng mặt kia vẫn đọc được → cảnh báo nhẹ rồi vẫn sang màn xác nhận
        final failed = scanCubit.state.ocrFailedSides;
        if (failed.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.ocrSideFailed(_sideLabel(l10n, failed.first).toLowerCase()) ??
                    'Không nhận dạng được một mặt, chỉ dùng thông tin mặt còn lại',
              ),
              backgroundColor: const Color(0xFFD97706),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        // Tự động chuyển thẳng sang Màn 3 với các trường đã được bóc tách và điền sẵn vào form
        context.push(AppRoutes.ocrReview);
      } else {
        // Chi tiết kỹ thuật (ocrErrorMessage) chỉ ghi log; người dùng thấy câu đã dịch
        debugPrint('OCR failed: ${scanCubit.state.ocrErrorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.ocrFailed ?? 'Không nhận dạng được chữ trên ảnh, vui lòng thử lại'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scanCubit = context.read<ScanCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            // 1. Header navy: [< Quay lại]  Căn chỉnh ảnh / Bước 2/3  [Đổi ảnh]
            NavyHeaderBar(
              title: l10n?.cropTitle ?? 'Căn chỉnh ảnh',
              subtitle: l10n?.stepProgress(2, 3) ?? 'Bước 2/3',
              leading: NavyHeaderTextButton(
                icon: Icons.chevron_left_rounded,
                label: l10n?.backAction ?? 'Quay lại',
                onPressed: () => context.pop(),
              ),
              trailing: NavyHeaderTextButton(
                label: l10n?.changePhoto ?? 'Đổi ảnh',
                onPressed: () => _onChangePhoto(context),
              ),
            ),

            Expanded(
              child: SafeArea(
                top: false,
                child: BlocBuilder<ScanCubit, ScanState>(
                  builder: (context, state) {
                    final imagePath = state.currentImagePath;

                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 2. Khung tối chứa ảnh + 4 góc kéo được
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.s16),
                              decoration: const BoxDecoration(
                                color: AppColors.scanChrome,
                                borderRadius: AppRadius.r10,
                              ),
                              child: Center(
                                child: imagePath != null
                                    ? InteractiveQuadCropper(
                                        imagePath: imagePath,
                                        rotationAngle: state.rotationAngle,
                                        aspectRatio: (state.imageWidth != null && state.imageHeight != null)
                                            ? (state.rotationAngle % 180 != 0
                                                ? state.imageHeight! / state.imageWidth!
                                                : state.imageWidth! / state.imageHeight!)
                                            : null,
                                        corners: state.cornerPoints,
                                        onCornerChanged: (index, newOffset) {
                                          scanCubit.updateCorner(index, newOffset);
                                        },
                                      )
                                    : Text(
                                        l10n?.noCardImage ?? 'Chưa có ảnh danh thiếp',
                                        style: const TextStyle(color: Colors.white54),
                                      ),
                              ),
                            ),
                          ),

                          AppSpacing.gapH12,

                          // 2b. Đã có 2 mặt → chuyển qua lại để căn chỉnh từng mặt
                          if (state.hasBothSides) ...[
                            Center(
                              child: SideSegmentedControl(
                                currentSide: state.currentSide,
                                frontLabel: '${l10n?.frontSide ?? 'Mặt trước'} ✓',
                                backLabel: '${l10n?.backSide ?? 'Mặt sau'} ✓',
                                onSideChanged: scanCubit.setSide,
                                onLightBackground: !isDark,
                              ),
                            ),
                            AppSpacing.gapH12,
                          ],

                          // 3. Ghi chú hướng dẫn
                          _CropInfoNote(
                            text: l10n?.autoDetectedSuccess ?? 'Đã tự nhận khung thẻ · kéo 4 góc nếu chưa khớp',
                          ),

                          AppSpacing.gapH16,

                          // 4. Công cụ: Xoay · Tự động · Thêm mặt sau
                          CropBottomToolbar(
                            rotateLabel: l10n?.rotate ?? 'Xoay',
                            autoLabel: l10n?.autoAlign ?? 'Tự động',
                            addBackLabel: l10n?.addBackSide ?? 'Thêm mặt sau',
                            onRotate: () => scanCubit.rotateImage(),
                            onAuto: () => scanCubit.resetCropCorners(),
                            onAddBack: () {
                              scanCubit.setSide(CardSide.back);
                              context.pushReplacement(AppRoutes.scanCamera);
                            },
                          ),

                          AppSpacing.gapH12,

                          // 5. Nút chính: Nhận dạng chữ (OCR)
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: () => _onRecognizeText(context),
                              style: FilledButton.styleFrom(
                                backgroundColor: isDark ? AppColors.darkNavy : AppColors.navy,
                                foregroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      l10n?.recognizeText ?? 'Nhận dạng chữ',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  AppSpacing.gapW8,
                                  const Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
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
          ],
        ),
      ),
    );
  }
}

/// Ô ghi chú (i) nền nhạt, chữ nhỏ nhiều dòng.
class _CropInfoNote extends StatelessWidget {
  final String text;

  const _CropInfoNote({required this.text});

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
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: isDark ? AppColors.darkTextMuted : AppColors.navy,
          ),
          AppSpacing.gapW8,
          Expanded(
            child: Text(text, style: TextStyle(color: fg, fontSize: 12.5, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
