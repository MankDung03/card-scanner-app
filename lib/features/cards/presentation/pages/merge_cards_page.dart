import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/navy_header_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/saved_card.dart';
import '../cubit/saved_cards_cubit.dart';

/// Một mục có thể chọn khi gộp.
class _Field {
  final String key;
  final String label;
  final Object? Function(SavedCard) read;
  final bool isImage;

  const _Field(this.key, this.label, this.read, {this.isImage = false});
}

/// So sánh 2 danh thiếp (thẻ bị nghi trùng và thẻ đang có) rồi gộp làm một.
/// Thẻ đang có được giữ lại (giữ id, ngày tạo); thẻ bị nghi trùng bị xoá sau khi gộp.
class MergeCardsPage extends StatefulWidget {
  /// id của thẻ bị nghi trùng (có `duplicateOf`)
  final String flaggedId;

  /// Mở từ màn chi tiết của thẻ bị nghi trùng. Thẻ đó bị xoá khi gộp, nên gộp xong
  /// thay màn chi tiết đó bằng chi tiết của thẻ được giữ (thay vì quay về thẻ đã xoá).
  final bool fromDetail;

  const MergeCardsPage({super.key, required this.flaggedId, this.fromDetail = false});

  @override
  State<MergeCardsPage> createState() => _MergeCardsPageState();
}

class _MergeCardsPageState extends State<MergeCardsPage> {
  /// key → true nếu lấy giá trị của thẻ mới thêm
  final Map<String, bool> _useNew = {};
  bool _initialized = false;
  bool _saving = false;

  List<_Field> _fields(AppLocalizations? l10n) => [
        _Field('name', l10n?.fullName ?? 'Họ tên', (c) => c.name),
        _Field('furigana', l10n?.furigana ?? 'Furigana', (c) => c.furigana),
        _Field('company', l10n?.company ?? 'Công ty', (c) => c.company),
        _Field('department', l10n?.department ?? 'Phòng ban', (c) => c.department),
        _Field('jobTitle', l10n?.jobTitle ?? 'Chức vụ', (c) => c.jobTitle),
        _Field('phone', l10n?.phone ?? 'Điện thoại', (c) => c.phone),
        _Field('mobile', l10n?.mobile ?? 'Di động', (c) => c.mobile),
        _Field('fax', l10n?.fax ?? 'FAX', (c) => c.fax),
        _Field('email', l10n?.email ?? 'Email', (c) => c.email),
        _Field('website', l10n?.website ?? 'Website', (c) => c.website),
        _Field('postalCode', l10n?.postalCode ?? 'Mã bưu chính', (c) => c.postalCode),
        _Field('address', l10n?.address ?? 'Địa chỉ', (c) => c.address),
        _Field('metAt', l10n?.metDateLabel ?? 'Ngày gặp', (c) => c.metAt),
        _Field('metPlace', l10n?.metPlaceLabel ?? 'Nơi gặp', (c) => c.metPlace),
        _Field('note', l10n?.noteLabel ?? 'Ghi chú', (c) => c.note),
        _Field('frontImagePath', l10n?.frontSide ?? 'Mặt trước', (c) => c.frontImagePath, isImage: true),
        _Field('backImagePath', l10n?.backSide ?? 'Mặt sau', (c) => c.backImagePath, isImage: true),
      ];

  static bool _isEmpty(Object? v) => v == null || (v is String && v.trim().isEmpty);

  static bool _same(_Field f, Object? a, Object? b) {
    if (_isEmpty(a) && _isEmpty(b)) return true;
    if (_isEmpty(a) || _isEmpty(b)) return false;
    if (f.isImage) return false; // khác file → để người dùng xem và chọn
    if (a is DateTime && b is DateTime) return a.year == b.year && a.month == b.month && a.day == b.day;
    return a.toString().trim() == b.toString().trim();
  }

  /// Mặc định: bên có giá trị; cả hai có giá trị → bên được sửa gần đây hơn.
  void _initDefaults(List<_Field> fields, SavedCard original, SavedCard flagged) {
    final newerIsNew = flagged.updatedAt.isAfter(original.updatedAt);
    for (final f in fields) {
      final a = f.read(original), b = f.read(flagged);
      _useNew[f.key] = _isEmpty(a) ? !_isEmpty(b) : (!_isEmpty(b) && newerIsNew);
    }
  }

  SavedCard _merged(List<_Field> fields, SavedCard original, SavedCard flagged) {
    Object? v(String key) {
      final f = fields.firstWhere((f) => f.key == key);
      return (_useNew[key] ?? false) ? f.read(flagged) : f.read(original);
    }

    return original.copyWith(
      name: v('name'),
      furigana: v('furigana'),
      company: v('company'),
      department: v('department'),
      jobTitle: v('jobTitle'),
      phone: v('phone'),
      mobile: v('mobile'),
      fax: v('fax'),
      email: v('email'),
      website: v('website'),
      postalCode: v('postalCode'),
      address: v('address'),
      metAt: v('metAt'),
      metPlace: v('metPlace'),
      note: v('note'),
      frontImagePath: v('frontImagePath'),
      backImagePath: v('backImagePath'),
      tags: {...original.tags, ...flagged.tags}.toList(),
    );
  }

  Future<void> _save(List<_Field> fields, SavedCard original, SavedCard flagged) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    final ok = await context.read<SavedCardsCubit>().mergeCards(
          merged: _merged(fields, original, flagged),
          removeId: flagged.id,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(ok ? (l10n?.mergedMsg ?? 'Đã gộp danh thiếp') : (l10n?.mergeFailed ?? 'Không gộp được')),
        backgroundColor: ok ? null : const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ));
    if (!ok) return;
    router.pop();
    if (widget.fromDetail) router.pushReplacement(AppRoutes.cardDetailPath(original.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final state = context.watch<SavedCardsCubit>().state;
    final flagged = state.findById(widget.flaggedId);
    final original = flagged?.duplicateOf == null ? null : state.findById(flagged!.duplicateOf!);

    final header = NavyHeaderBar(
      title: l10n?.compareMerge ?? 'So sánh và gộp',
      leading: NavyHeaderTextButton(
        icon: Icons.chevron_left_rounded,
        label: l10n?.backAction ?? 'Quay lại',
        onPressed: () => context.pop(),
      ),
    );

    if (flagged == null || original == null) {
      return Scaffold(
        body: Column(children: [
          header,
          Expanded(child: Center(child: Text(l10n?.duplicatesEmpty ?? 'Không còn danh thiếp nào cần xem lại'))),
        ]),
      );
    }

    final fields = _fields(l10n);
    if (!_initialized) {
      _initDefaults(fields, original, flagged);
      _initialized = true;
    }
    final differing = [for (final f in fields) if (!_same(f, f.read(original), f.read(flagged))) f];
    final sameCount = fields.length - differing.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            header,
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.s16),
                children: [
                  Text(
                    l10n?.mergeHint ?? 'Chọn nội dung muốn giữ cho từng mục. Danh thiếp còn lại sẽ bị xoá.',
                    style: TextStyle(color: muted, fontSize: 13, height: 1.5),
                  ),
                  AppSpacing.gapH12,
                  for (final f in differing) ...[
                    _FieldChoice(
                      field: f,
                      original: f.read(original),
                      added: f.read(flagged),
                      useNew: _useNew[f.key] ?? false,
                      onChanged: (useNew) => setState(() => _useNew[f.key] = useNew),
                    ),
                    AppSpacing.gapH12,
                  ],
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: muted),
                      AppSpacing.gapW6,
                      Expanded(
                        child: Text(
                          [
                            if (sameCount > 0) l10n?.mergeSameFields(sameCount) ?? '$sameCount',
                            if (original.tags.isNotEmpty || flagged.tags.isNotEmpty)
                              l10n?.mergeTagsNote ?? 'Tag của cả hai danh thiếp đều được giữ',
                          ].join(' · '),
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.divider)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : () => _save(fields, original, flagged),
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkNavy : AppColors.navy,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    icon: const Icon(Icons.merge_rounded, size: 20),
                    label: Text(l10n?.mergeSave ?? 'Gộp và lưu'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Một mục khác nhau: 2 ô chọn (Đã có trên máy / Thẻ mới thêm).
class _FieldChoice extends StatelessWidget {
  final _Field field;
  final Object? original;
  final Object? added;
  final bool useNew;
  final ValueChanged<bool> onChanged;

  const _FieldChoice({
    required this.field,
    required this.original,
    required this.added,
    required this.useNew,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppRadius.r10,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(field.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          AppSpacing.gapH8,
          _Option(
            caption: l10n?.dupExisting ?? 'Đã có trên máy',
            value: original,
            isImage: field.isImage,
            selected: !useNew,
            onTap: () => onChanged(false),
          ),
          AppSpacing.gapH6,
          _Option(
            caption: l10n?.dupNew ?? 'Thẻ mới thêm',
            value: added,
            isImage: field.isImage,
            selected: useNew,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String caption;
  final Object? value;
  final bool isImage;
  final bool selected;
  final VoidCallback onTap;

  const _Option({
    required this.caption,
    required this.value,
    required this.isImage,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF93B4E0) : AppColors.navy;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final empty = value == null || (value is String && (value as String).trim().isEmpty);

    Widget content;
    if (empty) {
      content = Text(l10n?.emptyValue ?? '(trống)', style: TextStyle(color: muted, fontSize: 13.5));
    } else if (isImage) {
      final path = value as String;
      content = ClipRRect(
        borderRadius: AppRadius.r4,
        child: File(path).existsSync()
            ? Image.file(File(path), height: 64, fit: BoxFit.cover, cacheWidth: 400)
            : Icon(Icons.broken_image_outlined, color: muted),
      );
    } else if (value is DateTime) {
      content = Text(
        DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).format(value as DateTime),
        style: const TextStyle(fontSize: 14),
      );
    } else {
      content = Text(value.toString(), style: const TextStyle(fontSize: 14));
    }

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.r8,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: selected ? (isDark ? AppColors.darkNavy : AppColors.navyTint) : null,
            borderRadius: AppRadius.r8,
            border: Border.all(
              color: selected ? accent : (isDark ? AppColors.darkBorder : AppColors.divider),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                size: 18,
                color: selected ? accent : muted,
              ),
              AppSpacing.gapW8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(caption, style: TextStyle(color: muted, fontSize: 11)),
                    const SizedBox(height: 2),
                    content,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
