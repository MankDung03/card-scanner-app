import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/circle_arrow_button.dart';
import '../../../../core/widgets/icon_badge.dart';
import 'business_card_illustration.dart';

class CameraActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const CameraActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title, $subtitle',
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          borderRadius: AppRadius.r24,
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.r24,
            splashColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            child: Stack(
              children: [
                // 1. Business Card Illustration in top-right background (Anti-aliased)
                const Positioned(
                  right: 20,
                  top: 20,
                  child: BusinessCardIllustration(),
                ),

                // 2. Foreground Content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Camera Badge
                      IconBadge(
                        icon: Icons.camera_alt_outlined,
                        iconColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.22),
                      ),

                      // Bottom Row: Clean Title (No L_ icon) & Arrow Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                AppSpacing.gapH4,
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const CircleArrowButton(
                            arrowColor: AppColors.blueCardArrow,
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
      ),
    );
  }
}
