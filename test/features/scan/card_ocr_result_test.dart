import 'dart:math';
import 'package:app_scanner_card/features/scan/domain/entities/card_ocr_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardOcrResult Domain Tests', () {
    test('Empty CardOcrResult check', () {
      const emptyResult = CardOcrResult(
        fullText: '',
        imageWidth: 0,
        imageHeight: 0,
        blocks: [],
      );

      expect(emptyResult.isEmpty, isTrue);
      expect(emptyResult.isNotEmpty, isFalse);
      expect(emptyResult.totalLines, equals(0));
      expect(emptyResult.totalElements, equals(0));
    });

    test('CardOcrResult with blocks, lines, and normalization', () {
      const sampleResult = CardOcrResult(
        fullText: '山田 太郎\n株式会社テスト\n東京都渋谷区1-2-3',
        imageWidth: 1000,
        imageHeight: 600,
        blocks: [
          CardTextBlock(
            text: '山田 太郎',
            boundingBox: Rect.fromLTWH(100, 50, 300, 80),
            cornerPoints: [
              Point(100, 50),
              Point(400, 50),
              Point(400, 130),
              Point(100, 130),
            ],
            lines: [
              CardTextLine(
                text: '山田 太郎',
                boundingBox: Rect.fromLTWH(100, 50, 300, 80),
                cornerPoints: [
                  Point(100, 50),
                  Point(400, 50),
                  Point(400, 130),
                  Point(100, 130),
                ],
                elements: [
                  CardTextElement(
                    text: '山田',
                    boundingBox: Rect.fromLTWH(100, 50, 140, 80),
                    cornerPoints: [
                      Point(100, 50),
                      Point(240, 50),
                      Point(240, 130),
                      Point(100, 130),
                    ],
                  ),
                  CardTextElement(
                    text: '太郎',
                    boundingBox: Rect.fromLTWH(260, 50, 140, 80),
                    cornerPoints: [
                      Point(260, 50),
                      Point(400, 50),
                      Point(400, 130),
                      Point(260, 130),
                    ],
                  ),
                ],
              ),
            ],
          ),
          CardTextBlock(
            text: '株式会社テスト\n東京都渋谷区1-2-3',
            boundingBox: Rect.fromLTWH(100, 200, 500, 120),
            cornerPoints: [],
            lines: [
              CardTextLine(
                text: '株式会社テスト',
                boundingBox: Rect.fromLTWH(100, 200, 400, 50),
                cornerPoints: [],
                elements: [],
              ),
              CardTextLine(
                text: '東京都渋谷区1-2-3',
                boundingBox: Rect.fromLTWH(100, 260, 500, 50),
                cornerPoints: [],
                elements: [],
              ),
            ],
          ),
        ],
      );

      expect(sampleResult.isNotEmpty, isTrue);
      expect(sampleResult.blocks.length, equals(2));
      expect(sampleResult.totalLines, equals(3));
      expect(sampleResult.totalElements, equals(2));
      expect(sampleResult.allLines.length, equals(3));
      expect(sampleResult.allElements.length, equals(2));

      // Test normalized rect
      const imgSize = Size(1000, 600);
      final block0Norm = sampleResult.blocks[0].normalizedRect(imgSize);
      expect(block0Norm.left, closeTo(0.1, 0.001));
      expect(block0Norm.top, closeTo(50 / 600, 0.001));
      expect(block0Norm.right, closeTo(0.4, 0.001));
      expect(block0Norm.bottom, closeTo(130 / 600, 0.001));

      // Test hitTestLine
      // Inside block 0 line: x=0.2 (200px), y=0.1 (60px)
      final hitLine = sampleResult.hitTestLine(const Offset(0.2, 0.1));
      expect(hitLine, isNotNull);
      expect(hitLine?.text, equals('山田 太郎'));

      // Outside any line
      final missLine = sampleResult.hitTestLine(const Offset(0.9, 0.9));
      expect(missLine, isNull);

      // Test hitTestBlock
      final hitBlock = sampleResult.hitTestBlock(const Offset(0.2, 0.1));
      expect(hitBlock, isNotNull);
      expect(hitBlock?.text, equals('山田 太郎'));

      // Test debug summary
      final summary = sampleResult.debugSummary();
      expect(summary, contains('1000x600 px'));
      expect(summary, contains('Total Blocks: 2'));
    });
  });
}
