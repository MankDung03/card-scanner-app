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
import '../../domain/entities/business_card_info.dart';
import '../../domain/entities/card_ocr_result.dart';
import '../../domain/entities/ocr_model.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../../domain/services/business_card_parser.dart';
import '../../domain/services/card_info_merger.dart';
import '../../domain/services/ocr_image_preprocessor.dart';
import '../../../../l10n/app_localizations.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  final ImagePicker _picker = ImagePicker();
  final OcrRepository _ocrRepository;

  /// Đọc ngôn ngữ OCR người dùng chọn trong Cài đặt ở thời điểm quét; không truyền = tự động.
  final OcrLanguageMode Function()? _languageMode;

  ScanCubit({OcrRepository? ocrRepository, OcrLanguageMode Function()? languageMode})
      : _ocrRepository = ocrRepository ?? MlKitOcrRepository(),
        _languageMode = languageMode,
        super(const ScanState());

  /// Chuyển mặt đang thao tác. Căn chỉnh (4 góc + xoay) của mặt cũ được lưu lại,
  /// căn chỉnh đã lưu của mặt mới (nếu có) được khôi phục.
  void setSide(CardSide side) {
    if (side == state.currentSide) return;
    final leaving = SideCrop(
      cornerPoints: state.cornerPoints,
      rotationAngle: state.rotationAngle,
      imageWidth: state.imageWidth,
      imageHeight: state.imageHeight,
    );
    final target = (side == CardSide.front ? state.frontCrop : state.backCrop) ?? const SideCrop();
    final imageForSide = state.imagePathFor(side);
    emit(state.copyWith(
      currentSide: side,
      currentImagePath: imageForSide ?? state.currentImagePath,
      frontCrop: state.currentSide == CardSide.front ? leaving : null,
      backCrop: state.currentSide == CardSide.back ? leaving : null,
      cornerPoints: target.cornerPoints,
      rotationAngle: target.rotationAngle,
      imageWidth: target.imageWidth,
      imageHeight: target.imageHeight,
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
    emit(state.copyWith(cornerPoints: kDefaultCropCorners, rotationAngle: 0));
  }

  /// Chỉnh góc tay bằng image_cropper theo spec A51 (tỉ lệ khóa 91:55)
  Future<void> cropWithImageCropper(BuildContext context) async {
    final currentPath = state.currentImagePath;
    if (currentPath == null) return;
    final cropTitle = AppLocalizations.of(context)?.cropTitle ?? 'Căn chỉnh ảnh';

    try {
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: currentPath,
        aspectRatio: const CropAspectRatio(ratioX: 91, ratioY: 55),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: cropTitle,
            toolbarColor: const Color(0xFF0F172A),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: cropTitle,
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

  /// Nhận dạng chữ on-device (Google ML Kit) cho MỌI mặt đã có ảnh (trước → sau),
  /// mỗi mặt crop theo căn chỉnh riêng của nó, parse riêng rồi gộp bằng [CardInfoMerger].
  ///
  /// - Một mặt lỗi nhưng mặt kia thành công → vẫn trả kết quả, mặt lỗi nằm trong `ocrFailedSides`.
  /// - Tất cả các mặt lỗi → trả `null` và đặt `ocrErrorMessage`.
  ///
  /// Trả về kết quả OCR của mặt trước (hoặc mặt sau nếu chỉ có mặt sau).
  Future<CardOcrResult?> processOcr({
    TextRecognitionScript script = TextRecognitionScript.japanese,
  }) async {
    final sides = state.sidesWithImage;
    if (sides.isEmpty) {
      emit(state.copyWith(
        ocrErrorMessage: 'Không tìm thấy tệp ảnh danh thiếp để nhận dạng',
      ));
      return null;
    }

    emit(state.copyWith(
      isOcrLoading: true,
      ocrSidesTotal: sides.length,
      ocrSideIndex: 0,
      ocrFailedSides: const [],
    ));

    final results = <CardSide, CardOcrResult>{};
    final processedPaths = <CardSide, String>{};
    final parsed = <CardSide, BusinessCardInfo>{};
    final failed = <CardSide>[];
    Object? lastError;

    // Chạy tuần tự: tránh 2 recognizer ML Kit cùng lúc và giảm RAM trên máy yếu
    for (var i = 0; i < sides.length; i++) {
      final side = sides[i];
      emit(state.copyWith(isOcrLoading: true, ocrSideInProgress: side, ocrSideIndex: i + 1));
      try {
        final (result, processedPath) = await _recognizeSide(side, script);
        results[side] = result;
        processedPaths[side] = processedPath;
        parsed[side] = BusinessCardParser.parse(result);
      } catch (e, stack) {
        debugPrint('OCR Error ($side): $e\n$stack');
        failed.add(side);
        lastError = e;
      }
    }

    if (results.isEmpty) {
      emit(state.copyWith(
        isOcrLoading: false,
        ocrErrorMessage: 'Lỗi nhận dạng chữ: $lastError',
        ocrFailedSides: failed,
      ));
      return null;
    }

    emit(state.withOcrResults(
      frontOcrResult: results[CardSide.front],
      backOcrResult: results[CardSide.back],
      frontProcessedImagePath: processedPaths[CardSide.front],
      backProcessedImagePath: processedPaths[CardSide.back],
      currentCardInfo: CardInfoMerger.merge(parsed[CardSide.front], parsed[CardSide.back]),
      ocrFailedSides: failed,
    ));

    return results[CardSide.front] ?? results[CardSide.back];
  }

  /// Crop theo 4 góc + xoay của [side], tiền xử lý rồi OCR. Trả về (kết quả, ảnh đã xử lý).
  Future<(CardOcrResult, String)> _recognizeSide(
    CardSide side,
    TextRecognitionScript script,
  ) async {
    final path = state.imagePathFor(side);
    if (path == null) throw StateError('Không có ảnh cho mặt $side');
    final crop = state.cropFor(side);

    final originalBytes = await File(path).readAsBytes();
    img.Image? image = img.decodeImage(originalBytes);
    if (image == null) {
      throw Exception('Không thể giải mã tệp ảnh danh thiếp');
    }

    image = img.bakeOrientation(image);

    // 1. Áp dụng góc xoay nếu người dùng đã xoay ảnh
    if (crop.rotationAngle != 0) {
      image = img.copyRotate(image, angle: crop.rotationAngle);
    }

    // 2. Tính toán vùng cắt (Bounding Box) từ 4 điểm cornerPoints do người dùng kéo
    final corners = crop.cornerPoints;
    final double minX = corners.map((p) => p.dx).reduce(math.min).clamp(0.0, 1.0);
    final double maxX = corners.map((p) => p.dx).reduce(math.max).clamp(0.0, 1.0);
    final double minY = corners.map((p) => p.dy).reduce(math.min).clamp(0.0, 1.0);
    final double maxY = corners.map((p) => p.dy).reduce(math.max).clamp(0.0, 1.0);

    // Bổ sung lề an toàn (Safety Padding ~1.5% kích thước ảnh)
    // để các chữ nằm sát mép như "FAX", "TEL" không bao giờ bị cắt cụt
    final int padding = ((image.width + image.height) * 0.015).round().clamp(15, 35);

    final int rawX = (minX * image.width).round();
    final int rawY = (minY * image.height).round();
    final int rawW = ((maxX - minX) * image.width).round();
    final int rawH = ((maxY - minY) * image.height).round();

    final int cropX = (rawX - padding).clamp(0, image.width - 1);
    final int cropY = (rawY - padding).clamp(0, image.height - 1);
    final int cropW = (rawW + padding * 2).clamp(1, image.width - cropX);
    final int cropH = (rawH + padding * 2).clamp(1, image.height - cropY);

    debugPrint('=== [OCR CROP DEBUG] side=$side ===');
    debugPrint('Original image size: ${image.width}x${image.height}');
    debugPrint('Corners: $corners, rotation: ${crop.rotationAngle}');
    debugPrint('Calculated Crop rect: x=$cropX, y=$cropY, w=$cropW, h=$cropH');

    // 3. Cắt ảnh chính xác theo vùng người dùng đã chọn
    final img.Image croppedImage = img.copyCrop(
      image,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );

    // 4. Lưu ảnh đã cắt vào file tạm cho OCR
    final tempDir = await getTemporaryDirectory();
    final String sidePrefix = side == CardSide.front ? 'front' : 'back';
    final String processedPath =
        '${tempDir.path}/${sidePrefix}_cropped_ocr_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(processedPath).writeAsBytes(img.encodeJpg(croppedImage, quality: 95));

    // 5. Tiền xử lý ảnh (Resize cạnh dài về 1500-2000px, cân bằng tương phản nếu tối) trong isolate
    final preprocessedPath = await OcrImagePreprocessor.preprocessImage(processedPath);

    // 6. Chạy OCR TRÊN ẢNH ĐÃ TIỀN XỬ LÝ theo ngôn ngữ chọn trong Cài đặt (mặc định Tự động: chạy cả Latin + Japanese
    //    rồi tự nhận biết thẻ tiếng Việt hay tiếng Nhật (xem MlKitOcrRepository).
    final result = await _ocrRepository.recognizeText(
      preprocessedPath,
      script: script,
      useDualScript: true,
      languageMode: _languageMode?.call() ?? OcrLanguageMode.auto,
    );

    return (result, preprocessedPath);
  }

  @override
  Future<void> close() async {
    await _ocrRepository.dispose();
    return super.close();
  }

  void updateCardInfo(BusinessCardInfo info) {
    emit(state.copyWith(currentCardInfo: info));
  }

  void updateCardField(String fieldKey, String? value) {
    if (state.currentCardInfo != null) {
      final updated = state.currentCardInfo!.updateField(fieldKey, value);
      emit(state.copyWith(currentCardInfo: updated));
    }
  }

  void assignUnmappedLine(OcrLine line, String targetFieldKey) {
    if (state.currentCardInfo != null) {
      final updated = state.currentCardInfo!.assignUnmappedLine(line, targetFieldKey);
      emit(state.copyWith(currentCardInfo: updated));
    }
  }

  /// Xoá toàn bộ trạng thái scan (ảnh, căn chỉnh, kết quả OCR).
  void reset() {
    emit(const ScanState());
  }

  /// Gọi trước khi bắt đầu scan một danh thiếp mới để không sót ảnh / dữ liệu của lần trước.
  void startNewScan() => reset();
}
