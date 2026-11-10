import 'package:flutter/material.dart';
import '../constants/app_radius.dart';

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const IconBadge({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.iconSize = 24.0,
    this.padding = const EdgeInsets.all(10.0),
    this.borderRadius = AppRadius.r14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: iconSize,
      ),
    );
  }
}
