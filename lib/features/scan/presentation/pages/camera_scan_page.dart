import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';
import '../widgets/camera_bottom_bar.dart';
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
  bool _isInit = false;
  String? _initError;
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
    final CameraController? controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _initError = 'Không tìm thấy máy ảnh trên thiết bị';
          });
        }
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
        _isInit = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = e.toString();
        });
      }
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

  void _onCropPressed(BuildContext context) {
    final state = context.read<ScanCubit>().state;
    if (state.currentImagePath != null) {
      context.push(AppRoutes.scanCrop);
    } else {
      _onShutterPressed(context);
    }
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
            if (_isInit && _cameraController != null)
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
              Container(
                color: AppColors.scanChrome,
                child: Center(
                  child: _initError != null
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                l10n?.cameraInitError ?? 'Không thể khởi động camera',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _initError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white54, fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _initCamera,
                                child: Text(l10n?.grantPermission ?? 'Thử lại'),
                              ),
                            ],
                          ),
                        )
                      : const CircularProgressIndicator(color: Colors.white),
                ),
              ),


            // 2. Viewfinder Overlay với khung 91x55mm
            CameraViewfinderOverlay(
              hint: l10n?.cameraHint ?? 'Đặt danh thiếp vừa khung, ở nơi đủ sáng',
              onRectCalculated: (rect) {
                _viewfinderRect = rect;
              },
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
                    cropLabel: l10n?.cropAction ?? 'Cắt ảnh',
                    shutterLabel: l10n?.captureCardTitle ?? 'Chụp ảnh',
                    isProcessing: state.isProcessing,
                    onShutter: () => _onShutterPressed(context),
                    onGallery: () => _onGalleryPressed(context),
                    onCrop: () => _onCropPressed(context),
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
