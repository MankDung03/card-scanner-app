import 'dart:ui';
import 'package:app_scanner_card/features/scan/domain/entities/card_ocr_result.dart';
import 'package:app_scanner_card/features/scan/domain/services/ocr_line_reconstructor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OcrLineReconstructor Baseline Merging Tests', () {
    test('Merges elements with wide kerning on the same Y-baseline (田 中 and 宏 -> 田 中 宏)', () {
      const raw = CardOcrResult(
        fullText: '田 中\n宏',
        imageWidth: 800,
        imageHeight: 500,
        blocks: [
          // Block 1: "田 中" ở X=100, Y=200
          CardTextBlock(
            text: '田 中',
            boundingBox: Rect.fromLTWH(100, 200, 100, 40),
            lines: [
              CardTextLine(
                text: '田 中',
                boundingBox: Rect.fromLTWH(100, 200, 100, 40),
                elements: [
                  CardTextElement(
                    text: '田 中',
                    boundingBox: Rect.fromLTWH(100, 200, 100, 40),
                  ),
                ],
              ),
            ],
          ),
          // Block 2: "宏" ở X=280, Y=202 (cùng trục Y nhưng bị ML Kit tách thành khối khác do khoảng cách xa)
          CardTextBlock(
            text: '宏',
            boundingBox: Rect.fromLTWH(280, 202, 40, 38),
            lines: [
              CardTextLine(
                text: '宏',
                boundingBox: Rect.fromLTWH(280, 202, 40, 38),
                elements: [
                  CardTextElement(
                    text: '宏',
                    boundingBox: Rect.fromLTWH(280, 202, 40, 38),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final reconstructed = OcrLineReconstructor.reconstruct(raw);

      expect(reconstructed.blocks.length, 1);
      expect(reconstructed.fullText, '田 中 宏');
      expect(reconstructed.blocks.first.boundingBox.left, 100);
      expect(reconstructed.blocks.first.boundingBox.right, 320);
    });

    test('Merges fragmented brand words (TOKYO + ENGINEERING -> TOKYO ENGINEERING)', () {
      const raw = CardOcrResult(
        fullText: 'TOKYO\nENGINEERING',
        imageWidth: 800,
        imageHeight: 500,
        blocks: [
          CardTextBlock(
            text: 'TOKYO',
            boundingBox: Rect.fromLTWH(50, 60, 120, 36),
            lines: [
              CardTextLine(
                text: 'TOKYO',
                boundingBox: Rect.fromLTWH(50, 60, 120, 36),
                elements: [
                  CardTextElement(
                    text: 'TOKYO',
                    boundingBox: Rect.fromLTWH(50, 60, 120, 36),
                  ),
                ],
              ),
            ],
          ),
          CardTextBlock(
            text: 'ENGINEERING',
            boundingBox: Rect.fromLTWH(180, 62, 160, 32),
            lines: [
              CardTextLine(
                text: 'ENGINEERING',
                boundingBox: Rect.fromLTWH(180, 62, 160, 32),
                elements: [
                  CardTextElement(
                    text: 'ENGINEERING',
                    boundingBox: Rect.fromLTWH(180, 62, 160, 32),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final reconstructed = OcrLineReconstructor.reconstruct(raw);

      expect(reconstructed.fullText, 'TOKYO ENGINEERING');
    });

    test('Merges phone with prefix and parentheses (PHONE + (03) + 1055-8141 + (代))', () {
      const raw = CardOcrResult(
        fullText: 'PHONE\n(03)\n1055-8141\n(代)',
        imageWidth: 800,
        imageHeight: 500,
        blocks: [
          CardTextBlock(
            text: 'PHONE',
            boundingBox: Rect.fromLTWH(50, 300, 50, 20),
            lines: [
              CardTextLine(
                text: 'PHONE',
                boundingBox: Rect.fromLTWH(50, 300, 50, 20),
                elements: [
                  CardTextElement(
                    text: 'PHONE',
                    boundingBox: Rect.fromLTWH(50, 300, 50, 20),
                  ),
                ],
              ),
            ],
          ),
          CardTextBlock(
            text: '(03)',
            boundingBox: Rect.fromLTWH(105, 300, 30, 20),
            lines: [
              CardTextLine(
                text: '(03)',
                boundingBox: Rect.fromLTWH(105, 300, 30, 20),
                elements: [
                  CardTextElement(
                    text: '(03)',
                    boundingBox: Rect.fromLTWH(105, 300, 30, 20),
                  ),
                ],
              ),
            ],
          ),
          CardTextBlock(
            text: '1055-8141',
            boundingBox: Rect.fromLTWH(140, 300, 90, 20),
            lines: [
              CardTextLine(
                text: '1055-8141',
                boundingBox: Rect.fromLTWH(140, 300, 90, 20),
                elements: [
                  CardTextElement(
                    text: '1055-8141',
                    boundingBox: Rect.fromLTWH(140, 300, 90, 20),
                  ),
                ],
              ),
            ],
          ),
          CardTextBlock(
            text: '(代)',
            boundingBox: Rect.fromLTWH(235, 300, 30, 20),
            lines: [
              CardTextLine(
                text: '(代)',
                boundingBox: Rect.fromLTWH(235, 300, 30, 20),
                elements: [
                  CardTextElement(
                    text: '(代)',
                    boundingBox: Rect.fromLTWH(235, 300, 30, 20),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final reconstructed = OcrLineReconstructor.reconstruct(raw);

      expect(reconstructed.fullText.contains('PHONE (03) 1055-8141 (代)'), isTrue);
    });
  });
}
