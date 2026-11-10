import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';
import '../widgets/crop_bottom_toolbar.dart';
import '../widgets/interactive_quad_cropper.dart';
import '../widgets/ocr_preview_sheet.dart';

class CardCropPage extends StatelessWidget {
  const CardCropPage({super.key});

  void _onChangePhoto(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scanCubit = context.read<ScanCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                  title: Text(l10n?.captureCardTitle ?? 'Chụp lại', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    context.pushReplacement(AppRoutes.scanCamera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: Colors.white),
                  title: Text(l10n?.gallery ?? 'Chọn từ thư viện', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                  child: Text(
                    l10n?.ocrProcessing ?? 'Đang nhận dạng chữ trên thẻ...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
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
        await OcrPreviewSheet.show(
          context,
          result,
          imagePath: scanCubit.state.currentImagePath,
        );
      } else {
        final error = scanCubit.state.ocrErrorMessage ?? 'Lỗi nhận dạng';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
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

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n?.cropTitle ?? 'Căn chỉnh ảnh',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _onChangePhoto(context),
            child: Text(
              l10n?.changePhoto ?? 'Đổi ảnh',
              style: const TextStyle(
                color: Color(0xFF38BDF8),
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ScanCubit, ScanState>(
          builder: (context, state) {
            final imagePath = state.currentImagePath;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
              child: Column(
                children: [
                  AppSpacing.gapH10,

                  // 1. Canvas chỉnh góc 4 điểm tương tác
                  Expanded(
                    child: Center(
                      child: imagePath != null
                          ? InteractiveQuadCropper(
                              imagePath: imagePath,
                              rotationAngle: state.rotationAngle,
                              corners: state.cornerPoints,
                              onCornerChanged: (index, newOffset) {
                                scanCubit.updateCorner(index, newOffset);
                              },
                            )
                          : const Center(
                              child: Text(
                                'Chưa có ảnh danh thiếp',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                    ),
                  ),

                  AppSpacing.gapH16,

                  // 2. Huy hiệu trạng thái đã tự nhận diện
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B),
                      borderRadius: AppRadius.r24,
                      border: Border.all(color: const Color(0xFF059669), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF34D399),
                          size: 16,
                        ),
                        AppSpacing.gapW8,
                        Flexible(
                          child: Text(
                            l10n?.autoDetectedSuccess ?? 'Đã tự nhận khung thẻ · kéo 4 góc nếu chưa khớp',
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.gapH24,

                  // 3. Thanh công cụ: Xoay, Tự động, Thêm mặt sau
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

                  AppSpacing.gapH14,

                  // 4. Nút hành động chính: Nhận dạng chữ (OCR)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _onRecognizeText(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueCardStart,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.r16,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.text_fields_rounded, size: 20),
                          AppSpacing.gapW10,
                          Text(
                            l10n?.recognizeText ?? 'Nhận dạng chữ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  AppSpacing.gapH16,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
