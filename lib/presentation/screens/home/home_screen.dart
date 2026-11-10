import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/recent_card.dart';
import 'widgets/action_cards.dart';
import 'widgets/recent_card_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<RecentCard> _recentCards = RecentCard.sampleData;

  void _onCaptureCard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng Chụp ảnh sẽ được kích hoạt ở bước tiếp theo'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onPickFromGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng Chọn từ thư viện sẽ được kích hoạt ở bước tiếp theo'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onViewAllCards() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Xem toàn bộ danh sách danh thiếp'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cài đặt ứng dụng (Ngôn ngữ JA/EN/VI, Backup, OCR)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Brand (Icon badge + Name)
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.brandBadgeBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            '名',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Scan Danh Thiếp',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  // Settings / Filters Button
                  InkWell(
                    onTap: _openSettings,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 2. Title & Subtitle
              const Text(
                'Thêm danh thiếp',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Chọn cách lấy ảnh danh thiếp của bạn',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),

              // 3. Action 1: Blue Card (Chụp ảnh)
              CameraActionCard(
                onTap: _onCaptureCard,
              ),

              const SizedBox(height: 14),

              // 4. Action 2: Green Card (Chọn từ thư viện)
              GalleryActionCard(
                onTap: _onPickFromGallery,
              ),

              const SizedBox(height: 28),

              // 5. Section "Đã lưu gần đây"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Đã lưu gần đây',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: _onViewAllCards,
                    child: const Text(
                      'Xem tất cả (24)',
                      style: TextStyle(
                        color: AppColors.linkColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 6. Recent cards list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentCards.length,
                itemBuilder: (context, index) {
                  final card = _recentCards[index];
                  return RecentCardTile(
                    card: card,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Xem chi tiết: ${card.name}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 28),

              // 7. Trust Badge Footer (100% On-device USP)
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.trustBadgeIcon,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Xử lý ngay trên máy · không cần mạng',
                      style: TextStyle(
                        color: AppColors.trustBadgeText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
