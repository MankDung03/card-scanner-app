import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/saved_card.dart';
import '../cubit/saved_cards_cubit.dart';
import '../widgets/card_list_item.dart';
import '../widgets/meeting_note_bottom_sheet.dart';

enum CardSortFilter {
  newest,
  nameAZ,
  hasNote,
  oldest,
}

/// Màn hình danh sách toàn bộ danh thiếp đã lưu trên máy.
class SavedCardsPage extends StatefulWidget {
  const SavedCardsPage({super.key});

  @override
  State<SavedCardsPage> createState() => _SavedCardsPageState();
}

class _SavedCardsPageState extends State<SavedCardsPage> {
  final TextEditingController _searchController = TextEditingController();
  CardSortFilter _currentFilter = CardSortFilter.newest;
  String _searchQuery = '';

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

  List<SavedCard> _filterAndSort(List<SavedCard> originalList) {
    var result = originalList;

    // 1. Tìm kiếm (theo query)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((c) {
        final name = (c.name ?? '').toLowerCase();
        final company = (c.company ?? '').toLowerCase();
        final dept = (c.department ?? '').toLowerCase();
        final job = (c.jobTitle ?? '').toLowerCase();
        final phone = (c.phone ?? '').toLowerCase();
        final mobile = (c.mobile ?? '').toLowerCase();
        final email = (c.email ?? '').toLowerCase();
        final note = (c.note ?? '').toLowerCase();
        final address = (c.address ?? '').toLowerCase();

        return name.contains(q) ||
            company.contains(q) ||
            dept.contains(q) ||
            job.contains(q) ||
            phone.contains(q) ||
            mobile.contains(q) ||
            email.contains(q) ||
            note.contains(q) ||
            address.contains(q);
      }).toList();
    }

    // 2. Lọc theo filter
    if (_currentFilter == CardSortFilter.hasNote) {
      result = result.where((c) => c.note != null && c.note!.trim().isNotEmpty).toList();
    }

    // 3. Sắp xếp
    final sorted = List<SavedCard>.from(result);
    switch (_currentFilter) {
      case CardSortFilter.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case CardSortFilter.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case CardSortFilter.nameAZ:
        sorted.sort((a, b) {
          final nameA = (a.displayName ?? '').toLowerCase();
          final nameB = (b.displayName ?? '').toLowerCase();
          return nameA.compareTo(nameB);
        });
        break;
      case CardSortFilter.hasNote:
        // Đã lọc có note, sắp xếp theo mới nhất
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return sorted;
  }

  void _onScanNewCard(BuildContext context) {
    context.push(AppRoutes.scanCamera);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final searchBg = isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9);
    final searchBorder = isDark ? AppColors.darkBorder : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: BlocBuilder<SavedCardsCubit, SavedCardsState>(
          builder: (context, state) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n?.savedCardsTitle ?? 'Danh thiếp đã lưu',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (state.cards.isNotEmpty) ...[
                  AppSpacing.gapW8,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.blueCardStart.withValues(alpha: 0.2)
                          : const Color(0xFFEFF6FF),
                      borderRadius: AppRadius.r12,
                      border: Border.all(
                        color: isDark
                            ? AppColors.blueCardStart.withValues(alpha: 0.4)
                            : const Color(0xFFBFDBFE),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${state.cards.length}',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF93C5FD) : AppColors.blueCardStart,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onScanNewCard(context),
        backgroundColor: AppColors.blueCardStart,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.camera_alt_rounded, size: 20),
        label: Text(
          l10n?.scanCardAction ?? 'Quét thẻ mới',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      body: BlocBuilder<SavedCardsCubit, SavedCardsState>(
        builder: (context, state) {
          if (state.isLoading && state.cards.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.cards.isEmpty) {
            return SavedCardsEmptyView(
              message: l10n?.noSavedCards,
              onScanTap: () => _onScanNewCard(context),
            );
          }

          final filteredCards = _filterAndSort(state.cards);
          final isFiltering = _searchQuery.isNotEmpty || _currentFilter != CardSortFilter.newest;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Search Box
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.sm, AppSpacing.s20, AppSpacing.sm),
                child: Container(
                  decoration: BoxDecoration(
                    color: searchBg,
                    borderRadius: AppRadius.r12,
                    border: Border.all(color: searchBorder, width: 1.1),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: textPrimary, fontSize: 14.5),
                    decoration: InputDecoration(
                      hintText: l10n?.searchCardPlaceholder ?? 'Tìm tên, công ty, SĐT, ghi chú...',
                      hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded, color: textSecondary, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.cancel_rounded, size: 18),
                              color: textSecondary,
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ),

              // 2. Filter & Sort Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: 4),
                child: Row(
                  children: [
                    _FilterChip(
                      label: l10n?.sortNewest ?? 'Mới nhất',
                      icon: Icons.access_time_rounded,
                      isSelected: _currentFilter == CardSortFilter.newest,
                      onTap: () => setState(() => _currentFilter = CardSortFilter.newest),
                    ),
                    AppSpacing.gapW8,
                    _FilterChip(
                      label: l10n?.sortNameAZ ?? 'Tên A-Z',
                      icon: Icons.sort_by_alpha_rounded,
                      isSelected: _currentFilter == CardSortFilter.nameAZ,
                      onTap: () => setState(() => _currentFilter = CardSortFilter.nameAZ),
                    ),
                    AppSpacing.gapW8,
                    _FilterChip(
                      label: l10n?.filterHasNote ?? 'Có ghi chú',
                      icon: Icons.sticky_note_2_outlined,
                      isSelected: _currentFilter == CardSortFilter.hasNote,
                      onTap: () => setState(() => _currentFilter = CardSortFilter.hasNote),
                    ),
                    AppSpacing.gapW8,
                    _FilterChip(
                      label: l10n?.sortOldest ?? 'Cũ nhất',
                      icon: Icons.history_rounded,
                      isSelected: _currentFilter == CardSortFilter.oldest,
                      onTap: () => setState(() => _currentFilter = CardSortFilter.oldest),
                    ),
                  ],
                ),
              ),

              // 3. Count summary if filtered
              if (isFiltering)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n?.showingCardsCount(filteredCards.length, state.cards.length) ??
                            'Hiển thị ${filteredCards.length} / ${state.cards.length} danh thiếp',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _currentFilter = CardSortFilter.newest);
                        },
                        child: Text(
                          l10n?.clearSearch ?? 'Xoá bộ lọc',
                          style: const TextStyle(
                            color: AppColors.linkColor,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              AppSpacing.gapH4,

              // 4. Cards List
              Expanded(
                child: filteredCards.isEmpty
                    ? _NoSearchResultsView(
                        query: _searchQuery,
                        onClear: () {
                          _searchController.clear();
                          setState(() => _currentFilter = CardSortFilter.newest);
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s20,
                          AppSpacing.sm,
                          AppSpacing.s20,
                          80, // bottom padding cho FAB
                        ),
                        itemCount: filteredCards.length,
                        itemBuilder: (context, index) {
                          final card = filteredCards[index];
                          return Dismissible(
                            key: ValueKey(card.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => _confirmDelete(context, card),
                            onDismissed: (_) => _onDeleted(context, card),
                            background: Container(
                              margin: const EdgeInsets.only(bottom: AppSpacing.md),
                              padding: const EdgeInsets.only(right: AppSpacing.s20),
                              alignment: Alignment.centerRight,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDC2626),
                                borderRadius: AppRadius.r16,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Xoá',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            child: CardListItem(
                              card: card,
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
                      ),
              ),
            ],
          );
        },
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

    final selectedBg = isDark
        ? AppColors.blueCardStart.withValues(alpha: 0.25)
        : const Color(0xFFEFF6FF);
    final selectedBorder = isDark
        ? AppColors.blueCardStart.withValues(alpha: 0.6)
        : const Color(0xFF93C5FD);
    final selectedFg = isDark ? const Color(0xFF93C5FD) : AppColors.blueCardStart;

    final unselectedBg = isDark ? AppColors.darkSurface : Colors.white;
    final unselectedBorder = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final unselectedFg = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.r16,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: AppRadius.r16,
            border: Border.all(
              color: isSelected ? selectedBorder : unselectedBorder,
              width: 1.1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? selectedFg : unselectedFg,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? selectedFg : unselectedFg,
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

  const _NoSearchResultsView({
    required this.query,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 32,
                color: textSecondary,
              ),
            ),
            AppSpacing.gapH16,
            Text(
              l10n?.noSearchResults ?? 'Không tìm thấy danh thiếp nào',
              style: TextStyle(
                fontSize: 16,
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
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            AppSpacing.gapH16,
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(l10n?.clearSearch ?? 'Xoá tìm kiếm'),
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.r12),
              ),
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
    final color = isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B);

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.contact_mail_outlined,
                size: 38,
                color: color,
              ),
            ),
            AppSpacing.gapH16,
            Text(
              message ?? 'Chưa có danh thiếp nào. Hãy scan tấm đầu tiên!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.gapH6,
            Text(
              l10n?.offlineBadge ?? 'Xử lý ngay trên máy · không cần mạng',
              style: TextStyle(
                color: color,
                fontSize: 12.5,
              ),
            ),
            if (onScanTap != null) ...[
              AppSpacing.gapH20,
              ElevatedButton.icon(
                onPressed: onScanTap,
                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                label: Text(
                  l10n?.captureCardTitle ?? 'Chụp ảnh',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueCardStart,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.r12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
