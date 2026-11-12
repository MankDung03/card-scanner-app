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

  Future<void> delete(String id);
}
