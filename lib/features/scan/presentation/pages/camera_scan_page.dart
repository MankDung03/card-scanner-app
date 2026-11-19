import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';
import '../widgets/camera_bottom_bar.dart';
import '../widgets/camera_problem_panel.dart';
import '../widgets/camera_viewfinder_overlay.dart';
import '../widgets/side_segmented_control.dart';

class CameraScanPage extends StatefulWidget {
  const CameraScanPage({super.key});

  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  _CameraStatus _status = _CameraStatus.loading;
  bool _initializing = false;
  Rect _viewfinderRect = Rect.zero;

  /// Luồng quét: 1 Chụp → 2 Cắt ảnh → 3 Xác nhận thông tin
  static const int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      // Bỏ tham chiếu TRƯỚC khi dispose: build sau đó không được dùng controller đã huỷ
      final controller = _cameraController;
      if (controller == null) return;
      setState(() {
        _cameraController = null;
        _status = _CameraStatus.loading;
      });
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Quay lại app (kể cả sau khi bật quyền trong Cài đặt) → khởi động lại, KHÔNG hỏi quyền lần nữa
      if (_cameraController == null) _initCamera(request: false);
    }
  }

  /// Kiểm tra / xin quyền camera rồi khởi động camera sau.
  /// [request] = false: chỉ kiểm tra (dùng khi quay lại app) để không bật hộp xin quyền liên tục.
  Future<void> _initCamera({bool request = true}) async {
    if (_initializing) return;
    _initializing = true;
    if (mounted && _status != _CameraStatus.loading) setState(() => _status = _CameraStatus.loading);
    try {
      var permission = await Permission.camera.status;
      if (!permission.isGranted && request && !permission.isPermanentlyDenied && !permission.isRestricted) {
        permission = await Permission.camera.request();
      }
      if (!permission.isGranted) {
        if (mounted) {
          setState(() => _status = permission.isPermanentlyDenied || permission.isRestricted
              ? _CameraStatus.permissionBlocked
              : _CameraStatus.needsPermission);
        }
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) setState(() => _status = _CameraStatus.unavailable);
        return;
      }

      // Ưu tiên camera sau
      final backCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _status = _CameraStatus.ready;
      });
    } on CameraException catch (e) {
      // Lỗi kỹ thuật chỉ ghi log; người dùng thấy thông báo dễ hiểu
      debugPrint('Camera init failed: ${e.code} ${e.description}');
      final denied = e.code.startsWith('CameraAccess') || e.code == 'cameraPermission';
      if (mounted) setState(() => _status = denied ? _CameraStatus.needsPermission : _CameraStatus.unavailable);
    } catch (e) {
      debugPrint('Camera init failed: $e');
      if (mounted) setState(() => _status = _CameraStatus.unavailable);
    } finally {
      _initializing = false;
    }
  }

  Future<void> _onShutterPressed(BuildContext context) async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    final scanCubit = context.read<ScanCubit>();
    final screenSize = MediaQuery.of(context).size;

    final croppedPath = await scanCubit.captureAndCrop(
      controller: controller,
      viewfinderRect: _viewfinderRect,
      screenSize: screenSize,
    );

    if (croppedPath != null && context.mounted) {
      context.push(AppRoutes.scanCrop);
    }
  }

  Future<void> _onGalleryPressed(BuildContext context) async {
    final scanCubit = context.read<ScanCubit>();
    final pickedPath = await scanCubit.pickFromGallery();
    if (pickedPath != null && context.mounted) {
      context.push(AppRoutes.scanCrop);
    }
  }

  /// Tự động chụp (khi thẻ nằm vừa khung, đủ nét): chưa có — tạm báo "sắp có".
  /// Khi làm: thêm cờ bật/tắt (truyền `autoCaptureOn` cho CameraBottomBar) + phân tích khung hình preview.
  void _onAutoCapturePressed(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(l10n?.autoCaptureComingSoon ?? 'Tự động chụp sẽ có trong bản cập nhật tới'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scanCubit = context.read<ScanCubit>();

    return Scaffold(
      backgroundColor: AppColors.scanChrome,
      body: SafeArea(
        top: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Camera Preview
            if (_status == _CameraStatus.ready && _cameraController != null)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _cameraController!.value.previewSize?.height ?? 1,
                    height: _cameraController!.value.previewSize?.width ?? 1,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              )
            else
              const ColoredBox(color: AppColors.scanChrome),

            // 2. Khung ngắm 91×55mm — chỉ khi camera đang chạy / đang khởi động.
            //    Khi lỗi / chưa có quyền thì ẩn hẳn để không đè lên thông báo.
            if (_status == _CameraStatus.ready || _status == _CameraStatus.loading)
              CameraViewfinderOverlay(
                hint: l10n?.cameraHint ?? 'Đặt danh thiếp vừa khung, ở nơi đủ sáng',
                onRectCalculated: (rect) {
                  _viewfinderRect = rect;
                },
              ),
            if (_status == _CameraStatus.loading) const Center(child: CircularProgressIndicator(color: Colors.white)),

            // Thông báo chưa có quyền / camera lỗi: nằm giữa header và thanh nút, cuộn được khi chữ to
            if (_status.isProblem)
              Positioned.fill(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 120, bottom: 150),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                        child: CameraProblemPanel(
                          problem: _status.problem!,
                          onPrimary: _status == _CameraStatus.permissionBlocked ? openAppSettings : () => _initCamera(),
                          onGallery: () => _onGalleryPressed(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 3. Header: [× Đóng]  Bước 1/3  [Flash]  +  segmented Mặt trước / Mặt sau
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: BlocBuilder<ScanCubit, ScanState>(
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 56,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () => context.pop(),
                                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                                      icon: const Icon(Icons.close_rounded, size: 20),
                                      label: Text(
                                        l10n?.closeAction ?? 'Đóng',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  l10n?.stepProgress(1, _totalSteps) ?? 'Bước 1/$_totalSteps',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: _FlashButton(
                                      isOn: state.isFlashOn,
                                      onTap: () => scanCubit.toggleFlash(_cameraController),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AppSpacing.gapH8,
                        SideSegmentedControl(
                          currentSide: state.currentSide,
                          frontLabel: l10n?.frontSide ?? 'Mặt trước',
                          backLabel: l10n?.backSideOptional ?? 'Mặt sau (tuỳ chọn)',
                          onSideChanged: (side) => scanCubit.setSide(side),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // 4. Bottom Controls
            Align(
              alignment: Alignment.bottomCenter,
              child: BlocBuilder<ScanCubit, ScanState>(
                buildWhen: (prev, curr) => prev.isProcessing != curr.isProcessing,
                builder: (context, state) {
                  return CameraBottomBar(
                    galleryLabel: l10n?.gallery ?? 'Thư viện',
                    autoCaptureLabel: l10n?.autoCapture ?? 'Tự động chụp',
                    shutterLabel: l10n?.captureCardTitle ?? 'Chụp ảnh',
                    isProcessing: state.isProcessing,
                    shutterEnabled: _status == _CameraStatus.ready,
                    onShutter: () => _onShutterPressed(context),
                    onGallery: () => _onGalleryPressed(context),
                    onAutoCapture: () => _onAutoCapturePressed(context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nút flash vuông bo góc; bật → nền trắng, icon tối.
class _FlashButton extends StatelessWidget {
  final bool isOn;
  final VoidCallback onTap;

  const _FlashButton({required this.isOn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: isOn,
      label: 'Flash',
      child: Material(
        color: isOn ? Colors.white : AppColors.scanControlBg,
        borderRadius: AppRadius.r10,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.r10,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: isOn ? AppColors.textPrimary : Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

enum _CameraStatus {
  loading,
  ready,

  /// Chưa có quyền, còn hỏi lại được → nút "Cấp quyền" bật hộp xin quyền của hệ thống
  needsPermission,

  /// Đã từ chối hẳn ("Không hỏi lại") / bị giới hạn → chỉ bật lại được trong Cài đặt
  permissionBlocked,

  /// Không có camera / camera lỗi / đang bị app khác dùng
  unavailable;

  bool get isProblem => this == needsPermission || this == permissionBlocked || this == unavailable;

  CameraProblem? get problem => switch (this) {
        needsPermission => CameraProblem.needsPermission,
        permissionBlocked => CameraProblem.permissionBlocked,
        unavailable => CameraProblem.unavailable,
        _ => null,
      };
}
