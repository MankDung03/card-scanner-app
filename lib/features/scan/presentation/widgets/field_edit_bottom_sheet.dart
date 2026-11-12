import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

class FieldEditBottomSheet extends StatefulWidget {
  final String label;
  final String? initialValue;
  final List<String> alternatives;
  final Function(String newValue) onSaved;

  const FieldEditBottomSheet({
    super.key,
    required this.label,
    required this.initialValue,
    this.alternatives = const [],
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String label,
    required String? initialValue,
    List<String> alternatives = const [],
    required Function(String newValue) onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FieldEditBottomSheet(
        label: label,
        initialValue: initialValue,
        alternatives: alternatives,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<FieldEditBottomSheet> createState() => _FieldEditBottomSheetState();
}

class _FieldEditBottomSheetState extends State<FieldEditBottomSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSaved(_controller.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpacing.gapH16,

          // Tiêu đề
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n?.editField ?? "Chỉnh sửa"}: ${widget.label}',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          AppSpacing.gapH12,

          // Danh sách các gợi ý thay thế (Alternatives) nếu có
          if (widget.alternatives.isNotEmpty) ...[
            Text(
              'Gợi ý từ danh thiếp:',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            AppSpacing.gapH8,
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: widget.alternatives.map((alt) {
                return ActionChip(
                  backgroundColor:
                      isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFBFDBFE),
                  ),
                  label: Text(
                    alt,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.text = alt;
                    });
                  },
                );
              }).toList(),
            ),
            AppSpacing.gapH14,
          ],

          // Ô nhập liệu
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: widget.label.contains('Địa chỉ') ? 3 : 1,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: AppRadius.r12,
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.r12,
                borderSide: BorderSide(color: AppColors.blueCardStart, width: 2),
              ),
              hintText: l10n?.enterFieldHint(widget.label) ?? 'Nhập ${widget.label}...',
            ),
            onSubmitted: (_) => _submit(),
          ),
          AppSpacing.gapH20,

          // Nút hành động
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.r12),
                  ),
                  child: Text(l10n?.cancel ?? 'Hủy'),
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueCardStart,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.r12),
                  ),
                  child: Text(
                    l10n?.done ?? 'Xong',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
