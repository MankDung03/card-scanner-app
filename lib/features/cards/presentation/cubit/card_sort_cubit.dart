import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/app_settings_storage.dart';
import '../../domain/services/card_list_query.dart';

/// Cách sắp xếp đang chọn ở màn danh sách — được ghi nhớ giữa các lần mở app.
class CardSortCubit extends Cubit<CardSortOrder> {
  final AppSettingsStorage? _storage;

  CardSortCubit({AppSettingsStorage? storage})
      : _storage = storage,
        super(_read(storage));

  static CardSortOrder _read(AppSettingsStorage? storage) {
    final saved = storage?.cardSortOrder;
    return CardSortOrder.values.firstWhere(
      (o) => o.name == saved,
      orElse: () => CardSortOrder.newest,
    );
  }

  Future<void> setSort(CardSortOrder order) async {
    if (order == state) return;
    emit(order);
    try {
      await _storage?.setCardSortOrder(order.name);
    } catch (e) {
      debugPrint('CardSortCubit: cannot save sort order: $e');
    }
  }
}
