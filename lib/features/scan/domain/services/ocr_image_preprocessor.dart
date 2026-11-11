import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Dữ liệu đầu vào cho worker isolate tiền xử lý ảnh
class PreprocessParams {
  final String sourcePath;
  final String outputPath;
  final int maxDimension;

  const PreprocessParams({
    required this.sourcePath,
    required this.outputPath,
    this.maxDimension = 1800,
  });
}

/// Service tiền xử lý ảnh trước khi gửi vào OCR engine (chạy trong Isolate)
class OcrImagePreprocessor {
  /// Tiền xử lý ảnh danh thiếp (Resize cạnh dài về 1500-2000px, tăng tương phản nếu tối)
  /// Chạy trong nền qua `compute` để đảm bảo 0 giật lag UI
  static Future<String> preprocessImage(
    String imagePath, {
    int maxDimension = 1800,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      return imagePath;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/preprocessed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final params = PreprocessParams(
        sourcePath: imagePath,
        outputPath: outPath,
        maxDimension: maxDimension,
      );

      final resultPath = await compute(_preprocessWorker, params);
      return resultPath;
    } catch (e) {
      debugPrint('[OcrImagePreprocessor] Error preprocessing image: $e');
      return imagePath; // Fallback ảnh gốc nếu có lỗi
    }
  }

  /// Worker isolate function
  static Future<String> _preprocessWorker(PreprocessParams params) async {
    final file = File(params.sourcePath);
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      return params.sourcePath;
    }

    // 1. Chuẩn hóa độ phân giải cạnh dài về dải tối ưu cho ML Kit (1600 - 2000px)
    // - Ảnh quá lớn (> 2200px): thu nhỏ để không quá tải bộ nhớ
    // - Ảnh nhỏ/vừa (< 1600px): phóng to bằng cubic interpolation để các chữ nhỏ như "FAX", "TEL", số lẻ
    //   đạt kích thước tối thiểu >= 18px theo tiêu chuẩn nhận diện của Google ML Kit
    final int currentLongEdge = max(image.width, image.height);
    if (currentLongEdge > params.maxDimension) {
      final double ratio = params.maxDimension / currentLongEdge;
      final int newW = (image.width * ratio).round();
      final int newH = (image.height * ratio).round();

      image = img.copyResize(
        image,
        width: newW,
        height: newH,
        interpolation: img.Interpolation.cubic,
      );
    } else if (currentLongEdge < 1600) {
      const double targetLongEdge = 1800.0;
      final double ratio = targetLongEdge / currentLongEdge;
      final int newW = (image.width * ratio).round();
      final int newH = (image.height * ratio).round();

      image = img.copyResize(
        image,
        width: newW,
        height: newH,
        interpolation: img.Interpolation.cubic,
      );
    }

    // 2. Tăng cường tương phản và độ nét nhẹ cho các nét chữ mảnh, dấu ngoặc ()
    image = img.adjustColor(
      image,
      contrast: 1.25,
      brightness: 1.05,
    );

    // 3. Thêm viền đệm trắng 24px xung quanh ảnh để ML Kit không bao giờ bị cắt cụt ký tự ở mép
    final padded = img.Image(
      width: image.width + 48,
      height: image.height + 48,
      backgroundColor: img.ColorRgb8(255, 255, 255),
    );
    img.compositeImage(padded, image, dstX: 24, dstY: 24);
    image = padded;

    // 4. Luôn ghi file đã được tiền xử lý (tăng tương phản & padding mép an toàn)
    final outFile = File(params.outputPath);
    await outFile.writeAsBytes(img.encodeJpg(image, quality: 95));
    return params.outputPath;
  }
}
