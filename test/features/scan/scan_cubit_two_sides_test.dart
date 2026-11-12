import 'dart:io';

import 'package:app_scanner_card/features/scan/domain/entities/card_ocr_result.dart';
import 'package:app_scanner_card/features/scan/domain/repositories/ocr_repository.dart';
import 'package:app_scanner_card/features/scan/presentation/cubit/scan_cubit.dart';
import 'package:app_scanner_card/features/scan/presentation/cubit/scan_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

CardOcrResult _ocr(List<String> lines) {
  final textLines = [
    for (var i = 0; i < lines.length; i++)
      CardTextLine(
        text: lines[i],
        boundingBox: Rect.fromLTWH(40, 40.0 + i * 40, 320, 18),
        cornerPoints: const [],
        elements: const [],
      ),
  ];
  return CardOcrResult(
    fullText: lines.join('\n'),
    imageWidth: 600,
    imageHeight: 360,
    blocks: [
      CardTextBlock(
        text: lines.join('\n'),
        boundingBox: const Rect.fromLTWH(40, 40, 320, 280),
        cornerPoints: const [],
        lines: textLines,
      ),
    ],
  );
}

/// Trả kết quả theo thứ tự gọi; `failOnCall` = lần gọi (0-based) sẽ ném lỗi.
class _SequencedOcrRepository implements OcrRepository {
  final List<CardOcrResult> results;
  final int? failOnCall;
  final List<String> recognizedPaths = [];

  _SequencedOcrRepository(this.results, {this.failOnCall});

  @override
  Future<CardOcrResult> recognizeText(
    String imagePath, {
    TextRecognitionScript script = TextRecognitionScript.japanese,
    bool useDualScript = true,
    OcrLanguageMode languageMode = OcrLanguageMode.auto,
  }) async {
    final call = recognizedPaths.length;
    recognizedPaths.add(imagePath);
    if (call == failOnCall) throw Exception('mock OCR failure');
    return results[call % results.length];
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String frontPath;
  late String backPath;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('scan_two_sides_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => tempDir.path,
    );
    final image = img.Image(width: 400, height: 200);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    frontPath = '${tempDir.path}/front.jpg';
    backPath = '${tempDir.path}/back.jpg';
    await File(frontPath).writeAsBytes(img.encodeJpg(image));
    await File(backPath).writeAsBytes(img.encodeJpg(image));
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  /// Mô phỏng luồng thật: ảnh mặt trước → chỉnh góc → "Thêm mặt sau" → ảnh mặt sau.
  void loadTwoSides(ScanCubit cubit, {List<Offset>? frontCorners}) {
    cubit.setImageForTesting(frontPath);
    if (frontCorners != null) {
      for (var i = 0; i < 4; i++) {
        cubit.updateCorner(i, frontCorners[i]);
      }
    }
    cubit.setSide(CardSide.back);
    cubit.emit(cubit.state.copyWith(backImagePath: backPath, currentImagePath: backPath));
  }

  test('OCRs both sides in order and merges fields from both', () async {
    final repo = _SequencedOcrRepository([
      _ocr(['taro.yamada@sample-shoji.example']),
      _ocr(['taro@other.example', 'https://www.sample-shoji.co.jp']),
    ]);
    final cubit = ScanCubit(ocrRepository: repo);
    loadTwoSides(cubit);

    final result = await cubit.processOcr();

    expect(result, isNotNull);
    expect(repo.recognizedPaths, hasLength(2));
    expect(repo.recognizedPaths.first, cubit.state.frontProcessedImagePath);
    expect(repo.recognizedPaths.last, cubit.state.backProcessedImagePath);
    expect(cubit.state.frontOcrResult, isNotNull);
    expect(cubit.state.backOcrResult, isNotNull);
    expect(cubit.state.ocrFailedSides, isEmpty);
    expect(cubit.state.isOcrLoading, isFalse);
    expect(cubit.state.ocrSideInProgress, isNull);

    final info = cubit.state.currentCardInfo!;
    expect(info.email, 'taro.yamada@sample-shoji.example', reason: 'mặt trước được ưu tiên');
    expect(info.alternatives['email'], contains('taro@other.example'));
    expect(info.website, contains('sample-shoji.co.jp'), reason: 'chỉ mặt sau có website');

    await cubit.close();
  });

  test('each side is cropped with its own corners', () async {
    final repo = _SequencedOcrRepository([_ocr(['a@b.jp'])]);
    final cubit = ScanCubit(ocrRepository: repo);
    // Mặt trước chỉ lấy 50% giữa ảnh, mặt sau dùng khung mặc định (gần toàn ảnh)
    loadTwoSides(cubit, frontCorners: const [
      Offset(0.25, 0.25),
      Offset(0.75, 0.25),
      Offset(0.75, 0.75),
      Offset(0.25, 0.75),
    ]);
    expect(cubit.state.cornerPoints, kDefaultCropCorners, reason: 'mặt sau bắt đầu với khung mặc định');

    await cubit.processOcr();

    // Tiền xử lý resize về cùng cạnh dài nên so tỉ lệ khung:
    // trước = 200×100 + lề → ~1.77, sau = 360×168 + lề → ~1.97
    double ratioOf(String path) {
      final i = img.decodeImage(File(path).readAsBytesSync())!;
      return i.width / i.height;
    }

    final frontRatio = ratioOf(cubit.state.frontProcessedImagePath!);
    final backRatio = ratioOf(cubit.state.backProcessedImagePath!);
    expect(frontRatio, closeTo(230 / 130, 0.05));
    expect(backRatio, closeTo(390 / 198, 0.05));

    // Quay lại mặt trước → khôi phục 4 góc đã chỉnh
    cubit.setSide(CardSide.front);
    expect(cubit.state.cornerPoints.first, const Offset(0.25, 0.25));
    expect(cubit.state.currentImagePath, frontPath);

    await cubit.close();
  });

  test('back side failure keeps front result and reports failed side', () async {
    final repo = _SequencedOcrRepository([_ocr(['taro.yamada@sample-shoji.example'])], failOnCall: 1);
    final cubit = ScanCubit(ocrRepository: repo);
    loadTwoSides(cubit);

    final result = await cubit.processOcr();

    expect(result, isNotNull);
    expect(cubit.state.ocrFailedSides, [CardSide.back]);
    expect(cubit.state.backOcrResult, isNull);
    expect(cubit.state.currentCardInfo!.email, 'taro.yamada@sample-shoji.example');
    expect(cubit.state.ocrErrorMessage, isNull);

    await cubit.close();
  });

  test('all sides failing returns null with error', () async {
    final repo = _SequencedOcrRepository([_ocr(['x'])], failOnCall: 0);
    final cubit = ScanCubit(ocrRepository: repo);
    cubit.setImageForTesting(frontPath);

    expect(await cubit.processOcr(), isNull);
    expect(cubit.state.ocrErrorMessage, isNotNull);
    expect(cubit.state.ocrFailedSides, [CardSide.front]);

    await cubit.close();
  });

  test('startNewScan clears leftover images', () async {
    final cubit = ScanCubit(ocrRepository: _SequencedOcrRepository([_ocr(['x'])]));
    loadTwoSides(cubit);
    expect(cubit.state.hasBothSides, isTrue);

    cubit.startNewScan();

    expect(cubit.state.frontImagePath, isNull);
    expect(cubit.state.backImagePath, isNull);
    expect(cubit.state.currentSide, CardSide.front);
    expect(cubit.state.backCrop, isNull);

    await cubit.close();
  });
}
