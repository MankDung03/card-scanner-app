import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Header navy kiểu Nhật tràn cả vùng status bar, cao cố định 56 (nút chụp nổi dựa vào
/// chiều cao này để không đè header).
///
/// Bố cục bằng [NavigationToolbar] (như AppBar): tiêu đề luôn ở giữa và chỉ dùng phần còn lại
/// sau [leading]/[trailing]. Mỗi bên tối đa 35% chiều ngang. Chữ to (cỡ chữ hệ thống lớn,
/// tiếng Việt dài…) thì nút và tiêu đề tự thu nhỏ cho vừa thay vì tràn khung.
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                Widget? side(Widget? child) => child == null
                    ? null
                    : ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.35),
                        child: FittedBox(fit: BoxFit.scaleDown, child: child),
                      );

                return NavigationToolbar(
                  leading: side(leading),
                  trailing: side(trailing),
                  middleSpacing: AppSpacing.md,
                  middle: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
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
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
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
