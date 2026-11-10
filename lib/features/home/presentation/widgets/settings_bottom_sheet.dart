import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/cubits/app_locale_cubit.dart';
import '../../../../core/cubits/app_theme_cubit.dart';
import '../../../../l10n/app_localizations.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final itemBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle bar
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: textTertiary.withValues(alpha: 0.35),
                  borderRadius: AppRadius.r4,
                ),
              ),
            ),
            AppSpacing.gapH16,

            // Header: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.blueCardStart.withValues(alpha: 0.12),
                        borderRadius: AppRadius.r12,
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.blueCardStart,
                        size: 22,
                      ),
                    ),
                    AppSpacing.gapW12,
                    Text(
                      l10n?.settingsTitle ?? 'Cài đặt & Tùy chọn',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: AppRadius.r24,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: itemBorder, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.close_rounded, color: textSecondary, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.gapH24,

            // Section 1: Giao diện (Theme Mode)
            Row(
              children: [
                Container(
                  width: 3.5,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.blueCardStart,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                AppSpacing.gapW8,
                Text(
                  (l10n?.themeTitle ?? 'GIAO DIỆN').toUpperCase(),
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            AppSpacing.gapH12,

            BlocBuilder<AppThemeCubit, ThemeMode>(
              builder: (context, currentMode) {
                return Row(
                  children: [
                    _buildThemeCard(
                      context,
                      label: l10n?.themeLight ?? 'Sáng',
                      icon: Icons.light_mode_rounded,
                      isSelected: currentMode == ThemeMode.light,
                      itemBg: cardBg,
                      borderColor: itemBorder,
                      onTap: () => context.read<AppThemeCubit>().setThemeMode(ThemeMode.light),
                    ),
                    AppSpacing.gapW10,
                    _buildThemeCard(
                      context,
                      label: l10n?.themeDark ?? 'Tối',
                      icon: Icons.dark_mode_rounded,
                      isSelected: currentMode == ThemeMode.dark,
                      itemBg: cardBg,
                      borderColor: itemBorder,
                      onTap: () => context.read<AppThemeCubit>().setThemeMode(ThemeMode.dark),
                    ),
                    AppSpacing.gapW10,
                    _buildThemeCard(
                      context,
                      label: l10n?.themeSystem ?? 'Hệ thống',
                      icon: Icons.settings_brightness_rounded,
                      isSelected: currentMode == ThemeMode.system,
                      itemBg: cardBg,
                      borderColor: itemBorder,
                      onTap: () => context.read<AppThemeCubit>().setThemeMode(ThemeMode.system),
                    ),
                  ],
                );
              },
            ),

            AppSpacing.gapH24,

            // Section 2: Ngôn ngữ (Language)
            Row(
              children: [
                Container(
                  width: 3.5,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.blueCardStart,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                AppSpacing.gapW8,
                Text(
                  (l10n?.languageTitle ?? 'NGÔN NGỮ').toUpperCase(),
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            AppSpacing.gapH12,

            BlocBuilder<AppLocaleCubit, Locale?>(
              builder: (context, currentLocale) {
                final localeCode = currentLocale?.languageCode ?? Localizations.localeOf(context).languageCode;

                return Column(
                  children: [
                    _buildLanguageCard(
                      context,
                      label: l10n?.langVi ?? 'Tiếng Việt 🇻🇳',
                      sublabel: 'Tiếng Việt',
                      isSelected: localeCode == 'vi',
                      itemBg: cardBg,
                      borderColor: itemBorder,
                      onTap: () => context.read<AppLocaleCubit>().setLocale(const Locale('vi')),
                    ),
                    AppSpacing.gapH10,
                    _buildLanguageCard(
                      context,
                      label: l10n?.langJa ?? '日本語 🇯🇵',
                      sublabel: 'Japanese',
                      isSelected: localeCode == 'ja',
                      itemBg: cardBg,
                      borderColor: itemBorder,
                      onTap: () => context.read<AppLocaleCubit>().setLocale(const Locale('ja')),
                    ),
                    AppSpacing.gapH10,
                    _buildLanguageCard(
                      context,
                      label: l10n?.langEn ?? 'English 🇬🇧',
                      sublabel: 'English',
                      isSelected: localeCode == 'en',
                      itemBg: cardBg,
                      borderColor: itemBorder,
                      onTap: () => context.read<AppLocaleCubit>().setLocale(const Locale('en')),
                    ),
                  ],
                );
              },
            ),
            AppSpacing.gapH16,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color itemBg,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.blueCardStart, AppColors.blueCardEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : itemBg,
          borderRadius: AppRadius.r16,
          border: Border.all(
            color: isSelected ? AppColors.blueCardEnd : borderColor,
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.blueCardStart.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.r16,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.22)
                          : (isDark ? AppColors.darkSurfaceMuted : const Color(0xFFF1F5F9)),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 20,
                        color: isSelected ? Colors.white : textSecondary,
                      ),
                    ),
                  ),
                  AppSpacing.gapH10,
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: isSelected ? Colors.white : textSecondary,
                      letterSpacing: -0.2,
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

  Widget _buildLanguageCard(
    BuildContext context, {
    required String label,
    required String sublabel,
    required bool isSelected,
    required Color itemBg,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? const Color(0xFF1E2E4A) : const Color(0xFFF0F6FF))
            : itemBg,
        borderRadius: AppRadius.r18,
        border: Border.all(
          color: isSelected ? AppColors.blueCardStart : borderColor,
          width: isSelected ? 2.0 : 1.2,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppColors.blueCardStart.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.r18,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s18, vertical: AppSpacing.s16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.blueCardStart.withValues(alpha: 0.14)
                            : (isDark ? AppColors.darkSurfaceMuted : const Color(0xFFF1F5F9)),
                        borderRadius: AppRadius.r12,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.language_rounded,
                          color: isSelected ? AppColors.blueCardStart : textSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                    AppSpacing.gapW14,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? AppColors.blueCardStart : textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          sublabel,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppColors.blueCardStart.withValues(alpha: 0.85) : textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.blueCardStart : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.blueCardStart : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
