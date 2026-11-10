import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../cubit/scan_state.dart';

class SideSegmentedControl extends StatelessWidget {
  final CardSide currentSide;
  final String frontLabel;
  final String backLabel;
  final ValueChanged<CardSide> onSideChanged;

  const SideSegmentedControl({
    super.key,
    required this.currentSide,
    required this.frontLabel,
    required this.backLabel,
    required this.onSideChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: AppRadius.r24,
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(
            label: frontLabel,
            isSelected: currentSide == CardSide.front,
            onTap: () => onSideChanged(CardSide.front),
          ),
          _buildSegment(
            label: backLabel,
            isSelected: currentSide == CardSide.back,
            onTap: () => onSideChanged(CardSide.back),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: AppRadius.r24,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}
