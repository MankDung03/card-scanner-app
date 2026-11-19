import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';

/// Thanh điều khiển dưới: [写真] — nút chụp — [自動撮影].
class CameraBottomBar extends StatelessWidget {
  final String galleryLabel;
  final String autoCaptureLabel;
  final String shutterLabel;
  final VoidCallback onShutter;
  final VoidCallback onGallery;
  final VoidCallback onAutoCapture;

  /// Tự động chụp đang bật (nút sáng màu)
  final bool autoCaptureOn;
  final bool isProcessing;

  /// false khi camera chưa sẵn sàng (chưa có quyền / lỗi): nút chụp mờ và không bấm được
  final bool shutterEnabled;

  const CameraBottomBar({
    super.key,
    required this.galleryLabel,
    required this.autoCaptureLabel,
    required this.shutterLabel,
    required this.onShutter,
    required this.onGallery,
    required this.onAutoCapture,
    this.autoCaptureOn = false,
    this.isProcessing = false,
    this.shutterEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSpacing.s20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
        child: Row(
          children: [
            Expanded(
              // heightFactor: 1 → Align chỉ cao bằng nút, không giãn hết màn hình
              // (nếu giãn, cả hàng nút bị kéo cao và trôi lên giữa màn hình)
              child: Align(
                alignment: Alignment.centerLeft,
                heightFactor: 1,
                child: _SideButton(icon: Icons.image_outlined, label: galleryLabel, onTap: onGallery),
              ),
            ),
            Opacity(
              opacity: shutterEnabled || isProcessing ? 1 : 0.35,
              child: _ShutterButton(
                label: shutterLabel,
                isProcessing: isProcessing,
                onTap: shutterEnabled ? onShutter : null,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                heightFactor: 1,
                child: _SideButton(
                  icon: Icons.motion_photos_auto_outlined,
                  label: autoCaptureLabel,
                  onTap: onAutoCapture,
                  active: autoCaptureOn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback? onTap;
  final String label;

  const _ShutterButton({required this.label, required this.isProcessing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: isProcessing ? null : onTap,
        child: Container(
          width: 76,
          height: 76,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 3),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isProcessing ? Colors.white54 : Colors.white,
            ),
            child: isProcessing
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.navy),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Đang bật (vd. tự động chụp): nền trắng, icon tối
  final bool active;

  const _SideButton({required this.icon, required this.label, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: active ? true : null,
      child: InkWell(
      onTap: onTap,
      borderRadius: AppRadius.r12,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: active ? Colors.white : AppColors.scanControlBg,
                borderRadius: AppRadius.r12,
              ),
              child: Icon(icon, color: active ? AppColors.navy : Colors.white, size: 22),
            ),
            AppSpacing.gapH6,
            // Nhãn dài ("Tự động chụp") / chữ to → xuống tối đa 2 dòng thay vì tràn ngang
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
