import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// Bottom sheet nhập ghi chú "gặp ở đâu". Trả về nội dung khi bấm Lưu, null khi huỷ.
class MeetingNoteBottomSheet extends StatefulWidget {
  final String? initialValue;

  const MeetingNoteBottomSheet({super.key, this.initialValue});

  static Future<String?> show(BuildContext context, {String? initialValue}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MeetingNoteBottomSheet(initialValue: initialValue),
    );
  }

  @override
  State<MeetingNoteBottomSheet> createState() => _MeetingNoteBottomSheetState();
}

class _MeetingNoteBottomSheetState extends State<MeetingNoteBottomSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.s18, AppSpacing.s20, AppSpacing.s16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n?.addMeetingNote ?? 'Ghi chú gặp ở đâu',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              AppSpacing.gapH12,
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 3,
                maxLines: 5,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n?.meetingNoteHint ?? 'VD: Gặp ở hội thảo tại Tokyo, 12/11',
                  border: const OutlineInputBorder(borderRadius: AppRadius.r12),
                ),
              ),
              AppSpacing.gapH8,
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
                      onPressed: () => Navigator.pop(context, _controller.text.trim()),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        backgroundColor: AppColors.blueCardStart,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.r12),
                      ),
                      child: Text(
                        l10n?.save ?? 'Lưu',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
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
