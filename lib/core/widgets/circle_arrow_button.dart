import 'package:flutter/material.dart';

class CircleArrowButton extends StatelessWidget {
  final Color backgroundColor;
  final Color arrowColor;
  final double size;
  final double iconSize;

  const CircleArrowButton({
    super.key,
    this.backgroundColor = Colors.white,
    required this.arrowColor,
    this.size = 44.0,
    this.iconSize = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.arrow_forward_rounded,
          color: arrowColor,
          size: iconSize,
        ),
      ),
    );
  }
}
