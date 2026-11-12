import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/saved_card.dart';
import '../cubit/saved_cards_cubit.dart';

/// Sửa các trường thông tin của danh thiếp. Pop với `true` nếu danh thiếp bị xoá.
class CardEditPage extends StatefulWidget {
  final String cardId;

  const CardEditPage({super.key, required this.cardId});

  @override
  State<CardEditPage> createState() => _CardEditPageState();
}

class _CardEditPageState extends State<CardEditPage> {
  static const _keys = [
    'name',
    'furigana',
    'jobTitle',
    'department',
    'company',
    'phone',
    'mobile',
    'fax',
    'email',
    'website',
    'postalCode',
    'address',
  ];

  late final SavedCard? _card;
  late final Map<String, TextEditingController> _controllers;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _card = context.read<SavedCardsCubit>().state.findById(widget.cardId);
    _controllers = {
      for (final k in _keys) k: TextEditingController(text: _valueOf(_card, k) ?? ''),
    };
  }

  static String? _valueOf(SavedCard? c, String key) => switch (key) {
        'name' => c?.name,
        'furigana' => c?.furigana,
        'jobTitle' => c?.jobTitle,
        'department' => c?.department,
        'company' => c?.company,
        'phone' => c?.phone,
        'mobile' => c?.mobile,
        'fax' => c?.fax,
        'email' => c?.email,
        'website' => c?.website,
        'postalCode' => c?.postalCode,
        'address' => c?.address,
        _ => null,
      };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _v(String key) => SavedCard.clean(_controllers[key]!.text);

  Future<void> _save() async {
    final card = _card;
    if (card == null || _saving) return;
    setState(() => _saving = true);

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<SavedCardsCubit>().updateCard(card.copyWith(
          name: _v('name'),
          furigana: _v('furigana'),
          jobTitle: _v('jobTitle'),
          department: _v('department'),
          company: _v('company'),
          phone: _v('phone'),
          mobile: _v('mobile'),
          fax: _v('fax'),
          email: _v('email'),
          website: _v('website'),
          postalCode: _v('postalCode'),
          address: _v('address'),
        ));
    if (!mounted) return;
    setState(() => _saving = false);

    messenger.showSnackBar(SnackBar(
      content: Text(ok
          ? (l10n?.cardUpdated ?? 'Đã cập nhật danh thiếp')
          : (l10n?.cardSaveFailed ?? 'Không thể lưu danh thiếp, vui lòng thử lại')),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
    if (ok) context.pop(false);
  }

  Future<void> _delete() async {
    final card = _card;
    if (card == null) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.r16),
        title: Text(l10n?.deleteCardTitle ?? 'Xoá danh thiếp?'),
        content: Text(l10n?.deleteCardMessage ?? 'Danh thiếp và ảnh sẽ bị xoá khỏi máy này.'),
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
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    await context.read<SavedCardsCubit>().delete(card.id);
    messenger.showSnackBar(SnackBar(
      content: Text(l10n?.cardDeleted ?? 'Đã xoá danh thiếp'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    final labels = <String, (String, IconData, TextInputType)>{
      'name': (l10n?.fullName ?? 'Họ tên', Icons.person_outline_rounded, TextInputType.name),
      'furigana': (l10n?.furigana ?? 'Furigana', Icons.text_fields_rounded, TextInputType.text),
      'jobTitle': (l10n?.jobTitle ?? 'Chức vụ', Icons.work_outline_rounded, TextInputType.text),
      'department': (l10n?.department ?? 'Phòng ban', Icons.domain_outlined, TextInputType.text),
      'company': (l10n?.company ?? 'Công ty', Icons.business_outlined, TextInputType.text),
      'phone': (l10n?.phone ?? 'Điện thoại', Icons.call_outlined, TextInputType.phone),
      'mobile': (l10n?.mobile ?? 'Di động', Icons.smartphone_outlined, TextInputType.phone),
      'fax': (l10n?.fax ?? 'FAX', Icons.print_outlined, TextInputType.phone),
      'email': (l10n?.email ?? 'Email', Icons.mail_outline_rounded, TextInputType.emailAddress),
      'website': (l10n?.website ?? 'Website', Icons.language_rounded, TextInputType.url),
      'postalCode': (l10n?.postalCode ?? 'Mã bưu chính', Icons.markunread_mailbox_outlined, TextInputType.text),
      'address': (l10n?.address ?? 'Địa chỉ', Icons.place_outlined, TextInputType.streetAddress),
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textPrimary),
          onPressed: () => context.pop(false),
        ),
        title: Text(
          l10n?.editCardTitle ?? 'Sửa danh thiếp',
          style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _card == null || _saving ? null : _save,
            child: Text(
              l10n?.save ?? 'Lưu',
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
      body: _card == null
          ? Center(child: Text(l10n?.cardNotFound ?? 'Không tìm thấy danh thiếp'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.sm, AppSpacing.s16, AppSpacing.s28),
              children: [
                for (final key in _keys) ...[
                  TextField(
                    controller: _controllers[key],
                    keyboardType: labels[key]!.$3,
                    maxLines: key == 'address' ? 3 : 1,
                    minLines: 1,
                    textInputAction: key == 'address' ? TextInputAction.newline : TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: labels[key]!.$1,
                      prefixIcon: Icon(labels[key]!.$2, size: 19),
                      border: const OutlineInputBorder(borderRadius: AppRadius.r12),
                      isDense: true,
                    ),
                  ),
                  AppSpacing.gapH12,
                ],
                AppSpacing.gapH12,
                OutlinedButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 19),
                  label: Text(l10n?.deleteCard ?? 'Xoá danh thiếp'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    minimumSize: const Size.fromHeight(48),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.r12),
                  ),
                ),
              ],
            ),
    );
  }
}
