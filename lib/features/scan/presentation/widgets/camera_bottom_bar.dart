import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../cubit/scan_state.dart';

class CameraBottomBar extends StatelessWidget {
  final CardSide currentSide;
  final String stepFrontLabel;
  final String stepBackLabel;
  final String galleryLabel;
  final String cropLabel;
  final VoidCallback onShutter;
  final VoidCallback onGallery;
  final VoidCallback onCrop;
  final bool isProcessing;

  const CameraBottomBar({
    super.key,
    required this.currentSide,
    required this.stepFrontLabel,
    required this.stepBackLabel,
    required this.galleryLabel,
    required this.cropLabel,
    required this.onShutter,
    required this.onGallery,
    required this.onCrop,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Step Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepDot(
              isActive: currentSide == CardSide.front,
              label: stepFrontLabel,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 24,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            _buildStepDot(
              isActive: currentSide == CardSide.back,
              label: stepBackLabel,
            ),
          ],
        ),

        AppSpacing.gapH20,

        // 2. Action Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Nút Thư viện
              _buildSideButton(
                icon: Icons.photo_library_outlined,
                label: galleryLabel,
                onTap: onGallery,
              ),

              // Nút Shutter chụp ảnh
              GestureDetector(
                onTap: isProcessing ? null : onShutter,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isProcessing ? Colors.white54 : Colors.white,
                      ),
                      child: isProcessing
                          ? const Center(
                              child: SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // Nút Cắt ảnh
              _buildSideButton(
                icon: Icons.crop_rounded,
                label: cropLabel,
                onTap: onCrop,
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildStepDot({required bool isActive, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : Colors.transparent,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
            fontSize: 12.5,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSideButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
