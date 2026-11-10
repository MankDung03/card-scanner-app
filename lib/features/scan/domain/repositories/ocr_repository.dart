import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../entities/card_ocr_result.dart';

abstract class OcrRepository {
  /// Thực hiện OCR On-Device trên ảnh đường dẫn [imagePath]
  /// Mặc định sử dụng script tiếng Nhật [TextRecognitionScript.japanese]
  /// (nhận dạng cả Kanji, Kana và chữ số Latin/Romaji)
  /// hoặc Latin [TextRecognitionScript.latin] (nhận dạng tiếng Việt có dấu, tiếng Anh)
  Future<CardOcrResult> recognizeText(
    String imagePath, {
    TextRecognitionScript script = TextRecognitionScript.japanese,
  });

  /// Giải phóng tài nguyên của các TextRecognizer khi không còn dùng
  Future<void> dispose();
}
