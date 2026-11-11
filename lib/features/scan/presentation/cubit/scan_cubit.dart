import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/repositories/mlkit_ocr_repository.dart';
import '../../domain/entities/card_ocr_result.dart';
import '../../domain/repositories/ocr_repository.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  final ImagePicker _picker = ImagePicker();
  final OcrRepository _ocrRepository;

  ScanCubit({OcrRepository? ocrRepository})
      : _ocrRepository = ocrRepository ?? MlKitOcrRepository(),
        super(const ScanState());

  void setSide(CardSide side) {
    final imageForSide = side == CardSide.front ? state.frontImagePath : state.backImagePath;
    emit(state.copyWith(
      currentSide: side,
      currentImagePath: imageForSide ?? state.currentImagePath,
      rotationAngle: 0,
    ));
  }

  @visibleForTesting
  void setImageForTesting(String path) {
    emit(state.copyWith(
      frontImagePath: path,
      currentImagePath: path,
    ));
  }

  Future<void> toggleFlash(CameraController? controller) async {
    if (controller == null || !controller.value.isInitialized) return;
    try {
      final newFlash = !state.isFlashOn;
      await controller.setFlashMode(newFlash ? FlashMode.torch : FlashMode.off);
      emit(state.copyWith(isFlashOn: newFlash));
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  /// Tự động crop ảnh chụp theo khung 91×55mm trên Viewfinder (100% On-device Pure Dart)
  Future<String?> captureAndCrop({
    required CameraController controller,
    required Rect viewfinderRect,
    required Size screenSize,
  }) async {
    if (!controller.value.isInitialized) return null;

    try {
      emit(state.copyWith(isProcessing: true));

      // 1. Chụp ảnh qua camera
      final XFile photo = await controller.takePicture();
      final bytes = await photo.readAsBytes();

      // 2. Decode ảnh offline bằng package `image`
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        emit(state.copyWith(isProcessing: false, errorMessage: 'Không thể đọc dữ liệu ảnh'));
        return null;
      }

      // Đảm bảo xoay theo Exif orientation nếu có
      originalImage = img.bakeOrientation(originalImage);

      // 3. Tính toán tỷ lệ ánh xạ khung ngắm 91×55mm vào ảnh thực tế
      final double imgW = originalImage.width.toDouble();
      final double imgH = originalImage.height.toDouble();

      final double scaleX = imgW / screenSize.width;
      final double scaleY = imgH / screenSize.height;
      final double scale = math.max(scaleX, scaleY);

      // Bù trừ căn giữa của BoxFit.cover trên preview
      final double offsetX = (screenSize.width * scale - imgW) / 2.0;
      final double offsetY = (screenSize.height * scale - imgH) / 2.0;

      int cropX = ((viewfinderRect.left * scale) - offsetX).round();
      int cropY = ((viewfinderRect.top * scale) - offsetY).round();
      int cropW = (viewfinderRect.width * scale).round();
      int cropH = (viewfinderRect.height * scale).round();

      // Clamp trong giới hạn ảnh
      cropX = cropX.clamp(0, originalImage.width - 1);
      cropY = cropY.clamp(0, originalImage.height - 1);
      cropW = cropW.clamp(1, originalImage.width - cropX);
      cropH = cropH.clamp(1, originalImage.height - cropY);

      // 4. Cắt ảnh theo khung
      final img.Image cropped = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropW,
        height: cropH,
      );

      // 5. Lưu vào thư mục cache
      final tempDir = await getTemporaryDirectory();
      final String sidePrefix = state.currentSide == CardSide.front ? 'front' : 'back';
      final String fileName = '${sidePrefix}_card_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedPath = '${tempDir.path}/$fileName';

      final File croppedFile = File(savedPath);
      await croppedFile.writeAsBytes(img.encodeJpg(cropped, quality: 92));

      // 6. Cập nhật state
      if (state.currentSide == CardSide.front) {
        emit(state.copyWith(
          frontImagePath: savedPath,
          currentImagePath: savedPath,
          imageWidth: cropW,
          imageHeight: cropH,
          isProcessing: false,
          rotationAngle: 0,
        ));
      } else {
        emit(state.copyWith(
          backImagePath: savedPath,
          currentImagePath: savedPath,
          imageWidth: cropW,
          imageHeight: cropH,
          isProcessing: false,
          rotationAngle: 0,
        ));
      }

      return savedPath;
    } catch (e) {
      debugPrint('Error in captureAndCrop: $e');
      emit(state.copyWith(isProcessing: false, errorMessage: e.toString()));
      return null;
    }
  }

  /// Chọn ảnh từ thư viện
  Future<String?> pickFromGallery() async {
    try {
      emit(state.copyWith(isProcessing: true));
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        emit(state.copyWith(isProcessing: false));
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final String sidePrefix = state.currentSide == CardSide.front ? 'front' : 'back';
      final String fileName = 'gallery_${sidePrefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedPath = '${tempDir.path}/$fileName';

      await File(picked.path).copy(savedPath);

      int? pickedW;
      int? pickedH;
      try {
        final bytes = await File(savedPath).readAsBytes();
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        final descriptor = await ui.ImageDescriptor.encoded(buffer);
        pickedW = descriptor.width;
        pickedH = descriptor.height;
        descriptor.dispose();
        buffer.dispose();
      } catch (e) {
        debugPrint('Warning getting gallery image dimensions: $e');
      }

      if (state.currentSide == CardSide.front) {
        emit(state.copyWith(
          frontImagePath: savedPath,
          currentImagePath: savedPath,
          imageWidth: pickedW,
          imageHeight: pickedH,
          isProcessing: false,
          rotationAngle: 0,
        ));
      } else {
        emit(state.copyWith(
          backImagePath: savedPath,
          currentImagePath: savedPath,
          imageWidth: pickedW,
          imageHeight: pickedH,
          isProcessing: false,
          rotationAngle: 0,
        ));
      }

      return savedPath;
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
      emit(state.copyWith(isProcessing: false, errorMessage: e.toString()));
      return null;
    }
  }

  /// Xoay ảnh 90 độ
  void rotateImage() {
    final nextAngle = (state.rotationAngle + 90) % 360;
    emit(state.copyWith(rotationAngle: nextAngle));
  }

  /// Cập nhật vị trí của 1 góc (0: TL, 1: TR, 2: BR, 3: BL)
  void updateCorner(int index, Offset normalizedOffset) {
    if (index < 0 || index >= state.cornerPoints.length) return;
    final List<Offset> updated = List<Offset>.from(state.cornerPoints);
    updated[index] = Offset(
      normalizedOffset.dx.clamp(0.0, 1.0),
      normalizedOffset.dy.clamp(0.0, 1.0),
    );
    emit(state.copyWith(cornerPoints: updated));
  }

  /// Đưa 4 góc về lại tỉ lệ chuẩn 91x55mm cân đối
  void resetCropCorners() {
    emit(state.copyWith(
      cornerPoints: const [
        Offset(0.05, 0.08),
        Offset(0.95, 0.08),
        Offset(0.95, 0.92),
        Offset(0.05, 0.92),
      ],
      rotationAngle: 0,
    ));
  }

  /// Chỉnh góc tay bằng image_cropper theo spec A51 (tỉ lệ khóa 91:55)
  Future<void> cropWithImageCropper(BuildContext context) async {
    final currentPath = state.currentImagePath;
    if (currentPath == null) return;

    try {
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: currentPath,
        aspectRatio: const CropAspectRatio(ratioX: 91, ratioY: 55),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Căn chỉnh danh thiếp',
            toolbarColor: const Color(0xFF0F172A),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Căn chỉnh danh thiếp',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (cropped != null) {
        if (state.currentSide == CardSide.front) {
          emit(state.copyWith(
            frontImagePath: cropped.path,
            currentImagePath: cropped.path,
          ));
        } else {
          emit(state.copyWith(
            backImagePath: cropped.path,
            currentImagePath: cropped.path,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error with image_cropper: $e');
    }
  }

  /// Thực hiện OCR On-Device bằng Google ML Kit (chỉ quét vùng crop theo 4 góc & xoay)
  Future<CardOcrResult?> processOcr({
    TextRecognitionScript script = TextRecognitionScript.japanese,
  }) async {
    final currentPath = state.currentImagePath;
    if (currentPath == null) {
      emit(state.copyWith(
        ocrErrorMessage: 'Không tìm thấy tệp ảnh danh thiếp để nhận dạng',
      ));
      return null;
    }

    try {
      emit(state.copyWith(isOcrLoading: true, ocrErrorMessage: null));

      final originalBytes = await File(currentPath).readAsBytes();
      img.Image? image = img.decodeImage(originalBytes);
      if (image == null) {
        throw Exception('Không thể giải mã tệp ảnh danh thiếp');
      }

      image = img.bakeOrientation(image);

      // 1. Áp dụng góc xoay nếu người dùng đã xoay ảnh
      if (state.rotationAngle != 0) {
        image = img.copyRotate(image, angle: state.rotationAngle);
      }

      // 2. Tính toán vùng cắt (Bounding Box) từ 4 điểm cornerPoints do người dùng kéo
      final corners = state.cornerPoints;
      final double minX = corners.map((p) => p.dx).reduce(math.min).clamp(0.0, 1.0);
      final double maxX = corners.map((p) => p.dx).reduce(math.max).clamp(0.0, 1.0);
      final double minY = corners.map((p) => p.dy).reduce(math.min).clamp(0.0, 1.0);
      final double maxY = corners.map((p) => p.dy).reduce(math.max).clamp(0.0, 1.0);

      final int cropX = (minX * image.width).round().clamp(0, image.width - 1);
      final int cropY = (minY * image.height).round().clamp(0, image.height - 1);
      final int cropW = ((maxX - minX) * image.width).round().clamp(1, image.width - cropX);
      final int cropH = ((maxY - minY) * image.height).round().clamp(1, image.height - cropY);

      debugPrint('=== [OCR CROP DEBUG] ===');
      debugPrint('Original image size: ${image.width}x${image.height}');
      debugPrint('Corners: $corners');
      debugPrint('Bounding Box normalized: minX=$minX, minY=$minY, maxX=$maxX, maxY=$maxY');
      debugPrint('Calculated Crop rect: x=$cropX, y=$cropY, w=$cropW, h=$cropH');

      // 3. Cắt ảnh chính xác theo vùng người dùng đã chọn
      final img.Image croppedImage = img.copyCrop(
        image,
        x: cropX,
        y: cropY,
        width: cropW,
        height: cropH,
      );

      debugPrint('Cropped image size: ${croppedImage.width}x${croppedImage.height}');

      // 4. Lưu ảnh đã cắt vào file tạm cho OCR
      final tempDir = await getTemporaryDirectory();
      final String sidePrefix = state.currentSide == CardSide.front ? 'front' : 'back';
      final String processedPath =
          '${tempDir.path}/${sidePrefix}_cropped_ocr_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(processedPath).writeAsBytes(img.encodeJpg(croppedImage, quality: 95));

      // 5. Chạy OCR TRÊN ẢNH ĐÃ CẮT THU NHỎ
      final result = await _ocrRepository.recognizeText(processedPath, script: script);

      emit(state.copyWith(
        isOcrLoading: false,
        lastProcessedImagePath: processedPath,
        frontOcrResult: state.currentSide == CardSide.front ? result : state.frontOcrResult,
        backOcrResult: state.currentSide == CardSide.back ? result : state.backOcrResult,
      ));

      return result;
    } catch (e, stack) {
      debugPrint('OCR Error: $e\n$stack');
      emit(state.copyWith(
        isOcrLoading: false,
        ocrErrorMessage: 'Lỗi nhận dạng chữ: $e',
      ));
      return null;
    }
  }

  @override
  Future<void> close() async {
    await _ocrRepository.dispose();
    return super.close();
  }

  void reset() {
    emit(const ScanState());
  }
}
