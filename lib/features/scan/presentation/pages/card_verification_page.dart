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
import '../../domain/entities/ocr_model.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';
import '../widgets/field_edit_bottom_sheet.dart';
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
    final fields = [
      {'key': 'name', 'label': 'Họ tên'},
      {'key': 'jobTitle', 'label': 'Chức vụ'},
      {'key': 'company', 'label': 'Công ty'},
      {'key': 'department', 'label': 'Phòng ban'},
      {'key': 'phone', 'label': 'Điện thoại bàn'},
      {'key': 'mobile', 'label': 'Di động'},
      {'key': 'fax', 'label': 'FAX'},
      {'key': 'email', 'label': 'Email'},
      {'key': 'website', 'label': 'Website'},
      {'key': 'address', 'label': 'Địa chỉ'},
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
                  const Text(
                    'Gán văn bản vào mục:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

    // Ảnh của mặt vừa OCR (ảnh đã crop) – mặt còn lại lấy ảnh gốc nếu có
    final processedImage = scanState.lastProcessedImagePath ?? scanState.currentImagePath;
    final isFront = scanState.currentSide == CardSide.front;

    final saved = await context.read<SavedCardsCubit>().saveFromScan(
          cardInfo,
          frontImagePath: isFront ? processedImage : scanState.frontImagePath,
          backImagePath: isFront ? scanState.backImagePath : processedImage,
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
                      _buildOriginalTextTab(context, l10n, isDark, state, imagePath),
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
          Tab(text: l10n?.originalTextTab ?? 'Văn bản gốc'),
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
              label: 'Website',
              value: cardInfo.website,
              isNeedsReview: cardInfo.isFieldNeedsReview('website'),
              placeholder: notOnCard,
              onTap: () => _onEditField(
                context,
                'website',
                'Website',
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
                        label: const Text(
                          'Gán vào...',
                          style: TextStyle(
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

  Widget _buildOriginalTextTab(
    BuildContext context,
    AppLocalizations? l10n,
    bool isDark,
    ScanState state,
    String? imagePath,
  ) {
    final ocrResult = state.currentOcrResult;
    if (ocrResult == null || ocrResult.isEmpty) {
      return Center(
        child: Text(
          l10n?.noTextDetected ?? 'Không có dữ liệu văn bản',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh thẻ
            if (imagePath != null && File(imagePath).existsSync()) ...[
              ClipRRect(
                borderRadius: AppRadius.r12,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.black12,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    cacheWidth: 800,
                  ),
                ),
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
    );
  }
}
