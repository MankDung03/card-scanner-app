import 'dart:math';
import 'dart:ui';
import '../entities/card_ocr_result.dart';
import 'text_normalizer.dart';

/// Phần tử ký tự nội bộ phục vụ cho thuật toán gom box
class _ElementItem {
  final String text;
  final Rect rect;
  final List<Point<int>> cornerPoints;
  final int blockIndex;
  final int lineIndex;
  bool isUsed;

  _ElementItem({
    required this.text,
    required this.rect,
    this.cornerPoints = const [],
    this.blockIndex = 0,
    this.lineIndex = 0,
  }) : isUsed = false;
}

/// Thuật toán tái tạo và gom dòng OCR dựa trên tọa độ phần tử (Bounding Box Merging)
/// Giải quyết triệt để các bài toán:
/// 1. Rớt chữ do khoảng cách thiết kế kerning rộng ("田 中     宏" -> "田 中 宏")
/// 2. Phân mảnh khối chữ lệch kích thước ("TOKYO" + "ENGINEERING" -> "TOKYO ENGINEERING")
/// 3. Ghép số điện thoại & dấu ngoặc ("(03" + "1055-8141" + "(代)" -> "(03) 1055-8141 (代)")
/// 4. Đảm bảo toàn vẹn các chữ ở lề ("FAX" + số fax -> "FAX 03-1055-8142")
/// 5. BẢO VỆ RANH GIỚI CỘT: Tuyệt đối không gộp các phần tử ở 2 cột khác nhau của thẻ
///    (ví dụ "Ngô Tiến Công" ở cột trái và "VIB Quốc Tế" ở cột phải)
class OcrLineReconstructor {
  /// Tái cấu trúc lại toàn bộ CardOcrResult từ tọa độ các TextElement
  static CardOcrResult reconstruct(
    CardOcrResult rawResult, {
    bool isVietnamese = false,
  }) {
    if (rawResult.isEmpty || rawResult.blocks.isEmpty) {
      return rawResult;
    }

    // 1. Trích xuất toàn bộ TextElement từ tất cả các khối (kèm thông tin blockIndex và lineIndex)
    final allElements = <_ElementItem>[];

    for (int bIdx = 0; bIdx < rawResult.blocks.length; bIdx++) {
      final block = rawResult.blocks[bIdx];
      for (int lIdx = 0; lIdx < block.lines.length; lIdx++) {
        final line = block.lines[lIdx];
        if (line.elements.isNotEmpty) {
          for (final elem in line.elements) {
            final t = elem.text.trim();
            if (t.isNotEmpty && elem.boundingBox.width > 0 && elem.boundingBox.height > 0) {
              allElements.add(_ElementItem(
                text: t,
                rect: elem.boundingBox,
                cornerPoints: elem.cornerPoints,
                blockIndex: bIdx,
                lineIndex: lIdx,
              ));
            }
          }
        } else {
          // Nếu dòng không có elements riêng, dùng chính dòng làm element
          final t = line.text.trim();
          if (t.isNotEmpty && line.boundingBox.width > 0 && line.boundingBox.height > 0) {
            allElements.add(_ElementItem(
              text: t,
              rect: line.boundingBox,
              cornerPoints: line.cornerPoints,
              blockIndex: bIdx,
              lineIndex: lIdx,
            ));
          }
        }
      }
    }

    if (allElements.isEmpty) {
      return rawResult;
    }

    // 2. Thuật toán gom cụm phần tử có cùng trục ngang (Horizontal Baseline & Gap Clustering)
    final lineClusters = <List<_ElementItem>>[];
    final cardW = rawResult.imageWidth.toDouble();

    for (int i = 0; i < allElements.length; i++) {
      final seed = allElements[i];
      if (seed.isUsed) continue;

      final currentCluster = <_ElementItem>[seed];
      seed.isUsed = true;

      // Tìm tất cả các candidate lân cận thỏa mãn cả baseline Y và khoảng cách ngang X
      bool addedAny = true;
      while (addedAny) {
        addedAny = false;
        for (int j = 0; j < allElements.length; j++) {
          final candidate = allElements[j];
          if (candidate.isUsed) continue;

          // Kiểm tra xem candidate có thể nối với bất kỳ member nào trong cluster không
          bool canConnect = false;
          for (final member in currentCluster) {
            if (_isCompatibleNeighbor(
              member,
              candidate,
              cardW,
              isVietnamese,
            )) {
              canConnect = true;
              break;
            }
          }

          if (canConnect) {
            candidate.isUsed = true;
            currentCluster.add(candidate);
            addedAny = true;
          }
        }
      }

      lineClusters.add(currentCluster);
    }

    // 3. Tái tạo từng dòng hoàn chỉnh từ các cluster
    final reconstructedLines = <CardTextLine>[];

    for (final cluster in lineClusters) {
      // 3.1 Sắp xếp các từ trong cùng dòng theo thứ tự từ trái sang phải (X tăng dần)
      cluster.sort((a, b) => a.rect.left.compareTo(b.rect.left));

      // 3.2 Tính toán bounding box bao trọn dòng
      double minLeft = cluster.first.rect.left;
      double minTop = cluster.first.rect.top;
      double maxRight = cluster.first.rect.right;
      double maxBottom = cluster.first.rect.bottom;

      for (final item in cluster) {
        minLeft = min(minLeft, item.rect.left);
        minTop = min(minTop, item.rect.top);
        maxRight = max(maxRight, item.rect.right);
        maxBottom = max(maxBottom, item.rect.bottom);
      }

      final lineBoundingBox = Rect.fromLTRB(minLeft, minTop, maxRight, maxBottom);

      // 3.3 Nối chuỗi văn bản thông minh (giữ khoảng cách từ hợp lý)
      final lineBuffer = StringBuffer();
      final lineElements = <CardTextElement>[];

      for (int k = 0; k < cluster.length; k++) {
        final current = cluster[k];
        lineElements.add(CardTextElement(
          text: current.text,
          boundingBox: current.rect,
          cornerPoints: current.cornerPoints,
        ));

        if (k > 0) {
          final prev = cluster[k - 1];
          final gap = current.rect.left - prev.rect.right;

          // Nếu là dấu đóng ngoặc hoặc ký tự nối sát
          final isPunctuation = current.text.startsWith(')') ||
              current.text.startsWith('）') ||
              current.text.startsWith(',') ||
              current.text.startsWith('.') ||
              current.text.startsWith(':');

          final isPrevPunctuation = prev.text.endsWith('(') ||
              prev.text.endsWith('（');

          if (isPunctuation || isPrevPunctuation) {
            // Nối liền không cần dấu cách
          } else if (gap > 2.0 || !TextNormalizer.containsCjk(prev.text) || !TextNormalizer.containsCjk(current.text)) {
            // Nối với khoảng trắng chuẩn
            lineBuffer.write(' ');
          }
        }

        lineBuffer.write(current.text);
      }

      final mergedText = lineBuffer.toString().trim();
      if (mergedText.isNotEmpty) {
        reconstructedLines.add(
          CardTextLine(
            text: mergedText,
            boundingBox: lineBoundingBox,
            elements: lineElements,
          ),
        );
      }
    }

    // 4. Sắp xếp toàn bộ các dòng theo thứ tự từ trên xuống dưới (Y tăng dần)
    reconstructedLines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    // 5. Gom nhóm các dòng liền kề thành khối (Blocks) logic
    final reconstructedBlocks = <CardTextBlock>[];
    final fullTextLines = <String>[];

    for (int idx = 0; idx < reconstructedLines.length; idx++) {
      final line = reconstructedLines[idx];
      fullTextLines.add(line.text);

      reconstructedBlocks.add(
        CardTextBlock(
          text: line.text,
          boundingBox: line.boundingBox,
          lines: [line],
        ),
      );
    }

    final fullText = fullTextLines.join('\n');

    return CardOcrResult(
      fullText: fullText,
      imageWidth: rawResult.imageWidth,
      imageHeight: rawResult.imageHeight,
      blocks: reconstructedBlocks,
    );
  }

  /// Kiểm tra 2 bounding box có nằm trên cùng 1 trục ngang (Baseline Y) hay không
  static bool _isSameHorizontalLine(Rect a, Rect b) {
    final double dy = (a.center.dy - b.center.dy).abs();
    final double minH = min(a.height, b.height);
    final double maxH = max(a.height, b.height);

    // 1. Chênh lệch tâm Y không vượt quá 55% chiều cao chữ
    if (dy > minH * 0.55 && dy > maxH * 0.35) {
      return false;
    }

    // 2. Độ giao thoa chiều dọc (Vertical Overlap) phải đủ lớn
    final double overlapY = max(0.0, min(a.bottom, b.bottom) - max(a.top, b.top));
    if (overlapY < minH * 0.35) {
      return false;
    }

    return true;
  }

  /// Tính khoảng cách ngang giữa 2 bounding box
  static double _horizontalGap(Rect a, Rect b) {
    if (a.right < b.left) {
      return b.left - a.right;
    } else if (b.right < a.left) {
      return a.left - b.right;
    }
    return 0.0;
  }

  /// Xác định xem 2 phần tử có phải là láng giềng hợp lệ trên cùng 1 dòng hay không
  /// (Kiểm tra cả trục dọc Y lẫn khoảng cách ngang X để ngăn chặn triệt để lỗi gom đè cột)
  static bool _isCompatibleNeighbor(
    _ElementItem member,
    _ElementItem candidate,
    double cardWidth,
    bool isVietnamese,
  ) {
    // 1. Bắt buộc phải có cùng baseline Y
    if (!_isSameHorizontalLine(member.rect, candidate.rect)) {
      return false;
    }

    // 2. Tính khoảng cách ngang giữa 2 box
    final gapX = _horizontalGap(member.rect, candidate.rect);
    final fontH = max(member.rect.height, candidate.rect.height);

    // TH 1: Cùng trong 1 block layout của ML Kit
    if (member.blockIndex == candidate.blockIndex) {
      if (member.lineIndex == candidate.lineIndex) {
        // Trong cùng 1 dòng ban đầu của ML Kit, cho phép nối nếu khoảng cách từ hợp lý
        final maxSameLineGap = max(fontH * (isVietnamese ? 2.0 : 3.0), 60.0);
        return gapX <= maxSameLineGap;
      }

      // Khác dòng trong cùng block (ví dụ ML Kit ngắt dòng sai nhưng cùng độ cao Y):
      final maxSameBlockGap = max(fontH * (isVietnamese ? 1.5 : 2.5), 50.0);
      if (cardWidth > 0 && gapX > cardWidth * (isVietnamese ? 0.10 : 0.15)) {
        return false;
      }
      return gapX <= maxSameBlockGap;
    }

    // TH 2: Khác block layout (2 khối hoàn toàn độc lập do ML Kit chia cột/đoạn)
    // CHẶN ĐÈ CỘT: Tuyệt đối không gộp nếu nằm ở 2 cột khác nhau (ví dụ Tên bên trái và Logo bên phải)
    if (isVietnamese) {
      // Đối với thẻ tiếng Việt, tuyệt đối không gộp giữa 2 block khác nhau nếu khoảng cách vượt quá 1 từ
      final maxCrossBlockGap = max(fontH * 0.8, 25.0);
      if (cardWidth > 0 && gapX > cardWidth * 0.05) return false;
      return gapX <= maxCrossBlockGap;
    } else {
      // Đối với thẻ tiếng Nhật, cho phép gom kerning tên người (như "田 中" và "宏")
      // nhưng giới hạn chặt chẽ không quá 2.2x fontH hoặc 12% chiều rộng thẻ
      double maxCrossBlockGap = max(fontH * 2.2, 75.0);
      if (cardWidth > 0) {
        maxCrossBlockGap = min(maxCrossBlockGap, cardWidth * 0.12);
      }
      return gapX <= maxCrossBlockGap;
    }
  }
}
