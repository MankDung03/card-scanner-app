import 'package:app_scanner_card/features/cards/domain/entities/saved_card.dart';
import 'package:app_scanner_card/features/cards/domain/repositories/card_repository.dart';
import 'package:app_scanner_card/features/cards/presentation/cubit/saved_cards_cubit.dart';
import 'package:app_scanner_card/features/cards/presentation/pages/card_detail_page.dart';
import 'package:app_scanner_card/features/cards/presentation/pages/duplicates_page.dart';
import 'package:app_scanner_card/features/cards/presentation/pages/merge_cards_page.dart';
import 'package:app_scanner_card/features/scan/domain/entities/business_card_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Repository trong bộ nhớ (widget test không chạy được I/O file thật trong fake async).
class _MemoryRepo implements CardRepository {
  final List<SavedCard> cards;
  _MemoryRepo(this.cards);

  @override
  Future<List<SavedCard>> getAll() async => [...cards];

  @override
  Future<SavedCard> update(SavedCard card) async {
    cards[cards.indexWhere((c) => c.id == card.id)] = card;
    return card;
  }

  @override
  Future<void> delete(String id) async => cards.removeWhere((c) => c.id == id);

  @override
  Future<List<SavedCard>> replaceAll(List<SavedCard> c) async => throw UnimplementedError();
  @override
  Future<List<SavedCard>> upsertAll(List<SavedCard> c) async => throw UnimplementedError();
  @override
  Future<SavedCard> saveFromScan(BusinessCardInfo info, {String? frontImagePath, String? backImagePath}) =>
      throw UnimplementedError();
  @override
  Future<SavedCard> setImage(SavedCard card, {required bool isFront, required String sourcePath}) =>
      throw UnimplementedError();
}

void main() {
  final t = DateTime(2026, 1, 1);
  SavedCard card(String id, String name, {String? note, String? duplicateOf, DateTime? updated}) => SavedCard(
        id: id,
        name: name,
        mobile: '090-1111-2222',
        note: note,
        createdAt: t,
        updatedAt: updated ?? t,
        duplicateOf: duplicateOf,
      );

  late SavedCardsCubit cubit;
  late GoRouter router;

  Future<void> pump(WidgetTester tester, List<SavedCard> cards, String initial) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    cubit = SavedCardsCubit(repository: _MemoryRepo(cards));
    await cubit.load();
    router = GoRouter(initialLocation: initial, routes: [
      GoRoute(path: '/', builder: (_, __) => const SizedBox(), routes: [
        GoRoute(
          path: 'cards/:id',
          builder: (_, s) => CardDetailPage(cardId: s.pathParameters['id']!),
        ),
        GoRoute(path: 'duplicates', builder: (_, __) => const DuplicatesPage(), routes: [
          GoRoute(
            path: ':id',
            builder: (_, s) => MergeCardsPage(
              flaggedId: s.pathParameters['id']!,
              fromDetail: s.uri.queryParameters['from'] == 'detail',
            ),
          ),
        ]),
      ]),
    ]);
    addTearDown(cubit.close);
    await tester.pumpWidget(BlocProvider.value(value: cubit, child: MaterialApp.router(routerConfig: router)));
    await tester.pumpAndSettle();
  }

  String location() => router.routerDelegate.currentConfiguration.last.matchedLocation;

  testWidgets('chi tiết thẻ nghi trùng → So sánh và gộp → sang chi tiết thẻ được giữ', (tester) async {
    await pump(tester, [
      card('keep', '山田 太郎', note: 'cũ'),
      card('dup', 'Yamada Taro', note: 'mới', duplicateOf: 'keep', updated: DateTime(2026, 6, 1)),
    ], '/cards/dup');

    // Banner chỉ hiện ở thẻ bị nghi trùng
    expect(find.text('Có thể trùng'), findsOneWidget);
    await tester.tap(find.text('So sánh và gộp'));
    await tester.pumpAndSettle();
    expect(location(), '/duplicates/dup');

    // Mặc định lấy giá trị của thẻ sửa gần đây hơn (thẻ mới); chọn lại tên của thẻ đang có
    await tester.tap(find.text('山田 太郎'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gộp và lưu'));
    await tester.pumpAndSettle();

    expect(location(), '/cards/keep');
    expect(cubit.state.cards, hasLength(1));
    final merged = cubit.state.cards.single;
    expect(merged.id, 'keep');
    expect(merged.name, '山田 太郎');
    expect(merged.note, 'mới');
    expect(merged.duplicateOf, isNull);
    expect(find.text('Có thể trùng'), findsNothing);
  });

  testWidgets('danh sách cặp trùng: Giữ cả hai → hết cặp', (tester) async {
    await pump(tester, [
      card('keep', '山田 太郎'),
      card('dup', '山田 太郎', note: 'x', duplicateOf: 'keep'),
    ], '/duplicates');

    expect(find.text('Trùng số di động'), findsOneWidget);
    await tester.tap(find.text('Giữ cả hai'));
    await tester.pumpAndSettle();

    expect(cubit.state.cards, hasLength(2));
    expect(cubit.state.duplicatePairs, isEmpty);
    expect(find.text('Không còn danh thiếp nào cần xem lại'), findsOneWidget);
  });
}
