import 'dart:io';
import 'package:app_scanner_card/features/scan/domain/entities/card_ocr_result.dart';
import 'package:app_scanner_card/features/scan/domain/repositories/ocr_repository.dart';
import 'package:app_scanner_card/features/scan/presentation/cubit/scan_cubit.dart';
import 'package:app_scanner_card/features/scan/presentation/cubit/scan_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class MockOcrRepository implements OcrRepository {
  bool disposed = false;
  CardOcrResult? mockResult;
  String? lastRecognizedPath;

  @override
  Future<CardOcrResult> recognizeText(
    String imagePath, {
    TextRecognitionScript script = TextRecognitionScript.japanese,
  }) async {
    lastRecognizedPath = imagePath;
    return mockResult ??
        const CardOcrResult(
          fullText: '山田 太郎\nテスト株式会社',
          imageWidth: 800,
          imageHeight: 500,
          blocks: [],
        );
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScanCubit OCR Tests', () {
    test('processOcr without image returns null and sets error', () async {
      final mockRepo = MockOcrRepository();
      final cubit = ScanCubit(ocrRepository: mockRepo);

      final result = await cubit.processOcr();

      expect(result, isNull);
      expect(cubit.state.ocrErrorMessage, isNotNull);
      expect(cubit.state.isOcrLoading, isFalse);

      await cubit.close();
      expect(mockRepo.disposed, isTrue);
    });

    test('setSide changes currentSide and reset restores state', () async {
      final mockRepo = MockOcrRepository();
      final cubit = ScanCubit(ocrRepository: mockRepo);

      cubit.setSide(CardSide.back);
      expect(cubit.state.currentSide, equals(CardSide.back));

      cubit.reset();
      expect(cubit.state.currentSide, equals(CardSide.front));
      expect(cubit.state.frontImagePath, isNull);

      await cubit.close();
    });

    test('processOcr crops image according to cornerPoints before recognition', () async {
      final mockRepo = MockOcrRepository();
      final cubit = ScanCubit(ocrRepository: mockRepo);

      // Tạo một ảnh test 200x100
      final tempDir = Directory.systemTemp.createTempSync('scan_test_');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          return tempDir.path;
        },
      );

      final testFile = File('${tempDir.path}/test_card.jpg');
      final dummyImage = img.Image(width: 200, height: 100);
      img.fill(dummyImage, color: img.ColorRgb8(255, 255, 255));
      await testFile.writeAsBytes(img.encodeJpg(dummyImage));

      cubit.setImageForTesting(testFile.path);

      // Cập nhật 4 điểm thu nhỏ về 50% vùng trung tâm (x: 50 -> 150, y: 25 -> 75)
      cubit.updateCorner(0, const Offset(0.25, 0.25)); // TL
      cubit.updateCorner(1, const Offset(0.75, 0.25)); // TR
      cubit.updateCorner(2, const Offset(0.75, 0.75)); // BR
      cubit.updateCorner(3, const Offset(0.25, 0.75)); // BL

      final result = await cubit.processOcr();

      expect(result, isNotNull);
      expect(cubit.state.lastProcessedImagePath, isNotNull);
      expect(mockRepo.lastRecognizedPath, equals(cubit.state.lastProcessedImagePath));
      expect(File(cubit.state.lastProcessedImagePath!).existsSync(), isTrue);

      // Xác minh kích thước ảnh đã cắt chính xác theo tỉ lệ:
      // Chiều rộng = 200 * (0.75 - 0.25) = 100 px
      // Chiều cao = 100 * (0.75 - 0.25) = 50 px
      final croppedBytes = await File(cubit.state.lastProcessedImagePath!).readAsBytes();
      final croppedImg = img.decodeImage(croppedBytes);
      expect(croppedImg, isNotNull);
      expect(croppedImg!.width, equals(100));
      expect(croppedImg.height, equals(50));

      await cubit.close();
      tempDir.deleteSync(recursive: true);
    });
  });
}
