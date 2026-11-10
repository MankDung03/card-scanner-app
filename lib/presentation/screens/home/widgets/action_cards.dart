import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CameraActionCard extends StatelessWidget {
  final VoidCallback onTap;

  const CameraActionCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.blueCardStart, AppColors.blueCardEnd],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueCardStart.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Business Card Illustration in background/top-right
              Positioned(
                right: 20,
                top: 20,
                child: Transform.rotate(
                  angle: 0.08,
                  child: Container(
                    width: 140,
                    height: 85,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Orange Accent Bar
                        Container(
                          width: 22,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Dark Name Line
                        Container(
                          width: 80,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Gray Detail Line
                        Container(
                          width: 60,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Gray Detail Line 2
                        Container(
                          width: 90,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Foreground Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Icon Badge
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    // Bottom Row: Text & Action Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Left: Titles
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Chụp ảnh',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(color: Colors.white.withValues(alpha: 0.9), width: 2),
                                      bottom: BorderSide(color: Colors.white.withValues(alpha: 0.9), width: 2),
                                    ),
                                  ),
                                  child: const SizedBox(width: 8, height: 8),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mở camera, tự căn khung thẻ',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        // Right: Circular Arrow Button
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.blueCardArrow,
                            size: 22,
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
      ),
    );
  }
}

class GalleryActionCard extends StatelessWidget {
  final VoidCallback onTap;

  const GalleryActionCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 105,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.greenCardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.greenCardGrid.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          children: [
            // Left Gallery Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.image_outlined,
                color: AppColors.greenCardText,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Middle Text
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chọn từ thư viện',
                    style: TextStyle(
                      color: AppColors.greenCardText,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Dùng ảnh danh thiếp có sẵn trong máy',
                    style: TextStyle(
                      color: AppColors.greenCardSubtext,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),

            // Right Grid Illustration (2x3 cells)
            SizedBox(
              width: 58,
              height: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGridCell(color: AppColors.greenCardGrid),
                      _buildGridCell(
                        color: Colors.white,
                        borderColor: AppColors.greenCardText,
                      ),
                      _buildGridCell(color: AppColors.greenCardGrid),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGridCell(color: AppColors.greenCardGrid),
                      _buildGridCell(color: AppColors.greenCardGrid),
                      _buildGridCell(color: AppColors.greenCardGrid),
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

  Widget _buildGridCell({required Color color, Color? borderColor}) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
      ),
    );
  }
}
