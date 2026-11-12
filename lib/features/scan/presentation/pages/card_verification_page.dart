import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cards/presentation/cubit/saved_cards_cubit.dart';
import '../../domain/entities/card_ocr_result.dart';
import '../../domain/entities/ocr_model.dart';
import '../../domain/services/ocr_line_field_matcher.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';
import '../widgets/assign_lines_bottom_sheet.dart';
import '../widgets/field_edit_bottom_sheet.dart';
import '../widgets/ocr_text_overlay.dart';
import '../widgets/verification_field_tile.dart';
import '../widgets/verification_header_card.dart';

class CardVerificationPage extends StatefulWidget {
  const CardVerificationPage({super.key});

  @override
  State<CardVerificationPage> createState() => _CardVerificationPageState();
}

class _CardVerificationPageState extends State<CardVerificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Mặt đang xem trong tab "Văn bản gốc"
  CardSide _textSide = CardSide.front;

  /// Các dòng OCR đang chọn trên ảnh (chỉ số trong `allLines` của mặt đang xem)
  final Set<int> _selectedLines = {};

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

  void _onAssignUnmappedLine(BuildContext context, OcrLine line) {
    final l10n = AppLocalizations.of(context);
    final fields = [
      {'key': 'name', 'label': l10n?.fullName ?? 'Họ tên'},
      {'key': 'jobTitle', 'label': l10n?.jobTitle ?? 'Chức vụ'},
      {'key': 'company', 'label': l10n?.company ?? 'Công ty'},
      {'key': 'department', 'label': l10n?.department ?? 'Phòng ban'},
      {'key': 'phone', 'label': l10n?.phone ?? 'Điện thoại'},
      {'key': 'mobile', 'label': l10n?.mobile ?? 'Di động'},
      {'key': 'fax', 'label': l10n?.fax ?? 'FAX'},
      {'key': 'email', 'label': l10n?.email ?? 'Email'},
      {'key': 'website', 'label': l10n?.website ?? 'Website'},
      {'key': 'address', 'label': l10n?.address ?? 'Địa chỉ'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.assignLineTitle ?? 'Gán văn bản vào mục:',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '"${line.text}"',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: fields.length,
                itemBuilder: (ctx, idx) {
                  final item = fields[idx];
                  return ListTile(
                    dense: true,
                    title: Text(item['label']!,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.read<ScanCubit>().assignUnmappedLine(line, item['key']!);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSaveCard(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final scanState = context.read<ScanCubit>().state;
    final cardInfo = scanState.currentCardInfo;
    if (cardInfo == null) return;

    // Mỗi mặt: ưu tiên ảnh đã crop theo 4 góc (dùng cho OCR), không có thì dùng ảnh gốc
    final saved = await context.read<SavedCardsCubit>().saveFromScan(
          cardInfo,
          frontImagePath: scanState.processedImagePathFor(CardSide.front) ?? scanState.frontImagePath,
          backImagePath: scanState.processedImagePathFor(CardSide.back) ?? scanState.backImagePath,
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

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n?.verificationTitle ?? 'Kiểm tra thông tin',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.pushReplacement(AppRoutes.scanCamera),
            child: Text(
              l10n?.retake ?? 'Chụp lại',
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ScanCubit, ScanState>(
        builder: (context, state) {
          final cardInfo = state.currentCardInfo;
          final imagePath = state.lastProcessedImagePath ?? state.currentImagePath;

          if (cardInfo == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              Expanded(
                child: NestedScrollView(
                  physics: const ClampingScrollPhysics(),
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                          child: VerificationHeaderCard(
                            cardInfo: cardInfo,
                            imagePath: imagePath,
                          ),
                        ),
                      ),
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
                      // TAB 1: DANH SÁCH FORM THEO MỤC
                      _buildFieldsList(context, l10n, isDark, cardInfo),

                      // TAB 2: VĂN BẢN GỐC & ẢNH OCR
                      _buildOriginalTextTab(context, l10n, isDark, state),
                    ],
                  ),
                ),
              ),

              // 4. Thanh nút hành động cố định ở chân trang: Lưu danh thiếp
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: context.select((SavedCardsCubit c) => c.state.isSaving)
                          ? null
                          : () => _onSaveCard(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.r16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_rounded, size: 20),
                          AppSpacing.gapW8,
                          Text(
                            l10n?.saveCard ?? 'Lưu danh thiếp',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegmentedTabs(bool isDark, AppLocalizations? l10n) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: AppRadius.r12,
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: isDark ? AppColors.blueCardStart : Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: isDark ? Colors.white : const Color(0xFF0F172A),
        unselectedLabelColor: isDark ? Colors.white60 : const Color(0xFF64748B),
        labelStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
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
    dynamic cardInfo,
  ) {
    final notOnCard = l10n?.notOnCardPlaceholder ?? 'Không có trên thẻ — nhập nếu cần';

    return SingleChildScrollView(
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
        child: ClipRRect(
          borderRadius: AppRadius.r16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // 1. Họ tên
            VerificationFieldTile(
              icon: Icons.person_outline_rounded,
              iconBgColor: const Color(0xFFE0F2FE),
              iconColor: const Color(0xFF0284C7),
              label: l10n?.fullName ?? 'Họ tên',
              value: cardInfo.name,
              isNeedsReview: cardInfo.isFieldNeedsReview('name'),
              placeholder: notOnCard,
              onTap: () => _onEditField(
                context,
                'name',
                l10n?.fullName ?? 'Họ tên',
                cardInfo.name,
                alternatives: cardInfo.alternatives['name'] ?? const [],
              ),
            ),
            _buildFieldDivider(isDark),

            // 2. Furigana
            VerificationFieldTile(
              icon: Icons.text_fields_rounded,
              iconBgColor: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              label: l10n?.furigana ?? 'Furigana',
              value: cardInfo.furigana,
              isNeedsReview: cardInfo.isFieldNeedsReview('furigana'),
              placeholder: notOnCard,
              onTap: () => _onEditField(
                context,
                'furigana',
                l10n?.furigana ?? 'Furigana',
                cardInfo.furigana,
              ),
            ),
            _buildFieldDivider(isDark),

            // 3. Chức vụ
            VerificationFieldTile(
              icon: Icons.work_outline_rounded,
              iconBgColor: const Color(0xFFF3E8FF),
              iconColor: const Color(0xFF9333EA),
              label: l10n?.jobTitle ?? 'Chức vụ',
              value: cardInfo.jobTitle,
              isNeedsReview: cardInfo.isFieldNeedsReview('jobTitle'),
              placeholder: notOnCard,
              onTap: () => _onEditField(
                context,
                'jobTitle',
                l10n?.jobTitle ?? 'Chức vụ',
                cardInfo.jobTitle,
                alternatives: cardInfo.alternatives['jobTitle'] ?? const [],
              ),
            ),
            _buildFieldDivider(isDark),

            // 4. Công ty
            VerificationFieldTile(
              icon: Icons.business_outlined,
              iconBgColor: const Color(0xFFF3E8FF),
              iconColor: const Color(0xFF9333EA),
              label: l10n?.company ?? 'Công ty',
              value: cardInfo.company,
              isNeedsReview: cardInfo.isFieldNeedsReview('company'),
              placeholder: notOnCard,
              onTap: () => _onEditField(
                context,
                'company',
                l10n?.company ?? 'Công ty',
                cardInfo.company,
                alternatives: cardInfo.alternatives['company'] ?? const [],
              ),
            ),
            _buildFieldDivider(isDark),

            // 5. Phòng ban
            VerificationFieldTile(
              icon: Icons.domain_outlined,
              iconBgColor: const Color(0xFFF3E8FF),
              iconColor: const Color(0xFF9333EA),
              label: l10n?.department ?? 'Phòng ban',
              value: cardInfo.department,
              isNeedsReview: cardInfo.isFieldNeedsReview('department'),
              placeholder: notOnCard,
              onTap: () => _onEditField(
                context,
                'department',
                l10n?.department ?? 'Phòng ban',
                cardInfo.department,
                alternatives: cardInfo.alternatives['department'] ?? const [],
              ),
            ),
            _buildFieldDivider(isDark),

            // 6. Điện thoại
            VerificationFieldTile(
              icon: Icons.phone_outlined,
              iconBgColor: const Color(0xFFDCFCE7),
              iconColor: const Color(0xFF16A34A),
              label: l10n?.phone ?? 'Điện thoại',
              value: cardInfo.phone,
              isNeedsReview: cardInfo.isFieldNeedsReview('phone'),
              placeholder: notOnCard,
              onTap: () => _onEditField(
                context,
                'phone',
                l10n?.phone ?? 'Điện thoại',
                cardInfo.phone,
              ),
            ),
            _buildFieldDivider(isDark),

            // 7. Di động
            VerificationFieldTile(
              icon: Icons.phone_android_outlined,
              iconBgColor: const Color(0xFFDCFCE7),
              iconColor: const Color(0xFF16A34A),
              label: l10n?.mobile ?? 'Di động',
              value: cardInfo.mobile,
              isNeedsReview: cardInfo.isFieldNeedsReview('mobile'),
              placeholder: notOnCard,
              onTap: () => _onEditField(
                context,
                'mobile',
                l10n?.mobile ?? 'Di động',
                cardInfo.mobile,
              ),
            ),
            _buildFieldDivider(isDark),

            // 8. FAX
            VerificationFieldTile(
              icon: Icons.print_outlined,
              iconBgColor: const Color(0xFFDCFCE7),
              iconColor: const Color(0xFF16A34A),
              label: l10n?.fax ?? 'FAX',
              value: cardInfo.fax,
              isNeedsReview: cardInfo.isFieldNeedsReview('fax'),
              placeholder: notOnCard,
              onTap: () => _onEditField(
                context,
                'fax',
                l10n?.fax ?? 'FAX',
                cardInfo.fax,
              ),
            ),
            _buildFieldDivider(isDark),

            // 9. Email
            VerificationFieldTile(
              icon: Icons.email_outlined,
              iconBgColor: const Color(0xFFDCFCE7),
              iconColor: const Color(0xFF16A34A),
              label: l10n?.email ?? 'Email',
              value: cardInfo.email,
              isNeedsReview: cardInfo.isFieldNeedsReview('email'),
              placeholder: notOnCard,
              onTap: () => _onEditField(
                context,
                'email',
                l10n?.email ?? 'Email',
                cardInfo.email,
              ),
            ),
            _buildFieldDivider(isDark),

            // 10. Website
            VerificationFieldTile(
              icon: Icons.language_rounded,
              iconBgColor: const Color(0xFFE0F2FE),
              iconColor: const Color(0xFF0284C7),
              label: l10n?.website ?? 'Website',
              value: cardInfo.website,
              isNeedsReview: cardInfo.isFieldNeedsReview('website'),
              placeholder: notOnCard,
              onTap: () => _onEditField(
                context,
                'website',
                l10n?.website ?? 'Website',
                cardInfo.website,
                alternatives: cardInfo.alternatives['website'] ?? const [],
              ),
            ),
            _buildFieldDivider(isDark),

            // 11. Địa chỉ
            VerificationFieldTile(
              icon: Icons.location_on_outlined,
              iconBgColor: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              label: l10n?.address ?? 'Địa chỉ',
              value: cardInfo.address,
              isNeedsReview: cardInfo.isFieldNeedsReview('address'),
              placeholder: notOnCard,
              showDivider: false,
              onTap: () => _onEditField(
                context,
                'address',
                l10n?.address ?? 'Địa chỉ',
                cardInfo.address,
                alternatives: cardInfo.alternatives['address'] ?? const [],
              ),
            ),

            // 12. Danh sách các dòng chưa được gán (Unmapped Lines)
            if (cardInfo.unmappedLines.isNotEmpty) ...[
              _buildFieldDivider(isDark),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: Color(0xFF0284C7)),
                    AppSpacing.gapW8,
                    Text(
                      l10n?.unmappedLinesCount(cardInfo.unmappedLines.length) ??
                          'Dòng chưa gán (${cardInfo.unmappedLines.length})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
              ...cardInfo.unmappedLines.map((line) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius: AppRadius.r12,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          line.text,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded,
                            size: 15, color: Color(0xFF0284C7)),
                        label: Text(
                          l10n?.assignTo ?? 'Gán vào...',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                        onPressed: () => _onAssignUnmappedLine(context, line),
                      ),
                    ],
                  ),
                );
              }),
              AppSpacing.gapH8,
            ],
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildFieldDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.8,
      indent: 64,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
    );
  }

  // ───────────── Tab "Trên ảnh": chạm dòng chữ trên ảnh để gán vào trường ─────────────

  void _toggleLine(int index) {
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
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ScanCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final previous = cubit.state.currentCardInfo;
    if (previous == null || _selectedLines.isEmpty) return;

    // Ghép các dòng theo thứ tự đọc (trên → dưới, trái → phải)
    final chosen = _selectedLines.map((i) => lines[i]).toList()
      ..sort((a, b) {
        final dy = a.boundingBox.top - b.boundingBox.top;
        if (dy.abs() > a.boundingBox.height / 2) return dy.sign.toInt();
        return a.boundingBox.left.compareTo(b.boundingBox.left);
      });
    final texts = chosen.map((l) => l.text.trim()).where((t) => t.isNotEmpty).toList();

    final result = await AssignLinesBottomSheet.show(context, text: texts.join(' '), cardInfo: previous);
    if (result == null || !mounted) return;

    cubit.updateCardInfo(previous.assignText(
      result.fieldKey,
      result.text,
      append: result.append,
      consumedLineTexts: texts,
    ));
    setState(_selectedLines.clear);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(
          l10n?.assignedToField(fieldLabel(l10n, result.fieldKey)) ??
              'Đã gán vào ${fieldLabel(l10n, result.fieldKey)}',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: l10n?.undo ?? 'Hoàn tác',
          onPressed: () => cubit.updateCardInfo(previous),
        ),
      ));
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
