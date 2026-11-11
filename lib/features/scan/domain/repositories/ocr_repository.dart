import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../entities/card_ocr_result.dart';

abstract class OcrRepository {
  /// Thực hiện OCR On-Device trên ảnh đường dẫn [imagePath]
  /// Khi [useDualScript] là true (mặc định), sẽ chạy kết hợp song song cả Latin (tiếng Việt/Anh)
  /// và Japanese (Kanji/Kana) để gộp kết quả tối ưu nhất.
  Future<CardOcrResult> recognizeText(
    String imagePath, {
    TextRecognitionScript script = TextRecognitionScript.japanese,
    bool useDualScript = true,
  });

  /// Giải phóng tài nguyên của các TextRecognizer khi không còn dùng
  Future<void> dispose();
}
