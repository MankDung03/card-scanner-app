import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/saved_card.dart';

typedef MeetingInfo = ({DateTime? metAt, String? metPlace, String? note});

/// Bottom sheet sửa thông tin "Gặp ở đâu, khi nào".
/// Trả về [MeetingInfo] khi bấm Lưu, null khi huỷ.
class MeetingInfoBottomSheet extends StatefulWidget {
  final SavedCard card;

  const MeetingInfoBottomSheet({super.key, required this.card});

  static Future<MeetingInfo?> show(BuildContext context, SavedCard card) {
    return showModalBottomSheet<MeetingInfo>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MeetingInfoBottomSheet(card: card),
    );
  }

  @override
  State<MeetingInfoBottomSheet> createState() => _MeetingInfoBottomSheetState();
}

class _MeetingInfoBottomSheetState extends State<MeetingInfoBottomSheet> {
  late DateTime? _metAt = widget.card.metAt;
  late final _placeController = TextEditingController(text: widget.card.metPlace ?? '');
  late final _noteController = TextEditingController(text: widget.card.note ?? '');

  @override
  void dispose() {
    _placeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _metAt ?? widget.card.createdAt,
      firstDate: DateTime(now.year - 30),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) setState(() => _metAt = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.s18, AppSpacing.s20, AppSpacing.s16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n?.meetingSectionTitle ?? 'Gặp ở đâu, khi nào',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              AppSpacing.gapH16,

              // Ngày gặp
              InkWell(
                onTap: _pickDate,
                borderRadius: AppRadius.r12,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n?.metDateLabel ?? 'Ngày gặp',
                    prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                    suffixIcon: _metAt == null
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => setState(() => _metAt = null),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.r12,
                      borderSide: BorderSide(color: border),
                    ),
                  ),
                  child: Text(
                    _metAt == null ? '—' : DateFormat.yMd(localeTag).format(_metAt!),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
              AppSpacing.gapH12,

              // Nơi gặp
              TextField(
                controller: _placeController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n?.metPlaceLabel ?? 'Nơi gặp',
                  hintText: l10n?.metPlaceHint ?? 'VD: Triển lãm IT, Tokyo',
                  prefixIcon: const Icon(Icons.place_outlined, size: 18),
                  border: const OutlineInputBorder(borderRadius: AppRadius.r12),
                ),
              ),
              AppSpacing.gapH12,

              // Ghi chú
              TextField(
                controller: _noteController,
                minLines: 3,
                maxLines: 6,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n?.noteLabel ?? 'Ghi chú',
                  hintText: l10n?.meetingNoteHint,
                  alignLabelWithHint: true,
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
                      onPressed: () => Navigator.pop<MeetingInfo>(context, (
                        metAt: _metAt,
                        metPlace: SavedCard.clean(_placeController.text),
                        note: SavedCard.clean(_noteController.text),
                      )),
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
