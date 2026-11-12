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
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/widgets/recent_card_tile.dart';
import '../../domain/entities/saved_card.dart';
import '../cubit/saved_cards_cubit.dart';
import '../utils/contact_launcher.dart';
import '../widgets/card_face_view.dart';
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
      builder: (_) => _AddTagDialog(suggestions: suggestions),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return BlocBuilder<SavedCardsCubit, SavedCardsState>(
      builder: (context, state) {
        final card = state.findById(widget.cardId);

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF3F5F9),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
              onPressed: () => context.pop(),
            ),
            title: Text(
              l10n?.cardDetailTitle ?? 'Danh thiếp',
              style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
            actions: [
              if (card != null)
                TextButton(
                  onPressed: () => _onEdit(card),
                  child: Text(
                    l10n?.edit ?? 'Sửa',
                    style: const TextStyle(
                      color: AppColors.linkColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              AppSpacing.gapW8,
            ],
          ),
          body: card == null
              ? Center(child: Text(l10n?.cardNotFound ?? 'Không tìm thấy danh thiếp'))
              : _buildBody(context, card, state, isDark),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SavedCard card, SavedCardsState state, bool isDark) {
    final l10n = _l10n;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final muted = isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B);
    final hasImageOnSide = _showFront ? card.frontImagePath != null : card.backImagePath != null;
    final tagSuggestions = {
      for (final c in state.cards) ...c.tags,
    }.where((t) => !card.tags.contains(t)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.sm, AppSpacing.s16, AppSpacing.s24),
      children: [
        // 1. Ảnh thẻ (mặt trước / mặt sau)
        Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: CardFaceView(
                key: ValueKey('${_showFront}_${_showFront ? card.frontImagePath : card.backImagePath}'),
                card: card,
                isFront: _showFront,
                onAddPhoto: () => _onPickImage(card),
              ),
            ),
            if (hasImageOnSide || _showFront)
              Positioned(
                right: 8,
                bottom: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: hasImageOnSide ? l10n?.changePhoto : l10n?.addPhoto,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 18),
                    onPressed: () => _onPickImage(card),
                  ),
                ),
              ),
          ],
        ),
        AppSpacing.gapH14,
        Center(
          child: _SideToggle(
            showFront: _showFront,
            frontLabel: l10n?.frontSide ?? 'Mặt trước',
            backLabel: l10n?.backSide ?? 'Mặt sau',
            onChanged: (front) => setState(() => _showFront = front),
          ),
        ),
        AppSpacing.gapH14,

        // 2. Người liên hệ
        _Section(child: _ContactHeader(card: card)),
        AppSpacing.gapH12,

        // 3. Nút hành động nhanh
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.call_outlined,
                label: l10n?.call ?? 'Gọi',
                fg: Colors.white,
                bg: AppColors.blueCardStart,
                onTap: (card.mobile ?? card.phone) == null ? null : () => _onCall(card),
              ),
            ),
            AppSpacing.gapW8,
            Expanded(
              child: _QuickAction(
                icon: Icons.mail_outline_rounded,
                label: l10n?.email ?? 'Email',
                fg: const Color(0xFF15803D),
                bg: const Color(0xFFDCFCE7),
                onTap: card.email == null ? null : () => _launch(() => ContactLauncher.email(card.email!)),
              ),
            ),
            AppSpacing.gapW8,
            Expanded(
              child: _QuickAction(
                icon: Icons.place_outlined,
                label: l10n?.map ?? 'Bản đồ',
                fg: const Color(0xFFB45309),
                bg: const Color(0xFFFEF3C7),
                onTap: card.address == null ? null : () => _launch(() => ContactLauncher.map(card.address!)),
              ),
            ),
            AppSpacing.gapW8,
            Expanded(
              child: _QuickAction(
                icon: Icons.ios_share_rounded,
                label: l10n?.export ?? 'Xuất',
                fg: const Color(0xFF7E22CE),
                bg: const Color(0xFFF3E8FF),
                onTap: () => _toast(l10n?.featureComingSoon ?? 'Chức năng sẽ được kích hoạt ở bước tiếp theo'),
              ),
            ),
          ],
        ),
        AppSpacing.gapH12,

        // 4. Thông tin liên hệ chi tiết
        _buildInfoList(card, isDark),
        AppSpacing.gapH12,

        // 5. Gặp ở đâu, khi nào + tag
        _Section(
          padding: const EdgeInsets.fromLTRB(16, 6, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n?.meetingSectionTitle ?? 'Gặp ở đâu, khi nào',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _onEditMeeting(card),
                    child: Text(
                      l10n?.edit ?? 'Sửa',
                      style: const TextStyle(color: AppColors.linkColor, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (card.metAt != null || card.metPlace != null) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (card.metAt != null)
                            _InfoChip(
                              icon: Icons.calendar_today_outlined,
                              text: DateFormat.yMd(localeTag).format(card.metAt!),
                              onTap: () => _onEditMeeting(card),
                            ),
                          if (card.metPlace != null)
                            _InfoChip(
                              icon: Icons.place_outlined,
                              text: card.metPlace!,
                              onTap: () => _onEditMeeting(card),
                            ),
                        ],
                      ),
                      AppSpacing.gapH10,
                    ],
                    if (card.note != null) ...[
                      Text(
                        card.note!,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          fontSize: 13.5,
                          height: 1.45,
                        ),
                      ),
                      AppSpacing.gapH12,
                    ],
                    if (card.metAt == null && card.metPlace == null && card.note == null) ...[
                      InkWell(
                        onTap: () => _onEditMeeting(card),
                        child: Text(
                          l10n?.meetingEmptyPrompt ?? 'Thêm ngày gặp, nơi gặp hoặc ghi chú để dễ nhớ hơn',
                          style: TextStyle(color: muted, fontSize: 13),
                        ),
                      ),
                      AppSpacing.gapH12,
                    ],
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in card.tags)
                          _TagChip(label: tag, onTap: () => _onRemoveTag(card, tag)),
                        _AddTagChip(
                          label: l10n?.addTag ?? 'Tag',
                          onTap: () => _onAddTag(card, tagSuggestions),
                        ),
                      ],
                    ),
                  ],
                ),
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

  Widget _buildInfoList(SavedCard card, bool isDark) {
    final l10n = _l10n;
    const green = (Color(0xFFDCFCE7), Color(0xFF16A34A));
    const blue = (Color(0xFFE0F2FE), Color(0xFF0284C7));
    const amber = (Color(0xFFFEF3C7), Color(0xFFD97706));

    final rows = <Widget>[
      if (card.phone != null)
        _InfoRow(
          icon: Icons.call_outlined,
          colors: green,
          label: l10n?.phone ?? 'Điện thoại',
          value: card.phone!,
          onTap: () => _launch(() => ContactLauncher.call(card.phone!)),
          onCopy: () => _copy(card.phone!),
        ),
      if (card.mobile != null)
        _InfoRow(
          icon: Icons.smartphone_outlined,
          colors: green,
          label: l10n?.mobile ?? 'Di động',
          value: card.mobile!,
          onTap: () => _launch(() => ContactLauncher.call(card.mobile!)),
          onCopy: () => _copy(card.mobile!),
        ),
      if (card.fax != null)
        _InfoRow(
          icon: Icons.print_outlined,
          colors: green,
          label: l10n?.fax ?? 'FAX',
          value: card.fax!,
          onCopy: () => _copy(card.fax!),
        ),
      if (card.email != null)
        _InfoRow(
          icon: Icons.mail_outline_rounded,
          colors: green,
          label: l10n?.email ?? 'Email',
          value: card.email!,
          onTap: () => _launch(() => ContactLauncher.email(card.email!)),
          onCopy: () => _copy(card.email!),
        ),
      if (card.website != null)
        _InfoRow(
          icon: Icons.language_rounded,
          colors: blue,
          label: l10n?.website ?? 'Website',
          value: card.website!,
          onTap: () => _launch(() => ContactLauncher.website(card.website!)),
          onCopy: () => _copy(card.website!),
        ),
      if (card.fullAddress != null)
        _InfoRow(
          icon: Icons.place_outlined,
          colors: amber,
          label: l10n?.address ?? 'Địa chỉ',
          value: card.fullAddress!,
          onTap: card.address == null ? null : () => _launch(() => ContactLauncher.map(card.address!)),
          onCopy: () => _copy(card.fullAddress!),
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    final divider = Divider(
      height: 1,
      thickness: 0.8,
      indent: 60,
      color: isDark ? AppColors.darkDivider : const Color(0xFFF1F5F9),
    );
    return _Section(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) divider,
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

  const _Section({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: AppRadius.r16,
      ),
      clipBehavior: Clip.antiAlias,
      padding: padding,
      child: child,
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
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? (isDark ? AppColors.darkSurface : Colors.white) : Colors.transparent,
            borderRadius: AppRadius.r8,
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 1))]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                  : (isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B)),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : const Color(0xFFE2E8F0),
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

class _ContactHeader extends StatelessWidget {
  final SavedCard card;

  const _ContactHeader({required this.card});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B);

    return Row(
      children: [
        SavedCardAvatar(card: card, size: 52),
        AppSpacing.gapW14,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (card.furigana != null)
                Text(card.furigana!, style: TextStyle(color: muted, fontSize: 11.5)),
              Text(
                card.displayName ?? l10n?.unnamedCard ?? '(Chưa có tên)',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              if (card.subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  card.subtitle,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF475569),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color fg;
  final Color bg;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.fg,
    required this.bg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: bg,
        borderRadius: AppRadius.r14,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.r14,
          child: SizedBox(
            height: 68,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: fg, size: 21),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final (Color, Color) colors;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final VoidCallback onCopy;

  const _InfoRow({
    required this.icon,
    required this.colors,
    required this.label,
    required this.value,
    required this.onCopy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      onLongPress: onCopy,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? colors.$2.withValues(alpha: 0.18) : colors.$1,
                borderRadius: AppRadius.r8,
              ),
              child: Icon(icon, color: colors.$2, size: 17),
            ),
            AppSpacing.gapW14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: muted, fontSize: 11.5)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _InfoChip({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.darkTextSecondary : const Color(0xFF334155);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.r8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: AppRadius.r8,
          border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
            Flexible(
              child: Text(text, style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w500)),
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

  static const _palette = [
    (Color(0xFFDBEAFE), Color(0xFF1D4ED8)),
    (Color(0xFFFEF3C7), Color(0xFFB45309)),
    (Color(0xFFDCFCE7), Color(0xFF15803D)),
    (Color(0xFFF3E8FF), Color(0xFF7E22CE)),
    (Color(0xFFFCE7F3), Color(0xFFBE185D)),
  ];

  @override
  Widget build(BuildContext context) {
    // Màu cố định theo nội dung tag (hash ổn định giữa các lần chạy)
    final hash = label.codeUnits.fold<int>(0, (h, c) => (h * 31 + c) & 0x7fffffff);
    final colors = _palette[hash % _palette.length];
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.r16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: colors.$1, borderRadius: AppRadius.r16),
        child: Text(
          label,
          style: TextStyle(color: colors.$2, fontSize: 12.5, fontWeight: FontWeight.w700),
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
    final fg = isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.r16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: AppRadius.r16,
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
        ),
        child: Text('+ $label', style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _AddTagDialog extends StatefulWidget {
  final List<String> suggestions;

  const _AddTagDialog({required this.suggestions});

  @override
  State<_AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<_AddTagDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.r16),
      title: Text('+ ${l10n?.addTag ?? 'Tag'}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 30,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: l10n?.tagHint ?? 'Tên tag'),
            onSubmitted: (v) => Navigator.pop(context, v),
          ),
          if (widget.suggestions.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in widget.suggestions.take(8))
                  ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 12.5)),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(context, s),
                  ),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.cancel ?? 'Hủy'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n?.save ?? 'Lưu'),
        ),
      ],
    );
  }
}
