import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/card_ocr_result.dart';

class OcrPreviewSheet extends StatefulWidget {
  final CardOcrResult ocrResult;
  final String? imagePath;

  const OcrPreviewSheet({
    super.key,
    required this.ocrResult,
    this.imagePath,
  });

  static Future<void> show(
    BuildContext context,
    CardOcrResult result, {
    String? imagePath,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OcrPreviewSheet(
        ocrResult: result,
        imagePath: imagePath,
      ),
    );
  }

  @override
  State<OcrPreviewSheet> createState() => _OcrPreviewSheetState();
}

class _OcrPreviewSheetState extends State<OcrPreviewSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedBlockIndex;

  bool get _hasImage =>
      widget.imagePath != null && File(widget.imagePath!).existsSync();

  @override
  void initState() {
    super.initState();
    final tabCount = _hasImage ? 3 : 2;
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);

    return Container(
      height: size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF131B2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF2A3A5B), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // 1. Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_rounded,
                              color: Color(0xFF22C55E), size: 18),
                          AppSpacing.gapW6,
                          Text(
                            l10n?.offlineBadge ?? '100% On-device · Offline',
                            style: const TextStyle(
                              color: Color(0xFF22C55E),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n?.ocrSuccess ?? 'Nhận dạng chữ thành công',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white70, size: 22),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.gapH12,

          // 3. Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildStatPill(
                  icon: Icons.layers_rounded,
                  label: l10n?.ocrBlocksCount(widget.ocrResult.blocks.length) ??
                      '${widget.ocrResult.blocks.length} khối chữ',
                ),
                AppSpacing.gapW8,
                _buildStatPill(
                  icon: Icons.format_list_bulleted_rounded,
                  label: l10n?.ocrLinesCount(widget.ocrResult.totalLines) ??
                      '${widget.ocrResult.totalLines} dòng chữ',
                ),
                AppSpacing.gapW8,
                _buildStatPill(
                  icon: Icons.aspect_ratio_rounded,
                  label:
                      '${widget.ocrResult.imageWidth}×${widget.ocrResult.imageHeight} px',
                ),
              ],
            ),
          ),

          AppSpacing.gapH14,

          // 4. Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: AppRadius.r12,
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: const BoxDecoration(
                color: AppColors.blueCardStart,
                borderRadius: AppRadius.r10,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              tabs: [
                if (_hasImage)
                  Tab(
                    iconMargin: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.visibility_rounded, size: 16),
                        AppSpacing.gapW6,
                        Text(l10n?.visualTab ?? 'Trực quan'),
                      ],
                    ),
                  ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.crop_free_rounded, size: 16),
                      AppSpacing.gapW6,
                      Text(l10n?.blocksTab ?? 'Khối & Tọa độ'),
                    ],
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.article_rounded, size: 16),
                      AppSpacing.gapW6,
                      Text(l10n?.rawTextTab ?? 'Văn bản thô'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.gapH12,

          // 5. Tab View Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                if (_hasImage) _buildVisualTab(context, l10n),
                _buildBlocksTab(context, l10n),
                _buildRawTextTab(context, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({required IconData icon, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2640),
          borderRadius: AppRadius.r10,
          border: Border.all(color: const Color(0xFF2C3E63)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF60A5FA), size: 14),
            AppSpacing.gapW6,
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualTab(BuildContext context, AppLocalizations? l10n) {
    if (widget.ocrResult.isEmpty) {
      return Center(
        child: Text(
          l10n?.noTextDetected ?? 'Không nhận diện được chữ nào trong ảnh',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    final double aspect = widget.ocrResult.imageWidth > 0 &&
            widget.ocrResult.imageHeight > 0
        ? widget.ocrResult.imageWidth / widget.ocrResult.imageHeight
        : 91 / 55;

    final imageSize = Size(
      widget.ocrResult.imageWidth.toDouble(),
      widget.ocrResult.imageHeight.toDouble(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 1. Image with Bounding Boxes Overlay
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double renderW = constraints.maxWidth;
                  double renderH = renderW / aspect;
                  if (renderH > constraints.maxHeight) {
                    renderH = constraints.maxHeight;
                    renderW = renderH * aspect;
                  }

                  return SizedBox(
                    width: renderW,
                    height: renderH,
                    child: Stack(
                      children: [
                        // Card Image
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: AppRadius.r12,
                            child: Image.file(
                              File(widget.imagePath!),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),

                        // Bounding Box Overlays
                        ...List.generate(widget.ocrResult.blocks.length, (idx) {
                          final block = widget.ocrResult.blocks[idx];
                          final norm = block.normalizedRect(imageSize);
                          final isSelected = _selectedBlockIndex == idx;

                          return Positioned(
                            left: norm.left * renderW,
                            top: norm.top * renderH,
                            width: norm.width * renderW,
                            height: norm.height * renderH,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedBlockIndex =
                                      isSelected ? null : idx;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF38BDF8)
                                          .withValues(alpha: 0.35)
                                      : const Color(0xFF22C55E)
                                          .withValues(alpha: 0.20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF22C55E),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF0284C7)
                                          : const Color(0xFF15803D),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      '#${idx + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          AppSpacing.gapH12,

          // 2. Selected Block Info Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: AppRadius.r12,
              border: Border.all(
                color: _selectedBlockIndex != null
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF1E293B),
              ),
            ),
            child: _selectedBlockIndex != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Khối #${_selectedBlockIndex! + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.copy_rounded,
                                size: 16, color: Colors.white70),
                            onPressed: () {
                              final text = widget
                                  .ocrResult.blocks[_selectedBlockIndex!].text;
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n?.copiedToClipboard ??
                                      'Đã sao chép vào bộ nhớ tạm'),
                                  backgroundColor: const Color(0xFF22C55E),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.ocrResult.blocks[_selectedBlockIndex!].text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                : const Row(
                    children: [
                      Icon(Icons.touch_app_rounded,
                          color: Color(0xFF38BDF8), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Chạm vào ô viền trên ảnh để xem nội dung khối chữ',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          AppSpacing.gapH14,
        ],
      ),
    );
  }

  Widget _buildRawTextTab(BuildContext context, AppLocalizations? l10n) {
    if (widget.ocrResult.isEmpty) {
      return Center(
        child: Text(
          l10n?.noTextDetected ?? 'Không nhận diện được chữ nào trong ảnh',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: AppRadius.r14,
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SelectableText(
                  widget.ocrResult.fullText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    height: 1.6,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
          AppSpacing.gapH12,
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.ocrResult.fullText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n?.copiedToClipboard ??
                        'Đã sao chép vào bộ nhớ tạm'),
                    backgroundColor: const Color(0xFF22C55E),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text(
                l10n?.copyRawText ?? 'Sao chép toàn bộ text',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF334155), width: 1.5),
                shape:
                    const RoundedRectangleBorder(borderRadius: AppRadius.r12),
              ),
            ),
          ),
          AppSpacing.gapH16,
        ],
      ),
    );
  }

  Widget _buildBlocksTab(BuildContext context, AppLocalizations? l10n) {
    if (widget.ocrResult.isEmpty) {
      return Center(
        child: Text(
          l10n?.noTextDetected ?? 'Không nhận diện được chữ nào trong ảnh',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    final imageSize = Size(
      widget.ocrResult.imageWidth.toDouble(),
      widget.ocrResult.imageHeight.toDouble(),
    );

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: widget.ocrResult.blocks.length,
      itemBuilder: (context, index) {
        final block = widget.ocrResult.blocks[index];
        final rect = block.boundingBox;
        final norm = block.normalizedRect(imageSize);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: AppRadius.r14,
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Block Header: Index & Rect
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.blueCardStart.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color:
                              AppColors.blueCardStart.withValues(alpha: 0.6)),
                    ),
                    child: Text(
                      'Khối #${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF60A5FA),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'L:${rect.left.toInt()} T:${rect.top.toInt()} W:${rect.width.toInt()} H:${rect.height.toInt()}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Normalized coordinates info
              Text(
                'Chuẩn hóa: [${norm.left.toStringAsFixed(2)}, ${norm.top.toStringAsFixed(2)}, ${norm.width.toStringAsFixed(2)}, ${norm.height.toStringAsFixed(2)}]',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),

              const SizedBox(height: 8),
              const Divider(color: Color(0xFF1E293B), height: 1),
              const SizedBox(height: 8),

              // Lines in this block
              ...block.lines.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right_rounded,
                            color: Color(0xFF38BDF8), size: 18),
                        Expanded(
                          child: Text(
                            line.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
