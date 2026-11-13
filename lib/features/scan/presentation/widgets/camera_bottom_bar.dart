import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';

/// Thanh điều khiển dưới: [写真] — nút chụp — [トリミング].
class CameraBottomBar extends StatelessWidget {
  final String galleryLabel;
  final String cropLabel;
  final String shutterLabel;
  final VoidCallback onShutter;
  final VoidCallback onGallery;
  final VoidCallback onCrop;
  final bool isProcessing;

  const CameraBottomBar({
    super.key,
    required this.galleryLabel,
    required this.cropLabel,
    required this.shutterLabel,
    required this.onShutter,
    required this.onGallery,
    required this.onCrop,
    this.isProcessing = false,
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
            _ShutterButton(label: shutterLabel, isProcessing: isProcessing, onTap: onShutter),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                heightFactor: 1,
                child: _SideButton(icon: Icons.crop_free_rounded, label: cropLabel, onTap: onCrop),
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
  final VoidCallback onTap;

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

  const _SideButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.r12,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: AppColors.scanControlBg, borderRadius: AppRadius.r12),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            AppSpacing.gapH6,
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
