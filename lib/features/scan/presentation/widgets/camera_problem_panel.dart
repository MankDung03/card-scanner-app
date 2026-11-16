import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// Lý do không dùng được camera
enum CameraProblem {
  /// Chưa có quyền, còn hỏi lại được → nút "Cấp quyền" bật hộp xin quyền của hệ thống
  needsPermission,

  /// Đã từ chối hẳn ("Không hỏi lại") / bị giới hạn → chỉ bật lại được trong Cài đặt
  permissionBlocked,

  /// Không có camera / camera lỗi / đang bị app khác dùng
  unavailable,
}

/// Thông báo khi không dùng được camera: icon + tiêu đề + giải thích dễ hiểu (không in lỗi kỹ thuật)
/// + nút chính (Cấp quyền / Mở Cài đặt / Thử lại) + lối thoát "Chọn từ Thư viện".
class CameraProblemPanel extends StatelessWidget {
  final CameraProblem problem;
  final VoidCallback onPrimary;
  final VoidCallback onGallery;

  const CameraProblemPanel({super.key, required this.problem, required this.onPrimary, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isPermission = problem != CameraProblem.unavailable;

    final title = isPermission
        ? (l10n?.cameraPermissionTitle ?? 'Cần quyền truy cập camera')
        : (l10n?.cameraInitError ?? 'Không thể khởi động camera');
    final body = switch (problem) {
      CameraProblem.permissionBlocked => l10n?.cameraPermissionDeniedBody ??
          'Quyền camera đang bị tắt. Mở Cài đặt của ứng dụng, vào Quyền → Camera để bật lại.',
      CameraProblem.unavailable =>
        l10n?.cameraUnavailableBody ?? 'Camera đang bận hoặc gặp sự cố. Hãy thử lại, hoặc chọn ảnh từ Thư viện.',
      CameraProblem.needsPermission => l10n?.cameraPermissionBody ??
          'Cho phép dùng camera để chụp danh thiếp. Bạn vẫn có thể chọn ảnh có sẵn từ Thư viện.',
    };
    final primaryLabel = switch (problem) {
      CameraProblem.permissionBlocked => l10n?.openAppSettings ?? 'Mở Cài đặt',
      CameraProblem.unavailable => l10n?.retryAction ?? 'Thử lại',
      CameraProblem.needsPermission => l10n?.grantPermission ?? 'Cấp quyền',
    };

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.s24, AppSpacing.s20, AppSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: AppRadius.r16,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(
                isPermission ? Icons.no_photography_outlined : Icons.videocam_off_outlined,
                color: Colors.white70,
                size: 28,
              ),
            ),
          ),
          AppSpacing.gapH16,
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          AppSpacing.gapH8,
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.5),
          ),
          AppSpacing.gapH20,
          FilledButton.icon(
            key: const ValueKey('camera-problem-primary'),
            onPressed: onPrimary,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.navy,
              minimumSize: const Size.fromHeight(46),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
              textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
            ),
            icon: Icon(
              problem == CameraProblem.permissionBlocked
                  ? Icons.settings_outlined
                  : (isPermission ? Icons.photo_camera_outlined : Icons.refresh_rounded),
              size: 19,
            ),
            label: Text(primaryLabel),
          ),
          AppSpacing.gapH8,
          TextButton.icon(
            onPressed: onGallery,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            icon: const Icon(Icons.image_outlined, size: 18),
            label: Text(l10n?.gallery ?? 'Thư viện'),
          ),
        ],
      ),
    );
  }
}
