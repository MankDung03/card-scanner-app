import '../entities/card_ocr_result.dart';

abstract class OcrRepository {
  /// Thực hiện OCR On-Device trên ảnh đường dẫn [imagePath]
  Future<CardOcrResult> recognizeText(String imagePath);

  /// Giải phóng tài nguyên của TextRecognizer khi không còn dùng
  Future<void> dispose();
}
