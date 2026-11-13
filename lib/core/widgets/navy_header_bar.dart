import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Header navy kiểu Nhật tràn cả vùng status bar.
/// [leading] và [trailing] chiếm 2 cột bằng nhau để tiêu đề luôn nằm giữa.
class NavyHeaderBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  const NavyHeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkNavy : AppColors.navy,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(child: Align(alignment: Alignment.centerLeft, child: leading)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                Expanded(child: Align(alignment: Alignment.centerRight, child: trailing)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút chữ trắng trên header navy (vd. "< 戻る", "写真を変更").
class NavyHeaderTextButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const NavyHeaderTextButton({super.key, required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    final style = TextButton.styleFrom(
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
    );
    final text = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    return icon == null
        ? TextButton(onPressed: onPressed, style: style, child: text)
        : TextButton.icon(onPressed: onPressed, style: style, icon: Icon(icon, size: 18), label: text);
  }
}
