import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/navy_header_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/saved_card.dart';
import '../../../scan/presentation/cubit/scan_cubit.dart';
import '../../domain/services/card_list_query.dart';
import '../cubit/card_sort_cubit.dart';
import '../cubit/saved_cards_cubit.dart';
import '../widgets/card_list_item.dart';
import '../widgets/csv_export_dialog.dart';
import '../widgets/meeting_note_bottom_sheet.dart';

/// Màn hình danh sách toàn bộ danh thiếp đã lưu trên máy.
class SavedCardsPage extends StatefulWidget {
  const SavedCardsPage({super.key});

  @override
  State<SavedCardsPage> createState() => _SavedCardsPageState();
}

class _SavedCardsPageState extends State<SavedCardsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _hasNoteOnly = false;
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query != _searchQuery) {
        setState(() {
          _searchQuery = query;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDelete(BuildContext context, SavedCard card) async {
    final l10n = AppLocalizations.of(context);
    final cardName = card.displayName ?? l10n?.unnamedCard ?? '';
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.r16),
        title: Text(l10n?.deleteCardTitle ?? 'Xoá danh thiếp?'),
        content: Text(
          cardName.isNotEmpty
              ? '${l10n?.deleteCardMessage ?? "Danh thiếp và ảnh sẽ bị xoá khỏi máy này."}\n\n($cardName)'
              : (l10n?.deleteCardMessage ?? 'Danh thiếp và ảnh sẽ bị xoá khỏi máy này.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
            child: Text(l10n?.delete ?? 'Xoá'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _onDeleted(BuildContext context, SavedCard card) {
    final l10n = AppLocalizations.of(context);
    context.read<SavedCardsCubit>().delete(card.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.cardDeleted ?? 'Đã xoá danh thiếp'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _editNote(BuildContext context, SavedCard card) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<SavedCardsCubit>();

    final note = await MeetingNoteBottomSheet.show(context, initialValue: card.note);
    if (note == null) return;

    final ok = await cubit.updateNote(card.id, note);
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok
            ? (l10n?.noteSaved ?? 'Đã lưu ghi chú')
            : (l10n?.cardSaveFailed ?? 'Không thể lưu danh thiếp, vui lòng thử lại')),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Bộ lọc hiện tại. Tag đã chọn nhưng không còn tồn tại (đã xoá) được bỏ qua.
  CardListQuery _query(CardSortOrder sort, List<String> availableTags) => CardListQuery(
        search: _searchQuery,
        sort: sort,
        hasNoteOnly: _hasNoteOnly,
        tags: _selectedTags.where(availableTags.contains).toSet(),
      );

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _hasNoteOnly = false;
      _selectedTags.clear();
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (!_selectedTags.remove(tag)) _selectedTags.add(tag);
    });
  }

  void _onScanNewCard(BuildContext context) {
    context.read<ScanCubit>().startNewScan();
    context.push(AppRoutes.scanCamera);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final accent = isDark ? const Color(0xFF93B4E0) : AppColors.navy;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      // Nút chụp: nút nổi kéo thả của AppShell (tab Danh thiếp là màn gốc nên không có nút back)
      child: Scaffold(
        body: BlocBuilder<SavedCardsCubit, SavedCardsState>(
          builder: (context, state) {
            final header = NavyHeaderBar(
              title: l10n?.savedCardsTitle ?? 'Danh thiếp đã lưu',
              subtitle: state.cards.isEmpty
                  ? null
                  : (l10n?.cardsCount(state.cards.length) ?? '${state.cards.length} danh thiếp'),
              // Xuất toàn bộ danh thiếp ra CSV
              trailing: state.cards.isEmpty
                  ? null
                  : NavyHeaderTextButton(
                      icon: Icons.file_download_outlined,
                      label: l10n?.exportCsv ?? 'Xuất CSV',
                      onPressed: () => CsvExportDialog.show(context, state.cards),
                    ),
            );

            if (state.isLoading && state.cards.isEmpty) {
              return Column(children: [header, const Expanded(child: Center(child: CircularProgressIndicator()))]);
            }

            if (state.cards.isEmpty) {
              return Column(
                children: [
                  header,
                  Expanded(
                    child: SavedCardsEmptyView(
                      message: l10n?.noSavedCards,
                      onScanTap: () => _onScanNewCard(context),
                    ),
                  ),
                ],
              );
            }

            final sort = context.watch<CardSortCubit>().state;
            final availableTags = CardListQuery.tagsByUsage(state.cards);
            final query = _query(sort, availableTags);
            final filteredCards = query.apply(state.cards);
            final isFiltering = query.isFiltering;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,

                // 1. Ô tìm kiếm
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, AppSpacing.md),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: textPrimary, fontSize: 14.5),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
                      hintText: l10n?.searchCardPlaceholder ?? 'Tìm tên, công ty, SĐT, ghi chú...',
                      hintStyle: TextStyle(color: textMuted, fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded, color: textMuted, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.cancel_rounded, size: 18),
                              color: textMuted,
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.r8,
                        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.r8,
                        borderSide: BorderSide(color: accent, width: 1.4),
                      ),
                    ),
                  ),
                ),

                // 2. Sắp xếp + bộ lọc (Có ghi chú, từng tag)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                  child: Row(
                    children: [
                      _SortChip(
                        label: _sortLabel(l10n, sort),
                        tooltip: l10n?.sortBy ?? 'Sắp xếp theo',
                        current: sort,
                        labelOf: (o) => _sortLabel(l10n, o),
                        onSelected: (o) => context.read<CardSortCubit>().setSort(o),
                      ),
                      AppSpacing.gapW8,
                      _FilterChip(
                        label: l10n?.filterHasNote ?? 'Có ghi chú',
                        icon: Icons.edit_note_rounded,
                        isSelected: _hasNoteOnly,
                        onTap: () => setState(() => _hasNoteOnly = !_hasNoteOnly),
                      ),
                      for (final tag in availableTags) ...[
                        AppSpacing.gapW8,
                        _FilterChip(
                          label: tag,
                          icon: Icons.sell_outlined,
                          isSelected: _selectedTags.contains(tag),
                          onTap: () => _toggleTag(tag),
                        ),
                      ],
                    ],
                  ),
                ),

                // 3. Tóm tắt khi đang lọc
                if (isFiltering)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.sm, AppSpacing.sm, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n?.showingCardsCount(filteredCards.length, state.cards.length) ??
                                'Hiển thị ${filteredCards.length} / ${state.cards.length} danh thiếp',
                            style: TextStyle(color: textMuted, fontSize: 12.5),
                          ),
                        ),
                        TextButton(
                          onPressed: _clearFilters,
                          style: TextButton.styleFrom(
                            foregroundColor: accent,
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          child: Text(l10n?.clearFilters ?? 'Xoá bộ lọc'),
                        ),
                      ],
                    ),
                  ),

                AppSpacing.gapH8,

                // 4. Danh sách (có tiêu đề nhóm khi sắp xếp theo công ty)
                Expanded(
                  child: filteredCards.isEmpty
                      ? _NoSearchResultsView(query: _searchQuery, onClear: _clearFilters)
                      : _buildList(context, l10n, filteredCards, sort),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _sortLabel(AppLocalizations? l10n, CardSortOrder order) => switch (order) {
        CardSortOrder.newest => l10n?.sortNewest ?? 'Mới nhất',
        CardSortOrder.oldest => l10n?.sortOldest ?? 'Cũ nhất',
        CardSortOrder.nameAZ => l10n?.sortNameAZ ?? 'Tên A-Z',
        CardSortOrder.companyAZ => l10n?.sortCompanyAZ ?? 'Công ty A-Z',
      };

  Widget _buildList(
    BuildContext context,
    AppLocalizations? l10n,
    List<SavedCard> cards,
    CardSortOrder sort,
  ) {
    // Danh sách phẳng gồm tiêu đề nhóm (_GroupHeader) và thẻ (SavedCard).
    // Các thẻ liền nhau giữa 2 tiêu đề ghép thành một khối trắng.
    final items = <Object>[];
    final headerCounts = <int, int>{};
    if (sort == CardSortOrder.companyAZ) {
      for (final group in CardListQuery.groupByCompany(cards)) {
        headerCounts[items.length] = group.cards.length;
        items.add(_GroupHeader(group.company ?? l10n?.noCompanyGroup ?? 'Không có công ty'));
        items.addAll(group.cards);
      }
    } else {
      items.addAll(cards);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 0, AppSpacing.s16, 96), // chừa chỗ cho FAB
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is _GroupHeader) {
          return _CompanyHeader(title: item.title, count: headerCounts[index] ?? 0, isFirst: index == 0);
        }
        final card = item as SavedCard;
        final isFirst = index == 0 || items[index - 1] is _GroupHeader;
        final isLast = index == items.length - 1 || items[index + 1] is _GroupHeader;

        return Dismissible(
          key: ValueKey(card.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(context, card),
          onDismissed: (_) => _onDeleted(context, card),
          background: Container(
            padding: const EdgeInsets.only(right: AppSpacing.s20),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626),
              borderRadius: BorderRadius.vertical(
                top: isFirst ? const Radius.circular(AppRadius.md) : Radius.zero,
                bottom: isLast ? const Radius.circular(AppRadius.md) : Radius.zero,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
                AppSpacing.gapW6,
                Text(
                  l10n?.delete ?? 'Xoá',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ),
          ),
          child: CardListItem(
            card: card,
            isFirst: isFirst,
            isLast: isLast,
            onTap: () => context.push(AppRoutes.cardDetailPath(card.id)),
            onEditNote: () => _editNote(context, card),
            onDelete: () async {
              final confirmed = await _confirmDelete(context, card);
              if (confirmed && context.mounted) {
                _onDeleted(context, card);
              }
            },
          ),
        );
      },
    );
  }
}

class _GroupHeader {
  final String title;
  const _GroupHeader(this.title);
}

/// Tiêu đề nhóm công ty: "株式会社サンプル商事  3"
class _CompanyHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isFirst;

  const _CompanyHeader({required this.title, required this.count, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.darkTextSecondary : AppColors.textTertiary;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    return Padding(
      padding: EdgeInsets.fromLTRB(2, isFirst ? 4 : AppSpacing.s16, 2, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3),
            ),
          ),
          Text('$count', style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Khung chip dùng chung: bo 8, viền mảnh; chọn → nền navy nhạt, chữ navy.
class _ChipFrame extends StatelessWidget {
  final bool isSelected;
  final Widget child;

  const _ChipFrame({required this.isSelected, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? AppColors.darkNavy : AppColors.navyTint)
            : (isDark ? AppColors.darkSurface : AppColors.surface),
        borderRadius: AppRadius.r8,
        border: Border.all(
          color: isSelected
              ? (isDark ? const Color(0xFF93B4E0) : AppColors.navy)
              : (isDark ? AppColors.darkBorder : AppColors.divider),
        ),
      ),
      child: child,
    );
  }
}

/// Chip sắp xếp: hiện cách sắp xếp hiện tại, chạm để mở menu chọn.
class _SortChip extends StatelessWidget {
  final String label;
  final String tooltip;
  final CardSortOrder current;
  final String Function(CardSortOrder) labelOf;
  final ValueChanged<CardSortOrder> onSelected;

  const _SortChip({
    required this.label,
    required this.tooltip,
    required this.current,
    required this.labelOf,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.darkTextPrimary : AppColors.navy;

    return PopupMenuButton<CardSortOrder>(
      useRootNavigator: true,
      tooltip: tooltip,
      initialValue: current,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
      itemBuilder: (_) => [
        for (final o in CardSortOrder.values)
          CheckedPopupMenuItem(value: o, checked: o == current, child: Text(labelOf(o))),
      ],
      child: _ChipFrame(
        isSelected: false,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_vert_rounded, size: 16, color: fg),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w700)),
            Icon(Icons.arrow_drop_down_rounded, size: 18, color: fg),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isSelected
        ? (isDark ? AppColors.darkTextPrimary : AppColors.navy)
        : (isDark ? AppColors.darkTextMuted : AppColors.textMuted);

    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.r8,
        child: _ChipFrame(
          isSelected: isSelected,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isSelected ? Icons.check_rounded : icon, size: 15, color: fg),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Giao diện khi chưa tìm thấy danh thiếp khớp từ khoá
class _NoSearchResultsView extends StatelessWidget {
  final String query;
  final VoidCallback onClear;

  const _NoSearchResultsView({required this.query, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final accent = isDark ? const Color(0xFF93B4E0) : AppColors.navy;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: textMuted),
            AppSpacing.gapH12,
            Text(
              l10n?.noSearchResults ?? 'Không tìm thấy danh thiếp nào',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            AppSpacing.gapH6,
            Text(
              query.isNotEmpty
                  ? '${l10n?.noSearchResultsDesc ?? "Thử tìm với từ khoá khác hoặc xoá bộ lọc"}\n("$query")'
                  : (l10n?.noSearchResultsDesc ?? 'Thử tìm với từ khoá khác hoặc xoá bộ lọc'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: textMuted, height: 1.5),
            ),
            AppSpacing.gapH16,
            OutlinedButton(
              onPressed: onClear,
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.divider),
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.r8),
              ),
              child: Text(l10n?.clearFilters ?? 'Xoá bộ lọc'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Giao diện rỗng khi chưa có danh thiếp nào trong máy
class SavedCardsEmptyView extends StatelessWidget {
  final String? message;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onScanTap;

  const SavedCardsEmptyView({
    super.key,
    this.message,
    this.padding = const EdgeInsets.all(AppSpacing.s24),
    this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.contact_mail_outlined, size: 40, color: muted),
            AppSpacing.gapH12,
            Text(
              message ?? 'Chưa có danh thiếp nào. Hãy scan tấm đầu tiên!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            if (onScanTap != null) ...[
              AppSpacing.gapH6,
              Text(l10n?.offlineBadge ?? 'Xử lý ngay trên máy · không cần mạng', style: TextStyle(color: muted, fontSize: 12.5)),
              AppSpacing.gapH20,
              FilledButton.icon(
                onPressed: onScanTap,
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: Text(l10n?.captureCardTitle ?? 'Chụp ảnh'),
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? AppColors.darkNavy : AppColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
