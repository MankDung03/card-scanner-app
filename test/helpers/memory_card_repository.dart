import 'package:app_scanner_card/features/cards/domain/entities/saved_card.dart';
import 'package:app_scanner_card/features/cards/domain/repositories/card_repository.dart';
import 'package:app_scanner_card/features/scan/domain/entities/business_card_info.dart';

/// Repository trong bộ nhớ cho widget test (I/O file thật không chạy được trong fake async).
class MemoryCardRepository implements CardRepository {
  final List<SavedCard> cards;

  MemoryCardRepository([List<SavedCard>? cards]) : cards = [...?cards];

  @override
  Future<List<SavedCard>> getAll() async => [...cards]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<SavedCard> saveFromScan(BusinessCardInfo info,
      {String? frontImagePath, String? backImagePath, String? ocrTextFront, String? ocrTextBack}) async {
    final now = DateTime.now();
    final card = SavedCard.fromCardInfo(info,
        id: now.microsecondsSinceEpoch.toString(), now: now, ocrTextFront: ocrTextFront, ocrTextBack: ocrTextBack);
    cards.add(card);
    return card;
  }

  @override
  Future<SavedCard> update(SavedCard card) async {
    cards[cards.indexWhere((c) => c.id == card.id)] = card;
    return card;
  }

  @override
  Future<SavedCard> setImage(SavedCard card, {required bool isFront, required String sourcePath}) async =>
      update(isFront ? card.copyWith(frontImagePath: sourcePath) : card.copyWith(backImagePath: sourcePath));

  @override
  Future<void> delete(String id) async => cards.removeWhere((c) => c.id == id);

  @override
  Future<List<SavedCard>> replaceAll(List<SavedCard> incoming) async {
    cards
      ..clear()
      ..addAll(incoming);
    return getAll();
  }

  @override
  Future<List<SavedCard>> upsertAll(List<SavedCard> incoming) async {
    for (final c in incoming) {
      final i = cards.indexWhere((e) => e.id == c.id);
      i == -1 ? cards.add(c) : cards[i] = c;
    }
    return getAll();
  }
}
