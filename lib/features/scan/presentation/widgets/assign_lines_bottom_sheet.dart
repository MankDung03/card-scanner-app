import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/business_card_info.dart';
import '../../domain/services/custom_field_labels.dart';
import '../../domain/services/ocr_line_order.dart';
import 'custom_field_editor_sheet.dart';

/// Đích gán đặc biệt (ngoài 12 trường chuẩn)
class AssignTarget {
  const AssignTarget._();

  /// Tạo trường tuỳ chỉnh mới (cần [AssignLinesResult.label])
  static const custom = '_custom';

  /// Thêm vào ghi chú
  static const note = '_note';

  /// Đích nối nhiều dòng bằng xuống dòng (trường chuẩn nối bằng dấu cách)
  static bool isMultiline(String key) => key == custom || key == note;
}

/// Kết quả gán: đích ([BusinessCardInfo.fieldKeys] hoặc [AssignTarget]), nội dung (đã sửa),
/// nối thêm hay thay thế, tên trường (khi đích là [AssignTarget.custom], đã chuẩn hoá).
typedef AssignLinesResult = ({String fieldKey, String text, bool append, String? label});

/// Áp dụng [r] vào [info]; các dòng chưa gán theo [consumedIds] / [consumedTexts] được bỏ khỏi danh sách.
BusinessCardInfo applyAssignResult(
  BusinessCardInfo info,
  AssignLinesResult r, {
  Iterable<String> consumedIds = const [],
  Iterable<String> consumedTexts = const [],
}) {
  switch (r.fieldKey) {
    case AssignTarget.custom:
      return info.addCustomField(r.label ?? '', r.text,
          append: r.append, consumedLineIds: consumedIds, consumedLineTexts: consumedTexts);
    case AssignTarget.note:
      return info.appendNote(r.text, append: r.append, consumedLineIds: consumedIds, consumedLineTexts: consumedTexts);
    default:
      return info.assignText(r.fieldKey, r.text,
          append: r.append, consumedLineIds: consumedIds, consumedLineTexts: consumedTexts);
  }
}

/// Nhãn đã dịch của từng trường
String fieldLabel(AppLocalizations? l10n, String key) => switch (key) {
      'name' => l10n?.fullName ?? 'Họ tên',
      'furigana' => l10n?.furigana ?? 'Furigana',
      'jobTitle' => l10n?.jobTitle ?? 'Chức vụ',
      'department' => l10n?.department ?? 'Phòng ban',
      'company' => l10n?.company ?? 'Công ty',
      'phone' => l10n?.phone ?? 'Điện thoại',
      'mobile' => l10n?.mobile ?? 'Di động',
      'fax' => l10n?.fax ?? 'FAX',
      'email' => l10n?.email ?? 'Email',
      'website' => l10n?.website ?? 'Website',
      'postalCode' => l10n?.postalCode ?? 'Mã bưu chính',
      'address' => l10n?.address ?? 'Địa chỉ',
      AssignTarget.note => l10n?.noteLabel ?? 'Ghi chú',
      _ => key,
    };

/// Sheet gán các dòng đã chọn (theo thứ tự đọc) vào một đích:
/// trường mới / ghi chú / 12 trường chuẩn → sửa nội dung → (nếu đích đã có giá trị) Thay thế / Nối thêm.
///
/// Nội dung được nối lại mỗi khi đổi đích (dấu cách cho trường chuẩn, xuống dòng cho
/// trường tuỳ chỉnh / ghi chú) cho tới khi người dùng tự sửa ô nội dung.
class AssignLinesBottomSheet extends StatefulWidget {
  final List<String> lines;
  final BusinessCardInfo cardInfo;
  final List<String> labelSuggestions;
  final List<String> existingLabels;

  /// Đích chọn sẵn khi mở ([AssignTarget] hoặc key trường chuẩn)
  final String? initialTarget;

  const AssignLinesBottomSheet({
    super.key,
    required this.lines,
    required this.cardInfo,
    this.labelSuggestions = const [],
    this.existingLabels = const [],
    this.initialTarget,
  });

  static Future<AssignLinesResult?> show(
    BuildContext context, {
    required List<String> lines,
    required BusinessCardInfo cardInfo,
    List<String> labelSuggestions = const [],
    List<String> existingLabels = const [],
  }) {
    return showModalBottomSheet<AssignLinesResult>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AssignLinesBottomSheet(
        lines: lines,
        cardInfo: cardInfo,
        labelSuggestions: labelSuggestions,
        existingLabels: existingLabels,
      ),
    );
  }

  @override
  State<AssignLinesBottomSheet> createState() => _AssignLinesBottomSheetState();
}

class _AssignLinesBottomSheetState extends State<AssignLinesBottomSheet> {
  late final _controller = TextEditingController(text: _joined(multiline: false));
  final _label = TextEditingController();
  String? _fieldKey;
  bool _append = false;

  /// Người dùng đã tự sửa nội dung → không nối lại khi đổi đích
  bool _edited = false;

  @override
  void initState() {
    super.initState();
    // Chọn đích ban đầu TRƯỚC khi gắn listener (đổi nội dung ô ở đây không được gọi setState)
    final initial = widget.initialTarget;
    if (initial != null) _applyTarget(initial);
    _controller.addListener(_refresh);
    _label.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _controller.dispose();
    _label.dispose();
    super.dispose();
  }

  String _joined({required bool multiline}) => OcrLineOrder.join(widget.lines, multiline: multiline);

  /// Tên trường tuỳ chỉnh đã chuẩn hoá đang nhập
  String get _normalizedLabel => CustomFieldLabels.normalize(_label.text, existing: widget.existingLabels);

  /// Đích hiện tại đã có giá trị (để hỏi Thay thế / Nối thêm)
  bool _targetHasValue(String key) => switch (key) {
        AssignTarget.note => widget.cardInfo.note?.trim().isNotEmpty ?? false,
        AssignTarget.custom =>
          _normalizedLabel.isNotEmpty && widget.cardInfo.customFields.any((f) => f.label == _normalizedLabel),
        _ => widget.cardInfo.fieldValue(key)?.trim().isNotEmpty ?? false,
      };

  void _selectTarget(String key) => setState(() => _applyTarget(key));

  void _applyTarget(String key) {
    _fieldKey = key;
    if (!_edited) {
      final text = _joined(multiline: AssignTarget.isMultiline(key));
      _controller.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
    }
    // Địa chỉ / ghi chú / trường tuỳ chỉnh thường nhiều dòng → mặc định nối thêm; trường khác → thay thế
    _append = key == 'address' || AssignTarget.isMultiline(key);
  }

  void _submit() {
    final key = _fieldKey!;
    final label = key == AssignTarget.custom ? _normalizedLabel : null;
    Navigator.pop<AssignLinesResult>(context, (
      fieldKey: key,
      text: _controller.text.trim(),
      append: _targetHasValue(key) && _append,
      label: label,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B);
    final key = _fieldKey;
    final canAssign = key != null &&
        _controller.text.trim().isNotEmpty &&
        (key != AssignTarget.custom || _normalizedLabel.isNotEmpty);

    Widget sectionLabel(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.md, AppSpacing.s20, AppSpacing.xs),
          child: Text(text, style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600)),
        );

    Widget option(String value, String title, {String? subtitle, IconData? icon}) => RadioListTile<String>(
          value: value,
          dense: true,
          secondary: icon == null ? null : Icon(icon, size: 20),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: muted, fontSize: 12.5),
                ),
        );

    final note = widget.cardInfo.note?.trim();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: RadioGroup<String>(
                  groupValue: _fieldKey,
                  onChanged: (k) {
                    if (k != null) _selectTarget(k);
                  },
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.s18, AppSpacing.s20, AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n?.assignLineTitle ?? 'Gán văn bản vào mục:',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            AppSpacing.gapH12,
                            TextField(
                              key: const ValueKey('assign-text'),
                              controller: _controller,
                              minLines: 1,
                              maxLines: 4,
                              onChanged: (_) => _edited = true,
                              decoration: InputDecoration(
                                labelText: l10n?.assignTextLabel ?? 'Nội dung sẽ gán',
                                border: const OutlineInputBorder(borderRadius: AppRadius.r12),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      option(
                        AssignTarget.custom,
                        l10n?.newCustomFieldOption ?? 'Tạo trường mới',
                        icon: Icons.playlist_add_rounded,
                      ),
                      // Trường mới → nhập tên trường ngay dưới lựa chọn (chip gợi ý + gõ tự do).
                      // Nằm trong danh sách cuộn nên chip xuống dòng thoải mái, không đẩy nút Gán khỏi màn thấp.
                      if (key == AssignTarget.custom)
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.xs, AppSpacing.s20, AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                key: const ValueKey('assign-custom-label'),
                                controller: _label,
                                decoration: InputDecoration(
                                  labelText: l10n?.customFieldLabel ?? 'Tên trường',
                                  hintText: l10n?.customFieldLabelHint ?? 'VD: LINE, 資格',
                                  border: const OutlineInputBorder(borderRadius: AppRadius.r12),
                                  isDense: true,
                                ),
                              ),
                              AppSpacing.gapH8,
                              LabelSuggestionChips(suggestions: widget.labelSuggestions, controller: _label),
                            ],
                          ),
                        ),
                      option(
                        AssignTarget.note,
                        l10n?.noteTargetOption ?? 'Thêm vào Ghi chú',
                        subtitle: (note == null || note.isEmpty) ? null : note.replaceAll('\n', ' / '),
                        icon: Icons.sticky_note_2_outlined,
                      ),
                      sectionLabel(l10n?.standardFieldsGroup ?? 'Trường chuẩn'),
                      for (final k in BusinessCardInfo.fieldKeys)
                        option(
                          k,
                          fieldLabel(l10n, k),
                          subtitle: widget.cardInfo.fieldValue(k)?.trim().isNotEmpty ?? false
                              ? widget.cardInfo.fieldValue(k)!
                              : (l10n?.emptyValue ?? '(trống)'),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.xl, AppSpacing.s20, AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Đích đã có giá trị → chọn Thay thế / Nối thêm
                    if (key != null && _targetHasValue(key)) ...[
                      SegmentedButton<bool>(
                        segments: [
                          ButtonSegment(
                            value: false,
                            label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n?.replaceValue ?? 'Thay thế')),
                          ),
                          ButtonSegment(
                            value: true,
                            label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n?.appendValue ?? 'Nối thêm')),
                          ),
                        ],
                        selected: {_append},
                        showSelectedIcon: false,
                        onSelectionChanged: (s) => setState(() => _append = s.first),
                      ),
                      AppSpacing.gapH12,
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              shape: const RoundedRectangleBorder(borderRadius: AppRadius.r12),
                            ),
                            child: Text(l10n?.cancel ?? 'Hủy'),
                          ),
                        ),
                        AppSpacing.gapW10,
                        Expanded(
                          child: ElevatedButton(
                            onPressed: canAssign ? _submit : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              backgroundColor: AppColors.blueCardStart,
                              foregroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(borderRadius: AppRadius.r12),
                            ),
                            child: Text(
                              l10n?.assign ?? 'Gán',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
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
