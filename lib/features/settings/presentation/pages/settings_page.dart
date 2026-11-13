import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/cubits/app_locale_cubit.dart';
import '../../../../core/cubits/app_theme_cubit.dart';
import '../../../../core/cubits/ocr_language_cubit.dart';
import '../../../../core/widgets/capture_fab/capture_fab_cubit.dart';
import '../../../../core/widgets/navy_header_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cards/presentation/cubit/saved_cards_cubit.dart';
import '../../../cards/presentation/widgets/csv_export_dialog.dart';
import '../../../scan/domain/entities/ocr_language_mode.dart';

/// Màn Cài đặt: quyền riêng tư & dữ liệu, ngôn ngữ, thông tin khác.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _danger = Color(0xFFDC2626);

  void _comingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(l10n?.featureComingSoon ?? 'Chức năng sẽ được kích hoạt ở bước tiếp theo'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
  }

  Future<void> _confirmDeleteAll(BuildContext context, int count) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SavedCardsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.r16),
        title: Text(l10n?.deleteAllConfirmTitle ?? 'Xoá toàn bộ danh thiếp?'),
        content: Text(
          l10n?.deleteAllConfirmBody(count) ??
              '$count danh thiếp và ảnh sẽ bị xoá vĩnh viễn khỏi máy này. Không thể hoàn tác.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n?.cancel ?? 'Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: _danger, foregroundColor: Colors.white),
            child: Text(l10n?.delete ?? 'Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await cubit.deleteAll();
    messenger.showSnackBar(SnackBar(
      content: Text(ok
          ? (l10n?.deleteAllDone ?? 'Đã xoá toàn bộ dữ liệu')
          : (l10n?.deleteAllFailed ?? 'Có danh thiếp chưa xoá được, vui lòng thử lại')),
      backgroundColor: ok ? null : _danger,
      behavior: SnackBarBehavior.floating,
    ));
  }

  static String _languageName(AppLocalizations? l10n, Locale? locale) => switch (locale?.languageCode) {
        'ja' => '日本語',
        'en' => 'English',
        'vi' => 'Tiếng Việt',
        _ => l10n?.systemDefault ?? 'Theo máy',
      };

  static String _themeName(AppLocalizations? l10n, ThemeMode mode) => switch (mode) {
        ThemeMode.light => l10n?.themeLight ?? 'Sáng',
        ThemeMode.dark => l10n?.themeDark ?? 'Tối',
        ThemeMode.system => l10n?.themeSystem ?? 'Theo máy',
      };

  Future<void> _pickLanguage(BuildContext context, Locale? current) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AppLocaleCubit>();
    final options = <Locale?>[null, const Locale('ja'), const Locale('en'), const Locale('vi')];
    final picked = await _OptionSheet.show<Locale?>(
      context,
      title: l10n?.displayLanguage ?? 'Ngôn ngữ hiển thị',
      options: [for (final o in options) (o, _languageName(l10n, o))],
      selected: current,
      equals: (a, b) => a?.languageCode == b?.languageCode,
    );
    if (picked != null) await cubit.setLocale(picked.$1);
  }

  Future<void> _pickTheme(BuildContext context, ThemeMode current) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AppThemeCubit>();
    final picked = await _OptionSheet.show<ThemeMode>(
      context,
      title: l10n?.themeTitle ?? 'Giao diện',
      options: [for (final m in [ThemeMode.system, ThemeMode.light, ThemeMode.dark]) (m, _themeName(l10n, m))],
      selected: current,
    );
    if (picked != null) await cubit.setThemeMode(picked.$1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cardCount = context.select((SavedCardsCubit c) => c.state.cards.length);
    final locale = context.watch<AppLocaleCubit>().state;
    final themeMode = context.watch<AppThemeCubit>().state;
    final ocrMode = context.watch<OcrLanguageCubit>().state;
    final fabVisible = context.select((CaptureFabCubit c) => c.state.visible);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            // Tab gốc của menu dưới → không có nút back
            NavyHeaderBar(title: l10n?.settingsPageTitle ?? 'Cài đặt'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s20,
                  AppSpacing.s16,
                  AppSpacing.s24 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  // ── Quyền riêng tư & dữ liệu ──
                  _SectionLabel(l10n?.sectionPrivacyData ?? 'Quyền riêng tư & dữ liệu'),
                  _LocalOnlyBanner(
                    title: l10n?.localOnlyTitle ?? 'Chỉ lưu trên máy · Không cần tài khoản',
                    body: l10n?.localOnlyBody ?? 'Dữ liệu danh thiếp không được gửi lên máy chủ',
                  ),
                  AppSpacing.gapH10,
                  _Group(
                    children: [
                      _SettingRow(
                        icon: Icons.download_outlined,
                        title: l10n?.backupTitle ?? 'Sao lưu',
                        subtitle: l10n?.backupDesc,
                        comingSoon: true,
                        onTap: () => _comingSoon(context),
                      ),
                      _SettingRow(
                        icon: Icons.upload_outlined,
                        title: l10n?.restoreTitle ?? 'Khôi phục từ bản sao lưu',
                        subtitle: l10n?.restoreDesc,
                        comingSoon: true,
                        onTap: () => _comingSoon(context),
                      ),
                      _SettingRow(
                        icon: Icons.table_chart_outlined,
                        title: l10n?.csvBulkTitle ?? 'Xuất CSV toàn bộ',
                        subtitle: l10n?.cardsCountLong(cardCount) ?? '$cardCount danh thiếp',
                        onTap: cardCount == 0
                            ? null
                            : () => CsvExportDialog.show(context, context.read<SavedCardsCubit>().state.cards),
                      ),
                      _SettingRow(
                        icon: Icons.content_copy_outlined,
                        title: l10n?.duplicateCheckTitle ?? 'Kiểm tra trùng khi lưu',
                        subtitle: l10n?.duplicateCheckDesc,
                        comingSoon: true,
                        trailing: const Checkbox(value: false, onChanged: null),
                        onTap: () => _comingSoon(context),
                      ),
                    ],
                  ),
                  AppSpacing.gapH10,
                  _DangerRow(
                    title: l10n?.deleteAllTitle ?? 'Xoá toàn bộ dữ liệu',
                    subtitle: l10n?.deleteAllDesc ?? 'Sẽ hỏi xác nhận trước khi xoá',
                    onTap: cardCount == 0 ? null : () => _confirmDeleteAll(context, cardCount),
                  ),
                  AppSpacing.gapH24,

                  // ── Ngôn ngữ ──
                  _SectionLabel(l10n?.languageTitle ?? 'Ngôn ngữ'),
                  _Group(
                    children: [
                      _SettingRow(
                        title: l10n?.displayLanguage ?? 'Ngôn ngữ hiển thị',
                        value: _languageName(l10n, locale),
                        onTap: () => _pickLanguage(context, locale),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.xl, AppSpacing.s16, AppSpacing.s16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _RowTitle(l10n?.ocrLanguageTitle ?? 'Ngôn ngữ ưu tiên khi đọc chữ'),
                            AppSpacing.gapH10,
                            _OcrLanguageSegment(
                              current: ocrMode,
                              labels: {
                                OcrLanguageMode.auto: l10n?.ocrLangAuto ?? 'Tự động',
                                OcrLanguageMode.japanese: l10n?.ocrLangJa ?? '日本語',
                                OcrLanguageMode.vietnamese: l10n?.ocrLangLatin ?? 'English・Việt',
                              },
                              onChanged: context.read<OcrLanguageCubit>().setMode,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapH24,

                  // ── Hiển thị: nút chụp nổi ──
                  _SectionLabel(l10n?.sectionDisplay ?? 'Hiển thị'),
                  _Group(
                    children: [
                      _SettingRow(
                        icon: Icons.photo_camera_outlined,
                        title: l10n?.showCaptureFab ?? 'Hiện nút chụp nổi',
                        subtitle: l10n?.showCaptureFabDesc,
                        trailing: Switch(
                          value: fabVisible,
                          onChanged: context.read<CaptureFabCubit>().setVisible,
                        ),
                        onTap: () => context.read<CaptureFabCubit>().setVisible(!fabVisible),
                      ),
                      _SettingRow(
                        icon: Icons.restart_alt_rounded,
                        title: l10n?.resetFabPosition ?? 'Đặt lại vị trí nút',
                        showChevron: false,
                        onTap: fabVisible
                            ? () {
                                context.read<CaptureFabCubit>().resetPosition();
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(SnackBar(
                                    content: Text(l10n?.fabPositionReset ?? 'Đã đặt lại vị trí'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ));
                              }
                            : null,
                      ),
                    ],
                  ),
                  AppSpacing.gapH24,

                  // ── Khác ──
                  _SectionLabel(l10n?.sectionOther ?? 'Khác'),
                  _Group(
                    children: [
                      _SettingRow(
                        title: l10n?.themeTitle ?? 'Giao diện',
                        value: _themeName(l10n, themeMode),
                        onTap: () => _pickTheme(context, themeMode),
                      ),
                      _SettingRow(
                        title: l10n?.privacyPolicy ?? 'Chính sách bảo mật',
                        comingSoon: true,
                        onTap: () => _comingSoon(context),
                      ),
                      _SettingRow(
                        title: l10n?.rateApp ?? 'Đánh giá ứng dụng',
                        comingSoon: true,
                        onTap: () => _comingSoon(context),
                      ),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snap) => _SettingRow(
                          title: l10n?.versionLabel ?? 'Phiên bản',
                          value: snap.data?.version ?? '',
                          showChevron: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Widgets ─────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: AppSpacing.md),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _RowTitle extends StatelessWidget {
  final String text;

  const _RowTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Banner xanh lá: "Chỉ lưu trên máy · Không cần tài khoản".
class _LocalOnlyBanner extends StatelessWidget {
  final String title;
  final String body;

  const _LocalOnlyBanner({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF1F7A4D);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12291F) : const Color(0xFFE8F5EE),
        borderRadius: AppRadius.r10,
        border: Border.all(color: isDark ? const Color(0xFF1F4D38) : const Color(0xFFBFE3CF)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: fg, size: 22),
          AppSpacing.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: fg, fontSize: 13.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(body, style: TextStyle(color: fg, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Khối trắng viền mảnh, kẻ dòng giữa các hàng.
class _Group extends StatelessWidget {
  final List<Widget> children;

  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.divider;
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.r10, side: BorderSide(color: border)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, indent: AppSpacing.s16, endIndent: AppSpacing.s16, color: border),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Một hàng cài đặt: [icon] tiêu đề (+ mô tả) … [giá trị] [trailing | chevron].
class _SettingRow extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final bool showChevron;
  final bool comingSoon;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.title,
    this.icon,
    this.subtitle,
    this.value,
    this.trailing,
    this.showChevron = true,
    this.comingSoon = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.xl, AppSpacing.md, AppSpacing.xl),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 21, color: isDark ? AppColors.darkTextSecondary : AppColors.navy),
                AppSpacing.gapW14,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(title, style: TextStyle(color: textPrimary, fontSize: 14.5, fontWeight: FontWeight.w500)),
                        if (comingSoon) _SoonTag(l10n?.comingSoonTag ?? 'Sắp có'),
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: TextStyle(color: muted, fontSize: 12, height: 1.4)),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                AppSpacing.gapW8,
                Text(value!, style: TextStyle(color: muted, fontSize: 13.5)),
              ],
              if (trailing != null)
                trailing!
              else if (showChevron)
                Icon(Icons.chevron_right_rounded, color: muted, size: 20)
              else
                AppSpacing.gapW8,
            ],
          ),
        ),
      ),
    );
  }
}

class _SoonTag extends StatelessWidget {
  final String text;

  const _SoonTag(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
        borderRadius: AppRadius.r4,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Hàng "Xoá toàn bộ dữ liệu": khối riêng viền đỏ.
class _DangerRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _DangerRow({required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final red = isDark ? const Color(0xFFF87171) : SettingsPage._danger;
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Material(
        color: isDark ? const Color(0xFF2A1416) : const Color(0xFFFEF2F2),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r10,
          side: BorderSide(color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded, color: red, size: 21),
                AppSpacing.gapW14,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: red, fontSize: 14.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút gạt 3 lựa chọn ngôn ngữ OCR, chia đều chiều ngang.
class _OcrLanguageSegment extends StatelessWidget {
  final OcrLanguageMode current;
  final Map<OcrLanguageMode, String> labels;
  final ValueChanged<OcrLanguageMode> onChanged;

  const _OcrLanguageSegment({required this.current, required this.labels, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : AppColors.divider,
        borderRadius: AppRadius.r10,
      ),
      child: Row(
        children: [
          for (final entry in labels.entries)
            Expanded(
              child: Semantics(
                button: true,
                selected: entry.key == current,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 36,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: entry.key == current
                          ? (isDark ? AppColors.darkSurface : Colors.white)
                          : Colors.transparent,
                      borderRadius: AppRadius.r8,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: entry.key == current ? FontWeight.w700 : FontWeight.w500,
                          color: entry.key == current
                              ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                              : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                        ),
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

/// Bảng chọn một giá trị (ngôn ngữ / giao diện). Trả về `(giá trị,)` hoặc null nếu đóng.
class _OptionSheet {
  static Future<(T,)?> show<T>(
    BuildContext context, {
    required String title,
    required List<(T, String)> options,
    required T selected,
    bool Function(T a, T b)? equals,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final same = equals ?? (a, b) => a == b;
    return showModalBottomSheet<(T,)>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.md),
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            for (final (value, label) in options)
              ListTile(
                title: Text(label),
                trailing: same(value, selected)
                    ? Icon(Icons.check_rounded, color: isDark ? const Color(0xFF93B4E0) : AppColors.navy)
                    : null,
                onTap: () => Navigator.pop(ctx, (value,)),
              ),
            AppSpacing.gapH8,
          ],
        ),
      ),
    );
  }
}
