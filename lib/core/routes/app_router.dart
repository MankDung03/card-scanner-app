import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/scan/presentation/pages/camera_scan_page.dart';
import '../../features/scan/presentation/pages/card_crop_page.dart';
import 'app_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.scanCamera,
        builder: (context, state) => const CameraScanPage(),
      ),
      GoRoute(
        path: AppRoutes.scanCrop,
        builder: (context, state) => const CardCropPage(),
      ),
    ],
  );
}
