import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/services/card_export.dart';
import '../utils/card_share_service.dart';

/// Hộp xác nhận "Xuất file CSV?" cho toàn bộ danh thiếp. Bấm Xuất → tạo CSV rồi mở menu chia sẻ.
class CsvExportDialog extends StatefulWidget {
  final List<SavedCard> cards;

  const CsvExportDialog({super.key, required this.cards});

  static Future<void> show(BuildContext context, List<SavedCard> cards) {
    return showDialog<void>(context: context, builder: (_) => CsvExportDialog(cards: cards));
  }

  @override
  State<CsvExportDialog> createState() => _CsvExportDialogState();
}

class _CsvExportDialogState extends State<CsvExportDialog> {
  late final String _fileName = CardExport.csvFileName(DateTime.now());
  bool _busy = false;

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final messenger = ScaffoldMessenger.of(context);
    final headers = [
      l10n?.fullName ?? 'Họ tên',
      l10n?.furigana ?? 'Furigana',
      l10n?.company ?? 'Công ty',
      l10n?.department ?? 'Phòng ban',
      l10n?.jobTitle ?? 'Chức vụ',
      l10n?.phone ?? 'Điện thoại',
      l10n?.mobile ?? 'Di động',
      l10n?.fax ?? 'FAX',
      l10n?.email ?? 'Email',
      l10n?.website ?? 'Website',
      l10n?.postalCode ?? 'Mã bưu chính',
      l10n?.address ?? 'Địa chỉ',
      l10n?.metDateLabel ?? 'Ngày gặp',
      l10n?.metPlaceLabel ?? 'Nơi gặp',
      l10n?.noteLabel ?? 'Ghi chú',
      l10n?.addTag ?? 'Tag',
      l10n?.csvCreatedAt ?? 'Ngày thêm',
    ];

    setState(() => _busy = true);
    try {
      final csv = CardExport.toCsv(widget.cards, headers, formatDate: DateFormat.yMd(localeTag).format);
      if (mounted) Navigator.pop(context);
      await CardShareService.shareCsv(csv, _fileName);
    } catch (e) {
      debugPrint('CSV export failed: $e');
      if (mounted) Navigator.pop(context);
      messenger.showSnackBar(SnackBar(
        content: Text(l10n?.exportFailed ?? 'Không xuất được file'),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final navy = isDark ? AppColors.darkNavy : AppColors.navy;
    final count = widget.cards.length;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.r16),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.s24, AppSpacing.s20, AppSpacing.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon + tiêu đề
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceMuted : AppColors.navyTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.table_chart_outlined, color: isDark ? AppColors.darkTextSecondary : AppColors.navy),
                ),
              ),
              AppSpacing.gapH12,
              Text(
                l10n?.csvDialogTitle ?? 'Xuất file CSV?',
                textAlign: TextAlign.center,
                style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.3),
              ),
              AppSpacing.gapH16,

              // Bảng thông tin
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
                  borderRadius: AppRadius.r8,
                ),
                child: Column(
                  children: [
                    _InfoLine(
                      label: l10n?.csvTarget ?? 'Đối tượng',
                      value: l10n?.csvTargetValue(count) ?? '$count danh thiếp (tất cả)',
                      bold: true,
                    ),
                    _InfoLine(label: l10n?.csvFormat ?? 'Định dạng', value: l10n?.csvFormatValue ?? 'CSV (UTF-8)'),
                    _InfoLine(label: l10n?.csvFileName ?? 'Tên file', value: _fileName),
                    _InfoLine(
                      label: l10n?.csvDestination ?? 'Nơi lưu',
                      value: l10n?.csvDestinationValue ?? 'Chọn trong menu chia sẻ sau khi xuất',
                      isLast: true,
                    ),
                  ],
                ),
              ),
              AppSpacing.gapH12,

              // Cảnh báo dữ liệu cá nhân
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309)),
                  AppSpacing.gapW6,
                  Expanded(
                    child: Text(
                      l10n?.csvPrivacyWarning ?? 'File chứa thông tin cá nhân. Hãy cẩn thận khi chia sẻ.',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapH20,

              // Nút
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _busy ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textPrimary,
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.divider),
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
                        ),
                        child: Text(l10n?.cancel ?? 'Hủy'),
                      ),
                    ),
                  ),
                  AppSpacing.gapW12,
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _busy || count == 0 ? null : _export,
                        style: FilledButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
                          textStyle: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        child: _busy
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(l10n?.exportAction ?? 'Xuất'),
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

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool isLast;

  const _InfoLine({required this.label, required this.value, this.bold = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, fontSize: 12.5, height: 1.4),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontSize: 13,
                height: 1.4,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
