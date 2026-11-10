import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import '../../domain/entities/card_ocr_result.dart';
import '../../domain/repositories/ocr_repository.dart';

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
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Tệp ảnh không tồn tại: $imagePath');
    }

    // 1. Xác định kích thước ảnh thực tế (px)
    int imgW = 0;
    int imgH = 0;
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        imgW = decoded.width;
        imgH = decoded.height;
      }
    } catch (e) {
      debugPrint('Warning reading image dimensions: $e');
    }

    // 2. Chạy Google ML Kit Text Recognition On-Device
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizer = _getRecognizer(script);
    final RecognizedText recognizedText = await recognizer.processImage(inputImage);

    // 3. Map sang Domain Entity CardOcrResult
    final domainBlocks = <CardTextBlock>[];

    for (final block in recognizedText.blocks) {
      final domainLines = <CardTextLine>[];

      for (final line in block.lines) {
        final domainElements = <CardTextElement>[];

        for (final element in line.elements) {
          domainElements.add(
            CardTextElement(
              text: element.text,
              boundingBox: element.boundingBox,
              cornerPoints: element.cornerPoints,
            ),
          );
        }

        domainLines.add(
          CardTextLine(
            text: line.text,
            boundingBox: line.boundingBox,
            cornerPoints: line.cornerPoints,
            elements: domainElements,
            confidence: line.confidence,
            angle: line.angle,
          ),
        );
      }

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
      fullText: recognizedText.text,
      imageWidth: imgW,
      imageHeight: imgH,
      blocks: domainBlocks,
    );

    debugPrint(result.debugSummary());
    return result;
  }

  @override
  Future<void> dispose() async {
    for (final recognizer in _recognizers.values) {
      await recognizer.close();
    }
    _recognizers.clear();
  }
}
