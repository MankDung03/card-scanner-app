import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/business_card_info.dart';

/// Kết quả gán: trường đích, nội dung (đã sửa), nối thêm hay thay thế
typedef AssignLinesResult = ({String fieldKey, String text, bool append});

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
      _ => key,
    };

/// Sheet gán các dòng đã chọn trên ảnh vào một trường:
/// sửa nội dung trước khi gán → chọn trường → (nếu trường đã có giá trị) Thay thế / Nối thêm.
class AssignLinesBottomSheet extends StatefulWidget {
  final String initialText;
  final BusinessCardInfo cardInfo;

  const AssignLinesBottomSheet({super.key, required this.initialText, required this.cardInfo});

  static Future<AssignLinesResult?> show(
    BuildContext context, {
    required String text,
    required BusinessCardInfo cardInfo,
  }) {
    return showModalBottomSheet<AssignLinesResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AssignLinesBottomSheet(initialText: text, cardInfo: cardInfo),
    );
  }

  @override
  State<AssignLinesBottomSheet> createState() => _AssignLinesBottomSheetState();
}

class _AssignLinesBottomSheetState extends State<AssignLinesBottomSheet> {
  late final _controller = TextEditingController(text: widget.initialText);
  String? _fieldKey;
  bool _append = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _hasValue(String key) => widget.cardInfo.fieldValue(key)?.trim().isNotEmpty ?? false;

  void _selectField(String key) {
    setState(() {
      _fieldKey = key;
      // Địa chỉ thường in trên nhiều dòng → mặc định nối thêm; trường khác → thay thế
      _append = key == 'address' && _hasValue(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B);
    final canAssign = _fieldKey != null && _controller.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.s18, AppSpacing.s20, AppSpacing.md),
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
              Flexible(
                child: RadioGroup<String>(
                  groupValue: _fieldKey,
                  onChanged: (k) {
                    if (k != null) _selectField(k);
                  },
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final key in BusinessCardInfo.fieldKeys)
                        RadioListTile<String>(
                          value: key,
                          dense: true,
                          title: Text(fieldLabel(l10n, key), style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            _hasValue(key) ? widget.cardInfo.fieldValue(key)! : (l10n?.emptyValue ?? '(trống)'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: muted, fontSize: 12.5),
                          ),
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
                    // Trường đã có giá trị → chọn Thay thế / Nối thêm
                    if (_fieldKey != null && _hasValue(_fieldKey!)) ...[
                      SegmentedButton<bool>(
                        segments: [
                          ButtonSegment(value: false, label: Text(l10n?.replaceValue ?? 'Thay thế')),
                          ButtonSegment(value: true, label: Text(l10n?.appendValue ?? 'Nối thêm')),
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
                            onPressed: canAssign
                                ? () => Navigator.pop<AssignLinesResult>(context, (
                                      fieldKey: _fieldKey!,
                                      text: _controller.text.trim(),
                                      append: _append,
                                    ))
                                : null,
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
