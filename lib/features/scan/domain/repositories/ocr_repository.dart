import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../entities/card_ocr_result.dart';
import '../entities/ocr_language_mode.dart';

abstract class OcrRepository {
  /// Thực hiện OCR On-Device trên ảnh đường dẫn [imagePath]
  /// Khi [languageMode] là [OcrLanguageMode.auto] (mặc định), hệ thống tự động chẩn đoán
  /// và chuyển đổi script giữa Latin và Japanese để không sinh ký tự rác.
  Future<CardOcrResult> recognizeText(
    String imagePath, {
    TextRecognitionScript script = TextRecognitionScript.japanese,
    bool useDualScript = true,
    OcrLanguageMode languageMode = OcrLanguageMode.auto,
  });

  /// Giải phóng tài nguyên của các TextRecognizer khi không còn dùng
  Future<void> dispose();
}
