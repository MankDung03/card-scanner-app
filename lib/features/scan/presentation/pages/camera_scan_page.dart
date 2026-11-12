import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';
import '../widgets/camera_bottom_bar.dart';
import '../widgets/camera_viewfinder_overlay.dart';
import '../widgets/ocr_language_toggle.dart';
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
      backgroundColor: Colors.black,
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
                color: const Color(0xFF0B0F19),
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
              title: l10n?.alignCardTitle ?? 'Đặt danh thiếp vừa khung',
              subtitle: l10n?.alignCardSubtitle ?? 'Khung tỉ lệ 91 × 55 mm · giữ máy song song với thẻ',
              onRectCalculated: (rect) {
                _viewfinderRect = rect;
              },
            ),

            // 3. Header Top Bar
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: BlocBuilder<ScanCubit, ScanState>(
                    builder: (context, state) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Nút Đóng X
                              _buildCircleIconButton(
                                icon: Icons.close_rounded,
                                onTap: () => context.pop(),
                              ),

                              // Segmented Switch [ Mặt trước | Mặt sau ]
                              SideSegmentedControl(
                                currentSide: state.currentSide,
                                frontLabel: l10n?.frontSide ?? 'Mặt trước',
                                backLabel: l10n?.backSide ?? 'Mặt sau',
                                onSideChanged: (side) => scanCubit.setSide(side),
                              ),

                              // Nút Flash
                              _buildCircleIconButton(
                                icon: state.isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                color: state.isFlashOn ? Colors.amber : Colors.white,
                                onTap: () => scanCubit.toggleFlash(_cameraController),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Nút chuyển đổi ngôn ngữ OCR: [ Tự động | VN | JP ]
                          OcrLanguageToggle(
                            currentMode: state.ocrLanguageMode,
                            onModeChanged: (mode) => scanCubit.setOcrLanguageMode(mode),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // 4. Bottom Controls
            Align(
              alignment: Alignment.bottomCenter,
              child: BlocBuilder<ScanCubit, ScanState>(
                builder: (context, state) {
                  return CameraBottomBar(
                    currentSide: state.currentSide,
                    stepFrontLabel: l10n?.stepFront ?? '1 - Mặt trước',
                    stepBackLabel: l10n?.stepBackOptional ?? '2 - Mặt sau (tuỳ chọn)',
                    galleryLabel: l10n?.gallery ?? 'Thư viện',
                    cropLabel: l10n?.cropAction ?? 'Cắt ảnh',
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

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
