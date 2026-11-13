import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../l10n/app_localizations.dart';

/// Dialog nhập tag mới (kèm gợi ý từ các tag đã dùng). Trả về chuỗi người dùng nhập, hoặc null nếu huỷ.
class AddTagDialog extends StatefulWidget {
  final List<String> suggestions;

  const AddTagDialog({super.key, required this.suggestions});

  static Future<String?> show(BuildContext context, {List<String> suggestions = const []}) {
    return showDialog<String>(context: context, builder: (_) => AddTagDialog(suggestions: suggestions));
  }

  @override
  State<AddTagDialog> createState() => AddTagDialogState();
}

class AddTagDialogState extends State<AddTagDialog> {
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
