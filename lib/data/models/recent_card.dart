import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RecentCard {
  final String id;
  final String name;
  final String company;
  final String timeAgo;
  final String avatarChar;
  final Color avatarBgColor;
  final Color avatarTextColor;

  const RecentCard({
    required this.id,
    required this.name,
    required this.company,
    required this.timeAgo,
    required this.avatarChar,
    required this.avatarBgColor,
    required this.avatarTextColor,
  });

  static List<RecentCard> get sampleData => [
        const RecentCard(
          id: '1',
          name: '山田 太郎',
          company: '株式会社サンプル商事',
          timeAgo: 'Hôm nay',
          avatarChar: '山',
          avatarBgColor: AppColors.avatarPurpleBg,
          avatarTextColor: AppColors.avatarPurpleText,
        ),
        const RecentCard(
          id: '2',
          name: 'Nguyễn Minh Anh',
          company: 'Công ty TNHH ABC Việt Nam',
          timeAgo: '08/11',
          avatarChar: 'A',
          avatarBgColor: AppColors.avatarAmberBg,
          avatarTextColor: AppColors.avatarAmberText,
        ),
      ];
}
