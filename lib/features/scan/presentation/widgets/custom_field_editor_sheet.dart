import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/custom_field.dart';
import '../../domain/services/custom_field_labels.dart';

/// Kết quả sửa trường tuỳ chỉnh: [field] mới, hoặc [deleted] = true khi người dùng xoá.
typedef CustomFieldEditResult = ({CustomField? field, bool deleted});

/// Chip gợi ý tên trường; chạm để điền vào [controller].
class LabelSuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final TextEditingController controller;

  const LabelSuggestionChips({super.key, required this.suggestions, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    final current = controller.text.trim();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final s in suggestions)
          ChoiceChip(
            label: Text(s),
            selected: current.isNotEmpty && CustomFieldLabels.same(current, s),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const StadiumBorder(),
            onSelected: (_) {
              controller.text = s;
              controller.selection = TextSelection.collapsed(offset: s.length);
            },
          ),
      ],
    );
  }
}

/// Bottom sheet tạo / sửa một trường tuỳ chỉnh: tên trường (chip gợi ý + gõ tự do) và nội dung
/// (nhiều dòng). Tên được chuẩn hoá bằng [CustomFieldLabels.normalize] khi lưu.
class CustomFieldEditorSheet extends StatefulWidget {
  final CustomField? initial;
  final List<String> suggestions;

  /// Tên đã dùng (để chuẩn hoá về cùng một cách viết)
  final List<String> existingLabels;

  const CustomFieldEditorSheet({
    super.key,
    this.initial,
    this.suggestions = const [],
    this.existingLabels = const [],
  });

  static Future<CustomFieldEditResult?> show(
    BuildContext context, {
    CustomField? initial,
    List<String> suggestions = const [],
    List<String> existingLabels = const [],
  }) {
    return showModalBottomSheet<CustomFieldEditResult>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => CustomFieldEditorSheet(
        initial: initial,
        suggestions: suggestions,
        existingLabels: existingLabels,
      ),
    );
  }

  @override
  State<CustomFieldEditorSheet> createState() => _CustomFieldEditorSheetState();
}

class _CustomFieldEditorSheetState extends State<CustomFieldEditorSheet> {
  late final _label = TextEditingController(text: widget.initial?.label ?? '');
  late final _value = TextEditingController(text: widget.initial?.value ?? '');

  @override
  void initState() {
    super.initState();
    _label.addListener(_refresh);
    _value.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _label.dispose();
    _value.dispose();
    super.dispose();
  }

  void _save() {
    final label = CustomFieldLabels.normalize(_label.text, existing: widget.existingLabels);
    final value = _value.text.trim();
    if (label.isEmpty || value.isEmpty) return;
    Navigator.pop<CustomFieldEditResult>(context, (field: CustomField(label: label, value: value), deleted: false));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final canSave = _label.text.trim().isNotEmpty && _value.text.trim().isNotEmpty;
    final isEdit = widget.initial != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEdit ? (l10n?.editCustomField ?? 'Sửa trường') : (l10n?.addCustomField ?? 'Thêm trường'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              AppSpacing.gapH14,
              TextField(
                key: const ValueKey('custom-field-label'),
                controller: _label,
                autofocus: !isEdit,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n?.customFieldLabel ?? 'Tên trường',
                  hintText: l10n?.customFieldLabelHint ?? 'VD: LINE, 資格',
                  border: const OutlineInputBorder(borderRadius: AppRadius.r12),
                  isDense: true,
                ),
              ),
              if (widget.suggestions.isNotEmpty) ...[
                AppSpacing.gapH8,
                Text(l10n?.labelSuggestions ?? 'Gợi ý', style: TextStyle(color: muted, fontSize: 12)),
                AppSpacing.gapH6,
                LabelSuggestionChips(suggestions: widget.suggestions, controller: _label),
              ],
              AppSpacing.gapH14,
              TextField(
                key: const ValueKey('custom-field-value'),
                controller: _value,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: l10n?.customFieldValue ?? 'Nội dung',
                  border: const OutlineInputBorder(borderRadius: AppRadius.r12),
                  isDense: true,
                ),
              ),
              AppSpacing.gapH16,
              Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  if (isEdit)
                    TextButton.icon(
                      onPressed: () => Navigator.pop<CustomFieldEditResult>(context, (field: null, deleted: true)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: Text(l10n?.deleteCustomField ?? 'Xoá trường'),
                    ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
                    ),
                    child: Text(l10n?.cancel ?? 'Hủy'),
                  ),
                  FilledButton(
                    onPressed: canSave ? _save : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkNavy : AppColors.navy,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
                    ),
                    child: Text(l10n?.save ?? 'Lưu'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
