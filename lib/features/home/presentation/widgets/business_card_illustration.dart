import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';

class BusinessCardIllustration extends StatefulWidget {
  const BusinessCardIllustration({super.key});

  @override
  State<BusinessCardIllustration> createState() => _BusinessCardIllustrationState();
}

class _BusinessCardIllustrationState extends State<BusinessCardIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _shadowBlurAnimation;
  late final Animation<double> _shadowOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat(reverse: true);

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Subtle floating up/down movement (-4px to +4px)
    _floatAnimation = Tween<double>(begin: -5.0, end: 3.0).animate(curved);
    // Shadow expands when card floats higher
    _shadowBlurAnimation = Tween<double>(begin: 18.0, end: 10.0).animate(curved);
    _shadowOpacityAnimation = Tween<double>(begin: 0.20, end: 0.12).animate(curved);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.rotate(
            angle: 0.08,
            filterQuality: FilterQuality.medium,
            child: Container(
              width: 142,
              height: 86,
              decoration: BoxDecoration(
                borderRadius: AppRadius.r10,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _shadowOpacityAnimation.value),
                    blurRadius: _shadowBlurAnimation.value,
                    offset: Offset(2, 6 - _floatAnimation.value * 0.4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: AppRadius.r10,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Accent Bar (Orange)
                      Container(
                        width: 22,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.cardIllustrationAccent,
                          borderRadius: AppRadius.r4,
                        ),
                      ),
                      AppSpacing.gapH10,
                      // Name Line (Dark Slate)
                      Container(
                        width: 80,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.cardIllustrationTextDark,
                          borderRadius: AppRadius.r4,
                        ),
                      ),
                      AppSpacing.gapH6,
                      // Detail Line 1 (Light Gray)
                      Container(
                        width: 60,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.cardIllustrationTextLight,
                          borderRadius: AppRadius.r4,
                        ),
                      ),
                      AppSpacing.gapH4,
                      // Detail Line 2 (Light Gray)
                      Container(
                        width: 90,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.cardIllustrationTextLight,
                          borderRadius: AppRadius.r4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
