import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/ocr_model.dart';

/// Lựa chọn trong hộp hỏi khi lưu:
/// - [skip] = true → lưu luôn, các dòng không gán vào đâu (vẫn còn trong chữ OCR gốc).
/// - [skip] = false → quay lại gán, [ids] là các dòng đã tick (chọn sẵn để gán).
/// Đóng hộp thoại (bấm ra ngoài / nút back) → null: không lưu, ở lại màn xác nhận.
typedef UnassignedLinesDecision = ({bool skip, Set<String> ids});

/// Hỏi gọn khi bấm Lưu mà còn dòng chưa gán (đã lọc rác): danh sách có ô tick (mặc định tick hết)
/// + 2 nút "Bỏ qua" / "Quay lại gán".
class UnassignedLinesDialog extends StatefulWidget {
  final List<OcrLine> lines;

  const UnassignedLinesDialog({super.key, required this.lines});

  static Future<UnassignedLinesDecision?> show(BuildContext context, List<OcrLine> lines) {
    return showDialog<UnassignedLinesDecision>(
      context: context,
      useRootNavigator: true,
      builder: (_) => UnassignedLinesDialog(lines: lines),
    );
  }

  @override
  State<UnassignedLinesDialog> createState() => _UnassignedLinesDialogState();
}

class _UnassignedLinesDialogState extends State<UnassignedLinesDialog> {
  late final Set<String> _ticked = widget.lines.map((l) => l.id).toSet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final count = widget.lines.length;

    return AlertDialog(
      // Cuộn được (tiêu đề + nội dung), nút luôn ở đáy: nhiều dòng / chữ to không tràn
      scrollable: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.r16),
      title: Text(l10n?.unassignedDialogTitle(count) ?? 'Còn $count dòng chưa gán'),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.unassignedDialogBody ??
                  'Dòng bỏ qua không mất: vẫn được lưu trong văn bản gốc và tìm kiếm được. '
                      'Tick các dòng muốn gán rồi chọn Quay lại gán.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 8),
            for (final line in widget.lines)
              CheckboxListTile(
                key: ValueKey('unassigned-${line.id}'),
                value: _ticked.contains(line.id),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(line.text, style: const TextStyle(fontSize: 14)),
                onChanged: (v) => setState(() {
                  if (v ?? false) {
                    _ticked.add(line.id);
                  } else {
                    _ticked.remove(line.id);
                  }
                }),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop<UnassignedLinesDecision>(context, (skip: true, ids: const <String>{})),
          child: Text(l10n?.skipUnassigned ?? 'Bỏ qua'),
        ),
        FilledButton(
          onPressed: _ticked.isEmpty
              ? null
              : () => Navigator.pop<UnassignedLinesDecision>(context, (skip: false, ids: {..._ticked})),
          style: FilledButton.styleFrom(
            backgroundColor: isDark ? AppColors.darkNavy : AppColors.navy,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
          ),
          child: Text(l10n?.backToAssign ?? 'Quay lại gán'),
        ),
      ],
    );
  }
}
