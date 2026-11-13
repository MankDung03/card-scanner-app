import '../../../scan/domain/entities/business_card_info.dart';
import '../entities/saved_card.dart';

abstract class CardRepository {
  /// Lấy toàn bộ danh thiếp đã lưu, mới nhất trước.
  Future<List<SavedCard>> getAll();

  /// Lưu danh thiếp mới từ kết quả scan (ảnh sẽ được copy vào bộ nhớ của app).
  Future<SavedCard> saveFromScan(
    BusinessCardInfo info, {
    String? frontImagePath,
    String? backImagePath,
  });

  Future<SavedCard> update(SavedCard card);

  /// Thêm / thay ảnh một mặt của thẻ (ảnh nguồn được copy vào bộ nhớ của app).
  Future<SavedCard> setImage(SavedCard card, {required bool isFront, required String sourcePath});

  /// Xoá thẻ; ảnh của thẻ chỉ bị xoá khi không còn thẻ nào khác dùng.
  Future<void> delete(String id);

  /// Xoá toàn bộ dữ liệu hiện tại rồi ghi [cards] (dùng khi khôi phục "Thay thế toàn bộ").
  /// Ảnh của [cards] có thể nằm ngoài thư mục app (vd. file giải nén tạm) — sẽ được copy vào.
  Future<List<SavedCard>> replaceAll(List<SavedCard> cards);

  /// Thêm thẻ mới / ghi đè thẻ cùng id (dùng khi khôi phục "Gộp"). Ảnh được copy như [replaceAll];
  /// ảnh cũ của thẻ bị ghi đè được xoá nếu không còn dùng.
  Future<List<SavedCard>> upsertAll(List<SavedCard> cards);
}
