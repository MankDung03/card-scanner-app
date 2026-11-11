import 'dart:math';
import 'dart:ui';

/// Model đại diện cho một phần tử ký tự/từ nhận diện được từ OCR
class OcrElement {
  final String text;
  final Rect boundingBox;
  final List<Point<int>> cornerPoints;

  const OcrElement({
    required this.text,
    required this.boundingBox,
    this.cornerPoints = const [],
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'boundingBox': {
      'left': boundingBox.left,
      'top': boundingBox.top,
      'width': boundingBox.width,
      'height': boundingBox.height,
    },
  };
}

/// Model đại diện cho một dòng văn bản OCR độc lập (không phụ thuộc ML Kit SDK)
class OcrLine {
  final String id;
  final String text;
  final String normalizedText;
  final Rect boundingBox;
  final List<Point<int>> cornerPoints;
  final List<OcrElement> elements;
  final double? confidence;
  final double? angle;
  final bool isVertical;
  final String sourceScript; // 'latin' | 'japanese' | 'merged'
  bool isConsumed;

  OcrLine({
    required this.id,
    required this.text,
    required this.normalizedText,
    required this.boundingBox,
    this.cornerPoints = const [],
    this.elements = const [],
    this.confidence,
    this.angle,
    bool? isVertical,
    this.sourceScript = 'latin',
    this.isConsumed = false,
  }) : isVertical = isVertical ?? (boundingBox.height > boundingBox.width * 1.4);

  OcrLine copyWith({
    String? id,
    String? text,
    String? normalizedText,
    Rect? boundingBox,
    List<Point<int>>? cornerPoints,
    List<OcrElement>? elements,
    double? confidence,
    double? angle,
    bool? isVertical,
    String? sourceScript,
    bool? isConsumed,
  }) {
    return OcrLine(
      id: id ?? this.id,
      text: text ?? this.text,
      normalizedText: normalizedText ?? this.normalizedText,
      boundingBox: boundingBox ?? this.boundingBox,
      cornerPoints: cornerPoints ?? this.cornerPoints,
      elements: elements ?? this.elements,
      confidence: confidence ?? this.confidence,
      angle: angle ?? this.angle,
      isVertical: isVertical ?? this.isVertical,
      sourceScript: sourceScript ?? this.sourceScript,
      isConsumed: isConsumed ?? this.isConsumed,
    );
  }
}

/// Model đại diện cho một khối văn bản OCR
class OcrBlock {
  final String id;
  final String text;
  final Rect boundingBox;
  final List<Point<int>> cornerPoints;
  final List<OcrLine> lines;
  final List<String> recognizedLanguages;

  const OcrBlock({
    required this.id,
    required this.text,
    required this.boundingBox,
    this.cornerPoints = const [],
    this.lines = const [],
    this.recognizedLanguages = const [],
  });
}
