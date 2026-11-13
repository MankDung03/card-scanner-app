import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';

/// Menu dưới 3 tab: Trang chủ · [Danh thiếp] (nút tròn navy nổi giữa) · Cài đặt.
///
/// Phần nút tròn nhô lên được tính vào chiều cao widget ([bumpHeight]) và tô màu nền trang,
/// nên nội dung phía trên không bao giờ bị nút tròn che.
class AppBottomNav extends StatelessWidget {
  /// Tab đang chọn: 0 Home, 1 Danh thiếp, 2 Cài đặt; -1 = không tab nào (vd. đang trong luồng quét).
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.selectedIndex, required this.onTap});

  static const double barHeight = 62;
  static const double bumpHeight = 22;
  static const double centerSize = 60;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final pageColor = Theme.of(context).scaffoldBackgroundColor;
    final border = isDark ? AppColors.darkBorder : AppColors.divider;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: bumpHeight + barHeight + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dải trên cùng mang màu nền trang để chỗ nút tròn nhô lên liền mạch với nội dung
          Positioned(left: 0, right: 0, top: 0, height: bumpHeight, child: ColoredBox(color: pageColor)),
          // Thanh menu
          Positioned(
            left: 0,
            right: 0,
            top: bumpHeight,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(color: barColor, border: Border(top: BorderSide(color: border))),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Row(
                  children: [
                    Expanded(
                      child: _NavItem(
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home_rounded,
                        label: l10n?.homeAction ?? 'Trang chủ',
                        selected: selectedIndex == 0,
                        onTap: () => onTap(0),
                      ),
                    ),
                    Expanded(
                      child: _CenterLabel(
                        label: l10n?.navCards ?? 'Danh thiếp',
                        selected: selectedIndex == 1,
                        onTap: () => onTap(1),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.settings_outlined,
                        selectedIcon: Icons.settings_rounded,
                        label: l10n?.settingsPageTitle ?? 'Cài đặt',
                        selected: selectedIndex == 2,
                        onTap: () => onTap(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Nút tròn navy nổi giữa (tab Danh thiếp)
          Positioned(
            top: bumpHeight - centerSize / 2 + 8,
            left: 0,
            right: 0,
            child: Center(
              child: Semantics(
                button: true,
                selected: selectedIndex == 1,
                label: l10n?.navCards ?? 'Danh thiếp',
                excludeSemantics: true,
                child: Material(
                  color: isDark ? AppColors.darkNavy : AppColors.navy,
                  shape: CircleBorder(side: BorderSide(color: barColor, width: 4)),
                  elevation: 3,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onTap(1),
                    child: const SizedBox.square(
                      dimension: centerSize,
                      child: Icon(Icons.contact_page_outlined, color: Colors.white, size: 27),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? (isDark ? const Color(0xFF93B4E0) : AppColors.navy)
        : (isDark ? AppColors.darkTextMuted : AppColors.textMuted);

    return Semantics(
      button: true,
      selected: selected,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nhãn dưới nút tròn giữa (phần nút nằm ở lớp trên trong [AppBottomNav]).
class _CenterLabel extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CenterLabel({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? (isDark ? const Color(0xFF93B4E0) : AppColors.navy)
        : (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
