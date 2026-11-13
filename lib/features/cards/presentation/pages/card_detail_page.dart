import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/navy_header_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/saved_card.dart';
import '../cubit/saved_cards_cubit.dart';
import '../utils/contact_launcher.dart';
import '../widgets/add_tag_dialog.dart';
import '../widgets/card_face_view.dart';
import '../widgets/card_image_viewer.dart';
import '../widgets/card_share_sheet.dart';
import '../widgets/duplicate_banner.dart';
import '../widgets/meeting_info_bottom_sheet.dart';

/// Màn chi tiết danh thiếp: ảnh 2 mặt, thông tin, gặp ở đâu/khi nào, tag, nút gọi/email/bản đồ.
class CardDetailPage extends StatefulWidget {
  final String cardId;

  const CardDetailPage({super.key, required this.cardId});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  bool _showFront = true;

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  void _toast(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? const Color(0xFFDC2626) : null,
        duration: const Duration(seconds: 2),
      ));
  }

  Future<void> _launch(Future<bool> Function() action) async {
    final ok = await action();
    if (!ok && mounted) {
      _toast(_l10n?.cannotOpenApp ?? 'Không mở được ứng dụng phù hợp trên máy', error: true);
    }
  }

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    _toast(_l10n?.copied ?? 'Đã sao chép');
  }

  // ───────────────────────── Actions ─────────────────────────

  Future<void> _onCall(SavedCard card) async {
    final numbers = <(String, String)>[
      if (card.mobile != null) (_l10n?.mobile ?? 'Di động', card.mobile!),
      if (card.phone != null) (_l10n?.phone ?? 'Điện thoại', card.phone!),
    ];
    if (numbers.isEmpty) return;
    if (numbers.length == 1) return _launch(() => ContactLauncher.call(numbers.first.$2));

    final chosen = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text(
                _l10n?.choosePhoneNumber ?? 'Chọn số để gọi',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            for (final (label, number) in numbers)
              ListTile(
                leading: const Icon(Icons.call_outlined, color: Color(0xFF16A34A)),
                title: Text(number, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(label),
                onTap: () => Navigator.pop(ctx, number),
              ),
            AppSpacing.gapH8,
          ],
        ),
      ),
    );
    if (chosen != null) await _launch(() => ContactLauncher.call(chosen));
  }

  Future<void> _onEditMeeting(SavedCard card) async {
    final result = await MeetingInfoBottomSheet.show(context, card);
    if (result == null || !mounted) return;
    final ok = await context.read<SavedCardsCubit>().updateCard(card.copyWith(
          metAt: result.metAt,
          metPlace: result.metPlace,
          note: result.note,
        ));
    if (mounted && !ok) _toast(_l10n?.cardSaveFailed ?? 'Không thể lưu', error: true);
  }

  Future<void> _onAddTag(SavedCard card, List<String> suggestions) async {
    final tag = await showDialog<String>(
      context: context,
      builder: (_) => AddTagDialog(suggestions: suggestions),
    );
    final cleaned = SavedCard.clean(tag);
    if (cleaned == null || !mounted) return;
    if (card.tags.any((t) => t.toLowerCase() == cleaned.toLowerCase())) return;
    await context.read<SavedCardsCubit>().updateCard(card.copyWith(tags: [...card.tags, cleaned]));
  }

  Future<void> _onRemoveTag(SavedCard card, String tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_l10n?.removeTag ?? 'Xoá tag'),
        content: Text('"$tag"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_l10n?.cancel ?? 'Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
            child: Text(_l10n?.delete ?? 'Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context
        .read<SavedCardsCubit>()
        .updateCard(card.copyWith(tags: card.tags.where((t) => t != tag).toList()));
  }

  Future<void> _onPickImage(SavedCard card) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpacing.gapH8,
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(_l10n?.captureCardTitle ?? 'Chụp ảnh'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(_l10n?.gallery ?? 'Thư viện'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            AppSpacing.gapH8,
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final cubit = context.read<SavedCardsCubit>();
    try {
      final picked = await ImagePicker().pickImage(source: source, maxWidth: 2000, imageQuality: 90);
      if (picked == null) return;
      final ok = await cubit.setImage(card.id, isFront: _showFront, sourcePath: picked.path);
      if (mounted && !ok) _toast(_l10n?.cardSaveFailed ?? 'Không thể lưu', error: true);
    } catch (e) {
      if (mounted) _toast(e.toString(), error: true);
    }
  }

  Future<void> _onEdit(SavedCard card) async {
    final deleted = await context.push<bool>(AppRoutes.cardEditPath(card.id));
    if (deleted == true && mounted) context.pop();
  }

  // ───────────────────────── Build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;

    return BlocBuilder<SavedCardsCubit, SavedCardsState>(
      builder: (context, state) {
        final card = state.findById(widget.cardId);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            body: Column(
              children: [
                // Header navy: [< Quay lại]  Chi tiết danh thiếp  [✎ Sửa]
                NavyHeaderBar(
                  title: l10n?.cardDetailTitle ?? 'Danh thiếp',
                  leading: NavyHeaderTextButton(
                    icon: Icons.chevron_left_rounded,
                    label: l10n?.backAction ?? 'Quay lại',
                    onPressed: () => context.pop(),
                  ),
                  trailing: card == null
                      ? null
                      : NavyHeaderTextButton(
                          icon: Icons.edit_outlined,
                          label: l10n?.edit ?? 'Sửa',
                          onPressed: () => _onEdit(card),
                        ),
                ),
                // Thẻ đang bị nghi trùng (cờ còn hiệu lực) → mở thẳng màn so sánh và gộp
                if (card?.duplicateOf != null && state.findById(card!.duplicateOf!) != null)
                  DuplicateBanner(
                    text: l10n?.dupTag ?? 'Có thể trùng',
                    actionLabel: l10n?.compareMerge ?? 'So sánh và gộp',
                    onTap: () => context.push(AppRoutes.mergePath(card.id, fromDetail: true)),
                  ),
                Expanded(
                  child: card == null
                      ? Center(child: Text(l10n?.cardNotFound ?? 'Không tìm thấy danh thiếp'))
                      : _buildBody(context, card, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SavedCard card, SavedCardsState state) {
    final l10n = _l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final imagePath = _showFront ? card.frontImagePath : card.backImagePath;
    final hasImageOnSide = imagePath != null && File(imagePath).existsSync();
    final tagSuggestions = {
      for (final c in state.cards) ...c.tags,
    }.where((t) => !card.tags.contains(t)).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        // Chừa chỗ cho nút chụp nổi để dòng cuối cuộn lên được, không bị nút che
        96 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        // 1. Ảnh thẻ (mặt trước / mặt sau)
        Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: CardFaceView(
                key: ValueKey('${_showFront}_$imagePath'),
                card: card,
                isFront: _showFront,
                onAddPhoto: () => _onPickImage(card),
              ),
            ),
            // Đổi / thêm ảnh
            if (hasImageOnSide || _showFront)
              Positioned(
                right: 8,
                top: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: AppRadius.r8,
                  child: IconButton(
                    tooltip: hasImageOnSide ? l10n?.changePhoto : l10n?.addPhoto,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 18),
                    onPressed: () => _onPickImage(card),
                  ),
                ),
              ),
            // Nút kính lúp: mở màn xem ảnh toàn màn hình (chạm vào ảnh cũng mở)
            if (hasImageOnSide)
              Positioned(
                right: 8,
                bottom: 8,
                child: GestureDetector(
                  onTap: () => CardImageViewer.open(context, card: card, isFront: _showFront),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          l10n?.tapToZoom ?? 'Chạm để phóng to',
                          style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        AppSpacing.gapH12,
        Center(
          child: _SideToggle(
            showFront: _showFront,
            frontLabel: l10n?.frontSide ?? 'Mặt trước',
            backLabel: l10n?.backSide ?? 'Mặt sau',
            onChanged: (front) => setState(() => _showFront = front),
          ),
        ),
        AppSpacing.gapH16,

        // 2. Tên + bảng công ty / phòng ban / chức vụ
        _Section(child: _ContactHeader(card: card)),
        AppSpacing.gapH12,

        // 3. Hành động nhanh
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.call_outlined,
                label: l10n?.call ?? 'Gọi',
                onTap: (card.mobile ?? card.phone) == null ? null : () => _onCall(card),
              ),
            ),
            AppSpacing.gapW8,
            Expanded(
              child: _QuickAction(
                icon: Icons.mail_outline_rounded,
                label: l10n?.email ?? 'Email',
                onTap: card.email == null ? null : () => _launch(() => ContactLauncher.email(card.email!)),
              ),
            ),
            AppSpacing.gapW8,
            Expanded(
              child: _QuickAction(
                icon: Icons.place_outlined,
                label: l10n?.map ?? 'Bản đồ',
                onTap: card.address == null ? null : () => _launch(() => ContactLauncher.map(card.address!)),
              ),
            ),
            AppSpacing.gapW8,
            Expanded(
              child: _QuickAction(
                icon: Icons.ios_share_rounded,
                label: l10n?.export ?? 'Xuất',
                onTap: () => CardShareSheet.show(context, card),
              ),
            ),
          ],
        ),
        AppSpacing.gapH12,

        // 4. Liên hệ
        _buildInfoList(card),
        AppSpacing.gapH12,

        // 5. Thông tin trao đổi · ghi chú · tag
        _Section(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                title: l10n?.meetingSectionTitle ?? 'Gặp ở đâu, khi nào',
                actionLabel: l10n?.edit ?? 'Sửa',
                onAction: () => _onEditMeeting(card),
              ),
              AppSpacing.gapH10,
              if (card.metAt != null || card.metPlace != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _LabeledValue(
                        label: l10n?.metDateLabel ?? 'Ngày gặp',
                        value: card.metAt == null ? '—' : DateFormat.yMd(localeTag).format(card.metAt!),
                      ),
                    ),
                    AppSpacing.gapW12,
                    Expanded(
                      child: _LabeledValue(
                        label: l10n?.metPlaceLabel ?? 'Nơi gặp',
                        value: card.metPlace ?? '—',
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH12,
              ],
              if (card.note != null) ...[
                InkWell(
                  onTap: () => _onEditMeeting(card),
                  borderRadius: AppRadius.r8,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
                      borderRadius: AppRadius.r8,
                    ),
                    child: Text(
                      card.note!,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontSize: 13.5,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),
                AppSpacing.gapH12,
              ],
              if (card.metAt == null && card.metPlace == null && card.note == null) ...[
                InkWell(
                  onTap: () => _onEditMeeting(card),
                  child: Text(
                    l10n?.meetingEmptyPrompt ?? 'Thêm ngày gặp, nơi gặp hoặc ghi chú để dễ nhớ hơn',
                    style: TextStyle(color: muted, fontSize: 13, height: 1.5),
                  ),
                ),
                AppSpacing.gapH12,
              ],
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in card.tags) _TagChip(label: tag, onTap: () => _onRemoveTag(card, tag)),
                  _AddTagChip(label: l10n?.addTag ?? 'Tag', onTap: () => _onAddTag(card, tagSuggestions)),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.gapH16,

        // 6. Footer
        Text(
          l10n?.addedOnLocal(DateFormat.yMd(localeTag).format(card.createdAt)) ??
              'Đã thêm ${DateFormat('dd/MM/yyyy').format(card.createdAt)} · Chỉ lưu trên máy này',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInfoList(SavedCard card) {
    final l10n = _l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final rows = <Widget>[
      if (card.phone != null)
        _InfoRow(
          label: l10n?.phone ?? 'Điện thoại',
          value: card.phone!,
          onTap: () => _launch(() => ContactLauncher.call(card.phone!)),
          onCopy: () => _copy(card.phone!),
        ),
      if (card.mobile != null)
        _InfoRow(
          label: l10n?.mobile ?? 'Di động',
          value: card.mobile!,
          onTap: () => _launch(() => ContactLauncher.call(card.mobile!)),
          onCopy: () => _copy(card.mobile!),
        ),
      if (card.fax != null)
        _InfoRow(
          label: l10n?.fax ?? 'FAX',
          value: card.fax!,
          onCopy: () => _copy(card.fax!),
        ),
      if (card.email != null)
        _InfoRow(
          label: l10n?.email ?? 'Email',
          value: card.email!,
          onTap: () => _launch(() => ContactLauncher.email(card.email!)),
          onCopy: () => _copy(card.email!),
        ),
      if (card.website != null)
        _InfoRow(
          label: l10n?.website ?? 'Website',
          value: card.website!,
          onTap: () => _launch(() => ContactLauncher.website(card.website!)),
          onCopy: () => _copy(card.website!),
        ),
      if (card.fullAddress != null)
        _InfoRow(
          label: l10n?.address ?? 'Địa chỉ',
          value: card.fullAddress!,
          onTap: card.address == null ? null : () => _launch(() => ContactLauncher.map(card.address!)),
          onCopy: () => _copy(card.fullAddress!),
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    final divider = Divider(height: 1, thickness: 1, color: isDark ? AppColors.darkDivider : AppColors.divider);
    return _Section(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.xxl, AppSpacing.xs, AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(title: l10n?.sectionContact ?? 'Liên hệ'),
          AppSpacing.gapH4,
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Padding(padding: const EdgeInsets.only(right: AppSpacing.xl), child: divider),
            rows[i],
          ],
        ],
      ),
    );
  }
}

// ───────────────────────── Widgets ─────────────────────────

class _Section extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Section({required this.child, this.padding = const EdgeInsets.all(AppSpacing.s16)});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppRadius.r10,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Tiêu đề khối, tuỳ chọn có nút chữ bên phải (vd. "Sửa").
class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionTitle({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: isDark ? const Color(0xFF93B4E0) : AppColors.navy,
              minimumSize: const Size(0, 28),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _LabeledValue extends StatelessWidget {
  final String label;
  final String value;

  const _LabeledValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, fontSize: 11.5)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SideToggle extends StatelessWidget {
  final bool showFront;
  final String frontLabel;
  final String backLabel;
  final ValueChanged<bool> onChanged;

  const _SideToggle({
    required this.showFront,
    required this.frontLabel,
    required this.backLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget segment(String label, bool selected, VoidCallback onTap) {
      return Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minWidth: 88, minHeight: 34),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: selected ? (isDark ? AppColors.darkSurface : Colors.white) : Colors.transparent,
              borderRadius: AppRadius.r8,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                    : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : AppColors.divider,
        borderRadius: AppRadius.r10,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment(frontLabel, showFront, () => onChanged(true)),
          segment(backLabel, !showFront, () => onChanged(false)),
        ],
      ),
    );
  }
}

/// Furigana + tên lớn, bên dưới là bảng Công ty / Phòng ban / Chức vụ.
class _ContactHeader extends StatelessWidget {
  final SavedCard card;

  const _ContactHeader({required this.card});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    final facts = <(String, String)>[
      if (card.company != null && card.company != card.displayName) (l10n?.company ?? 'Công ty', card.company!),
      if (card.department != null) (l10n?.department ?? 'Phòng ban', card.department!),
      if (card.jobTitle != null) (l10n?.jobTitle ?? 'Chức vụ', card.jobTitle!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (card.furigana != null) Text(card.furigana!, style: TextStyle(color: muted, fontSize: 11.5)),
        Text(
          card.displayName ?? l10n?.unnamedCard ?? '(Chưa có tên)',
          style: TextStyle(color: textPrimary, fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
        if (facts.isNotEmpty) ...[
          AppSpacing.gapH12,
          for (final (label, value) in facts)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(label, style: TextStyle(color: muted, fontSize: 12.5, height: 1.5)),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

/// Ô hành động nhanh: nền trắng viền mảnh, icon + chữ navy.
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickAction({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.darkTextPrimary : AppColors.navy;

    return Opacity(
      opacity: onTap != null ? 1 : 0.4,
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r10,
          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: fg, size: 21),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dòng liên hệ: nhãn nhỏ + giá trị (màu navy nếu chạm được) + nút sao chép.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final VoidCallback onCopy;

  const _InfoRow({required this.label, required this.value, required this.onCopy, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final linkColor = isDark ? const Color(0xFF93B4E0) : AppColors.navy;

    return InkWell(
      onTap: onTap,
      onLongPress: onCopy,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: muted, fontSize: 11.5)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: onTap != null
                          ? linkColor
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onCopy,
              icon: Icon(Icons.copy_rounded, size: 17, color: muted),
              tooltip: AppLocalizations.of(context)?.copied,
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TagChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.r4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkNavy : AppColors.navyTint,
          borderRadius: AppRadius.r4,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AddTagChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddTagChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.r4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: AppRadius.r4,
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
        ),
        child: Text('+ $label', style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
