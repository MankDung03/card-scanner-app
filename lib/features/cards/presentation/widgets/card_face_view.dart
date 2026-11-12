import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/saved_card.dart';

/// Tỉ lệ danh thiếp chuẩn 91 × 55 mm
const double kBusinessCardAspectRatio = 91 / 55;

/// Hiển thị một mặt danh thiếp:
/// - Có ảnh → ảnh thật (chạm để phóng to)
/// - Mặt trước không có ảnh → thẻ dựng lại từ dữ liệu
/// - Mặt sau không có ảnh → ô trống + nút thêm ảnh
class CardFaceView extends StatelessWidget {
  final SavedCard card;
  final bool isFront;
  final VoidCallback? onAddPhoto;

  const CardFaceView({
    super.key,
    required this.card,
    required this.isFront,
    this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final path = isFront ? card.frontImagePath : card.backImagePath;
    final file = path != null ? File(path) : null;
    final hasImage = file != null && file.existsSync();

    Widget child;
    if (hasImage) {
      child = GestureDetector(
        onTap: () => CardImageViewer.open(context, file),
        child: Hero(
          tag: file.path,
          child: Image.file(
            file,
            fit: BoxFit.cover,
            cacheWidth: 1200,
            errorBuilder: (_, __, ___) => _RenderedCard(card: card),
          ),
        ),
      );
    } else if (isFront) {
      child = _RenderedCard(card: card);
    } else {
      child = _EmptyFace(onAddPhoto: onAddPhoto);
    }

    return AspectRatio(
      aspectRatio: kBusinessCardAspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : const Color(0xFFFCFBF7),
          borderRadius: AppRadius.r12,
          border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

/// Danh thiếp dựng lại từ các trường đã lưu (dùng khi không có ảnh mặt trước).
class _RenderedCard extends StatelessWidget {
  final SavedCard card;

  const _RenderedCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkTextPrimary : const Color(0xFF111827);
    final muted = isDark ? AppColors.darkTextTertiary : const Color(0xFF4B5563);
    final role = [card.department, card.jobTitle].whereType<String>().join(' ');
    final contact = [
      if (card.phone != null) 'TEL ${card.phone}',
      if (card.mobile != null) 'MOBILE ${card.mobile}',
      if (card.fax != null) 'FAX ${card.fax}',
    ].join('   ');

    return LayoutBuilder(
      builder: (context, constraints) {
        // Co giãn chữ theo bề rộng thẻ
        final s = constraints.maxWidth / 320;
        return Padding(
          padding: EdgeInsets.fromLTRB(18 * s, 16 * s, 18 * s, 14 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (card.company != null)
                Row(
                  children: [
                    Container(
                      width: 14 * s,
                      height: 14 * s,
                      decoration: BoxDecoration(
                        color: AppColors.blueCardStart,
                        borderRadius: BorderRadius.circular(2 * s),
                      ),
                    ),
                    SizedBox(width: 6 * s),
                    Expanded(
                      child: Text(
                        card.company!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: ink, fontSize: 10.5 * s, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              const Spacer(flex: 3),
              if (role.isNotEmpty)
                Text(
                  role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: muted, fontSize: 9.5 * s),
                ),
              SizedBox(height: 2 * s),
              Text(
                card.name ?? card.displayName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ink,
                  fontSize: 24 * s,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5 * s,
                ),
              ),
              const Spacer(flex: 2),
              if (card.fullAddress != null)
                Text(
                  card.fullAddress!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: const Color(0xFFB91C1C), fontSize: 8.5 * s),
                ),
              if (contact.isNotEmpty) ...[
                SizedBox(height: 2 * s),
                Text(
                  contact,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: muted, fontSize: 8.5 * s),
                ),
              ],
              if (card.email != null) ...[
                SizedBox(height: 2 * s),
                Text(
                  card.email!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: muted, fontSize: 8.5 * s),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _EmptyFace extends StatelessWidget {
  final VoidCallback? onAddPhoto;

  const _EmptyFace({this.onAddPhoto});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flip_to_back_rounded, color: muted, size: 30),
          AppSpacing.gapH8,
          Text(
            l10n?.noImageForSide ?? 'Chưa có ảnh mặt này',
            style: TextStyle(color: muted, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          if (onAddPhoto != null) ...[
            AppSpacing.gapH10,
            OutlinedButton.icon(
              onPressed: onAddPhoto,
              icon: const Icon(Icons.add_a_photo_outlined, size: 16),
              label: Text(l10n?.addPhoto ?? 'Thêm ảnh'),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Xem ảnh thẻ toàn màn hình, có thể phóng to / kéo.
class CardImageViewer extends StatelessWidget {
  final File file;

  const CardImageViewer({super.key, required this.file});

  static void open(BuildContext context, File file) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => CardImageViewer(file: file),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              maxScale: 5,
              child: Center(
                child: Hero(tag: file.path, child: Image.file(file, fit: BoxFit.contain)),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
