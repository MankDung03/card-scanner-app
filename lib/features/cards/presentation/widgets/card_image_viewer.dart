import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../scan/presentation/cubit/scan_state.dart';
import '../../../scan/presentation/widgets/side_segmented_control.dart';
import '../../domain/entities/saved_card.dart';
import '../cubit/saved_cards_cubit.dart';
import '../utils/card_share_service.dart';
import 'card_face_view.dart';

/// Xem ảnh danh thiếp toàn màn hình: phóng to/thu nhỏ, chạm đúp về kích thước gốc,
/// chuyển mặt trước/sau, xoay 90° và lưu ảnh vào thư viện ảnh.
class CardImageViewer extends StatefulWidget {
  final String cardId;
  final bool initialFront;

  const CardImageViewer({super.key, required this.cardId, this.initialFront = true});

  static void open(BuildContext context, {required SavedCard card, bool isFront = true}) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: AppColors.scanChrome,
        // Giữ SavedCardsCubit của màn gọi (route mới nằm ngoài cây widget hiện tại)
        pageBuilder: (_, __, ___) => BlocProvider.value(
          value: context.read<SavedCardsCubit>(),
          child: CardImageViewer(cardId: card.id, initialFront: isFront),
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<CardImageViewer> createState() => _CardImageViewerState();
}

class _CardImageViewerState extends State<CardImageViewer> {
  final _transform = TransformationController();
  late bool _front = widget.initialFront;
  int _quarterTurns = 0;
  bool _saving = false;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _resetZoom() => _transform.value = Matrix4.identity();

  void _switchSide(CardSide side) {
    setState(() {
      _front = side == CardSide.front;
      _quarterTurns = 0;
    });
    _resetZoom();
  }

  Future<void> _save(String path) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final result = await CardShareService.saveImageToGallery(path, quarterTurns: _quarterTurns);
    if (!mounted) return;
    setState(() => _saving = false);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: result == SaveImageResult.saved ? null : const Color(0xFFDC2626),
        content: Text(switch (result) {
          SaveImageResult.saved => l10n?.imageSaved ?? 'Đã lưu ảnh vào thư viện ảnh',
          SaveImageResult.permissionDenied => l10n?.galleryPermissionDenied ?? 'Chưa được cấp quyền lưu ảnh',
          SaveImageResult.failed => l10n?.imageSaveFailed ?? 'Không lưu được ảnh',
        }),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final card = context.select((SavedCardsCubit c) => c.state.findById(widget.cardId));
    if (card == null) return const SizedBox.shrink();

    final path = _front ? card.frontImagePath : card.backImagePath;
    final hasImage = path != null && File(path).existsSync();
    final muted = Colors.white.withValues(alpha: 0.7);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.scanChrome,
        body: SafeArea(
          child: Column(
            children: [
              // 1. Header: [× Đóng]  Tên người
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(foregroundColor: Colors.white),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          label: Text(
                            l10n?.closeAction ?? 'Đóng',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.5),
                      child: Text(
                        card.displayName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),

              // 2. Ảnh: pinch zoom, chạm đúp về gốc
              Expanded(
                child: GestureDetector(
                  onDoubleTap: _resetZoom,
                  child: InteractiveViewer(
                    transformationController: _transform,
                    minScale: 1,
                    maxScale: 5,
                    child: Center(
                      child: AnimatedRotation(
                        turns: _quarterTurns / 4,
                        duration: const Duration(milliseconds: 220),
                        child: hasImage
                            ? Image.file(File(path), fit: BoxFit.contain)
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                                child: CardFaceView(card: card, isFront: _front),
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Gợi ý thao tác
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.zoom_in_rounded, size: 16, color: muted),
                    AppSpacing.gapW6,
                    Flexible(
                      child: Text(
                        l10n?.zoomHint ?? 'Chụm 2 ngón để phóng to/thu nhỏ, chạm đúp để về kích thước gốc',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapH20,

              // 4. Mặt trước / mặt sau
              SideSegmentedControl(
                currentSide: _front ? CardSide.front : CardSide.back,
                frontLabel: l10n?.frontSide ?? 'Mặt trước',
                backLabel: l10n?.backSide ?? 'Mặt sau',
                onSideChanged: _switchSide,
              ),
              AppSpacing.gapH16,

              // 5. Xoay · Lưu ảnh
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s16),
                child: Row(
                  children: [
                    Expanded(
                      child: _DarkButton(
                        icon: Icons.rotate_right_rounded,
                        label: l10n?.rotate ?? 'Xoay',
                        onPressed: hasImage ? () => setState(() => _quarterTurns++) : null,
                      ),
                    ),
                    AppSpacing.gapW12,
                    Expanded(
                      child: _DarkButton(
                        icon: Icons.download_rounded,
                        label: l10n?.saveImage ?? 'Lưu ảnh',
                        busy: _saving,
                        onPressed: hasImage && !_saving ? () => _save(path) : null,
                      ),
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

class _DarkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  const _DarkButton({required this.icon, required this.label, this.onPressed, this.busy = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white38,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        icon: busy
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}
