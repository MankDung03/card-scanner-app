import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../scan/domain/entities/business_card_info.dart';
import '../../data/repositories/local_card_repository.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/repositories/card_repository.dart';

class SavedCardsState {
  final List<SavedCard> cards;
  final bool isLoading;
  final bool isSaving;

  const SavedCardsState({
    this.cards = const [],
    this.isLoading = false,
    this.isSaving = false,
  });

  SavedCard? findById(String id) {
    for (final c in cards) {
      if (c.id == id) return c;
    }
    return null;
  }

  SavedCardsState copyWith({List<SavedCard>? cards, bool? isLoading, bool? isSaving}) {
    return SavedCardsState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class SavedCardsCubit extends Cubit<SavedCardsState> {
  final CardRepository _repository;

  SavedCardsCubit({CardRepository? repository})
      : _repository = repository ?? LocalCardRepository(),
        super(const SavedCardsState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final cards = await _repository.getAll();
      emit(state.copyWith(cards: cards, isLoading: false));
    } catch (e) {
      debugPrint('SavedCardsCubit.load error: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Lưu danh thiếp vừa scan. Trả về null nếu lưu thất bại.
  Future<SavedCard?> saveFromScan(
    BusinessCardInfo info, {
    String? frontImagePath,
    String? backImagePath,
  }) async {
    if (state.isSaving) return null;
    emit(state.copyWith(isSaving: true));
    try {
      final card = await _repository.saveFromScan(
        info,
        frontImagePath: frontImagePath,
        backImagePath: backImagePath,
      );
      emit(state.copyWith(cards: [card, ...state.cards], isSaving: false));
      return card;
    } catch (e) {
      debugPrint('SavedCardsCubit.saveFromScan error: $e');
      emit(state.copyWith(isSaving: false));
      return null;
    }
  }

  Future<bool> updateNote(String id, String? note) async {
    final card = state.findById(id);
    if (card == null) return false;
    return updateCard(card.copyWith(note: SavedCard.clean(note)));
  }

  /// Lưu toàn bộ thay đổi của một danh thiếp (thông tin, ghi chú, ngày/nơi gặp, tag).
  Future<bool> updateCard(SavedCard card) async {
    try {
      final updated = await _repository.update(card.copyWith(updatedAt: DateTime.now()));
      _replace(updated);
      return true;
    } catch (e) {
      debugPrint('SavedCardsCubit.updateCard error: $e');
      return false;
    }
  }

  Future<bool> setImage(String id, {required bool isFront, required String sourcePath}) async {
    final card = state.findById(id);
    if (card == null) return false;
    try {
      final updated = await _repository.setImage(card, isFront: isFront, sourcePath: sourcePath);
      _replace(updated);
      return true;
    } catch (e) {
      debugPrint('SavedCardsCubit.setImage error: $e');
      return false;
    }
  }

  void _replace(SavedCard updated) {
    emit(state.copyWith(
      cards: state.cards.map((c) => c.id == updated.id ? updated : c).toList(),
    ));
  }

  /// Xoá ngay trên UI (cần cho Dismissible), sau đó xoá trên đĩa; lỗi thì nạp lại.
  Future<void> delete(String id) async {
    emit(state.copyWith(cards: state.cards.where((c) => c.id != id).toList()));
    try {
      await _repository.delete(id);
    } catch (e) {
      debugPrint('SavedCardsCubit.delete error: $e');
      await load();
    }
  }
}
