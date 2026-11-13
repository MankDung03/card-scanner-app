import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../features/scan/presentation/cubit/scan_cubit.dart';
import '../../routes/app_routes.dart';
import '../capture_fab/capture_fab_cubit.dart';
import '../capture_fab/draggable_capture_fab.dart';
import 'app_bottom_nav.dart';

/// Khung chung của app: nội dung trang + menu dưới + nút chụp nổi.
///
/// - Menu dưới hiện ở mọi màn, trừ màn camera (cần toàn màn hình) và khi bàn phím đang mở.
/// - Nút chụp nổi chỉ hiện ở Danh sách và Chi tiết danh thiếp.
/// - Hộp thoại / bảng trượt mở bằng root navigator nên luôn nằm TRÊN menu và nút nổi.
///
/// Không dùng Scaffold ở đây: Scaffold lồng nhau khiến SnackBar hiện ở Scaffold ngoài cùng
/// (đè lên menu dưới). Mỗi trang tự có Scaffold riêng nằm gọn phía trên menu.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  /// Màn không hiện menu dưới
  static const _fullscreenRoutes = {AppRoutes.scanCamera};

  static final _cardDetailPattern = RegExp('^${RegExp.escape(AppRoutes.savedCards)}/[^/]+\$');

  /// Màn hiện nút chụp nổi: Danh sách và Chi tiết danh thiếp
  static bool showsCaptureFab(String location) =>
      location == AppRoutes.savedCards || _cardDetailPattern.hasMatch(location);

  /// Tab tương ứng với màn hiện tại; -1 = không thuộc tab nào (luồng quét, màn lưu xong…)
  static int tabIndexOf(String location) {
    if (location == AppRoutes.home) return 0;
    if (location == AppRoutes.savedCards || location.startsWith('${AppRoutes.savedCards}/')) return 1;
    if (location == AppRoutes.settings) return 2;
    return -1;
  }

  static const _tabRoots = [AppRoutes.home, AppRoutes.savedCards, AppRoutes.settings];

  /// Màn trên cùng (kể cả màn mở bằng `push`, vốn không cập nhật `uri` của go_router)
  static String _currentLocation(GoRouter router) {
    final config = router.routerDelegate.currentConfiguration;
    return config.isEmpty ? AppRoutes.home : config.last.matchedLocation;
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final fabEnabled = context.select((CaptureFabCubit c) => c.state.visible);

    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, _) {
        final location = _currentLocation(router);
        final showNav = !keyboardOpen && !_fullscreenRoutes.contains(location);
        final showFab = fabEnabled && !keyboardOpen && showsCaptureFab(location);
        final tab = tabIndexOf(location);

        return Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              Expanded(
                // Menu dưới đã lo phần vùng an toàn phía dưới → trang không cần chừa thêm
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: showNav,
                  child: Stack(
                    children: [
                      child,
                      if (showFab)
                        Positioned.fill(
                          child: DraggableCaptureFab(
                            // Không đè lên header navy của trang (status bar + 56)
                            topInset: MediaQuery.paddingOf(context).top + 56,
                            onTap: () {
                              context.read<ScanCubit>().startNewScan();
                              router.push(AppRoutes.scanCamera);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (showNav)
                AppBottomNav(
                  selectedIndex: tab,
                  onTap: (index) {
                    final target = _tabRoots[index];
                    if (location != target) router.go(target);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
