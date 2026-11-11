import '../entities/business_card_info.dart';
import '../entities/business_card_result.dart';
import '../entities/card_ocr_result.dart';
import '../entities/ocr_model.dart';
import 'heuristic_field_scorer.dart';
import 'regex_field_extractor.dart';
import 'text_normalizer.dart';

/// Orchestrator chịu trách nhiệm bóc tách dữ liệu danh thiếp từ kết quả OCR thô
class BusinessCardParser {
  /// Bóc tách trả về BusinessCardInfo (dùng trực tiếp cho Cubit và UI hiện tại)
  static BusinessCardInfo parse(CardOcrResult ocrResult) {
    final result = parseToResult(ocrResult);
    return BusinessCardInfo.fromResult(result);
  }

  /// Bóc tách trả về BusinessCardResult chi tiết (hỗ trợ đầy đủ confidence, line IDs, alternatives, unmapped lines)
  static BusinessCardResult parseToResult(CardOcrResult ocrResult) {
    if (ocrResult.isEmpty) {
      return const BusinessCardResult();
    }

    // 1. Chuyển đổi và chuẩn hóa tất cả các dòng sang OcrLine trung gian
    final allLines = <OcrLine>[];
    int lineCounter = 0;

    for (int bIdx = 0; bIdx < ocrResult.blocks.length; bIdx++) {
      final block = ocrResult.blocks[bIdx];
      for (int lIdx = 0; lIdx < block.lines.length; lIdx++) {
        final line = block.lines[lIdx];
        final rawText = line.text.trim();
        if (rawText.isEmpty) continue;

        final normalized = TextNormalizer.normalize(rawText);

        final elements = line.elements.map((e) {
          return OcrElement(
            text: e.text,
            boundingBox: e.boundingBox,
            cornerPoints: e.cornerPoints,
          );
        }).toList();

        allLines.add(
          OcrLine(
            id: 'b${bIdx}_l${lIdx}_$lineCounter',
            text: rawText,
            normalizedText: normalized,
            boundingBox: line.boundingBox,
            cornerPoints: line.cornerPoints,
            elements: elements,
            confidence: line.confidence,
            angle: line.angle,
            sourceScript: 'merged',
          ),
        );
        lineCounter++;
      }
    }

    if (allLines.isEmpty) {
      return const BusinessCardResult();
    }

    // 2. Chạy bước 1: Regex Extraction (Email -> Zipcode -> Phones -> Website)
    final regexResult = RegexFieldExtractor.extract(allLines);

    // 3. Chạy bước 2: Heuristic Field Scoring (Company, Title, Department, Address, Name, Furigana)
    final heuristicResult = HeuristicFieldScorer.scoreAndAssign(
      allLines: allLines,
      cardWidth: ocrResult.imageWidth.toDouble(),
      cardHeight: ocrResult.imageHeight.toDouble(),
    );

    // 4. Đóng gói thành BusinessCardResult
    final result = BusinessCardResult(
      name: heuristicResult['name'] as FieldValue?,
      furigana: heuristicResult['furigana'] as FieldValue?,
      title: heuristicResult['title'] as FieldValue?,
      company: heuristicResult['company'] as FieldValue?,
      department: heuristicResult['department'] as FieldValue?,
      phones: regexResult.phones,
      emails: regexResult.emails,
      website: regexResult.website,
      zipcode: regexResult.zipcode,
      address: heuristicResult['address'] as FieldValue?,
      unmappedLines: heuristicResult['unmappedLines'] as List<OcrLine>,
      allLines: allLines,
    );

    return result;
  }
}
