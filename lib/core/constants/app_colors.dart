import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Surfaces & Backgrounds
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFCBD5E1); // Tăng độ tương phản viền cho rõ nét
  static const Color divider = Color(0xFFE2E8F0);

  // Dark Theme Surfaces & Backgrounds
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF161F30);
  static const Color darkSurfaceMuted = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF26334D);

  // Text Colors (Light) - Đổi chữ xám sang đen nhẹ rõ nét (nhẹ hơn title)
  static const Color textPrimary = Color(0xFF0F172A); // Đen đậm tiêu đề chính
  static const Color textSecondary = Color(0xFF1E293B); // Đen nhẹ sắc nét (thay thế hoàn toàn màu xám)
  static const Color textTertiary = Color(0xFF334155); // Đen nhẹ phụ đề/thông tin phụ

  // Text Colors (Dark)
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFE2E8F0);
  static const Color darkTextTertiary = Color(0xFFCBD5E1);

  // Primary Action Card (Chụp ảnh)
  static const Color blueCardStart = Color(0xFF2563EB);
  static const Color blueCardEnd = Color(0xFF1D4ED8);
  static const Color blueCardArrow = Color(0xFF2563EB);

  // Secondary Action Card (Chọn từ thư viện)
  static const Color greenCardBg = Color(0xFFE8F7F0);
  static const Color greenCardText = Color(0xFF15803D);
  static const Color greenCardSubtext = Color(0xFF2D5A42); // Đen ánh xanh lá đậm rõ nét
  static const Color greenCardGrid = Color(0xFFA7E8C9);

  // Secondary Action Card (Dark Theme)
  static const Color darkGreenCardBg = Color(0xFF132B20);
  static const Color darkGreenCardText = Color(0xFF4ADE80);
  static const Color darkGreenCardSubtext = Color(0xFF86EFAC);
  static const Color darkGreenCardGrid = Color(0xFF1D4E37);

  // Business Card Illustration Colors
  static const Color cardIllustrationAccent = Color(0xFFF59E0B);
  static const Color cardIllustrationTextDark = Color(0xFF1E293B);
  static const Color cardIllustrationTextLight = Color(0xFFCBD5E1);

  // Brand Badge
  static const Color brandBadgeBg = Color(0xFF181C24);

  // Avatar Colors for Recent Cards
  static const Color avatarPurpleBg = Color(0xFFE0E7FF);
  static const Color avatarPurpleText = Color(0xFF4338CA);

  static const Color avatarAmberBg = Color(0xFFFEF3C7);
  static const Color avatarAmberText = Color(0xFFD97706);

  static const Color avatarTealBg = Color(0xFFCCFBF1);
  static const Color avatarTealText = Color(0xFF0F766E);

  // Link / Accent
  static const Color linkColor = Color(0xFF2563EB);

  // Trust Badge (Offline USP)
  static const Color trustBadgeIcon = Color(0xFF059669);
  static const Color trustBadgeText = Color(0xFF1E293B); // Đen nhẹ rõ nét
  static const Color darkTrustBadgeText = Color(0xFFE2E8F0);
}
