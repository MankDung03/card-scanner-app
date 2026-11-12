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

  Future<void> delete(String id);
}
