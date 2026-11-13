import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../features/cards/presentation/pages/card_detail_page.dart';
import '../../features/cards/presentation/pages/card_edit_page.dart';
import '../../features/cards/presentation/pages/card_saved_page.dart';
import '../../features/cards/presentation/pages/saved_cards_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/scan/presentation/pages/camera_scan_page.dart';
import '../../features/scan/presentation/pages/card_crop_page.dart';
import '../../features/scan/presentation/pages/card_verification_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../widgets/app_shell/app_shell.dart';
import 'app_routes.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      // Mọi màn nằm trong khung có menu dưới + nút chụp nổi (xem AppShell).
      // Hộp thoại / bảng trượt mở bằng root navigator → nằm trên khung.
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomePage(),
            // Route con của Home: khi `go` tới đây, stack sẽ là [Home, page] → back luôn về Home
            routes: [
              GoRoute(
                path: AppRoutes.cardSaved.substring(1),
                builder: (context, state) => CardSavedPage(cardId: state.extra as String?),
              ),
              GoRoute(
                path: AppRoutes.settings.substring(1),
                builder: (context, state) => const SettingsPage(),
              ),
              GoRoute(
                path: AppRoutes.savedCards.substring(1),
                builder: (context, state) => const SavedCardsPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => CardDetailPage(cardId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => CardEditPage(cardId: state.pathParameters['id']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.scanCamera,
            builder: (context, state) => const CameraScanPage(),
          ),
          GoRoute(
            path: AppRoutes.scanCrop,
            builder: (context, state) => const CardCropPage(),
          ),
          GoRoute(
            path: AppRoutes.ocrReview,
            builder: (context, state) => const CardVerificationPage(),
          ),
        ],
      ),
    ],
  );
}
