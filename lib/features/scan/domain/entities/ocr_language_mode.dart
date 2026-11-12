/// Chế độ ngôn ngữ cho bộ nhận dạng OCR
enum OcrLanguageMode {
  /// Tự động bắt mạch ngôn ngữ:
  /// - Kiểm tra số lượng chữ Hán Kanji và dấu tiếng Việt.
  /// - Tự động loại bỏ ảo giác ép dấu tiếng Việt thành Hiragana của model Japanese.
  auto,

  /// Chuyên dụng tiếng Việt:
  /// - Khởi tạo trực tiếp TextRecognitionScript.latin.
  /// - Nhận diện hoàn hảo mọi loại dấu (ả, ễ, ặ, ô, đ...), tuyệt đối không sinh ký tự lạ tiếng Nhật.
  vietnamese,

  /// Chuyên dụng tiếng Nhật:
  /// - Chạy mô hình Japanese Recognizer kết hợp Latin để đọc Kanji, Kana, Furigana.
  japanese,
}
