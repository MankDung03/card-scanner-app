import 'dart:math';
import 'package:flutter/material.dart';

/// Kết quả trích xuất OCR đầy đủ của một mặt thẻ danh thiếp
class CardOcrResult {
  final String fullText;
  final int imageWidth;
  final int imageHeight;
  final List<CardTextBlock> blocks;

  const CardOcrResult({
    required this.fullText,
    required this.imageWidth,
    required this.imageHeight,
    required this.blocks,
  });

  bool get isEmpty => blocks.isEmpty || fullText.trim().isEmpty;
  bool get isNotEmpty => !isEmpty;

  int get totalLines => blocks.fold(0, (sum, b) => sum + b.lines.length);
  int get totalElements => blocks.fold(0, (sum, b) => sum + b.totalElements);

  /// Danh sách tất cả các dòng chữ trong thẻ
  List<CardTextLine> get allLines {
    final list = <CardTextLine>[];
    for (final block in blocks) {
      list.addAll(block.lines);
    }
    return list;
  }

  /// Danh sách tất cả các từ / ký tự đơn lẻ
  List<CardTextElement> get allElements {
    final list = <CardTextElement>[];
    for (final block in blocks) {
      for (final line in block.lines) {
        list.addAll(line.elements);
      }
    }
    return list;
  }

  /// Trích xuất danh sách tất cả các dòng chữ theo thứ tự từ trên xuống dưới
  List<CardTextLine> get sortedLines {
    final list = List<CardTextLine>.from(allLines);
    list.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));
    return list;
  }

  /// Tìm dòng chữ chứa điểm tọa độ chuẩn hóa [normalizedPoint] ([0.0 -> 1.0])
  CardTextLine? hitTestLine(Offset normalizedPoint) {
    final size = Size(imageWidth.toDouble(), imageHeight.toDouble());
    for (final block in blocks) {
      for (final line in block.lines) {
        if (line.normalizedRect(size).contains(normalizedPoint)) {
          return line;
        }
      }
    }
    return null;
  }

  /// Tìm khối chữ chứa điểm tọa độ chuẩn hóa [normalizedPoint] ([0.0 -> 1.0])
  CardTextBlock? hitTestBlock(Offset normalizedPoint) {
    final size = Size(imageWidth.toDouble(), imageHeight.toDouble());
    for (final block in blocks) {
      if (block.normalizedRect(size).contains(normalizedPoint)) {
        return block;
      }
    }
    return null;
  }

  /// Tóm tắt cấu trúc để debug / logging
  String debugSummary() {
    final buffer = StringBuffer();
    buffer.writeln('=== CardOcrResult (Image: ${imageWidth}x$imageHeight px) ===');
    buffer.writeln('Total Blocks: ${blocks.length}, Total Lines: $totalLines');
    buffer.writeln('--- Blocks Detail ---');
    for (int i = 0; i < blocks.length; i++) {
      final b = blocks[i];
      buffer.writeln('[Block $i] Rect: ${b.boundingBox} | Norm: ${b.normalizedRect(Size(imageWidth.toDouble(), imageHeight.toDouble()))}');
      buffer.writeln('  Text: "${b.text.replaceAll('\n', ' ')}"');
      for (int j = 0; j < b.lines.length; j++) {
        final l = b.lines[j];
        buffer.writeln('    (Line $j) Rect: ${l.boundingBox} -> "${l.text}"');
      }
    }
    buffer.writeln('=== End CardOcrResult ===');
    return buffer.toString();
  }
}

/// Một khối văn bản (Paragraph / Block) nhận dạng được
class CardTextBlock {
  final String text;
  final Rect boundingBox;
  final List<Point<int>> cornerPoints;
  final List<CardTextLine> lines;
  final List<String> recognizedLanguages;

  const CardTextBlock({
    required this.text,
    required this.boundingBox,
    required this.cornerPoints,
    required this.lines,
    this.recognizedLanguages = const [],
  });

  int get totalElements => lines.fold(0, (sum, l) => sum + l.elements.length);

  /// Tọa độ chuẩn hóa trong khoảng [0.0 -> 1.0] tương ứng với kích thước ảnh
  Rect normalizedRect(Size imageSize) {
    if (imageSize.width <= 0 || imageSize.height <= 0) return Rect.zero;
    return Rect.fromLTRB(
      (boundingBox.left / imageSize.width).clamp(0.0, 1.0),
      (boundingBox.top / imageSize.height).clamp(0.0, 1.0),
      (boundingBox.right / imageSize.width).clamp(0.0, 1.0),
      (boundingBox.bottom / imageSize.height).clamp(0.0, 1.0),
    );
  }
}

/// Một dòng văn bản (Line) trong khối
class CardTextLine {
  final String text;
  final Rect boundingBox;
  final List<Point<int>> cornerPoints;
  final List<CardTextElement> elements;
  final double? confidence;
  final double? angle;

  const CardTextLine({
    required this.text,
    required this.boundingBox,
    required this.cornerPoints,
    required this.elements,
    this.confidence,
    this.angle,
  });

  /// Tọa độ chuẩn hóa [0.0 -> 1.0]
  Rect normalizedRect(Size imageSize) {
    if (imageSize.width <= 0 || imageSize.height <= 0) return Rect.zero;
    return Rect.fromLTRB(
      (boundingBox.left / imageSize.width).clamp(0.0, 1.0),
      (boundingBox.top / imageSize.height).clamp(0.0, 1.0),
      (boundingBox.right / imageSize.width).clamp(0.0, 1.0),
      (boundingBox.bottom / imageSize.height).clamp(0.0, 1.0),
    );
  }
}

/// Một từ hoặc ký tự đơn lẻ (Element)
class CardTextElement {
  final String text;
  final Rect boundingBox;
  final List<Point<int>> cornerPoints;

  const CardTextElement({
    required this.text,
    required this.boundingBox,
    required this.cornerPoints,
  });

  /// Tọa độ chuẩn hóa [0.0 -> 1.0]
  Rect normalizedRect(Size imageSize) {
    if (imageSize.width <= 0 || imageSize.height <= 0) return Rect.zero;
    return Rect.fromLTRB(
      (boundingBox.left / imageSize.width).clamp(0.0, 1.0),
      (boundingBox.top / imageSize.height).clamp(0.0, 1.0),
      (boundingBox.right / imageSize.width).clamp(0.0, 1.0),
      (boundingBox.bottom / imageSize.height).clamp(0.0, 1.0),
    );
  }
}
