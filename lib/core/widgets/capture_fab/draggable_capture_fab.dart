import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import 'capture_fab_cubit.dart';
import 'capture_fab_geometry.dart';

/// Nút chụp nổi: kéo thả tự do, thả tay thì hút vào mép trái/phải gần nhất.
/// Bấm nhẹ (không kéo) → [onTap]. Nhấn giữ → menu "Ẩn nút này".
///
/// Đặt widget này phủ kín vùng nội dung (vd. `Positioned.fill` trong Stack). Vùng trống
/// không nhận chạm nên không chặn thao tác với trang bên dưới.
class DraggableCaptureFab extends StatefulWidget {
  final VoidCallback onTap;

  /// Khoảng chừa phía trên (header của trang) mà nút không được đè lên.
  final double topInset;

  const DraggableCaptureFab({super.key, required this.onTap, required this.topInset});

  static const double buttonSize = 56;
  static const Size hitSize = Size(64, 80); // nút + nhãn "撮影"
  static const double edgeMargin = 12;
  static const double verticalMargin = 8;

  @override
  State<DraggableCaptureFab> createState() => _DraggableCaptureFabState();
}

class _DraggableCaptureFabState extends State<DraggableCaptureFab> with SingleTickerProviderStateMixin {
  late final AnimationController _snap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  Animation<Offset>? _snapAnimation;

  /// Vị trí khi đang kéo; null = lấy từ vị trí đã lưu.
  Offset? _drag;

  @override
  void dispose() {
    _snap.dispose();
    super.dispose();
  }

  FabGeometry _geometry(BoxConstraints c) => FabGeometry(
        bounds: Rect.fromLTRB(
          DraggableCaptureFab.edgeMargin,
          widget.topInset + DraggableCaptureFab.verticalMargin,
          c.maxWidth - DraggableCaptureFab.edgeMargin,
          c.maxHeight - DraggableCaptureFab.verticalMargin,
        ),
        size: DraggableCaptureFab.hitSize,
      );

  Offset _currentOffset(FabGeometry geo, FabAnchor anchor) {
    if (_drag != null) return _drag!;
    if (_snap.isAnimating && _snapAnimation != null) return _snapAnimation!.value;
    return geo.offsetOf(anchor);
  }

  void _onPanStart(FabGeometry geo, FabAnchor anchor) {
    final start = _currentOffset(geo, anchor);
    _snap.stop();
    setState(() => _drag = start);
  }

  void _onPanUpdate(FabGeometry geo, DragUpdateDetails d) {
    setState(() => _drag = geo.clamp(_drag! + d.delta));
  }

  void _onPanEnd(FabGeometry geo, DragEndDetails d) {
    final from = _drag!;
    final anchor = geo.snap(from, velocity: d.velocity.pixelsPerSecond);
    _snapAnimation = Tween(begin: from, end: geo.offsetOf(anchor))
        .animate(CurvedAnimation(parent: _snap, curve: Curves.easeOutBack));
    setState(() => _drag = null);
    _snap.forward(from: 0).whenComplete(() => HapticFeedback.lightImpact());
    context.read<CaptureFabCubit>().setAnchor(anchor);
  }

  Future<void> _onLongPress(Offset globalPosition) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<CaptureFabCubit>();
    final messenger = ScaffoldMessenger.of(context);
    HapticFeedback.mediumImpact();

    final overlay = Overlay.of(context, rootOverlay: true).context.findRenderObject() as RenderBox;
    final chosen = await showMenu<String>(
      context: context,
      useRootNavigator: true,
      position: RelativeRect.fromRect(globalPosition & const Size(1, 1), Offset.zero & overlay.size),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      items: [
        PopupMenuItem(
          value: 'hide',
          child: Row(
            children: [
              const Icon(Icons.visibility_off_outlined, size: 18),
              const SizedBox(width: 10),
              Text(l10n?.fabHide ?? 'Ẩn nút này'),
            ],
          ),
        ),
      ],
    );
    if (chosen != 'hide') return;

    await cubit.setVisible(false);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(l10n?.fabHiddenMsg ?? 'Đã ẩn nút chụp. Có thể bật lại trong Cài đặt.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(label: l10n?.undo ?? 'Hoàn tác', onPressed: () => cubit.setVisible(true)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final anchor = context.select((CaptureFabCubit c) => c.state.anchor);

    return LayoutBuilder(
      builder: (context, constraints) {
        final geo = _geometry(constraints);
        return AnimatedBuilder(
          animation: _snap,
          builder: (context, child) {
            final offset = _currentOffset(geo, anchor);
            return Stack(
              children: [
                Positioned(left: offset.dx, top: offset.dy, child: child!),
              ],
            );
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onLongPressStart: (d) => _onLongPress(d.globalPosition),
            onPanStart: (_) => _onPanStart(geo, anchor),
            onPanUpdate: (d) => _onPanUpdate(geo, d),
            onPanEnd: (d) => _onPanEnd(geo, d),
            onPanCancel: () {
              if (_drag != null) _onPanEnd(geo, DragEndDetails());
            },
            child: _FabVisual(dragging: _drag != null),
          ),
        );
      },
    );
  }
}

class _FabVisual extends StatelessWidget {
  final bool dragging;

  const _FabVisual({required this.dragging});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navy = isDark ? const Color(0xFF93B4E0) : AppColors.navy;
    final label = l10n?.captureFabLabel ?? 'Chụp';

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: SizedBox.fromSize(
        size: DraggableCaptureFab.hitSize,
        child: AnimatedScale(
          scale: dragging ? 1.08 : 1,
          duration: const Duration(milliseconds: 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: isDark ? AppColors.darkSurface : Colors.white,
                shape: CircleBorder(side: BorderSide(color: navy, width: 1.5)),
                elevation: dragging ? 10 : 4,
                shadowColor: Colors.black54,
                child: SizedBox.square(
                  dimension: DraggableCaptureFab.buttonSize,
                  child: Icon(Icons.photo_camera_outlined, color: navy, size: 26),
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkBackground : Colors.white).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(color: navy, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
