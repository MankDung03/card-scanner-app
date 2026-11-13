import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/services/card_backup_service.dart';
import '../../domain/services/restore_planner.dart';
import '../cubit/backup_cubit.dart';
import '../cubit/saved_cards_cubit.dart';

/// Luồng Sao lưu / Khôi phục (gọi từ Cài đặt).
class BackupRestoreFlow {
  BackupRestoreFlow._();

  static const _danger = Color(0xFFDC2626);

  // ───────────────────────── Sao lưu ─────────────────────────

  static Future<void> backup(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cards = context.read<SavedCardsCubit>().state.cards;
    final backupCubit = context.read<BackupCubit>();

    if (cards.isEmpty) {
      _toast(messenger, l10n?.backupNoCards ?? 'Chưa có danh thiếp nào để sao lưu');
      return;
    }

    final close = _showProgress(context, l10n?.backupCreating ?? 'Đang tạo bản sao lưu…');
    File zip;
    try {
      final outDir = Directory('${(await getTemporaryDirectory()).path}/backup');
      // Xoá bản cũ còn sót trong thư mục tạm (mỗi bản có thể vài chục MB)
      if (await outDir.exists()) await outDir.delete(recursive: true);
      String? appVersion;
      try {
        appVersion = (await PackageInfo.fromPlatform()).version;
      } catch (_) {}
      zip = await CardBackupService.createBackup(cards: cards, outDir: outDir, appVersion: appVersion);
    } catch (e) {
      debugPrint('Backup failed: $e');
      close();
      _toast(messenger, l10n?.backupFailed ?? 'Không tạo được bản sao lưu', error: true);
      return;
    }
    close();

    try {
      final result = await SharePlus.instance.share(ShareParams(
        files: [XFile(zip.path, mimeType: 'application/zip')],
        subject: zip.uri.pathSegments.last,
      ));
      // Android không phải lúc nào cũng báo kết quả → chỉ bỏ qua khi người dùng huỷ rõ ràng
      if (result.status != ShareResultStatus.dismissed) {
        await backupCubit.markBackedUp(DateTime.now());
      }
    } catch (e) {
      debugPrint('Share backup failed: $e');
      _toast(messenger, l10n?.backupFailed ?? 'Không tạo được bản sao lưu', error: true);
    }
  }

  // ───────────────────────── Khôi phục ─────────────────────────

  static Future<void> restore(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<SavedCardsCubit>();
    final router = GoRouter.of(context);

    // 1. Chọn file .zip
    final PlatformFile? picked;
    try {
      picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['zip']);
    } catch (e) {
      debugPrint('Pick backup failed: $e');
      _toast(messenger, l10n?.restoreErrCorrupted ?? 'File sao lưu bị hỏng hoặc không đọc được.', error: true);
      return;
    }
    if (picked == null || !context.mounted) return;

    // 2. Đọc + giải nén
    final close = _showProgress(context, l10n?.restoreReading ?? 'Đang đọc bản sao lưu…');
    BackupContents contents;
    try {
      final tmp = await getTemporaryDirectory();
      var zipPath = picked.path;
      if (zipPath == null) {
        zipPath = '${tmp.path}/picked_backup.zip';
        await picked.xFile.saveTo(zipPath);
      }
      contents = await CardBackupService.readBackup(zipPath, workDir: tmp);
    } catch (e) {
      close();
      debugPrint('Read backup failed: $e');
      if (context.mounted) await _showError(context, e);
      return;
    }
    close();
    if (!context.mounted) {
      await contents.dispose();
      return;
    }

    try {
      // 3. Chọn chế độ (mặc định Gộp)
      final mode = await showDialog<RestoreMode>(
        context: context,
        builder: (_) => _RestoreModeDialog(manifest: contents.manifest),
      );
      if (mode == null || !context.mounted) return;

      // 4. Thay thế toàn bộ → xác nhận thêm một lần
      if (mode == RestoreMode.replaceAll && cubit.state.cards.isNotEmpty) {
        final ok = await _confirmReplace(context, cubit.state.cards.length, contents.cards.length);
        if (ok != true || !context.mounted) return;
      }

      // 5. Khôi phục
      final closeRunning = _showProgress(context, l10n?.restoreRunning ?? 'Đang khôi phục…');
      RestoreSummary summary;
      try {
        summary = await cubit.restore(contents.cards, mode);
      } catch (e) {
        closeRunning();
        _toast(messenger, l10n?.restoreFailed ?? 'Khôi phục thất bại, vui lòng thử lại.', error: true);
        return;
      }
      closeRunning();
      if (!context.mounted) return;

      // 6. Tổng kết
      final review = await showDialog<bool>(
        context: context,
        builder: (_) => _RestoreSummaryDialog(summary: summary, mode: mode),
      );
      if (review == true) router.push(AppRoutes.duplicates);
    } finally {
      await contents.dispose();
    }
  }

  // ───────────────────────── Hỗ trợ ─────────────────────────

  /// Hộp tiến trình không đóng được bằng tay; trả về hàm đóng.
  static VoidCallback _showProgress(BuildContext context, String message) {
    final navigator = Navigator.of(context, rootNavigator: true);
    var open = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.r16),
          content: Row(
            children: [
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
              AppSpacing.gapW16,
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
    return () {
      if (open) {
        open = false;
        navigator.pop();
      }
    };
  }

  static void _toast(ScaffoldMessengerState messenger, String message, {bool error = false}) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: error ? _danger : null,
        behavior: SnackBarBehavior.floating,
      ));
  }

  static Future<void> _showError(BuildContext context, Object error) {
    final l10n = AppLocalizations.of(context);
    final message = switch (error) {
      BackupException(error: BackupError.notABackup) =>
        l10n?.restoreErrNotBackup ?? 'File này không phải bản sao lưu của ứng dụng.',
      BackupException(error: BackupError.unsupportedVersion) =>
        l10n?.restoreErrVersion ?? 'Bản sao lưu được tạo bằng phiên bản mới hơn.',
      _ => l10n?.restoreErrCorrupted ?? 'File sao lưu bị hỏng hoặc không đọc được.',
    };
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.r16),
        title: Text(l10n?.restoreTitle ?? 'Khôi phục từ bản sao lưu'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n?.closeAction ?? 'Đóng'))],
      ),
    );
  }

  static Future<bool?> _confirmReplace(BuildContext context, int current, int incoming) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.r16),
        title: Text(l10n?.replaceConfirmTitle ?? 'Thay thế toàn bộ dữ liệu?'),
        content: Text(
          l10n?.replaceConfirmBody(current, incoming) ??
              '$current danh thiếp trên máy sẽ bị xoá và thay bằng $incoming danh thiếp trong bản sao lưu.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n?.cancel ?? 'Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: _danger, foregroundColor: Colors.white),
            child: Text(l10n?.replaceAction ?? 'Thay thế'),
          ),
        ],
      ),
    );
  }
}

/// Chọn chế độ khôi phục; mặc định Gộp.
class _RestoreModeDialog extends StatefulWidget {
  final BackupManifest manifest;

  const _RestoreModeDialog({required this.manifest});

  @override
  State<_RestoreModeDialog> createState() => _RestoreModeDialogState();
}

class _RestoreModeDialogState extends State<_RestoreModeDialog> {
  RestoreMode _mode = RestoreMode.merge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final date = DateFormat.yMd(Localizations.localeOf(context).toLanguageTag())
        .add_Hm()
        .format(widget.manifest.createdAt.toLocal());

    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.r16),
      title: Text(l10n?.restoreTitle ?? 'Khôi phục từ bản sao lưu'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.restoreBackupInfo(date, widget.manifest.cardCount) ??
                  'Bản sao lưu ngày $date · ${widget.manifest.cardCount} danh thiếp',
              style: TextStyle(color: muted, fontSize: 13),
            ),
            AppSpacing.gapH16,
            _ModeOption(
              selected: _mode == RestoreMode.merge,
              title: l10n?.restoreModeMerge ?? 'Gộp với dữ liệu hiện có',
              badge: l10n?.recommended ?? 'Khuyên dùng',
              body: l10n?.restoreModeMergeDesc ?? '',
              onTap: () => setState(() => _mode = RestoreMode.merge),
            ),
            AppSpacing.gapH10,
            _ModeOption(
              selected: _mode == RestoreMode.replaceAll,
              title: l10n?.restoreModeReplace ?? 'Thay thế toàn bộ',
              body: l10n?.restoreModeReplaceDesc ?? '',
              danger: true,
              onTap: () => setState(() => _mode = RestoreMode.replaceAll),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n?.cancel ?? 'Hủy')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _mode),
          style: FilledButton.styleFrom(
            backgroundColor: isDark ? AppColors.darkNavy : AppColors.navy,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n?.restoreAction ?? 'Khôi phục'),
        ),
      ],
    );
  }
}

class _ModeOption extends StatelessWidget {
  final bool selected;
  final String title;
  final String body;
  final String? badge;
  final bool danger;
  final VoidCallback onTap;

  const _ModeOption({
    required this.selected,
    required this.title,
    required this.body,
    required this.onTap,
    this.badge,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = danger
        ? const Color(0xFFDC2626)
        : (isDark ? const Color(0xFF93B4E0) : AppColors.navy);
    final border = selected ? accent : (isDark ? AppColors.darkBorder : AppColors.divider);

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.r10,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: AppRadius.r10,
            border: Border.all(color: border, width: selected ? 1.6 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? accent : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                size: 20,
              ),
              AppSpacing.gapW10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: danger ? accent : null,
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkNavy : AppColors.navyTint,
                              borderRadius: AppRadius.r4,
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(color: accent, fontSize: 10.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        fontSize: 12,
                        height: 1.45,
                      ),
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

/// Bảng tổng kết sau khi khôi phục. Trả về true nếu người dùng bấm "Xem lại" thẻ trùng.
class _RestoreSummaryDialog extends StatelessWidget {
  final RestoreSummary summary;
  final RestoreMode mode;

  const _RestoreSummaryDialog({required this.summary, required this.mode});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String count(int n) => l10n?.cardsCount(n) ?? '$n';

    final rows = <(String, int, bool)>[
      (l10n?.summaryAdded ?? 'Thêm mới', summary.added, false),
      if (mode == RestoreMode.merge) ...[
        (l10n?.summaryUpdated ?? 'Cập nhật', summary.updated, false),
        (l10n?.summaryKeptLocal ?? 'Giữ bản trên máy', summary.keptLocal, false),
        (l10n?.summarySkipped ?? 'Bỏ qua vì giống hệt', summary.skippedIdentical, false),
        (l10n?.summaryFlagged ?? 'Có thể trùng', summary.flagged, true),
      ],
    ];

    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.r16),
      icon: Icon(Icons.check_circle_outline_rounded, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D)),
      title: Text(l10n?.restoreDoneTitle ?? 'Đã khôi phục'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (label, value, warn) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: warn && value > 0
                            ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309))
                            : null,
                      ),
                    ),
                  ),
                  Text(count(value), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n?.closeAction ?? 'Đóng')),
        if (summary.flagged > 0)
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkNavy : AppColors.navy,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.reviewNow ?? 'Xem lại'),
          ),
      ],
    );
  }
}
