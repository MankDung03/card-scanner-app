import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../domain/entities/card_ocr_result.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../../domain/services/ocr_line_reconstructor.dart';
import '../../domain/services/text_normalizer.dart';

class MlKitOcrRepository implements OcrRepository {
  final Map<TextRecognitionScript, TextRecognizer> _recognizers = {};

  TextRecognizer _getRecognizer(TextRecognitionScript script) {
    return _recognizers.putIfAbsent(
      script,
      () => TextRecognizer(script: script),
    );
  }

  @override
  Future<CardOcrResult> recognizeText(
    String imagePath, {
    TextRecognitionScript script = TextRecognitionScript.japanese,
    bool useDualScript = true,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Tệp ảnh không tồn tại: $imagePath');
    }

    // 1. Xác định kích thước ảnh thực tế (px) qua Header metadata
    int imgW = 0;
    int imgH = 0;
    try {
      final bytes = await file.readAsBytes();
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      imgW = descriptor.width;
      imgH = descriptor.height;
      descriptor.dispose();
      buffer.dispose();
    } catch (e) {
      debugPrint('Warning reading image dimensions: $e');
    }

    final inputImage = InputImage.fromFilePath(imagePath);

    // 2. Chế độ Dual-Script: Chạy đồng thời Latin (Việt/Anh) và Japanese (Kanji/Kana)
    if (useDualScript) {
      final latinRecognizer = _getRecognizer(TextRecognitionScript.latin);
      final japaneseRecognizer = _getRecognizer(TextRecognitionScript.japanese);

      final results = await Future.wait([
        latinRecognizer.processImage(inputImage),
        japaneseRecognizer.processImage(inputImage),
      ]);

      final RecognizedText latinResult = results[0];
      final RecognizedText japaneseResult = results[1];

      // Nếu kết quả Japanese hoàn toàn không có ký tự CJK nào -> Đây là danh thiếp thuần Latin / Tiếng Việt!
      // Bỏ qua kết quả Japanese để tránh lỗi hallucination ép ký tự Latin/dấu tiếng Việt thành Kana (như 'Quản lý' -> 'のudny')
      final bool hasCjk = TextNormalizer.containsCjk(japaneseResult.text);

      if (!hasCjk) {
        debugPrint('[DualScriptOCR] No CJK characters detected. Using Latin OCR result.');
        final raw = _mapToDomain(latinResult, imgW, imgH);
        return OcrLineReconstructor.reconstruct(raw);
      }

      // Nếu có CJK: Hợp nhất thông minh giữa Japanese và Latin
      debugPrint('[DualScriptOCR] CJK characters detected. Merging Japanese and Latin results.');
      final merged = _mergeRecognizedTexts(latinResult, japaneseResult, imgW, imgH);
      return OcrLineReconstructor.reconstruct(merged);
    }

    // Chế độ đơn script theo yêu cầu
    final recognizer = _getRecognizer(script);
    final RecognizedText recognizedText = await recognizer.processImage(inputImage);
    final raw = _mapToDomain(recognizedText, imgW, imgH);
    return OcrLineReconstructor.reconstruct(raw);
  }

  /// Gộp kết quả giữa Japanese và Latin recognizer
  CardOcrResult _mergeRecognizedTexts(
    RecognizedText latin,
    RecognizedText japanese,
    int imgW,
    int imgH,
  ) {
    // Trích xuất toàn bộ dòng của Latin để tra cứu chồng lấn
    final latinLines = <CardTextLine>[];
    for (final block in latin.blocks) {
      for (final line in block.lines) {
        latinLines.add(_mapLine(line));
      }
    }

    final mergedBlocks = <CardTextBlock>[];
    final Set<CardTextLine> usedLatinLines = {};

    for (final block in japanese.blocks) {
      final mergedLines = <CardTextLine>[];

      for (final line in block.lines) {
        final lineText = line.text;
        final hasLineCjk = TextNormalizer.containsCjk(lineText);

        if (hasLineCjk) {
          // Dòng chứa CJK -> Giữ kết quả của Japanese
          mergedLines.add(_mapLine(line));
        } else {
          // Dòng KHÔNG chứa CJK (ví dụ Email, SĐT, Website, Tiếng Việt, Tiếng Anh)
          // Tìm xem có dòng Latin nào chồng lấn không
          CardTextLine? bestLatinMatch;
          double maxOverlap = 0;

          for (final lLine in latinLines) {
            final overlap = _computeOverlap(line.boundingBox, lLine.boundingBox);
            if (overlap > maxOverlap && overlap >= 0.35) {
              maxOverlap = overlap;
              bestLatinMatch = lLine;
            }
          }

          if (bestLatinMatch != null) {
            // Ưu tiên bản đọc Latin chuẩn
            mergedLines.add(bestLatinMatch);
            usedLatinLines.add(bestLatinMatch);
          } else {
            mergedLines.add(_mapLine(line));
          }
        }
      }

      if (mergedLines.isNotEmpty) {
        mergedBlocks.add(
          CardTextBlock(
            text: mergedLines.map((l) => l.text).join('\n'),
            boundingBox: block.boundingBox,
            cornerPoints: block.cornerPoints,
            lines: mergedLines,
            recognizedLanguages: block.recognizedLanguages,
          ),
        );
      }
    }

    // Giữ lại các dòng Latin mồ côi (Latin Recognizer đọc được nhưng Japanese bỏ sót)
    // Ví dụ: chữ "FAX" ở lề, cụm số hoặc logo tiếng Anh bị Japanese model bỏ qua
    final List<CardTextLine> orphanLatinLines = [];
    for (final lLine in latinLines) {
      if (usedLatinLines.contains(lLine)) continue;

      // Không thêm nếu dòng Latin này trùng vị trí với một dòng Kanji/CJK đã có
      bool overlapsWithCjk = false;
      for (final block in japanese.blocks) {
        for (final jLine in block.lines) {
          if (TextNormalizer.containsCjk(jLine.text)) {
            if (_computeOverlap(lLine.boundingBox, jLine.boundingBox) >= 0.25) {
              overlapsWithCjk = true;
              break;
            }
          }
        }
        if (overlapsWithCjk) break;
      }

      if (!overlapsWithCjk && lLine.text.trim().isNotEmpty) {
        orphanLatinLines.add(lLine);
      }
    }

    if (orphanLatinLines.isNotEmpty) {
      mergedBlocks.add(
        CardTextBlock(
          text: orphanLatinLines.map((l) => l.text).join('\n'),
          boundingBox: orphanLatinLines.first.boundingBox,
          cornerPoints: orphanLatinLines.first.cornerPoints,
          lines: orphanLatinLines,
          recognizedLanguages: const ['en'],
        ),
      );
    }

    final fullText = mergedBlocks.map((b) => b.text).join('\n\n');

    return CardOcrResult(
      fullText: fullText,
      imageWidth: imgW,
      imageHeight: imgH,
      blocks: mergedBlocks,
    );
  }

  double _computeOverlap(ui.Rect a, ui.Rect b) {
    final intersection = a.intersect(b);
    if (intersection.width <= 0 || intersection.height <= 0) return 0.0;
    final intersectionArea = intersection.width * intersection.height;
    final minArea = min(a.width * a.height, b.width * b.height);
    if (minArea <= 0) return 0.0;
    return intersectionArea / minArea;
  }

  CardOcrResult _mapToDomain(RecognizedText text, int imgW, int imgH) {
    final domainBlocks = <CardTextBlock>[];

    for (final block in text.blocks) {
      final domainLines = block.lines.map(_mapLine).toList();

      domainBlocks.add(
        CardTextBlock(
          text: block.text,
          boundingBox: block.boundingBox,
          cornerPoints: block.cornerPoints,
          lines: domainLines,
          recognizedLanguages: block.recognizedLanguages,
        ),
      );
    }

    final result = CardOcrResult(
      fullText: text.text,
      imageWidth: imgW,
      imageHeight: imgH,
      blocks: domainBlocks,
    );

    debugPrint(result.debugSummary());
    return result;
  }

  CardTextLine _mapLine(TextLine line) {
    final domainElements = line.elements.map((e) {
      return CardTextElement(
        text: e.text,
        boundingBox: e.boundingBox,
        cornerPoints: e.cornerPoints,
      );
    }).toList();

    return CardTextLine(
      text: line.text,
      boundingBox: line.boundingBox,
      cornerPoints: line.cornerPoints,
      elements: domainElements,
      confidence: line.confidence,
      angle: line.angle,
    );
  }

  @override
  Future<void> dispose() async {
    for (final recognizer in _recognizers.values) {
      await recognizer.close();
    }
    _recognizers.clear();
  }
}
