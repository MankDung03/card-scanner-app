import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';

/// Dải cảnh báo màu cam "Có N danh thiếp có thể bị trùng  [Xem lại]".
class DuplicateBanner extends StatelessWidget {
  final String text;
  final String actionLabel;
  final VoidCallback onTap;

  const DuplicateBanner({super.key, required this.text, required this.actionLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
    return Material(
      color: isDark ? const Color(0xFF2E2210) : const Color(0xFFFFF7ED),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF6B4A12) : const Color(0xFFFCD9A8))),
          ),
          padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.lg, AppSpacing.sm, AppSpacing.lg),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: fg),
              AppSpacing.gapW8,
              // Nội dung chiếm phần lớn, nút chữ tối đa ~1/3; chữ to thì "…" thay vì tràn
              Expanded(
                flex: 2,
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              AppSpacing.gapW8,
              Flexible(
                child: Text(
                  actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}
