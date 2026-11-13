class AppRoutes {
  static const String home = '/';
  static const String camera = '/camera';
  static const String crop = '/crop';
  static const String scanCamera = '/camera';
  static const String scanCrop = '/crop';
  static const String ocrReview = '/ocr-review';
  static const String cardDetail = '/card-detail';
  static const String cardSaved = '/card-saved';
  static const String savedCards = '/cards';

  /// Chi tiết danh thiếp: /cards/:id
  static String cardDetailPath(String id) => '$savedCards/$id';

  /// Sửa danh thiếp: /cards/:id/edit
  static String cardEditPath(String id) => '$savedCards/$id/edit';
  static const String settings = '/settings';

  /// Danh sách cặp danh thiếp có thể trùng; gộp một cặp: /duplicates/:flaggedId
  static const String duplicates = '/duplicates';
  /// [fromDetail]: mở từ màn chi tiết của thẻ bị nghi trùng → gộp xong thì chuyển sang chi tiết thẻ được giữ
  static String mergePath(String flaggedId, {bool fromDetail = false}) =>
      '$duplicates/$flaggedId${fromDetail ? '?from=detail' : ''}';
}
