import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/navy_header_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cards/presentation/cubit/saved_cards_cubit.dart';
import '../../domain/entities/business_card_info.dart';
import '../../domain/entities/card_ocr_result.dart';
import '../../domain/services/ocr_line_field_matcher.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';
import '../../domain/entities/custom_field.dart';
import '../../domain/services/custom_field_labels.dart';
import '../../domain/services/ocr_line_order.dart';
import '../widgets/assign_lines_bottom_sheet.dart';
import '../widgets/custom_field_editor_sheet.dart';
import '../widgets/unassigned_lines_dialog.dart';
import '../widgets/field_edit_bottom_sheet.dart';
import '../widgets/ocr_text_overlay.dart';
import '../widgets/verification_field_tile.dart';
import '../widgets/verification_header_card.dart';

class CardVerificationPage extends StatefulWidget {
  const CardVerificationPage({super.key});

  @override
  State<CardVerificationPage> createState() => _CardVerificationPageState();
}

class _CardVerificationPageState extends State<CardVerificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Mặt đang xem trong tab "Văn bản gốc"
  CardSide _textSide = CardSide.front;

  /// Các dòng OCR đang chọn trên ảnh (chỉ số trong `allLines` của mặt đang xem)
  final Set<int> _selectedLines = {};

  /// Id các dòng chưa gán đang tick ở tab "Theo mục"
  final Set<String> _selectedUnmapped = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onEditField(
    BuildContext context,
    String fieldKey,
    String label,
    String? currentValue, {
    List<String> alternatives = const [],
  }) {
    FieldEditBottomSheet.show(
      context,
      label: label,
      initialValue: currentValue,
      alternatives: alternatives,
      onSaved: (newValue) {
        context.read<ScanCubit>().updateCardField(fieldKey, newValue);
      },
    );
  }

  // ───────────── Trường tuỳ chỉnh / ghi chú / dòng chưa gán ─────────────

  /// Tên trường tuỳ chỉnh đã dùng (thẻ đang xác nhận + mọi thẻ đã lưu)
  List<List<CustomField>> _labelSources(BusinessCardInfo info) => [
        info.customFields,
        for (final c in context.read<SavedCardsCubit>().state.cards) c.customFields,
      ];

  List<String> _existingLabels(BusinessCardInfo info) =>
      [for (final fields in _labelSources(info)) ...fields.map((f) => f.label)];

  List<String> _labelSuggestions(BusinessCardInfo info) => CustomFieldLabels.suggestions(_labelSources(info));

  /// Mở sheet gán cho các dòng chưa gán có id thuộc [ids] (theo thứ tự đọc).
  Future<void> _assignUnmapped(BuildContext context, Set<String> ids) async {
    final cubit = context.read<ScanCubit>();
    final previous = cubit.state.currentCardInfo;
    if (previous == null || ids.isEmpty) return;
    final lines = OcrLineOrder.sortUnmapped(previous.unmappedLines.where((l) => ids.contains(l.id)));
    if (lines.isEmpty) return;

    final result = await AssignLinesBottomSheet.show(
      context,
      lines: lines.map((l) => l.text).toList(),
      cardInfo: previous,
      labelSuggestions: _labelSuggestions(previous),
      existingLabels: _existingLabels(previous),
    );
    if (result == null || !mounted || !context.mounted) return;

    cubit.updateCardInfo(applyAssignResult(previous, result, consumedIds: lines.map((l) => l.id)));
    setState(() => _selectedUnmapped.removeAll(lines.map((l) => l.id)));
    _showAssignedSnack(context, result, previous);
  }

  void _showAssignedSnack(BuildContext context, AssignLinesResult result, BusinessCardInfo previous) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ScanCubit>();
    final target = result.fieldKey == AssignTarget.custom ? (result.label ?? '') : fieldLabel(l10n, result.fieldKey);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(l10n?.assignedToField(target) ?? 'Đã gán vào $target'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: l10n?.undo ?? 'Hoàn tác',
          onPressed: () => cubit.updateCardInfo(previous),
        ),
      ));
  }

  /// Thêm ([index] == null) hoặc sửa / xoá trường tuỳ chỉnh.
  Future<void> _editCustomField(BuildContext context, BusinessCardInfo info, {int? index}) async {
    final cubit = context.read<ScanCubit>();
    final result = await CustomFieldEditorSheet.show(
      context,
      initial: index == null ? null : info.customFields[index],
      suggestions: _labelSuggestions(info),
      existingLabels: _existingLabels(info),
    );
    if (result == null || !mounted) return;
    final current = cubit.state.currentCardInfo ?? info;
    if (index == null) {
      if (result.field != null) {
        cubit.updateCardInfo(current.addCustomField(result.field!.label, result.field!.value));
      }
    } else {
      cubit.updateCardInfo(current.setCustomField(index, result.deleted ? null : result.field));
    }
  }

  void _editNote(BuildContext context, BusinessCardInfo info) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ScanCubit>();
    FieldEditBottomSheet.show(
      context,
      label: l10n?.noteLabel ?? 'Ghi chú',
      initialValue: info.note,
      multiline: true,
      onSaved: (v) => cubit.updateCardInfo((cubit.state.currentCardInfo ?? info).copyWith(note: v.trim())),
    );
  }

  /// Bấm Lưu: còn dòng chưa gán (sau khi lọc rác) → hỏi gọn; hết → lưu luôn.
  Future<void> _onSavePressed(BuildContext context) async {
    final info = context.read<ScanCubit>().state.currentCardInfo;
    if (info == null) return;
    final pending = OcrLineOrder.sortUnmapped(info.unmappedLines).where((l) => !OcrLineOrder.isJunk(l.text)).toList();
    if (pending.isEmpty) return _onSaveCard(context);

    final decision = await UnassignedLinesDialog.show(context, pending);
    if (decision == null || !mounted || !context.mounted) return;
    if (decision.skip) return _onSaveCard(context);

    // Quay lại gán: các dòng đã tick được chọn sẵn và mở luôn sheet gán
    setState(() {
      _selectedUnmapped
        ..clear()
        ..addAll(decision.ids);
    });
    _tabController.animateTo(0);
    await _assignUnmapped(context, decision.ids);
  }

  Future<void> _onSaveCard(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final scanState = context.read<ScanCubit>().state;
    final cardInfo = scanState.currentCardInfo;
    if (cardInfo == null) return;

    // Mỗi mặt: ưu tiên ảnh đã crop theo 4 góc (dùng cho OCR), không có thì dùng ảnh gốc.
    // Chữ OCR gốc của từng mặt được lưu kèm (kể cả các dòng không gán vào đâu) để tìm kiếm.
    final saved = await context.read<SavedCardsCubit>().saveFromScan(
          cardInfo,
          frontImagePath: scanState.processedImagePathFor(CardSide.front) ?? scanState.frontImagePath,
          backImagePath: scanState.processedImagePathFor(CardSide.back) ?? scanState.backImagePath,
          ocrTextFront: scanState.ocrResultFor(CardSide.front)?.fullText,
          ocrTextBack: scanState.ocrResultFor(CardSide.back)?.fullText,
        );
    if (!context.mounted) return;

    if (saved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.cardSaveFailed ?? 'Không thể lưu danh thiếp, vui lòng thử lại'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.r12),
        ),
      );
      return;
    }

    // Thay toàn bộ stack scan bằng [Home, Đã lưu]
    context.go(AppRoutes.cardSaved, extra: saved.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            // 1. Header navy: [< Chụp lại]  Kiểm tra thông tin / Bước 3/3
            NavyHeaderBar(
              title: l10n?.verificationTitle ?? 'Kiểm tra thông tin',
              subtitle: l10n?.stepProgress(3, 3) ?? 'Bước 3/3',
              leading: NavyHeaderTextButton(
                icon: Icons.chevron_left_rounded,
                label: l10n?.retake ?? 'Chụp lại',
                onPressed: () => context.pushReplacement(AppRoutes.scanCamera),
              ),
            ),

            Expanded(
              child: BlocBuilder<ScanCubit, ScanState>(
                builder: (context, state) {
                  final cardInfo = state.currentCardInfo;
                  final imagePath = state.lastProcessedImagePath ?? state.currentImagePath;

                  if (cardInfo == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return NestedScrollView(
                    physics: const ClampingScrollPhysics(),
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        // 2. Tóm tắt kết quả đọc
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: VerificationHeaderCard(cardInfo: cardInfo, imagePath: imagePath),
                          ),
                        ),
                        // 3. Chuyển chế độ: Theo mục / Trên ảnh
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: _buildSegmentedTabs(isDark, l10n),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildFieldsList(context, l10n, isDark, cardInfo),
                        _buildOriginalTextTab(context, l10n, isDark, state),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // 4. Nút lưu cố định ở đáy — đặt ở bottomNavigationBar để snackbar (Đã gán… / Hoàn tác)
        //    hiện PHÍA TRÊN thanh này thay vì che nút Lưu.
        bottomNavigationBar: Builder(
          builder: (context) => Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.divider)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: context.select((SavedCardsCubit c) => c.state.isSaving) ||
                          context.select((ScanCubit c) => c.state.currentCardInfo == null)
                      ? null
                      : () => _onSavePressed(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkNavy : AppColors.navy,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
                    textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: Text(l10n?.saveCard ?? 'Lưu danh thiếp'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedTabs(bool isDark, AppLocalizations? l10n) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : AppColors.divider,
        borderRadius: AppRadius.r10,
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: AppRadius.r8,
        ),
        labelColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: [
          Tab(text: l10n?.byFieldsTab ?? 'Theo mục'),
          Tab(text: l10n?.onImageTab ?? 'Trên ảnh'),
        ],
      ),
    );
  }

  Widget _buildFieldsList(
    BuildContext context,
    AppLocalizations? l10n,
    bool isDark,
    BusinessCardInfo cardInfo,
  ) {
    final empty = l10n?.notOnCardPlaceholder ?? 'Chưa nhập';

    Widget field(String key, String label, String? value, {bool withAlternatives = false}) {
      return VerificationFieldTile(
        label: label,
        value: value,
        isNeedsReview: cardInfo.isFieldNeedsReview(key),
        placeholder: empty,
        onTap: () => _onEditField(
          context,
          key,
          label,
          value,
          alternatives: withAlternatives ? (cardInfo.alternatives[key] ?? const []) : const [],
        ),
      );
    }

    final accent = isDark ? const Color(0xFF93B4E0) : AppColors.navy;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 氏名
          VerificationSection(
            title: l10n?.sectionName ?? 'Họ tên',
            children: [
              field('name', l10n?.fullName ?? 'Họ tên', cardInfo.name, withAlternatives: true),
              field('furigana', l10n?.furigana ?? 'Furigana', cardInfo.furigana),
            ],
          ),
          AppSpacing.gapH12,

          // 会社情報
          VerificationSection(
            title: l10n?.sectionCompany ?? 'Thông tin công ty',
            children: [
              field('company', l10n?.company ?? 'Công ty', cardInfo.company, withAlternatives: true),
              field('department', l10n?.department ?? 'Phòng ban', cardInfo.department, withAlternatives: true),
              field('jobTitle', l10n?.jobTitle ?? 'Chức vụ', cardInfo.jobTitle, withAlternatives: true),
            ],
          ),
          AppSpacing.gapH12,

          // 連絡先
          VerificationSection(
            title: l10n?.sectionContact ?? 'Liên hệ',
            children: [
              field('phone', l10n?.phone ?? 'Điện thoại', cardInfo.phone),
              field('mobile', l10n?.mobile ?? 'Di động', cardInfo.mobile),
              field('fax', l10n?.fax ?? 'FAX', cardInfo.fax),
              field('email', l10n?.email ?? 'Email', cardInfo.email),
              field('website', l10n?.website ?? 'Website', cardInfo.website, withAlternatives: true),
              field('address', l10n?.address ?? 'Địa chỉ', cardInfo.address, withAlternatives: true),
            ],
          ),

          // その他: trường tuỳ chỉnh (từ dòng chưa gán hoặc nhập tay)
          AppSpacing.gapH12,
          VerificationSection(
            title: l10n?.otherFieldsSection ?? 'Trường khác',
            children: [
              for (var i = 0; i < cardInfo.customFields.length; i++)
                VerificationFieldTile(
                  key: ValueKey('custom-field-$i'),
                  label: cardInfo.customFields[i].label,
                  value: cardInfo.customFields[i].value,
                  placeholder: empty,
                  onTap: () => _editCustomField(context, cardInfo, index: i),
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  key: const ValueKey('add-custom-field'),
                  style: TextButton.styleFrom(
                    foregroundColor: accent,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n?.addCustomField ?? 'Thêm trường'),
                  onPressed: () => _editCustomField(context, cardInfo),
                ),
              ),
            ],
          ),
          AppSpacing.gapH12,

          // メモ
          VerificationSection(
            title: l10n?.noteLabel ?? 'Ghi chú',
            children: [
              VerificationFieldTile(
                key: const ValueKey('note-field'),
                label: l10n?.noteLabel ?? 'Ghi chú',
                value: cardInfo.note,
                placeholder: empty,
                onTap: () => _editNote(context, cardInfo),
              ),
            ],
          ),

          // Các dòng OCR chưa gán vào mục nào: tick nhiều dòng rồi gán một lần
          if (cardInfo.unmappedLines.isNotEmpty) ...[
            AppSpacing.gapH12,
            _buildUnmappedSection(context, l10n, isDark, accent, cardInfo),
          ],
        ],
      ),
    );
  }

  Widget _buildUnmappedSection(
    BuildContext context,
    AppLocalizations? l10n,
    bool isDark,
    Color accent,
    BusinessCardInfo cardInfo,
  ) {
    final lines = OcrLineOrder.sortUnmapped(cardInfo.unmappedLines);
    // Bỏ id của dòng đã gán (không còn trong danh sách)
    _selectedUnmapped.retainAll(lines.map((l) => l.id));
    final selected = _selectedUnmapped.length;

    return VerificationSection(
      title: l10n?.unmappedLinesCount(lines.length) ?? 'Dòng chưa gán (${lines.length})',
      children: [
        for (final line in lines)
          Material(
            key: ValueKey('unmapped-${line.id}'),
            color: _selectedUnmapped.contains(line.id)
                ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF))
                : (isDark ? AppColors.darkBackground : AppColors.surfaceMuted),
            borderRadius: AppRadius.r8,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _toggleUnmapped(line.id),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 12, 2),
                child: Row(
                  children: [
                    Checkbox(
                      value: _selectedUnmapped.contains(line.id),
                      visualDensity: VisualDensity.compact,
                      onChanged: (_) => _toggleUnmapped(line.id),
                    ),
                    Expanded(
                      child: Text(
                        line.text,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Thanh hành động: Wrap để chữ to / màn hẹp thì xuống dòng thay vì tràn
        Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            if (selected > 0) ...[
              Text(
                l10n?.selectedLinesCount(selected) ?? 'Đã chọn $selected dòng',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: accent),
              ),
              TextButton(
                onPressed: () => setState(_selectedUnmapped.clear),
                child: Text(l10n?.clearSelection ?? 'Bỏ chọn'),
              ),
            ],
            FilledButton.icon(
              key: const ValueKey('assign-unmapped'),
              onPressed: selected == 0 ? null : () => _assignUnmapped(context, {..._selectedUnmapped}),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blueCardStart,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
              ),
              icon: const Icon(Icons.input_rounded, size: 18),
              label: Text(l10n?.assignTo ?? 'Gán vào...'),
            ),
          ],
        ),
      ],
    );
  }

  // ───────────── Tab "Trên ảnh": chạm dòng chữ trên ảnh để gán vào trường ─────────────

  /// Bắt đầu chọn dòng mới → ẩn snackbar "Đã gán / Hoàn tác" của lần trước để nó không che thanh hành động.
  void _hideAssignSnack() => ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();

  void _toggleUnmapped(String id) {
    _hideAssignSnack();
    setState(() {
      if (!_selectedUnmapped.remove(id)) _selectedUnmapped.add(id);
    });
  }

  void _toggleLine(int index) {
    _hideAssignSnack();
    setState(() {
      if (!_selectedLines.remove(index)) _selectedLines.add(index);
    });
  }

  void _switchTextSide(CardSide side) {
    setState(() {
      _textSide = side;
      _selectedLines.clear(); // chỉ số dòng thuộc về từng mặt
    });
  }

  Future<void> _assignSelectedLines(BuildContext context, List<CardTextLine> lines) async {
    final cubit = context.read<ScanCubit>();
    final previous = cubit.state.currentCardInfo;
    if (previous == null || _selectedLines.isEmpty) return;

    // Ghép các dòng theo thứ tự đọc (hàng trên → dưới, trong hàng trái → phải; chữ dọc phải → trái)
    final chosen = OcrLineOrder.sort(
      _selectedLines.map((i) => lines[i]),
      rect: (l) => l.boundingBox,
      isVertical: (l) => l.boundingBox.height > l.boundingBox.width * 1.4,
    );
    final texts = chosen.map((l) => l.text.trim()).where((t) => t.isNotEmpty).toList();

    final result = await AssignLinesBottomSheet.show(
      context,
      lines: texts,
      cardInfo: previous,
      labelSuggestions: _labelSuggestions(previous),
      existingLabels: _existingLabels(previous),
    );
    if (result == null || !mounted || !context.mounted) return;

    cubit.updateCardInfo(applyAssignResult(previous, result, consumedTexts: texts));
    setState(_selectedLines.clear);
    _showAssignedSnack(context, result, previous);
  }

  Widget _buildOriginalTextTab(
    BuildContext context,
    AppLocalizations? l10n,
    bool isDark,
    ScanState state,
  ) {
    // Các mặt có kết quả OCR; mặt đang xem rơi về mặt có dữ liệu nếu mặt đã chọn không có
    final sides = [
      for (final s in CardSide.values)
        if (state.ocrResultFor(s) != null) s,
    ];
    final side = sides.contains(_textSide) ? _textSide : (sides.isEmpty ? _textSide : sides.first);
    final ocrResult = state.ocrResultFor(side);
    final imagePath = state.processedImagePathFor(side) ?? state.imagePathFor(side);
    final cardInfo = state.currentCardInfo;

    if (ocrResult == null || cardInfo == null || (ocrResult.isEmpty && sides.length < 2)) {
      return Center(
        child: Text(
          l10n?.noTextDetected ?? 'Không có dữ liệu văn bản',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    final lines = ocrResult.allLines;
    final hasImage = imagePath != null && File(imagePath).existsSync();
    final muted = isDark ? Colors.white60 : const Color(0xFF64748B);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: AppRadius.r16,
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chuyển mặt trước / mặt sau khi cả 2 mặt đều đã OCR
                  if (sides.length > 1) ...[
                    Center(
                      child: SegmentedButton<CardSide>(
                        segments: [
                          ButtonSegment(value: CardSide.front, label: Text(l10n?.frontSide ?? 'Mặt trước')),
                          ButtonSegment(value: CardSide.back, label: Text(l10n?.backSide ?? 'Mặt sau')),
                        ],
                        selected: {side},
                        showSelectedIcon: false,
                        style: const ButtonStyle(visualDensity: VisualDensity.compact),
                        onSelectionChanged: (s) => _switchTextSide(s.first),
                      ),
                    ),
                    AppSpacing.gapH12,
                  ],

                  // Ảnh + khung từng dòng chữ (chạm để chọn)
                  if (hasImage && lines.isNotEmpty) ...[
                    Text(
                      l10n?.tapLinesHint ?? 'Chạm vào dòng chữ trên ảnh để chọn, rồi gán vào mục',
                      style: TextStyle(fontSize: 12.5, color: muted),
                    ),
                    AppSpacing.gapH8,
                    OcrTextOverlay(
                      imagePath: imagePath,
                      ocr: ocrResult,
                      lines: lines,
                      selected: _selectedLines,
                      isAssigned: (i) => OcrLineFieldMatcher.fieldOf(cardInfo, lines[i].text) != null,
                      onTapLine: _toggleLine,
                    ),
                    AppSpacing.gapH8,
                    Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      children: [
                        _LegendDot(color: OcrOverlayColors.assigned, label: l10n?.lineAssigned ?? 'Đã có trong form'),
                        _LegendDot(color: OcrOverlayColors.unassigned, label: l10n?.lineUnassigned ?? 'Chưa dùng'),
                      ],
                    ),
                    AppSpacing.gapH14,
                  ] else if (hasImage) ...[
                    ClipRRect(
                      borderRadius: AppRadius.r12,
                      child: Image.file(File(imagePath), fit: BoxFit.contain, cacheWidth: 800),
                    ),
                    AppSpacing.gapH12,
                  ],

                  // Văn bản thô OCR
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: AppRadius.r12,
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: SelectableText(
                      ocrResult.fullText,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13.5,
                        height: 1.5,
                        color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  AppSpacing.gapH14,

                  // Nút copy văn bản
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: ocrResult.fullText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n?.copiedToClipboard ?? 'Đã sao chép vào bộ nhớ tạm'),
                            backgroundColor: const Color(0xFF16A34A),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: Text(l10n?.copyRawText ?? 'Sao chép toàn bộ text'),
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Thanh hành động khi đang chọn dòng
        if (_selectedLines.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
              border: Border(
                top: BorderSide(color: isDark ? const Color(0xFF1E40AF) : const Color(0xFFBFDBFE)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n?.selectedLinesCount(_selectedLines.length) ?? 'Đã chọn ${_selectedLines.length} dòng',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(_selectedLines.clear),
                  child: Text(l10n?.clearSelection ?? 'Bỏ chọn'),
                ),
                AppSpacing.gapW4,
                ElevatedButton.icon(
                  onPressed: () => _assignSelectedLines(context, lines),
                  icon: const Icon(Icons.input_rounded, size: 18),
                  label: Text(l10n?.assignTo ?? 'Gán vào...'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueCardStart,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.r10),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
