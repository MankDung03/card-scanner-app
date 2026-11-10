import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';

class CropBottomToolbar extends StatelessWidget {
  final String rotateLabel;
  final String autoLabel;
  final String addBackLabel;
  final VoidCallback onRotate;
  final VoidCallback onAuto;
  final VoidCallback onAddBack;

  const CropBottomToolbar({
    super.key,
    required this.rotateLabel,
    required this.autoLabel,
    required this.addBackLabel,
    required this.onRotate,
    required this.onAuto,
    required this.onAddBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildToolButton(
          icon: Icons.cached_rounded,
          label: rotateLabel,
          onTap: onRotate,
        ),
        AppSpacing.gapW10,
        _buildToolButton(
          icon: Icons.crop_rounded,
          label: autoLabel,
          onTap: onAuto,
        ),
        AppSpacing.gapW10,
        _buildToolButton(
          icon: Icons.add_rounded,
          label: addBackLabel,
          onTap: onAddBack,
        ),
      ],
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: AppRadius.r14,
          border: Border.all(color: const Color(0xFF334155), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.r14,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
